import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:video_call_flutter_poc/services/room_service.dart';
import 'package:video_call_flutter_poc/states/preview/preview_state_notifier.dart';

import '../states/video_room/video_room_state.dart';
import '../states/video_room/video_room_state_notifier.dart';

final _roomService = Provider<RoomService>((ref) => RoomService());

final previewStateProvider =
    StateNotifierProvider.autoDispose<PreviewStateNotifier, PreviewState>(
  (ref) => PreviewStateNotifier(
    roomService: ref.read(_roomService),
  ),
);

final videoRoomProvider =
    StateNotifierProvider.autoDispose<VideoRoomStateNotifier, VideoRoomState>(
  (ref) => VideoRoomStateNotifier(roomService: ref.read(_roomService)),
);
