import 'dart:developer';
import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:music_room/src/bloc/room/room_bloc.dart';
import 'package:music_room/src/data/model/playlist.dart';
import 'package:music_room/src/data/model/right_license.dart';
import 'package:music_room/src/data/model/right_license_time.dart';
import 'package:music_room/src/data/model/room_user.dart';
import 'package:music_room/src/data/model/song.dart';

import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:socket_io_client/socket_io_client.dart';

part 'playlist_socket_state.dart';

class PlaylistSocketCubit extends Cubit<PlaylistSocketState> {
  IO.Socket? socket;
  PlaylistSocketCubit(String authToken) : super(PlaylistSocketInitial()) {
    if (socket == null) {
      socket = IO.io(
          'ws://10.0.2.2:3001/playlist',
          OptionBuilder()
              .setTransports(['websocket']) // for Flutter or Dart VM
              .disableAutoConnect() // disable auto-connection
              .setExtraHeaders({'authorization': authToken}) // optional
              .build());
      socket!.connect();
    }
  }

  void joinPlaylist(String roomId, String pseudo, String role, bool isInvited) {
    if (socket != null) {
      socket!.emit('joinPlaylist', {
        'playlistId': roomId,
        'pseudo': pseudo,
        'role': role,
        'isInvited': isInvited
      });
      socket!.on('userJoinedPlaylist', (data) {
        emit(UserJoined(RoomUser.fromMap(data)));
      });
      socket!
          .on('userLeavedPlaylist', (data) => emit(UserLeaved(data['userId'])));

      socket!.on('userAddedSong', (data) {
        emit(
          UserAddedSong(
            Song.fromMap(data),
          ),
        );
      });

      socket!.on('rightLicenseUpdated', (data) {
        emit(
          UpdateRightLicense(
            RightLicense(
              onlyInvitedEnabled: data['onlyInvitedEnabled'],
            ),
          ),
        );
      });
    }
  }

  void addSong(String roomId, Song song) {
    socket!.emit('addSongToWaitingList', {
      'playlistId': roomId,
      'name': song.name,
      'image': song.image,
      'url': song.url,
      'author': song.author,
    });
  }

  void leavePlaylist(String roomId) {
    socket!.emit('leavePlaylist', roomId);
    socket!.clearListeners();
  }

  void updateRightLicense(String roomId, RightLicense rightLicense) {
    socket!.emit('updateRightLicense', {
      'onlyInvitedEnabled': rightLicense.onlyInvitedEnabled,
      'playlistId': roomId
    });
  }

  @override
  Future<void> close() {
    if (socket != null) {
      socket!.close();
    }
    return super.close();
  }
}
