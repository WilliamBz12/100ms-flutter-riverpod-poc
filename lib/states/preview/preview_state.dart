part of 'preview_state_notifier.dart';

class PreviewState extends Equatable {
  const PreviewState({
    this.isMicOff = true,
    this.isVideoOff = true,
    this.tracks = const <HMSVideoTrack>[],
    this.error,
  });

  final bool isMicOff;
  final bool isVideoOff;
  final List<HMSVideoTrack> tracks;
  final String? error;

  PreviewState copyWith({
    bool? isMicOff,
    bool? isVideoOff,
    List<HMSVideoTrack>? tracks,
    String? error,
  }) {
    return PreviewState(
      isMicOff: isMicOff ?? this.isMicOff,
      isVideoOff: isVideoOff ?? this.isVideoOff,
      tracks: tracks ?? this.tracks,
      error: error ?? this.error,
    );
  }

  @override
  String toString() {
    return '''PreviewState { isMicOff: $isMicOff, isVideoOff: $isVideoOff}''';
  }

  @override
  List<Object> get props => [isMicOff, isVideoOff, tracks];
}
