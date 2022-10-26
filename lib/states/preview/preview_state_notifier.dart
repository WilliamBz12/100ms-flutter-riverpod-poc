import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hmssdk_flutter/hmssdk_flutter.dart';
import 'package:video_call_flutter_poc/observers/preview_observer.dart';
import 'package:video_call_flutter_poc/services/room_service.dart';

part 'preview_state.dart';

class PreviewStateNotifier extends StateNotifier<PreviewState> {
  PreviewStateNotifier({
    required this.roomService,
  }) : super(const PreviewState()) {
    observer = PreviewObserver(previewStateNotifier: this);
  }
  final hmsSdk = HMSSDK();
  final RoomService roomService;
  late PreviewObserver observer;

  void joinPreview({
    required String name,
    required String url,
  }) async {
    hmsSdk.addPreviewListener(listener: observer);
    hmsSdk.build();
    final token = await roomService.generateToken(
      user: name,
      room: url,
    );
    HMSConfig config = HMSConfig(
      authToken: token,
      userName: name,
    );
    await hmsSdk.preview(config: config);
  }

  void toggleVideo() {
    hmsSdk.switchVideo(isOn: !state.isVideoOff);

    state = state.copyWith(isVideoOff: !state.isVideoOff);
  }

  void toggleAudio() {
    hmsSdk.switchAudio(isOn: !state.isMicOff);
    state = state.copyWith(isMicOff: !state.isMicOff);
  }

  void updateTracks(List<HMSVideoTrack> localTracks) {
    state = state.copyWith(tracks: localTracks);
  }

  void setError(String? message) {
    state = state.copyWith(error: message);
  }

  void close() {
    hmsSdk.removePreviewListener(listener: observer);
    hmsSdk.removeHMSLogger();
  }
}
