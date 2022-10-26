import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hmssdk_flutter/hmssdk_flutter.dart';
import 'package:video_call_flutter_poc/dependencies/dependencies.dart';

class MessageDrawer extends ConsumerStatefulWidget {
  const MessageDrawer({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _MessageDrawerState();
}

class _MessageDrawerState extends ConsumerState<MessageDrawer> {
  late double width;
  TextEditingController messageTextController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    width = MediaQuery.of(context).size.width;
    List<HMSMessage> messages = ref.watch(videoRoomProvider).messages;
    final localPeer = ref
        .watch(videoRoomProvider)
        .peerTrackNodes
        .firstWhere((element) => element.peer!.isLocal);
    return Drawer(
      child: SafeArea(
          bottom: true,
          minimum:
              EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(10.0),
                  color: Colors.amber,
                  child: Row(
                    children: [
                      const Expanded(
                        child: Text(
                          "Message",
                          style: TextStyle(color: Colors.black, fontSize: 20.0),
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.of(context).pop();
                        },
                        child: const Icon(
                          Icons.clear,
                          size: 25.0,
                        ),
                      )
                    ],
                  ),
                ),
                Expanded(
                  child: messages.isEmpty
                      ? const Center(child: Text('No messages'))
                      : ListView.separated(
                          itemCount: messages.length,
                          itemBuilder: (itemBuilder, index) {
                            return Container(
                              padding: const EdgeInsets.all(5.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          messages[index].sender?.name ?? '',
                                          style: const TextStyle(
                                              fontSize: 10.0,
                                              color: Colors.black,
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                      Text(
                                        messages[index].time.toString(),
                                        style: const TextStyle(
                                            fontSize: 10.0,
                                            color: Colors.black,
                                            fontWeight: FontWeight.w900),
                                      )
                                    ],
                                  ),
                                  const SizedBox(
                                    height: 10.0,
                                  ),
                                  Text(
                                    messages[index].message.toString(),
                                    style: const TextStyle(
                                        fontSize: 14.0,
                                        color: Colors.black,
                                        fontWeight: FontWeight.w300),
                                  ),
                                ],
                              ),
                            );
                          },
                          separatorBuilder: (BuildContext context, int index) {
                            return const Divider();
                          },
                        ),
                ),
                Container(
                  color: Colors.amberAccent,
                  margin: const EdgeInsets.only(top: 10.0),
                  child: Row(
                    children: [
                      Container(
                        margin: const EdgeInsets.only(bottom: 5.0, left: 5.0),
                        width: 230,
                        child: TextField(
                          autofocus: true,
                          controller: messageTextController,
                          decoration: const InputDecoration(
                            focusedBorder: InputBorder.none,
                            contentPadding: EdgeInsets.only(
                              left: 15,
                              bottom: 11,
                              top: 11,
                              right: 15,
                            ),
                            hintText: "Input a Message",
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          if (messageTextController.text.trim().isNotEmpty) {
                            ref
                                .read(videoRoomProvider.notifier)
                                .sendMessage(messageTextController.text);
                            // SdkInitializer.hmssdk.sendBroadcastMessage(
                            //     message: messageTextController.text);
                            // setState(() {
                            //   messages.add(Message(
                            //       message: messageTextController.text.trim(),
                            //       time: DateTime.now().toString(),
                            //       peerId: "localUser",
                            //       senderName: localPeer.name));
                            // });
                            messageTextController.text = "";
                          }
                        },
                        child: const Icon(
                          Icons.send,
                          size: 40.0,
                        ),
                      )
                    ],
                  ),
                )
              ],
            ),
          )),
    );
  }
}
