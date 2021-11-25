import 'dart:convert';

import 'package:equatable/equatable.dart';
import 'package:music_room/src/data/model/right_license.dart';
import 'package:music_room/src/data/model/room_user.dart';
import 'package:music_room/src/data/model/song.dart';

class Playlist extends Equatable {
  final String id;
  final String creatorId;
  final String invitationCode;
  final String name;
  final bool private;
  final RightLicense rightLicense;
  final List<Song> songs;
  final List<RoomUser> users;
  final bool isInvited;
  const Playlist({
    this.id = '',
    this.creatorId = '',
    this.invitationCode = '',
    this.name = '',
    this.private = false,
    this.rightLicense = const RightLicense(),
    this.songs = const [],
    this.users = const [],
    this.isInvited = false,
  });

  static const empty = Playlist();

  bool get isEmpty => this == empty;
  bool get isNotEmpty => this != empty;

  Map<String, dynamic> toMap() {
    return {
      'creatorId': creatorId,
      'invitationCode': invitationCode,
      'name': name,
      'private': private,
      'rightLicense': rightLicense.toMap(),
      'songs': songs.map((x) => x.toMap()).toList(),
      'users': users.map((x) => x.toMap()).toList(),
    };
  }

  factory Playlist.fromMap(Map<String, dynamic> map) {
    return Playlist(
      id: map['id'],
      creatorId: map['creatorId'],
      invitationCode: map['invitationCode'] ?? "",
      name: map['name'],
      private: map['private'],
      rightLicense: RightLicense.fromMap(map['rightLicense']),
      songs: List<Song>.from(map['songs']?.map((x) => Song.fromMap(x))),
      users: List<RoomUser>.from(map['users']?.map((x) => RoomUser.fromMap(x))),
    );
  }

  Playlist copyWith({
    String? id,
    String? creatorId,
    String? invitationCode,
    String? name,
    bool? private,
    RightLicense? rightLicense,
    List<Song>? songs,
    List<RoomUser>? users,
    bool? isInvited,
  }) {
    return Playlist(
      id: id ?? this.id,
      creatorId: creatorId ?? this.creatorId,
      invitationCode: invitationCode ?? this.invitationCode,
      name: name ?? this.name,
      private: private ?? this.private,
      rightLicense: rightLicense ?? this.rightLicense,
      songs: songs ?? this.songs,
      users: users ?? this.users,
      isInvited: isInvited ?? this.isInvited,
    );
  }

  @override
  List<Object?> get props => [
        id,
        creatorId,
        invitationCode,
        name,
        private,
        rightLicense,
        songs,
        users,
      ];
}
