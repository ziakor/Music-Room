import 'dart:async';
import 'dart:developer';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';
import 'package:music_room/src/data/model/_room.dart';
import 'package:music_room/src/data/model/current_song.dart';
import 'package:music_room/src/data/model/return_repository.dart';
import 'package:music_room/src/data/model/right_license.dart';
import 'package:music_room/src/data/model/room_user.dart';
import 'package:music_room/src/data/model/song.dart';
import 'package:music_room/src/data/repository/room_repository.dart';
import 'package:music_room/utils/utils.dart';

part 'room_event.dart';
part 'room_state.dart';

class RoomBloc extends Bloc<RoomEvent, RoomState> {
  final RoomRepository _roomRepository;
  RoomBloc({required RoomRepository roomRepository})
      : _roomRepository = roomRepository,
        super(RoomState());

  @override
  Stream<RoomState> mapEventToState(
    RoomEvent event,
  ) async* {
    if (event is UpdateListRooms) {
      yield state.copyWith(listRooms: await _getRooms());
    } else if (event is UpdateCurrentRoom) {
      yield state.copyWith(currentRoom: event.room);
    } else if (event is UpdateNewRoomName) {
      yield state.copyWith(newRoom: state.newRoom.copyWith(name: event.name));
    } else if (event is UpdateNewRoomPrivate) {
      yield state.copyWith(
          newRoom: state.newRoom.copyWith(private: event.private));
    } else if (event is CreateNewRoom) {
      yield await _createRoom(
          state.newRoom, event.creatorId, event.creatorPseudo);
    } else if (event is UpdateInvitationCode) {
      yield await _getInvitationCode(event.roomId, event.invitationCode);
    } else if (event is EnterRoomInvitationCode) {
      yield await _enterInvitation(event.code, event.pseudo);
    } else if (event is ResetRoomError) {
      state.copyWith(error: '');
    } else if (event is UpdateOnPlayCurrentSong) {
      yield state.copyWith(
        currentRoom: state.currentRoom.copyWith(
          currentSong: state.currentRoom.currentSong
              .copyWith(onPlay: !state.currentRoom.currentSong.onPlay),
        ),
      );
    } else if (event is UpdateTimeCurrentSong) {
      yield state.copyWith(
        currentRoom: state.currentRoom.copyWith(
          currentSong: state.currentRoom.currentSong
              .copyWith(time: event.time.inSeconds.toDouble()),
        ),
      );
    } else if (event is AddSongToSongs) {
      List<Song> newList = List.from(state.currentRoom.songs);
      newList.add(event.song);
      yield state.copyWith(
          currentRoom: state.currentRoom.copyWith(
              songs: newList,
              currentSong: state.currentRoom.currentSong.copyWith(
                  song: state.currentRoom.currentSong.song == Song.empty
                      ? event.song
                      : state.currentRoom.currentSong.song)));
    } else if (event is UpdateCurrentSong) {
      state.currentRoom.songs.removeWhere((element) =>
          element.author == state.currentRoom.currentSong.song.author &&
          state.currentRoom.currentSong.song.name == element.name);
      yield state.copyWith(
        currentRoom: state.currentRoom.copyWith(
            currentSong: CurrentSong(
          song: event.song,
          onPlay: state.currentRoom.currentSong.onPlay,
        )),
      );
    } else if (event is UpdateRightLicenseCurrentRoom) {
      yield state.copyWith(
          currentRoom:
              state.currentRoom.copyWith(rightLicense: event.newLicense));
    } else if (event is JoinRoom) {
      yield await _joinRoom(event.roomId, event.pseudo);
    } else if (event is UpdateVoteSong) {
      List<Song> t = List.from(state.currentRoom.songs);
      // inspect(state.currentRoom.songs);

      if (t[event.index].grade.length - 1 < event.indexVote ||
          event.indexVote == -1) {
        // add
        t[event.index].grade.add(event.grade);
      } else {
        t[event.index].grade[event.indexVote] = t[event.index]
            .grade[event.indexVote]
            .copyWith(note: event.grade.note);
      }

      yield state.copyWith(
        currentRoom: state.currentRoom.copyWith(songs: t),
        error: getRandomString(15),
      );
    } else if (event is UpdateUserRole) {
      List<RoomUser> t = List.from(state.currentRoom.users);
      int index = t.indexWhere((element) => event.userId == element.id);
      t[index] = RoomUser(
          id: state.currentRoom.users[index].id,
          pseudo: state.currentRoom.users[index].pseudo,
          role: event.role,
          isInvited: state.currentRoom.users[index].isInvited);
      yield state.copyWith(currentRoom: state.currentRoom.copyWith(users: t));
    } else if (event is AddUserToCurrentRoom) {
      List<RoomUser> t = List.from(state.currentRoom.users);
      t.add(event.user);
      yield state.copyWith(currentRoom: state.currentRoom.copyWith(users: t));
    } else if (event is RemoveUserToCurrentRoom) {
      List<RoomUser> t = List.from(state.currentRoom.users);
      t.removeWhere((element) => element.id == event.userId);
      yield state.copyWith(currentRoom: state.currentRoom.copyWith(users: t));
    }
  }

  Future<RoomState> _createRoom(
      Room newRoom, String creatorId, String creatorPseudo) async {
    final Room createRoomTmp = newRoom.copyWith(
      rightLicense: newRoom.private
          ? newRoom.rightLicense.copyWith(onlyInvitedEnabled: true)
          : newRoom.rightLicense,
      invitationCode:
          "${getRandomString(6)}-${getRandomString(4)}-${getRandomString(2)}",
      users: [
        RoomUser(
          id: creatorId,
          pseudo: creatorPseudo,
          role: 'Admin',
          isInvited: false,
        )
      ],
    );

    final res = await _roomRepository.createRoom(createRoomTmp);
    if (res.status == true) {
      return (state.copyWith(
        status: true,
        error: "",
        currentRoom: createRoomTmp.copyWith(id: res.data['idRoom']),
        newRoom: Room.empty,
      ));
    }
    return (state.copyWith(
      status: false,
      error: "Server error, try again",
    ));
  }

  Future<List<Room>> _getRooms() async {
    return (await _roomRepository.getRooms(false));
  }

  Future<RoomState> _getInvitationCode(String id, String code) async {
    if (code.isNotEmpty) {}
    final ReturnRepository res = await _roomRepository.getInvitationCode(id);
    if (res.status == false) {
      return (state.copyWith(
          currentRoom: state.currentRoom.copyWith(invitationCode: code)));
    }
    return (state.copyWith(
        currentRoom: state.currentRoom
            .copyWith(invitationCode: res.data['invitationCode'])));
  }

  Future<RoomState> _enterInvitation(String code, String pseudo) async {
    if (code.isEmpty) {
      return (state.copyWith(error: "Invalid code.", status: false));
    }
    final ReturnRepository res =
        await _roomRepository.enterInvitationCode(code, pseudo);
    if (res.status == false) {
      return (state.copyWith(error: res.message, status: false));
    }
    return (state.copyWith(
        status: true, currentRoom: res.data['room'].copyWith(isInvited: true)));
  }

  Future<RoomState> _joinRoom(String roomId, String pseudo) async {
    final ReturnRepository res = await _roomRepository.joinRoom(roomId, pseudo);
    if (res.status == false) {
      return (state.copyWith(error: res.message, status: false));
    }
    return (state.copyWith(status: true, currentRoom: res.data['room']));
  }
}
