import 'dart:math';

import 'package:flutter/material.dart';
import 'package:music_room/src/data/model/room_user.dart';
import 'package:music_room/src/ui/widgets/modal_dialog.dart';
import 'package:vrouter/src/core/extended_context.dart';

Map<String, dynamic> removeNullFieldOfMap(Map<String, dynamic> map) {
  map.removeWhere((key, value) => value == null);
  return map;
}

String getMessageErrorFromFirebaseAuthException(String errorCode) {
  switch (errorCode) {
    case "ERROR_EMAIL_ALREADY_IN_USE":
    case "account-exists-with-different-credential":
    case "email-already-in-use":
      return "Email already used. Go to login page.";
    case "ERROR_WRONG_PASSWORD":
    case "wrong-password":
      return "Wrong email/password combination.";
    case "ERROR_USER_NOT_FOUND":
    case "user-not-found":
      return "No user found with this email.";
    case "ERROR_USER_DISABLED":
    case "user-disabled":
      return "User disabled.";
    case "ERROR_TOO_MANY_REQUESTS":
    case "operation-not-allowed":
      return "Too many requests to log into this account.";
    case "ERROR_OPERATION_NOT_ALLOWED":
      return "Server error, please try again later.";
    case "ERROR_INVALID_EMAIL":
    case "invalid-email":
      return "Email address is invalid.";
    default:
      return "Login failed. Please try again.";
  }
}

RoomUser getRoomUser(List<RoomUser> list, String myUid, bool isInvited) {
  final RoomUser user = list.firstWhere((element) => element.id == myUid,
      orElse: () =>
          RoomUser(id: '', pseudo: '', role: '', isInvited: isInvited));
  return (user);
}

String getRandomString(int length) {
  const _chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890';
  Random _rnd = Random();
  return (String.fromCharCodes(
    Iterable.generate(
      length,
      (_) => _chars.codeUnitAt(_rnd.nextInt(_chars.length)),
    ),
  ));
}

Future<void> confirmBeforeLeave(
  BuildContext context,
  String title,
  String body,
  void Function()? onYes,
  void Function()? onNo,
) async {
  modalDialog(
      context,
      Center(
        child: Text(
          title,
          style: TextStyle(color: Colors.white),
        ),
      ),
      SingleChildScrollView(
        child: Text(
          body,
          style: TextStyle(color: Colors.white, fontSize: 15),
        ),
      ),
      [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 45,
              child: OutlinedButton(
                key: Key("YesAlert"),
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all(Colors.white10),
                  shape: MaterialStateProperty.all(RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30.0))),
                ),
                onPressed: onYes,
                child: const Text("Yes", style: TextStyle(color: Colors.white)),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 8.0),
              child: Container(
                width: 80,
                height: 45,
                child: OutlinedButton(
                  key: Key("NoAlert"),
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all(Colors.white10),
                    shape: MaterialStateProperty.all(RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30.0))),
                  ),
                  onPressed: onNo,
                  child:
                      const Text("No", style: TextStyle(color: Colors.white)),
                ),
              ),
            ),
          ],
        ),
      ],
      true,
      backgroundColors: Colors.black87);
}
