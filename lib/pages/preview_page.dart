// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hmssdk_flutter/hmssdk_flutter.dart';
import 'package:video_call_flutter_poc/args/room_args.dart';
import 'package:video_call_flutter_poc/dependencies/dependencies.dart';

class PreviewPage extends ConsumerStatefulWidget {
  final String meetingUrl;
  final String userName;

  const PreviewPage({
    this.meetingUrl =
        'https://alineadevtest.app.100ms.live/meeting/iho-blv-nuj',
    this.userName = 'Bezerrra',
    super.key,
  });

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _PreviewPageState();
}

class _PreviewPageState extends ConsumerState<PreviewPage> {
  @override
  void initState() {
    super.initState();
    ref.read(previewStateProvider.notifier).joinPreview(
          name: 'Bezerra',
          url: 'https://alineadevtest.app.100ms.live/meeting/iho-blv-nuj',
        );
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        ref.read(previewStateProvider.notifier).close();
        return true;
      },
      child: Scaffold(
        body: _buildContent(),
      ),
    );
  }

  Widget _buildContent() {
    final previewState = ref.watch(previewStateProvider);
    var size = MediaQuery.of(context).size;
    final double itemHeight = size.height;
    final double itemWidth = size.width;
    if (previewState.error != null) {
      return Center(
        child: Text(previewState.error!),
      );
    }
    return previewState.tracks.isEmpty
        ? SizedBox(
            height: itemHeight / 1.3,
            child: const Center(
              child: CircularProgressIndicator(),
            ),
          )
        : SizedBox(
            height: itemHeight,
            width: itemWidth,
            child: Stack(
              children: [
                HMSVideoView(track: previewState.tracks[0], matchParent: true),
                Positioned(
                  bottom: 20.0,
                  left: itemWidth / 2 - 50.0,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        padding: const EdgeInsets.all(14)),
                    onPressed: () {
                      Navigator.popAndPushNamed(
                        context,
                        '/meeting',
                        arguments: const RoomArgs(
                          name: 'Bezerra',
                          room:
                              'https://alineadevtest.app.100ms.live/meeting/iho-blv-nuj',
                        ),
                      );
                    },
                    child: const Text(
                      "Join Now",
                      style: TextStyle(height: 1, fontSize: 18),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 20.0,
                  right: 50.0,
                  child: IconButton(
                    onPressed: () {
                      ref.read(previewStateProvider.notifier).toggleAudio();
                    },
                    icon: Icon(
                      previewState.isMicOff ? Icons.mic_off : Icons.mic,
                      size: 30.0,
                      color: Colors.blue,
                    ),
                  ),
                ),
                Positioned(
                  bottom: 20.0,
                  left: 50.0,
                  child: IconButton(
                    onPressed: () {
                      ref.read(previewStateProvider.notifier).toggleVideo();
                    },
                    icon: Icon(
                      previewState.isVideoOff
                          ? Icons.videocam_off
                          : Icons.videocam,
                      size: 30.0,
                      color: Colors.blueAccent,
                    ),
                  ),
                ),
              ],
            ),
          );
  }
}
