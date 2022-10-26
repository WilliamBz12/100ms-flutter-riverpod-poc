import 'package:flutter/foundation.dart';
import 'package:hmssdk_flutter/hmssdk_flutter.dart';
import 'package:video_call_flutter_poc/states/preview/preview_state_notifier.dart';

class PreviewObserver implements HMSPreviewListener {
  final PreviewStateNotifier previewStateNotifier;

  List<HMSVideoTrack> localTracks = <HMSVideoTrack>[];

  PreviewObserver({
    required this.previewStateNotifier,
  });

  @override
  void onAudioDeviceChanged({
    HMSAudioDevice? currentAudioDevice,
    List<HMSAudioDevice>? availableAudioDevice,
  }) {}

  @override
  void onHMSError({required HMSException error}) {
    if (kDebugMode) {
      print("OnError ${error.message}");
    }
    previewStateNotifier.setError(error.message);
  }

  @override
  void onPeerUpdate({
    required HMSPeer peer,
    required HMSPeerUpdate update,
  }) {}

  @override
  void onPreview({
    required HMSRoom room,
    required List<HMSTrack> localTracks,
  }) {
    List<HMSVideoTrack> videoTracks = [];
    for (var track in localTracks) {
      if (track.kind == HMSTrackKind.kHMSTrackKindVideo) {
        videoTracks.add(track as HMSVideoTrack);
      }
    }
    this.localTracks.clear();
    this.localTracks.addAll(videoTracks);
    previewStateNotifier.updateTracks(this.localTracks);
  }

  @override
  void onRoomUpdate({
    required HMSRoom room,
    required HMSRoomUpdate update,
  }) {
    //TODO: Podemos implementar para entrar automaticamente na sala quando o médico entrar
  }
}
