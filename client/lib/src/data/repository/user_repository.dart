import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:music_room/src/data/model/_user.dart' as m;
import 'package:music_room/src/data/model/user_firestore.dart';
import 'package:music_room/src/data/model/return_repository.dart';
import 'package:music_room/src/data/service/api_service.dart';
import 'package:music_room/src/data/service/firebase_service.dart';
import 'package:music_room/utils/utils.dart';

class UserRepository {
  final FirebaseService _fireBaseService;
  final ApiService _apiService;
  UserRepository(this._fireBaseService, this._apiService);

  Future<String?> signupWithEmailAndPassword(String email, String password,
      String pseudo, String gender, DateTime birth) async {
    try {
      String? uid = await _fireBaseService.signupWithEmailAndPassword(
        email,
        password,
      );
      if (uid != null) {
        await _fireBaseService.createFirestoreUser(
            uid,
            UserFirestore(
                    pseudo: pseudo,
                    birth: Timestamp.fromDate(birth),
                    gender: gender)
                .toMap());
      }

      _apiService.sendLog("SignupWithEmailAndPassword");
      return (uid);
    } on SignupFailure {
      rethrow;
    } catch (e) {
      throw ServerError();
    }
  }

  Future<bool> checkPseudoAvailable(String pseudo) async {
    final Map? userData =
        await _fireBaseService.getFirestoreUserFromPseudo(pseudo);
    _apiService.sendLog("verifyPseudo");
    return (userData == null);
  }

  Future<void> signupWithGoogle() async {
    Map? user = await _fireBaseService.signWithGoogle();
    if (user != null) {
      await _fireBaseService.createFirestoreUser(
          user['uid'],
          UserFirestore(
                  pseudo: user['pseudo'],
                  birth: Timestamp.fromDate(DateTime.now()),
                  gender: "NB")
              .toMap());
    }
    _apiService.sendLog("SignupWithGoogle");
  }

  Future<void> signupWithFacebook() async {
    try {
      Map? user = await _fireBaseService.signWithFacebook();

      if (user != null) {
        await _fireBaseService.createFirestoreUser(
            user['uid'],
            UserFirestore(
                    pseudo: user['pseudo'],
                    birth: Timestamp.fromDate(DateTime.now()),
                    gender: "NB")
                .toMap());
      }
      _apiService.sendLog("SignupWithFacebook");
    } catch (e) {
      rethrow;
    }
  }

  Future<void> signinWithEmailAndPassword(
    String email,
    String password,
  ) async {
    await _fireBaseService.signinWithEmailAndPassword(email, password);
    _apiService.sendLog("SigninWithEmailAndPassword");
  }

  Future<void> resendEmailVerificationAccount() async {
    _fireBaseService.sendVerificationEmail();
    _apiService.sendLog("SendVerificationEmail");
  }

  Stream<m.User> get user {
    return _fireBaseService.onAuthStateChange().map((firebaseUser) {
      final user = firebaseUser == null
          ? m.User.empty
          : firebaseUser.emailVerified != false
              ? _fireBaseService.toUser(firebaseUser)
              : m.User.empty;
      return user;
    });
  }

  m.User get currentUser {
    final User? user = _fireBaseService.currentUser();
    return (user != null ? _fireBaseService.toUser(user) : m.User.empty);
  }

  Future<String> getAuthToken() async {
    _apiService.sendLog("GetAuthToken");
    return await _fireBaseService.getAuthToken();
  }

  Future<void> resetPasswordCode(String email) async {
    try {
      _apiService.sendLog("ResetPasswordCode");
      await _apiService.forgetPasswordCode(email);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> resetPassword(String email, String password, String code) async {
    try {
      _apiService.sendLog("UpdatePassword");
      await _apiService.forgetPasswordUpdate(email, password, code);
    } catch (e) {
      rethrow;
    }
  }

  Future<ReturnRepository> getUsersList() async {
    try {
      _apiService.sendLog("GetUsersList");
      final List<m.User> res = await _apiService.getUsers();
      return ReturnRepository.success(data: {'users': res});
    } catch (e) {
      return ReturnRepository.failed(message: 'ServerError');
    }
  }

  Future<void> logoutUser() async {
    _apiService.sendLog("Logout");
    await _fireBaseService.logout();
  }

  Future<UserFirestore?> getFirestoreUserDataFromId(String id) async {
    _apiService.sendLog("GetDataWithId");
    return (await _fireBaseService.getFirestoreUserFromId(id));
  }

  Future<ReturnRepository> updateUser({
    required String? pseudo,
    required String? email,
    required String? bio,
    required String? password,
    required String currentPassword,
    required DateTime? birth,
    required List<String>? musicalInterests,
    required String? gender,
    required GeoPoint? location,
  }) async {
    Map<String, dynamic> toFirestore = {
      'pseudo': pseudo,
      'bio': bio,
      'birth': birth,
      'musicalInterests': musicalInterests,
      'gender': gender,
      'location': location,
    };
    toFirestore = removeNullFieldOfMap(toFirestore);
    _apiService.sendLog("UpdateUser");
    final uid = _fireBaseService.currentUser();
    try {
      if (toFirestore.isNotEmpty) {
        _fireBaseService.updateUserFirestore(uid!.uid, toFirestore, true);
      }
      if (email != null || password != null) {
        List<String> signinMethods =
            await _fireBaseService.getUserAuthMethodWithEmail(uid!.email!);
        final idToken = await uid.getIdTokenResult();
        await _fireBaseService.reauthenticateWithCredential(
            signinMethods, uid.email!, currentPassword, '', idToken.token!);
        if (await _fireBaseService.updateUserAuth(
              uid.uid,
              uid.email!,
              email,
              currentPassword,
              password,
            ) ==
            false) {
          return (ReturnRepository.failed(message: 'Server error, try again'));
        }
      }
      return (ReturnRepository.success());
    } on FirebaseAuthException catch (e) {
      return (ReturnRepository.failed(
          message: getMessageErrorFromFirebaseAuthException(e.code)));
    } catch (e) {
      return (ReturnRepository.failed(message: 'Server error, try again'));
    }
  }

  Future<ReturnRepository> getUserProfileData(String id) async {
    try {
      _apiService.sendLog("GetProfileData");
      final String authToken = await _fireBaseService.getAuthToken();
      final m.User? res = await _apiService.getUserProfile(id, authToken);
      if (res == null) {
        return ReturnRepository.failed(message: '');
      }
      return ReturnRepository.success(data: {'user': res});
    } catch (e) {
      print(e);
      return ReturnRepository.failed(message: '');
    }
  }

  Future<ReturnRepository> addFriend(String friendId) async {
    try {
      _apiService.sendLog("Add Friend");
      final String authToken = await _fireBaseService.getAuthToken();
      await _apiService.addFriend(friendId, authToken);

      return ReturnRepository.success();
    } catch (e) {
      print(e);
      return ReturnRepository.failed(message: '');
    }
  }

  Future<ReturnRepository> removeFriend(String friendId) async {
    try {
      _apiService.sendLog("RemoveFriend");
      final String authToken = await _fireBaseService.getAuthToken();
      await _apiService.removeFriend(friendId, authToken);

      return ReturnRepository.success();
    } catch (e) {
      print(e);
      return ReturnRepository.failed(message: '');
    }
  }

  Future<ReturnRepository> linkToGoogle() async {
    final res = await _fireBaseService.linkToGoogle();
    if (res == false) {
      return ReturnRepository.failed(message: 'Account link failed');
    }
    return ReturnRepository.success();
  }
}
