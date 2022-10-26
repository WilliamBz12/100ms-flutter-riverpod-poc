import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hmssdk_flutter/hmssdk_flutter.dart';
import 'package:video_call_flutter_poc/args/room_args.dart';
import 'package:video_call_flutter_poc/dependencies/dependencies.dart';
import 'package:video_call_flutter_poc/states/room/peer_track_node.dart';
import 'package:video_call_flutter_poc/states/video_room/video_room_state.dart';
import 'package:video_call_flutter_poc/widgets/message_screen.dart';

class VideoRoomPage extends ConsumerStatefulWidget {
  const VideoRoomPage({
    super.key,
    required this.args,
  });
  final RoomArgs args;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _VideoRoomPageState();
}

class _VideoRoomPageState extends ConsumerState<VideoRoomPage> {
  Offset position = const Offset(10, 10);

  @override
  void initState() {
    super.initState();
    Future.microtask(
      () {
        ref
            .read(videoRoomProvider.notifier)
            .joinRoom(widget.args.name, widget.args.room);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(
      videoRoomProvider,
      (previous, next) {
        if (next.leaveMeeting) {
          Navigator.of(context).popUntil((route) => route.isFirst);
        }
      },
    );
    return WillPopScope(
      onWillPop: () async {
        await ref.read(videoRoomProvider.notifier).leaveRequested();
        return true;
      },
      child: Scaffold(
        appBar: AppBar(),
        bottomNavigationBar: _buildBottom(),
        drawer: const MessageDrawer(),
        body: _buildContent(),
      ),
    );
  }

  Widget _buildContent() {
    final state = ref.watch(videoRoomProvider);

    final remoteTrack = state.remoteTrack;

    final localVideoTrack = state.localTrack;

    if (state.status == VideoRoomStatus.loading) {
      return const Center(child: CircularProgressIndicator());
    }
    return Stack(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 5.0),
          child: Center(
            child: SizedBox(
              height: MediaQuery.of(context).size.height,
              width: MediaQuery.of(context).size.width,
              child: Column(
                children: [
                  Flexible(
                    child: dectorPeerVideo(remoteTrack),
                  ),
                ],
              ),
            ),
          ),
        ),
        Positioned(
          left: position.dx,
          top: position.dy,
          child: Draggable<bool>(
            data: true,
            childWhenDragging: Container(),
            onDragEnd: (details) => {
              setState(() => position = details.offset),
            },
            feedback: Container(
              height: 200,
              width: 150,
              color: Colors.black,
              child: const Icon(
                Icons.videocam_off_rounded,
                color: Colors.white,
              ),
            ),
            child: localPeerVideo(localVideoTrack),
          ),
        ),
      ],
    );
  }

  Widget dectorPeerVideo(PeerTrackNode? remoteTrack) {
    return Container(
      child: (remoteTrack?.hmsVideoTrack != null &&
              remoteTrack?.hmsVideoTrack is HMSVideoTrack)
          ? HMSVideoView(
              track: remoteTrack!.hmsVideoTrack! as HMSVideoTrack,
            )
          : const Center(
              child: Text(
                'Waiting for the Doctor to join!',
              ),
            ),
    );
  }

  Widget localPeerVideo(PeerTrackNode? localTrack) {
    return Container(
      height: 200,
      width: 150,
      color: Colors.black,
      child: (localTrack?.hmsVideoTrack != null &&
              localTrack?.hmsVideoTrack is HMSVideoTrack)
          ? HMSVideoView(
              track: localTrack!.hmsVideoTrack! as HMSVideoTrack,
            )
          : const Icon(
              Icons.videocam_off_rounded,
              color: Colors.white,
            ),
    );
  }

  Widget _buildBottom() {
    final state = ref.watch(videoRoomProvider);

    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      backgroundColor: Colors.black,
      selectedItemColor: Colors.grey,
      unselectedItemColor: Colors.grey,
      items: <BottomNavigationBarItem>[
        BottomNavigationBarItem(
          icon: Icon(state.isAudioMute ? Icons.mic_off : Icons.mic),
          label: 'Mic',
        ),
        BottomNavigationBarItem(
          icon: Icon(state.isVideoMute ? Icons.videocam_off : Icons.videocam),
          label: 'Camera',
        ),
        const BottomNavigationBarItem(
          icon: Icon(Icons.cancel),
          label: 'Leave Meeting',
        ),
      ],

      //New
      onTap: (index) => _onItemTapped(index, context),
    );
  }

  void _onItemTapped(int index, BuildContext context) {
    switch (index) {
      case 0:
        ref.read(videoRoomProvider.notifier).onLocalAudioToggled();
        break;
      case 1:
        ref.read(videoRoomProvider.notifier).onLocalVideoToggled();
        break;
      case 2:
        ref.read(videoRoomProvider.notifier).leaveRequested();
    }
  }
}
