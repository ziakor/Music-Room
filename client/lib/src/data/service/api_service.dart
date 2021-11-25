import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:device_info/device_info.dart';
import 'package:dio/dio.dart';
import 'package:music_room/src/data/model/_room.dart';
import 'package:music_room/src/data/model/_user.dart';
import 'package:music_room/src/data/model/playlist.dart';
import 'package:music_room/src/data/model/return_repository.dart';
import 'package:music_room/src/data/model/song.dart';

class ApiServerError implements Exception {
  final String message;

  ApiServerError(this.message);
}

class ReturnTracks {
  final List<Song> tracks;

  ReturnTracks(this.tracks);
}

class ApiService {
  final Dio _dio;
  ApiService(this._dio);

  Future<void> forgetPasswordCode(String email) async {
    try {
      await _dio.post(
        '/users/forgetPassword',
        data: {
          "email": email,
        },
      );
    } on DioError catch (e) {
      print(e);
      throw ApiServerError(e.response!.data['message']);
    } catch (e) {
      print(e);
      throw ApiServerError("Server error, try again.");
    }
  }

  Future<void> forgetPasswordUpdate(
      String email, String password, String code) async {
    try {
      await _dio.post(
        '/users/forgetPassword/$code',
        data: {
          "email": email,
          "password": password,
        },
      );
    } on DioError catch (e) {
      throw ApiServerError(e.response!.data['message']);
    } catch (e) {
      throw ApiServerError("Server error, try again.");
    }
  }

  Future<ReturnTracks> searchSong(String trackName) async {
    try {
      final res = await _dio.get('/songs/search/',
          queryParameters: {
            'name': trackName,
          },
          options: Options(headers: {
            'Content-Type': 'application/json',
          }));
      List<Song> listTracks = [];

      for (var i = 0; i < res.data['tracks'].length; i++) {
        listTracks.add(Song(
          name: res.data['tracks'][i]['name'],
          url: res.data['tracks'][i]['url'],
          image: res.data['tracks'][i]['image'],
          author: res.data['tracks'][i]['author'],
        ));
      }
      return (ReturnTracks(listTracks));
    } on DioError catch (e) {
      throw ApiServerError(e.response!.data['message']);
    } catch (e) {
      throw ApiServerError("Server error, try again.");
    }
  }

  Future<Room?> joinInvitedRoom(
      String invitationCode, String authToken, String pseudo) async {
    try {
      final res = await _dio.post('/rooms/joinInvited',
          data: {
            'invitationCode': invitationCode,
            "pseudo": pseudo,
          },
          options: Options(headers: {
            'Content-Type': 'application/json',
            'authorization': authToken,
          }));
      if (res.data['id'].isEmpty) return null;
      res.data['data']['id'] = res.data['id'];

      res.data['data']['rightLicense']['location'] = GeoPoint(
          res.data['data']['rightLicense']['location']['_latitude'].toDouble(),
          res.data['data']['rightLicense']['location']['_longitude']
              .toDouble());
      return (Room.fromMap(res.data['data']));
    } on DioError catch (e) {
      throw ApiServerError(e.response!.data['message']);
    } catch (e) {
      throw ApiServerError("Server error, try again.");
    }
  }

  Future<Room?> joinRoom(String roomId, String authToken, String pseudo) async {
    try {
      final res = await _dio.post('/rooms/join/$roomId',
          data: {
            "pseudo": pseudo,
          },
          options: Options(headers: {
            'Content-Type': 'application/json',
            'authorization': authToken,
          }));
      res.data['id'] = roomId;
      res.data['rightLicense']['location'] = GeoPoint(
          res.data['rightLicense']['location']['_latitude'].toDouble(),
          res.data['rightLicense']['location']['_longitude'].toDouble());
      return (Room.fromMap(res.data));
    } on DioError catch (e) {
      throw ApiServerError(e.response!.data['message']);
    } catch (e) {
      throw ApiServerError("Server error, try again.");
    }
  }

