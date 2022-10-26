import 'package:hmssdk_flutter/hmssdk_flutter.dart';
import 'package:rxdart/rxdart.dart';
import 'package:video_call_flutter_poc/states/video_room/video_room_state_notifier.dart';

import '../states/room/peer_track_node.dart';

class RoomObserver implements HMSUpdateListener, HMSActionResultListener {
  final VideoRoomStateNotifier roomOverviewBloc;

  RoomObserver(this.roomOverviewBloc);

  @override
  void onAudioDeviceChanged({
    HMSAudioDevice? currentAudioDevice,
    List<HMSAudioDevice>? availableAudioDevice,
  }) {
    // TODO: implement onAudioDeviceChanged
  }

  @override
  void onChangeTrackStateRequest({
    required HMSTrackChangeRequest hmsTrackChangeRequest,
  }) {
    // TODO: implement onChangeTrackStateRequest
  }

  @override
  void onException({
    HMSActionResultListenerMethod? methodType,
    Map<String, dynamic>? arguments,
    required HMSException hmsException,
  }) {
    // TODO: implement onException
  }

  @override
  void onHMSError({required HMSException error}) {
    // TODO: implement onHMSError
    print('ROOM: error');
  }

  @override
  void onJoin({required HMSRoom room}) {
    // TODO: implement onJoin
    roomOverviewBloc.onJoinSuccess(room);

    print('ROOM: join');
  }

  @override
  void onMessage({required HMSMessage message}) {
    // TODO: implement onMessage
    print('ROOM: MESSAGE ${message.message}');
    final mes = [...messageStreamController.value];
    mes.add(message);
    messageStreamController.add(mes);
  }

  @override
  void onPeerUpdate({required HMSPeer peer, required HMSPeerUpdate update}) {
    // TODO: implement onPeerUpdate
    print('ROOM: PEER UPDATE');
    print('ROOM: ' + peer.toString());
    print('ROOM: ${peer.videoTrack.toString()}');
    switch (update) {
      case HMSPeerUpdate.peerJoined:
        if (peer is HMSRemotePeer) {
          addPeer(
            peer.videoRemoteTrack,
            peer,
          );
        } else {
          addPeer(
            peer.videoTrack,
            peer,
          );
        }

        break;
      case HMSPeerUpdate.peerLeft:
        deletePeer(peer.peerId);
        break;
      default:
    }
  }

  @override
  void onReconnected() {
    // TODO: implement onReconnected
  }

  @override
  void onReconnecting() {
    // TODO: implement onReconnecting
  }

  @override
  void onRemovedFromRoom({
    required HMSPeerRemovedFromPeer hmsPeerRemovedFromPeer,
  }) {
    print('ROOM: REMOVED');
    roomOverviewBloc.leaveRequested();

    // TODO: implement onRemovedFromRoom
  }

  @override
  void onRoleChangeRequest({
    required HMSRoleChangeRequest roleChangeRequest,
  }) {
    // TODO: implement onRoleChangeRequest
  }

  @override
  void onRoomUpdate({
    required HMSRoom room,
    required HMSRoomUpdate update,
  }) {
    print('ROOM: UPDATE');
    // TODO: implement onRoomUpdate
  }

  @override
  void onSuccess({
    HMSActionResultListenerMethod? methodType,
    Map<String, dynamic>? arguments,
  }) {
    _peerNodeStreamController.add([]);
  }

  @override
  void onTrackUpdate({
    required HMSTrack track,
    required HMSTrackUpdate trackUpdate,
    required HMSPeer peer,
  }) {
    print('ROOM: TRACK UPDATED');

    if (track.kind == HMSTrackKind.kHMSTrackKindVideo) {
      if (trackUpdate == HMSTrackUpdate.trackRemoved) {
        print('ROOM: TRACK REMOVED');
        deletePeer(peer.peerId);
      } else if (trackUpdate == HMSTrackUpdate.trackAdded ||
          trackUpdate == HMSTrackUpdate.trackMuted ||
          trackUpdate == HMSTrackUpdate.trackUnMuted) {
        print('ROOM: TRACK ADEDED OU UPDATED');
        addPeer(
          track,
          peer,
        );
      }
    }
  }

  @override
  void onUpdateSpeakers({required List<HMSSpeaker> updateSpeakers}) {
    // TODO: implement onUpdateSpeakers
  }

  final _peerNodeStreamController =
      BehaviorSubject<List<PeerTrackNode>>.seeded(const []);

  Stream<List<PeerTrackNode>> get tracks =>
      _peerNodeStreamController.asBroadcastStream();

  final messageStreamController =
      BehaviorSubject<List<HMSMessage>>.seeded(const []);

  Stream<List<HMSMessage>> get messages =>
      messageStreamController.asBroadcastStream();

  Future<void> addPeer(HMSTrack? hmsVideoTrack, HMSPeer peer) async {
    final tracks = [..._peerNodeStreamController.value];
    final todoIndex = tracks.indexWhere((t) => t.peer?.peerId == peer.peerId);
    if (todoIndex >= 0) {
      print("onTrackUpdate ${peer.name} ${hmsVideoTrack?.isMute}");
      tracks[todoIndex] =
          PeerTrackNode(hmsVideoTrack, hmsVideoTrack?.isMute, peer, false);
    } else {
      tracks.add(
          PeerTrackNode(hmsVideoTrack, hmsVideoTrack?.isMute, peer, false));
    }

    _peerNodeStreamController.add(tracks);
  }

  void sendMessage(String message, HMSPeer? sender) {
    final mes = [...messageStreamController.value];
    mes.add(
      HMSMessage(
        message: message,
        sender: sender,
        type: '',
        time: DateTime.now(),
      ),
    );
    messageStreamController.add(mes);
  }

  Future<void> deletePeer(String id) async {
    final tracks = [..._peerNodeStreamController.value];
    final todoIndex = tracks.indexWhere((t) => t.peer?.peerId == id);
    if (todoIndex >= 0) {
      tracks.removeAt(todoIndex);
    }
    _peerNodeStreamController.add(tracks);
  }

  Future<void> leaveMeeting() async {
    roomOverviewBloc.hmsSdk.leave(hmsActionResultListener: this);
  }

  Future<void> setOffScreen(int index, bool setOffScreen) async {
    final tracks = [..._peerNodeStreamController.value];

    if (index >= 0) {
      tracks[index] = tracks[index].copyWith(isOffScreen: setOffScreen);
    }
    _peerNodeStreamController.add(tracks);
  }
}
