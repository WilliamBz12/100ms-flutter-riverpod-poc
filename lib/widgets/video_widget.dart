import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:focus_detector/focus_detector.dart';
import 'package:video_call_flutter_poc/dependencies/dependencies.dart';

class VideoWidget extends ConsumerStatefulWidget {
  final int index;

  const VideoWidget(this.index, {Key? key}) : super(key: key);

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _VideoWidgetState();
}

class _VideoWidgetState extends ConsumerState<VideoWidget> {
  @override
  Widget build(BuildContext context) {
    final state = ref.watch(videoRoomProvider);
    return FocusDetector(
      onFocusGained: () {
        if (state.leaveMeeting && !mounted) {
          return;
        }

        ref.read(videoRoomProvider.notifier).setOffScreen(
              widget.index,
              false,
            );
      },
      onFocusLost: () {
        if (state.leaveMeeting && !mounted) {
          return;
        }
        ref.read(videoRoomProvider.notifier).setOffScreen(
              widget.index,
              true,
            );
      },
      child: (state.peerTrackNodes[widget.index].peer!.isLocal
                  ? !state.isVideoMute
                  : !state.peerTrackNodes[widget.index].isMute!) &&
              !(state.peerTrackNodes[widget.index].isOffScreen)
          ? ClipRRect(
              borderRadius: const BorderRadius.all(Radius.circular(10)),
              child: Column(
                children: [
                  // SizedBox(
                  //   height: 200.0,
                  //   width: 400.0,
                  //   child: VideoView(
                  //       state.peerTrackNodes[widget.index].hmsVideoTrack!),
                  // ),
                  Text(
                    state.peerTrackNodes[widget.index].peer!.name,
                  )
                ],
              ),
            )
          : Container(
              height: 200.0,
              width: 400.0,
              alignment: Alignment.center,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircleAvatar(
                    backgroundColor: Colors.green,
                    radius: 36,
                    child: Text(
                      state.peerTrackNodes[widget.index].peer!.name[0],
                      style: const TextStyle(fontSize: 36, color: Colors.white),
                    ),
                  ),
                  const SizedBox(
                    height: 20.0,
                  ),
                  Text(
                    state.peerTrackNodes[widget.index].peer!.name,
                  )
                ],
              ),
            ),
    );
  }
}
