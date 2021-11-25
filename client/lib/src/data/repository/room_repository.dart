import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:music_room/src/bloc/room/room_bloc.dart';
import 'package:music_room/src/data/model/_room.dart';
import 'package:music_room/src/data/model/playlist.dart';
import 'package:music_room/src/data/model/return_repository.dart';
import 'package:music_room/src/data/model/song.dart';
import 'package:music_room/src/data/service/api_service.dart';
import 'package:music_room/src/data/service/firebase_service.dart';

class RoomRepository {
  final FirebaseService _firebaseService;
  final ApiService _apiService;

  RoomRepository(this._firebaseService, this._apiService);

  Future<List<Room>> getRooms(bool private) async {
    _apiService.sendLog("GetRooms");
    final List rooms = await _firebaseService.getAllRooms(private);
    if (rooms.isNotEmpty) {
      return (List.from(rooms.map((e) => Room.fromMap(e))));
    }
    return ([]);
  }

  Future<ReturnRepository> createRoom(Room newRoom) async {
    _apiService.sendLog("CreateRooms");
    final User? currentUser = _firebaseService.currentUser();
    if (currentUser == null) return (ReturnRepository.failed(message: 'Unlog'));

    Map<String, dynamic> roomMap = newRoom.toMap();
    roomMap['creatorId'] = currentUser.uid;
    try {
      final String idRoom = await _firebaseService.createRoom(roomMap);
      return (ReturnRepository.success(data: {'idRoom': idRoom}));
    } catch (e) {
      return (ReturnRepository.failed(message: 'Server error, try again.'));
    }
  }

  Future<ReturnRepository> updateRoom(
      String idRoom, Map<String, dynamic> data, bool merge) async {
    try {
      _apiService.sendLog("UpdateRooms");
      await _firebaseService.updateRoom(idRoom, data, merge);
      return (ReturnRepository.success());
    } catch (e) {
      return (ReturnRepository.failed(message: e.toString()));
    }
  }

  Future<ReturnRepository> getInvitationCode(String id) async {
    try {
      _apiService.sendLog("getInvitationCode");
      final data = await _firebaseService.getRoomData(id);

      if (data == null) {
        return (ReturnRepository.failed(message: 'Server error, try again.'));
      }
      return (ReturnRepository.success(
          data: {'invitationCode': data.invitationCode}));
    } catch (e) {
      return (ReturnRepository.failed(message: e.toString()));
    }
  }

  Future<ReturnRepository> enterInvitationCode(
      String code, String pseudo) async {
    try {
      _apiService.sendLog("EnterInvitationCode");
      final String authToken = await _firebaseService.getAuthToken();

      final Room? data =
          await _apiService.joinInvitedRoom(code, authToken, pseudo);

      if (data == null) {
        return (ReturnRepository.failed(message: 'Invalid invitation code.'));
      }
      return (ReturnRepository.success(data: {'room': data}));
    } catch (e) {
      return (ReturnRepository.failed(message: "Server error, try again."));
    }
  }

  Future<ReturnRepository> joinRoom(String roomId, String pseudo) async {
    try {
      _apiService.sendLog("JoinRoom");
      final String authToken = await _firebaseService.getAuthToken();

      final Room? data = await _apiService.joinRoom(roomId, authToken, pseudo);

      if (data == null) {
        return (ReturnRepository.failed(message: 'Invalid invitation code.'));
      }
      return (ReturnRepository.success(data: {'room': data}));
    } catch (e) {
      return (ReturnRepository.failed(message: "Server error, try again."));
    }
  }

  Future<ReturnTracks> searchSongs(String trackName) async {
    _apiService.sendLog("SearchSongs");
    return await _apiService.searchSong(
      trackName,
    );
  }
}
