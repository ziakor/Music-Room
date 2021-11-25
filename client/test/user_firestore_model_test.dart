import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:music_room/src/data/model/user_firestore.dart';

void main() {
  test('fromMap', () {
    Map<String, dynamic> data = {
      "pseudo": "pseudoTest",
      "gender": "Man",
      "birth": Timestamp(0, 2),
      "code": "codeTest",
      "messengerIds": [],
      "bio": "bioTest",
      "musicalInterests": ["Rap, Pop"],
    };
    expect(
        UserFirestore.fromMap(data),
        UserFirestore(
          gender: "Man",
          pseudo: "pseudoTest",
          birth: Timestamp(0, 2),
          code: "codeTest",
          messengerIds: [],
          bio: "bioTest",
          musicalInterests: ["Rap, Pop"],
        ));
  });
}
