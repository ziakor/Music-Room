import 'dart:developer';

import 'package:equatable/equatable.dart';
import 'package:music_room/src/data/model/current_song.dart';
import 'package:music_room/src/data/model/right_license.dart';
import 'package:music_room/src/data/model/room_user.dart';
import 'package:music_room/src/data/model/song.dart';

class Room extends Equatable {
  final String id;
  final String creatorId;
  final String invitationCode;
  final String name;
  final bool private;
  final RightLicense rightLicense;
  final CurrentSong currentSong;
  final int time;
  final List<Song> songs;
  final List<RoomUser> users;
  final bool isInvited;

  const Room({
    this.id = "",
    this.creatorId = "",
    this.invitationCode = '',
    this.name = "",
    this.private = false,
    this.rightLicense = const RightLicense(),
    this.currentSong = CurrentSong.empty,
    this.time = 0,
    this.songs = const [],
    this.users = const [],
    this.isInvited = false,
  });

  static const empty = Room();

  bool get isEmpty => this == empty;
  bool get isNotEmpty => this != empty;

  Map<String, dynamic> toMap() {
    return {
      'creatorId': creatorId,
      'invitationCode': invitationCode,
      'name': name,
      'private': private,
      'rightLicense': rightLicense.toMap(),
      'currentSong': currentSong.toMap(),
      'time': time,
      'songs': songs.map((x) => x.toMap()).toList(),
      'users': users.map((x) => x.toMap()).toList(),
    };
  }

  factory Room.fromMap(Map<String, dynamic> map) {
    return Room(
      id: map['id'],
      creatorId: map['creatorId'],
      invitationCode: map['invitationCode'] ?? '',
      name: map['name'],
      private: map['private'],
      rightLicense: RightLicense.fromMap(map['rightLicense']),
      currentSong: CurrentSong.fromMap(map['currentSong']),
      time: map['time'],
      songs: List<Song>.from(map['songs'].map((x) => Song.fromMap(x))),
      users: List<RoomUser>.from(map['users'].map((x) => RoomUser.fromMap(x))),
    );
  }

  Room copyWith({
    String? id,
    String? creatorId,
    String? invitationCode,
    String? name,
    bool? private,
    RightLicense? rightLicense,
    CurrentSong? currentSong,
    int? time,
    List<Song>? songs,
    List<RoomUser>? users,
    bool? isInvited,
  }) {
    return Room(
      id: id ?? this.id,
      creatorId: creatorId ?? this.creatorId,
      invitationCode: invitationCode ?? this.invitationCode,
      name: name ?? this.name,
      private: private ?? this.private,
      rightLicense: rightLicense ?? this.rightLicense,
      currentSong: currentSong ?? this.currentSong,
      time: time ?? this.time,
      songs: songs ?? this.songs,
      users: users ?? this.users,
      isInvited: isInvited ?? this.isInvited,
    );
  }

  @override
  List<Object> get props => [
        id,
        creatorId,
        invitationCode,
        name,
        private,
        rightLicense,
        currentSong,
        time,
        songs,
        users,
      ];
}
