import 'dart:developer';
import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:music_room/src/bloc/room/room_bloc.dart';
import 'package:music_room/src/data/model/right_license.dart';
import 'package:music_room/src/data/model/right_license_time.dart';
import 'package:music_room/src/data/model/room_user.dart';
import 'package:music_room/src/data/model/song.dart';

import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:socket_io_client/socket_io_client.dart';

part 'room_socket_state.dart';

class RoomSocketCubit extends Cubit<RoomSocketState> {
  IO.Socket? socket;
  RoomSocketCubit(String authToken) : super(RoomSocketInitial()) {
    if (socket == null) {
      socket = IO.io(
          'ws://10.0.2.2:3001/rooms',
          OptionBuilder()
              .setTransports(['websocket']) // for Flutter or Dart VM
              .disableAutoConnect() // disable auto-connection
              .setExtraHeaders({'authorization': authToken}) // optional
              .build());
      socket!.connect();
    }
  }

  void joinRoom(String roomId, String pseudo, String role, bool isInvited) {
    if (socket != null) {
      socket!.emit('joinRoom', {
        'roomId': roomId,
        'pseudo': pseudo,
        'role': role,
        'isInvited': isInvited
      });
      socket!.on(
          'userJoinedRoom', (data) => emit(UserJoined(RoomUser.fromMap(data))));
      socket!.on('userLeavedRoom', (data) => emit(UserLeaved(data['userId'])));
      socket!.on('currentSongChanged', (data) {
        emit(CurrentSongChanged(Song.fromMap(data)));
      });
      socket!.on('userVoteSong', (data) {
        emit(UserVoteSong(
            data['index'], SongGrade.fromMap(data), data['indexVote']));
      });
      socket!.on('userAddedSong', (data) {
        emit(
          UserAddedSong(
            Song.fromMap(data),
          ),
        );
      });
      socket!.on('currentSongTimeChanged', (data) {
        emit(CurrentSongTimeChanged(data));
      });
      socket!.on('currentSongStatusChanged', (data) {
        emit(CurrentSongStatusChanged(data));
      });
      socket!.on('rightLicenseUpdated', (data) {
        emit(
          UpdateRightLicense(
            RightLicense(
              location: GeoPoint(data['locationLatitude'].toDouble(),
                  data['locationLongitude'].toDouble()),
              time: RightLicenseTime(
                  start: data['timeStart'], end: data['timeEnd']),
              onlyInvitedEnabled: data['onlyInvitedEnabled'],
              timeEnabled: data['timeEnabled'],
              locationEnabled: data['locationEnabled'],
            ),
          ),
        );
      });
      socket!.on(
          'invitationCodeUpdated', (data) => emit(InvitationCodeUpdated(data)));
      socket!.on('roleUserUpdated',
          (data) => emit(RoleUserUpdated(data['role'], data['userId'])));
    }
  }

  void playSong(String roomId, bool status) {
    socket!
        .emit('updateCurrentSongStatus', {'roomId': roomId, 'status': status});
  }

  void updateTimeSong(String roomId, int time) {
    socket!.emit('updateCurrentSongTime', {'roomId': roomId, 'time': time});
  }

  void updateCurrentSong(String roomId, Song newSong) {
    socket!.emit('updateCurrentSong', {
      'roomId': roomId,
      'name': newSong.name,
      'url': newSong.url,
      'image': newSong.image,
      'author': newSong.author,
    });
  }

  void addSong(String roomId, Song song) {
    socket!.emit('addSongToWaitingList', {
      'roomId': roomId,
      'name': song.name,
      'image': song.image,
      'url': song.url,
      'author': song.author,
    });
  }

  void updateInvitationCode(String roomId, String code) {
    socket!.emit(
        'updateInvitationCode', {'roomId': roomId, 'invitationCode': code});
  }

  void updateUserRole(String roomId, String userId, String role) {
    socket!.emit(
        'updateRoleUser', {'roomId': roomId, 'userId': userId, 'role': role});
  }

  void voteSong(String roomId, int note, String songName, String author) {
    socket!.emit('voteSong', {
      'roomId': roomId,
      'note': note,
      'name': songName,
      'author': author,
    });
  }

  void leaveRoom(String roomId) {
    socket!.emit('leaveRoom', roomId);
    socket!.clearListeners();
  }

  void updateRightLicense(String roomId, RightLicense rightLicense) {
    socket!.emit('updateRightLicense', {
      'locationLatitude': rightLicense.location.latitude,
      'locationLongitude': rightLicense.location.longitude,
      'timeStart': rightLicense.time.start,
      'timeEnd': rightLicense.time.end,
      'onlyInvitedEnabled': rightLicense.onlyInvitedEnabled,
      'timeEnabled': rightLicense.timeEnabled,
      'locationEnabled': rightLicense.locationEnabled,
      'roomId': roomId
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
