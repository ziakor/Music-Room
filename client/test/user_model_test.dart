import 'package:flutter_test/flutter_test.dart';
import 'package:music_room/src/data/model/_user.dart';

void main() {
  group('user empty', () {
    test('should be empty ??', () {
      expect(User.empty, User(id: ""));
    });
    test('isEmpty should return false', () {
      expect(
          User(
                  id: "some_random_id",
                  pseudo: "ziakor",
                  email: "dimitrihauet@gmail.com")
              .isEmpty,
          false);
    });
    test('isEmpty should return true', () {
      expect(User(id: "").isEmpty, true);
    });

    test('isNotEmpty should return true', () {
      expect(User(id: '').isNotEmpty, false);
    });
    test('isNotEmpty should return true', () {
      expect(
          User(
                  id: "some_random_id",
                  pseudo: "ziakor",
                  email: "dimitrihauet@gmail.com")
              .isNotEmpty,
          true);
    });

    test('copyWith should not updated any value', () {
      User user = User(
          id: "some_random_id",
          pseudo: "testPseudo",
          email: "test@gmail.com",
          bio: "bioTest",
          birth: DateTime(2011),
          gender: "Man",
          musicalInterests: ['Rap']);
      expect(
          user.copyWith(),
          User(
            id: "some_random_id",
            pseudo: "testPseudo",
            email: "test@gmail.com",
            bio: "bioTest",
            birth: DateTime(2011),
            gender: "Man",
            musicalInterests: ['Rap'],
          ));
    });

    test('copyWith should update all value', () {
      User user = User(
          id: "some_random_id",
          pseudo: "testPseudo",
          email: "test@gmail.com",
          bio: "bioTest",
          birth: DateTime(2011),
          gender: "Man",
          musicalInterests: ['Rap']);
      expect(
          user.copyWith(
            id: "some_random_id1",
            pseudo: "testPseudo1",
            email: "test@gmail.com1",
            bio: "bioTest1",
            birth: DateTime(2012),
            gender: "Man1",
            musicalInterests: ['Rap', 'Pop'],
          ),
          User(
            id: "some_random_id1",
            pseudo: "testPseudo1",
            email: "test@gmail.com1",
            bio: "bioTest1",
            birth: DateTime(2012),
            gender: "Man1",
            musicalInterests: ['Rap', 'Pop'],
          ));
    });
  });
}
