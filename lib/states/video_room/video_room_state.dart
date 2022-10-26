// ignore_for_file: depend_on_referenced_packages

import 'package:equatable/equatable.dart';
import 'package:hmssdk_flutter/hmssdk_flutter.dart';
import 'package:collection/collection.dart';
import '../room/peer_track_node.dart';

enum VideoRoomStatus { initial, loading, success, failure }

class VideoRoomState extends Equatable {
  final VideoRoomStatus status;
  final List<PeerTrackNode> peerTrackNodes;
  final bool isVideoMute;
  final bool isAudioMute;
  final bool leaveMeeting;
  final List<HMSMessage> messages;
  const VideoRoomState({
    this.status = VideoRoomStatus.initial,
    this.peerTrackNodes = const [],
    this.isVideoMute = false,
    this.isAudioMute = false,
    this.leaveMeeting = false,
    this.messages = const <HMSMessage>[],
  });

  PeerTrackNode? get localTrack =>
      peerTrackNodes.firstWhereOrNull((item) => item.peer?.isLocal ?? false);

  PeerTrackNode? get remoteTrack =>
      peerTrackNodes.firstWhereOrNull((item) => !(item.peer?.isLocal ?? true));

  @override
  List<Object?> get props => [
        status,
        peerTrackNodes,
        isAudioMute,
        isVideoMute,
        leaveMeeting,
      ];

  VideoRoomState copyWith({
    VideoRoomStatus? status,
    List<PeerTrackNode>? peerTrackNodes,
    bool? isVideoMute,
    bool? isAudioMute,
    bool? leaveMeeting,
    bool? isScreenShareActive,
    List<HMSMessage>? messages,
  }) {
    return VideoRoomState(
      status: status ?? this.status,
      peerTrackNodes: peerTrackNodes ?? this.peerTrackNodes,
      isVideoMute: isVideoMute ?? this.isVideoMute,
      isAudioMute: isAudioMute ?? this.isAudioMute,
      leaveMeeting: leaveMeeting ?? this.leaveMeeting,
      messages: messages ?? this.messages,
    );
  }
}