  Future<List<User>> getUsers() async {
    try {
      final res = await _dio.get('/users',
          options: Options(headers: {
            'Content-Type': 'application/json',
          }));
      List<User> listUsers = [];

      for (var i = 0; i < res.data.length; i++) {
        listUsers
            .add(User(id: res.data[i]['id'], pseudo: res.data[i]['pseudo']));
      }
      return (listUsers);
    } on DioError catch (e) {
      throw ApiServerError(e.response!.data['message']);
    } catch (e) {
      throw ApiServerError("Server error, try again.");
    }
  }

  Future<User?> getUserProfile(String id, String authToken) async {
    try {
      final res = await _dio.get('/users/$id',
          options: Options(headers: {
            'Content-Type': 'application/json',
            'authorization': authToken,
          }));

      return (User(
        id: id,
        pseudo: res.data['pseudo'],
        birth: res.data['birth'] != null
            ? DateTime.fromMillisecondsSinceEpoch(
                res.data['birth']['_seconds'] * 1000)
            : null,
        gender: res.data['gender'],
        bio: res.data['bio'],
        friends: List<String>.from(res.data['friends']),
      ));
    } on DioError catch (e) {
      print(e);
      throw ApiServerError(e.response!.data['message']);
    } catch (e) {
      print(e);

      throw ApiServerError("Server error, try again.");
    }
  }

  Future<bool> addFriend(String friendId, String authToken) async {
    try {
      final res = await _dio.post('/users/addFriend',
          data: {'friendId': friendId},
          options: Options(headers: {
            'Content-Type': 'application/json',
            'authorization': authToken,
          }));

      return (true);
    } on DioError catch (e) {
      print(e);
      throw ApiServerError(e.response!.data['message']);
    } catch (e) {
      print(e);

      throw ApiServerError("Server error, try again.");
    }
  }

  Future<bool> removeFriend(String friendId, String authToken) async {
    try {
      final res = await _dio.post('/users/removeFriend',
          data: {'friendId': friendId},
          options: Options(headers: {
            'Content-Type': 'application/json',
            'authorization': authToken,
          }));

      return (true);
    } on DioError catch (e) {
      print(e);
      throw ApiServerError(e.response!.data['message']);
    } catch (e) {
      print(e);

      throw ApiServerError("Server error, try again.");
    }
  }

  Future<Playlist?> joinInvitedPlaylist(
      String invitationCode, String authToken, String pseudo) async {
    try {
      final res = await _dio.post('/playlist/joinInvited',
          data: {
            'invitationCode': invitationCode,
            "pseudo": pseudo,
          },
          options: Options(headers: {
            'Content-Type': 'application/json',
            'authorization': authToken,
          }));
      if (res.data['id'].isEmpty) return null;
      res.data['data']['id'] = res.data['id'];

      res.data['data']['rightLicense']['location'] = GeoPoint(
          res.data['data']['rightLicense']['location']['_latitude'].toDouble(),
          res.data['data']['rightLicense']['location']['_longitude']
              .toDouble());
      return (Playlist.fromMap(res.data['data']));
    } on DioError catch (e) {
      throw ApiServerError(e.response!.data['message']);
    } catch (e) {
      throw ApiServerError("Server error, try again.");
    }
  }

  Future<Playlist?> joinPlaylist(
      String playlistId, String authToken, String pseudo) async {
    try {
      final res = await _dio.post('/playlist/join/$playlistId',
          data: {
            "pseudo": pseudo,
          },
          options: Options(headers: {
            'Content-Type': 'application/json',
            'authorization': authToken,
          }));
      res.data['id'] = playlistId;
      res.data['rightLicense']['location'] = GeoPoint(
          res.data['rightLicense']['location']['_latitude'].toDouble(),
          res.data['rightLicense']['location']['_longitude'].toDouble());
      return (Playlist.fromMap(res.data));
    } on DioError catch (e) {
      throw ApiServerError(e.response!.data['message']);
    } catch (e) {
      throw ApiServerError("Server error, try again.");
    }
  }

  void sendLog(String message) async {
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
    print(androidInfo.model);

    try {
      _dio.post('/log',
          data: {
            "platform": 'Android',
            "device": androidInfo.device,
            "application_version": "1.0",
            "message": message,
          },
          options: Options(headers: {
            'Content-Type': 'application/json',
          }));
    } on DioError catch (e) {
    } catch (e) {}
  }
}
