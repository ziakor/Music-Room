import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:music_room/src/data/model/_room.dart';
import 'package:music_room/src/data/model/_user.dart' as m;
import 'package:music_room/src/data/model/playlist.dart';
import 'package:music_room/src/data/model/user_firestore.dart';

abstract class AuthError implements Exception {
  const AuthError();
}

class ServerError implements Exception {
  const ServerError({this.message = "Server error"});

  final String message;
}

class SignupFailure extends AuthError {
  const SignupFailure({required this.message});
  final String message;
}

class SigninFailure extends AuthError {
  final String message;

  SigninFailure(this.message);
}

class FirebaseService {
  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;
  final GoogleSignIn _googleSignIn;
  final FacebookAuth _facebokSignIn;

  FirebaseService(
      this._auth, this._firestore, this._googleSignIn, this._facebokSignIn);

  Future<String?> signupWithEmailAndPassword(
    String email,
    String password,
  ) async {
    try {
      UserCredential userCredential = await _auth
          .createUserWithEmailAndPassword(email: email, password: password);
      await userCredential.user!.sendEmailVerification();
      return (userCredential.user!.uid);
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        throw SignupFailure(message: 'The password provided is too weak.');
      } else if (e.code == 'email-already-in-use') {
        throw SignupFailure(
            message: 'This e-mail address has already been used!');
      }
    } catch (e) {
      throw ServerError(message: 'Error happened, try again');
    }
  }

  Future<bool> linkToGoogle() async {
    try {
      //get currently logged in user
      final existingUser = _auth.currentUser!;
      //get the credentials of the new linking account
      final GoogleSignInAccount? googleSignInAccount =
          await _googleSignIn.signIn();
      final GoogleSignInAuthentication googleSignInAuthentication =
          await googleSignInAccount!.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleSignInAuthentication.accessToken,
        idToken: googleSignInAuthentication.idToken,
      );

      //now link these credentials with the existing user
      final linkauthresult = await existingUser.linkWithCredential(credential);
      return true;
    } catch (e) {
      print(e);
      return false;
    }
  }

  Future<UserCredential?> signinWithEmailAndPassword(
    String email,
    String password,
  ) async {
    try {
      final authUser = await _auth.signInWithEmailAndPassword(
          email: email, password: password);
      if (authUser.user!.emailVerified == false) {
        throw FirebaseAuthException(code: 'mail-not-verified');
      }
      final credential =
          EmailAuthProvider.credential(email: email, password: password);
      final UserCredential user = await _auth.signInWithCredential(credential);
      return (user);
    } on FirebaseAuthException catch (e) {
      print(e);

      if (e.code == 'user-not-found') {
        throw (SigninFailure('No user found for that email.'));
      } else if (e.code == 'wrong-password') {
        throw (SigninFailure('Wrong password provided for that user.'));
      } else if (e.code == 'mail-not-verified') {
        throw (SigninFailure('mail-not-verified'));
      }
    } catch (e) {
      print(e);
      throw (ServerError(message: "Server error, try again."));
    }
  }

  Future<bool> createFirestoreUser(
    String uid,
    Map<String, dynamic> data,
  ) async {
    try {
      CollectionReference users = _firestore.collection('Users');
      DocumentSnapshot docReference = await users.doc(uid).get();
      if (!docReference.exists) {
        await users.doc(uid).set(data);
        return (true);
      }
      return (false);
    } catch (e) {
      return (false);
    }
  }

  Future<bool> updateUserFirestore(
      String uid, Map<String, dynamic> data, bool merge) async {
    try {
      if (uid.isEmpty) throw Exception();
      CollectionReference users = _firestore.collection('Users');

      await users.doc(uid).set(data, SetOptions(merge: merge));
      return (true);
    } catch (e) {
      return (false);
    }
  }

  Future<List<String>> getUserAuthMethodWithEmail(String email) async {
    return (await _auth.fetchSignInMethodsForEmail(email));
  }

  Future<bool> reauthenticateWithCredential(List<String> signinMethods,
      String email, String password, String accessToken, String idToken) async {
    AuthCredential credential;
    if (signinMethods.contains('password')) {
      credential =
          EmailAuthProvider.credential(email: email, password: password);
    } else if (signinMethods.contains('google.com')) {
      final GoogleSignInAccount? googleSignInAccount =
          await _googleSignIn.signIn();
      if (googleSignInAccount == null) {
        return (false);
      }
      final GoogleSignInAuthentication googleSignInAuthentication =
          await googleSignInAccount.authentication;
      credential = GoogleAuthProvider.credential(
          idToken: googleSignInAuthentication.idToken,
          accessToken: googleSignInAuthentication.accessToken);
    } else if (signinMethods.contains('facebook.com')) {
      final LoginResult result = await _facebokSignIn.login();
      credential = FacebookAuthProvider.credential(result.accessToken!.token);
    } else {
      return (false);
    }
    await _auth.currentUser!.reauthenticateWithCredential(credential);
    return (true);
  }

  Future<bool> updateUserAuth(String uid, String email, String? newEmail,
      String currentPassword, String? newPassword) async {
    if (newEmail != null) {
      await _auth.currentUser!.updateEmail(newEmail);
    }
    if (newPassword != null) {
      await _auth.currentUser!.updatePassword(newPassword);
    }
    return (true);
  }

  Future<Map?> signWithGoogle() async {
    try {
      final GoogleSignInAccount? googleSignInAccount =
          await _googleSignIn.signIn();
      final GoogleSignInAuthentication googleSignInAuthentication =
          await googleSignInAccount!.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleSignInAuthentication.accessToken,
        idToken: googleSignInAuthentication.idToken,
      );

      final UserCredential user = await _auth.signInWithCredential(credential);

      return ({"pseudo": user.user!.displayName, "uid": user.user!.uid});
    } catch (e) {
      throw SignupFailure(message: 'Error happened, try again');
    }
  }

  Future<Map?> signWithFacebook() async {
    try {
      final LoginResult result = await _facebokSignIn.login();

      if (result.status == LoginStatus.success) {
        final OAuthCredential credential =
            FacebookAuthProvider.credential(result.accessToken!.token);
        final user = await _auth.signInWithCredential(credential);

        return ({"uid": user.user!.uid, "pseudo": user.user!.displayName});
      }
      return (null);
    } catch (e) {
      throw SignupFailure(message: 'Error happened, try again');
    }
  }

  Future<Map?> getFirestoreUserFromPseudo(String pseudo) async {
    try {
      final user = await _firestore
          .collection('Users')
          .where("pseudo", isEqualTo: pseudo)
          .get();
      return (user.size == 1 ? user.docs[0].data() : null);
    } catch (e) {
      throw ServerError();
    }
  }

  Future<UserFirestore?> getFirestoreUserFromId(String id) async {
    final user = await _firestore
        .collection('Users')
        .doc(id)
        .get()
        .then((value) => value.data());
    return (user != null ? UserFirestore.fromMap(user) : null);
  }

  Future<void> sendVerificationEmail() async {
    try {
      _auth.currentUser!.sendEmailVerification();
    } catch (e) {
      throw ServerError(message: 'Error happened, try again');
    }
  }

  Stream<User?> onAuthStateChange() {
    return _auth.authStateChanges();
  }

  Future<void> logout() async {
    await _auth.signOut();
  }

  m.User toUser(User firebaseAuthUser) {
    return m.User(
      id: firebaseAuthUser.uid,
      email: firebaseAuthUser.email,
    );
  }

  User? currentUser() {
    return (_auth.currentUser);
  }

  Future<String> getAuthToken() async {
    return _auth.currentUser!.getIdToken();
  }

  Future<List> getAllRooms(bool private) async {
    try {
      final rooms = await _firestore
          .collection('Rooms')
          .where("private", isEqualTo: private)
          .get();
      final List list = List.from(rooms.docs.map((e) {
        Map list = e.data();
        list['id'] = e.id;
        list.remove('invitationCode');
        return (list);
      }));
      return (rooms.docs.isEmpty ? [] : list);
    } catch (e) {
      return ([]);
    }
  }

  Future<List> getAllPlaylist(bool private) async {
    try {
      final playlist = await _firestore
          .collection('Playlist')
          .where("private", isEqualTo: private)
          .get();
      final List list = List.from(
        playlist.docs.map(
          (e) {
            Map list = e.data();
            list['id'] = e.id;
            list.remove('invitationCode');
            return (list);
          },
        ),
      );
      return (playlist.docs.isEmpty ? [] : list);
    } catch (e) {
      return ([]);
    }
  }

  Future<String> createRoom(Map<String, dynamic> roomData) async {
    final _ref = _firestore.collection("Rooms");
    final doc = await _ref.add(roomData);

    return (doc.id);
  }

  Future<String> createPlaylist(Map<String, dynamic> playlistData) async {
    final _ref = _firestore.collection("Playlist");
    final newPlaylist = await _ref.add(playlistData);
    return (newPlaylist.id);
  }

  Future<bool> updatePlaylist(
      String id, Map<String, dynamic> playlistData, bool merge) async {
    if (id.isEmpty) throw Exception("Wrong playlist id.");
    CollectionReference playlist = _firestore.collection("Playlist");
    await playlist.doc(id).set(playlistData, SetOptions(merge: merge));
    return (true);
  }

  Future<bool> updateRoom(
      String id, Map<String, dynamic> roomData, bool merge) async {
    if (id.isEmpty) throw Exception("Wrong room id.");
    CollectionReference room = _firestore.collection("Rooms");
    await room.doc(id).set(roomData, SetOptions(merge: merge));
    return (true);
  }

  Future<Playlist?> getPlaylistData(String id) async {
    final _ref = await _firestore.collection('Playlist').doc(id).get();
    final data = _ref.data();
    if (data == null) return (null);
    return (Playlist(invitationCode: data['invitationCode']));
  }

  Future<Playlist?> getRoomData(String id) async {
    final _ref = await _firestore.collection('Rooms').doc(id).get();
    final data = _ref.data();
    if (data == null) return (null);
    return (Playlist(invitationCode: data['invitationCode']));
  }

  Future<Room?> getRoomDataWhereMatch(String code, String field) async {
    final _ref = await _firestore
        .collection('Rooms')
        .where(field, isEqualTo: code)
        .get();
    if (_ref.docs.isEmpty == true) return (null);
    Map<String, dynamic> room = _ref.docs[0].data();
    room['id'] = _ref.docs[0].id;
    return (Room.fromMap(room));
  }

  Future<Playlist?> getPlaylistDataWhereMatch(String code, String field) async {
    final _ref = await _firestore
        .collection('Playlist')
        .where(field, isEqualTo: code)
        .get();
    if (_ref.docs.isEmpty == true) return (null);
    Map<String, dynamic> playlist = _ref.docs[0].data();
    playlist['id'] = _ref.docs[0].id;
    return (Playlist.fromMap(playlist));
  }
}
