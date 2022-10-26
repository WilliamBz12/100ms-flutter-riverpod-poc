import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hmssdk_flutter/hmssdk_flutter.dart';
import 'package:video_call_flutter_poc/observers/room_observer.dart';
import 'package:video_call_flutter_poc/states/video_room/video_room_state.dart';

import '../../services/room_service.dart';
import '../room/peer_track_node.dart';

class VideoRoomStateNotifier extends StateNotifier<VideoRoomState> {
  VideoRoomStateNotifier({
    required this.roomService,
  }) : super(const VideoRoomState()) {
    observer = RoomObserver(this);
  }

  final hmsSdk = HMSSDK();
  final RoomService roomService;
  late RoomObserver observer;
  late StreamSubscription<List<PeerTrackNode>> subscription;
  late StreamSubscription<List<HMSMessage>> subscriptionMessage;

  Future<void> joinRoom(String name, String room) async {
    state = state.copyWith(status: VideoRoomStatus.loading);
    hmsSdk.addUpdateListener(listener: observer);
    hmsSdk.build();

    final token = await roomService.generateToken(user: name, room: room);
    HMSConfig config = HMSConfig(
      authToken: token,
      userName: name,
    );
    await hmsSdk.join(config: config);
    onSubscription();
    onSubscriptionMessage();
  }

  void onSubscription() {
    subscription = observer.tracks.listen((tracks) {
      'ROOM: Update track listen ${tracks.length}';
      state = state.copyWith(peerTrackNodes: tracks);
    }, onError: (error) {
      state = state.copyWith(
        status: VideoRoomStatus.failure,
      );
    });
  }

  void onSubscriptionMessage() {
    subscriptionMessage = observer.messages.listen((message) {
      'ROOM: Update track listen ${message.length}';
      state = state.copyWith(messages: message);
    }, onError: (error) {
      state = state.copyWith(
        status: VideoRoomStatus.failure,
      );
    });
  }

  void sendMessage(String message) async {
    await hmsSdk.sendBroadcastMessage(message: message);

    observer.sendMessage(
      message,
      state.localTrack?.peer,
    );
  }

  Future<void> onLocalVideoToggled() async {
    await hmsSdk.switchVideo(isOn: !state.isVideoMute);
    state = (state.copyWith(isVideoMute: !state.isVideoMute));
  }

  Future<void> onLocalAudioToggled() async {
    hmsSdk.switchAudio(isOn: !state.isAudioMute);
    state = (state.copyWith(isAudioMute: !state.isAudioMute));
  }

  Future<void> onJoinSuccess(
    HMSRoom hmsRoom,
  ) async {
    if (state.isAudioMute) {
      hmsSdk.switchAudio(isOn: state.isAudioMute);
    }

    if (state.isVideoMute) {
      hmsSdk.switchVideo(isOn: state.isVideoMute);
    }
    state = state.copyWith(status: VideoRoomStatus.success);
  }

  Future<void> onPeerLeave(
    HMSPeer hmsPeer,
    HMSVideoTrack hmsVideoTrack,
  ) async {
    await observer.deletePeer(hmsPeer.peerId);
  }

  Future<void> onPeerJoin(
    HMSPeer hmsPeer,
    HMSVideoTrack hmsVideoTrack,
  ) async {
    await observer.addPeer(hmsVideoTrack, hmsPeer);
  }

  Future<void> leaveRequested() async {
    state = state.copyWith(status: VideoRoomStatus.loading);
    await observer.leaveMeeting();
    state = state.copyWith(leaveMeeting: true);
  }

  Future<void> setOffScreen(
    int index,
    bool setOffScreen,
  ) async {
    await observer.setOffScreen(index, setOffScreen);
  }

  @override
  void dispose() async {
    await subscription.cancel();
    await subscriptionMessage.cancel();
    hmsSdk.removeUpdateListener(listener: observer);
    super.dispose();
  }
}
