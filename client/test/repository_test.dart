import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_sign_in_mocks/google_sign_in_mocks.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:music_room/src/data/model/return_repository.dart';
import 'package:music_room/src/data/model/_user.dart' as m;
import 'package:music_room/src/data/model/user_firestore.dart';
import 'package:music_room/src/data/repository/user_repository.dart';
import 'package:music_room/src/data/service/api_service.dart';
import 'package:music_room/src/data/service/firebase_service.dart';
import 'mocks/api_service_mock.dart';
import 'mocks/facebook_auth_mock.dart';
import 'mocks/firebase_service.mock.dart';

// @GenerateMocks([FirebaseService])
void main() {
  final mockFirebaseService = MockFirebaseService();
  final MockApiService mockApiService = MockApiService();
  final UserRepository repository =
      UserRepository(mockFirebaseService, mockApiService);

  group("checkPseudoAvailable", () {
    test("pseudo is available", () async {
      when(mockFirebaseService.getFirestoreUserFromPseudo(any))
          .thenAnswer((_) async => {"uid": "someUid"});
      expect(await repository.checkPseudoAvailable("ziakor"), false);
    });

    test("pseudo is not available", () async {
      when(mockFirebaseService.getFirestoreUserFromPseudo(any))
          .thenAnswer((_) async => null);
      expect(await repository.checkPseudoAvailable("ziakor"), true);
    });

    test("throw ServerError", () async {
      when(mockFirebaseService.getFirestoreUserFromPseudo(any))
          .thenThrow(ServerError());
      expect(() async => await repository.checkPseudoAvailable("ziakor"),
          throwsA(isA<ServerError>()));
    });
  });

  group('signupWithEmailAndPassword', () {
    test('should create account', () async {
      String email = "dimitrihauet@gmail.com";
      String password = "ZAazerty59@";
      String pseudo = "ziakor";
      String gender = "Man";
      DateTime birth = DateTime.now();

      String expectResult = "uidSignin";
      when(mockFirebaseService.signupWithEmailAndPassword(any, any))
          .thenAnswer((realInvocation) async => "uidSignin");
      when(mockFirebaseService.createFirestoreUser(any, any))
          .thenAnswer((realInvocation) async => true);
      expect(
          await repository.signupWithEmailAndPassword(
              email, password, pseudo, gender, birth),
          expectResult);
    });

    test('should not create account', () async {
      String email = "dimitrihauet@gmail.com";
      String password = "ZAazerty59@";
      String pseudo = "ziakor";
      String gender = "Man";
      DateTime birth = DateTime.now();

      final expectResult = null;
      when(mockFirebaseService.signupWithEmailAndPassword(any, any))
          .thenAnswer((realInvocation) async => null);

      expect(
          await repository.signupWithEmailAndPassword(
              email, password, pseudo, gender, birth),
          expectResult);
      verifyNever(mockFirebaseService.updateUserFirestore(any, any, any));
    });
    test('should throw a SignupFailure error', () async {
      String email = "dimitrihauet@gmail.com";
      String password = "ZAazerty59@";
      String pseudo = "ziakor";
      String gender = "Man";
      DateTime birth = DateTime.now();

      when(mockFirebaseService.signupWithEmailAndPassword(any, any))
          .thenThrow(SignupFailure(message: "Error happened, try again"));
      expect(
          () async => await repository.signupWithEmailAndPassword(
              email, password, pseudo, gender, birth),
          throwsA(isA<SignupFailure>()));
      verifyNever(mockFirebaseService.updateUserFirestore(any, any, any));
    });
    test('should throw ServerError', () async {
      String email = "dimitrihauet@gmail.com";
      String password = "ZAazerty59@";
      String pseudo = "ziakor";
      String gender = "Man";
      DateTime birth = DateTime.now();

      when(mockFirebaseService.getFirestoreUserFromPseudo(any))
          .thenThrow(ServerError());
      expect(() async => await repository.checkPseudoAvailable("ziakor"),
          throwsA(isA<ServerError>()));
      when(mockFirebaseService.signupWithEmailAndPassword(any, any))
          .thenThrow(ServerError());
      expect(
          () async => await repository.signupWithEmailAndPassword(
              email, password, pseudo, gender, birth),
          throwsA(isA<ServerError>()));
      verifyNever(mockFirebaseService.updateUserFirestore(any, any, any));
    });
  });

  group('signupWithGoogle', () {
    test('should  create account', () async {
      when(mockFirebaseService.signWithGoogle()).thenAnswer(
          (realInvocation) async => {"pseudo": "ziakor", "uid": "someUid"});
      when(mockFirebaseService.createFirestoreUser(any, any))
          .thenAnswer((realInvocation) async => true);
      await repository.signupWithGoogle();
      verify(mockFirebaseService.signWithGoogle()).called(1);
    });
    test('should not  create account', () async {
      when(mockFirebaseService.signWithGoogle())
          .thenAnswer((realInvocation) async => null);
      await repository.signupWithGoogle();
      verify(mockFirebaseService.signWithGoogle()).called(1);
    });
    test('should throw an error', () {
      when(mockFirebaseService.signWithGoogle())
          .thenThrow(SignupFailure(message: "error"));

      expect(() async => await repository.signupWithGoogle(),
          throwsA(isA<SignupFailure>()));
      verify(mockFirebaseService.signWithGoogle()).called(1);
    });
  });
  group('signupWithFacebook', () {
    test('should create an account', () async {
      when(mockFirebaseService.signWithFacebook()).thenAnswer(
          (realInvocation) async => {"pseudo": "ziakor", "uid": "someUid"});
      when(mockFirebaseService.createFirestoreUser(any, any))
          .thenAnswer((realInvocation) async => true);
      await repository.signupWithFacebook();
      verify(mockFirebaseService.signWithFacebook()).called(1);
    });
    test('should not create an account', () async {
      when(mockFirebaseService.signWithFacebook())
          .thenAnswer((realInvocation) async => null);
      await repository.signupWithFacebook();
      verify(mockFirebaseService.signWithFacebook()).called(1);
    });
    test('should throw an error', () async {
      when(mockFirebaseService.signWithFacebook())
          .thenThrow(SignupFailure(message: "error"));
      expect(() async => await repository.signupWithFacebook(),
          throwsA(isA<SignupFailure>()));
      verify(mockFirebaseService.signWithFacebook()).called(1);
    });
  });

  group('signinWithEmailAndPassword', () {
    test('should not throw an error', () async {
      when(mockFirebaseService.signinWithEmailAndPassword(
              argThat(isA<String>()), argThat(isA<String>())))
          .thenAnswer((realInvocation) async => null);
      expect(
          () async => await repository.signinWithEmailAndPassword(
              "dimitrihauet@gmail.com", "ZAazerty59@"),
          returnsNormally);
      verify(mockFirebaseService.signinWithEmailAndPassword(
              argThat(isA<String>()), argThat(isA<String>())))
          .called(1);
      verifyNever(mockFirebaseService.updateUserFirestore(any, any, any));
    });
    test('should  throw an error', () async {
      when(mockFirebaseService.signinWithEmailAndPassword(
              argThat(isA<String>()), argThat(isA<String>())))
          .thenThrow(ServerError());
      expect(
          () async => await repository.signinWithEmailAndPassword(
              "dimitrihauet@gmail.com", "ZAazerty59@"),
          throwsA(isA<ServerError>()));
      verify(mockFirebaseService.signinWithEmailAndPassword(
              argThat(isA<String>()), argThat(isA<String>())))
          .called(1);
      verifyNever(mockFirebaseService.updateUserFirestore(any, any, any));
    });
  });
  group('resendEmailVerificationAccount', () {
    test(
        'should call firebaseService.resendEmailVerificationAccount with success',
        () async {
      when(mockFirebaseService.sendVerificationEmail())
          .thenAnswer((realInvocation) async => null);

      expect(() async => await repository.resendEmailVerificationAccount(),
          returnsNormally);
      verify(mockFirebaseService.sendVerificationEmail()).called(1);
    });

    test('should throw an error', () async {
      when(mockFirebaseService.sendVerificationEmail())
          .thenThrow(ServerError());

      expect(() async => await repository.resendEmailVerificationAccount(),
          throwsA(isA<ServerError>()));
      verify(mockFirebaseService.sendVerificationEmail()).called(1);
    });
  });

  group('get user', () {
    test('should return a user', () {
      final FakeFirebaseFirestore firestore = FakeFirebaseFirestore();
      final FirebaseAuth mockAuth = MockFirebaseAuth(
          signedIn: true, mockUser: MockUser(email: "dimitrihauet@gmail.com"));
      final googleSignIn = MockGoogleSignIn();
      final facebookSignIn = MockFacebookAuth();
      final FirebaseService firebaseService =
          FirebaseService(mockAuth, firestore, googleSignIn, facebookSignIn);

      UserRepository repository =
          UserRepository(firebaseService, mockApiService);
      final user = repository.user;
      int i = 0;
      final expected = [
        m.User(
          id: "some_random_id",
          pseudo: null,
          email: "dimitrihauet@gmail.com",
        ),
        m.User.empty,
      ];

      user.listen((event) {
        expect(event, expected[i]);
        i++;
      });
      mockAuth.signOut();
    });
  });

  group('currentUser', () {
    test('should return a user', () {
      final FakeFirebaseFirestore firestore = FakeFirebaseFirestore();
      final FirebaseAuth mockAuth = MockFirebaseAuth(
          signedIn: true, mockUser: MockUser(email: "dimitrihauet@gmail.com"));
      final googleSignIn = MockGoogleSignIn();
      final facebookSignIn = MockFacebookAuth();
      final FirebaseService firebaseService =
          FirebaseService(mockAuth, firestore, googleSignIn, facebookSignIn);

      UserRepository repository =
          UserRepository(firebaseService, mockApiService);

      expect(
          repository.currentUser,
          m.User(
              id: "some_random_id",
              pseudo: null,
              email: "dimitrihauet@gmail.com"));
    });
    test('should return an empty user', () {
      final FakeFirebaseFirestore firestore = FakeFirebaseFirestore();
      final FirebaseAuth mockAuth = MockFirebaseAuth();
      final googleSignIn = MockGoogleSignIn();
      final facebookSignIn = MockFacebookAuth();
      final FirebaseService firebaseService =
          FirebaseService(mockAuth, firestore, googleSignIn, facebookSignIn);

      UserRepository repository =
          UserRepository(firebaseService, mockApiService);

      expect(repository.currentUser, m.User.empty);
    });
  });

  group('resetPasswordCode', () {
    test('should not throw an error', () async {
      final String email = "dimitrihauet@gmail.com";
      when(mockApiService.forgetPasswordCode("dimitrihauet@gmail.com"))
          .thenAnswer((realInvocation) async => null);
      expect(() async => await repository.resetPasswordCode(email),
          returnsNormally);
    });
    test('should  throw an error', () async {
      final String email = "dimitrihauet@gmail.com";
      when(mockApiService.forgetPasswordCode("dimitrihauet@gmail.com"))
          .thenThrow(ServerError());

      expect(() async => await repository.resetPasswordCode(email),
          throwsA(isA<ServerError>()));
    });
  });

  group('resetPassword', () {
    test('should not throw an error', () async {
      final String email = "dimitrihauet@gmail.com";
      final String password = "ZAazerrty59@";
      final String code = "165a4sd";
      when(mockApiService.forgetPasswordUpdate(email, password, code))
          .thenAnswer((realInvocation) async => null);
      expect(() async => await repository.resetPassword(email, password, code),
          returnsNormally);
    });
    test('should  throw an error', () async {
      final String email = "dimitrihauet@gmail.com";
      final String password = "ZAazerrty59@";
      final String code = "165a4sd";
      when(mockApiService.forgetPasswordUpdate(email, password, code))
          .thenThrow(ServerError());

      expect(() async => await repository.resetPasswordCode(email),
          throwsA(isA<ServerError>()));
    });
  });

  group('logout', () {
    test('should return normally', () async {
      when(mockFirebaseService.logout())
          .thenAnswer((realInvocation) async => {});
      expect(() async => await repository.logoutUser(), returnsNormally);
    });
  });

  group('getFirestoreUserDataFromId', () {
    test('should return a UserFirestore', () async {
      when(mockFirebaseService.getFirestoreUserFromId(argThat(isA<String>())))
          .thenAnswer((realInvocation) async =>
              UserFirestore(birth: Timestamp.fromDate(DateTime(2022))));

      expect(await repository.getFirestoreUserDataFromId(''),
          UserFirestore(birth: Timestamp.fromDate(DateTime(2022))));
    });

    test('should return null', () async {
      when(mockFirebaseService.getFirestoreUserFromId(argThat(isA<String>())))
          .thenAnswer((realInvocation) async => null);

      expect(await repository.getFirestoreUserDataFromId(''), null);
    });
  });

  group('updateUser', () {
    test('should update user and return true', () async {
      when(mockFirebaseService.currentUser())
          .thenReturn(MockUser(uid: 'some-uid', email: "test@gmail.com"));
      when(mockFirebaseService.updateUserFirestore(any, any, any))
          .thenAnswer((realInvocation) async => true);
      when(mockFirebaseService.getUserAuthMethodWithEmail(any))
          .thenAnswer((realInvocation) async => ['password']);
      when(mockFirebaseService.reauthenticateWithCredential(
              any, any, any, any, any))
          .thenAnswer((realInvocation) async => true);
      when(mockFirebaseService.updateUserAuth(any, any, any, any, any))
          .thenAnswer((realInvocation) async => true);
      final ReturnRepository res = await repository.updateUser(
          bio: 'qwdqwdqwd',
          birth: null,
          currentPassword: 'qwdqwd',
          email: 'qwdqwd',
          gender: 'qwdqwd',
          musicalInterests: [],
          password: 'qwdqwd',
          pseudo: 'qwdqwdq');
      expect(res.status, true);
    });
    test('should failed to update auth user and return false', () async {
      when(mockFirebaseService.currentUser())
          .thenReturn(MockUser(uid: 'some-uid', email: "test@gmail.com"));
      when(mockFirebaseService.updateUserFirestore(any, any, any))
          .thenAnswer((realInvocation) async => true);
      when(mockFirebaseService.getUserAuthMethodWithEmail(any))
          .thenAnswer((realInvocation) async => ['password']);
      when(mockFirebaseService.reauthenticateWithCredential(
              any, any, any, any, any))
          .thenAnswer((realInvocation) async => true);
      when(mockFirebaseService.updateUserAuth(any, any, any, any, any))
          .thenAnswer((realInvocation) async => false);
      final ReturnRepository res = await repository.updateUser(
          bio: 'qwdqwdqwd',
          birth: null,
          currentPassword: 'qwdqwd',
          email: 'qwdqwd',
          gender: 'qwdqwd',
          musicalInterests: [],
          password: 'qwdqwd',
          pseudo: 'qwdqwdq');
      expect(res.status, false);
    });
    test('should return false because FirebaseAuthException', () async {
      when(mockFirebaseService.currentUser())
          .thenReturn(MockUser(uid: 'some-uid', email: "test@gmail.com"));
      when(mockFirebaseService.updateUserFirestore(any, any, any))
          .thenAnswer((realInvocation) async => true);
      when(mockFirebaseService.getUserAuthMethodWithEmail(any))
          .thenAnswer((realInvocation) async => ['password']);
      when(mockFirebaseService.reauthenticateWithCredential(
              any, any, any, any, any))
          .thenAnswer((realInvocation) async => true);
      when(mockFirebaseService.updateUserAuth(any, any, any, any, any))
          .thenThrow(FirebaseAuthException(code: 'user-not-found'));
      final ReturnRepository res = await repository.updateUser(
          bio: 'qwdqwdqwd',
          birth: null,
          currentPassword: 'qwdqwd',
          email: 'qwdqwd',
          gender: 'qwdqwd',
          musicalInterests: [],
          password: 'qwdqwd',
          pseudo: 'qwdqwdq');
      expect(res.status, false);
    });
    test('should return false because Exception', () async {
      when(mockFirebaseService.currentUser())
          .thenReturn(MockUser(uid: 'some-uid', email: "test@gmail.com"));
      when(mockFirebaseService.updateUserFirestore(any, any, any))
          .thenAnswer((realInvocation) async => true);
      when(mockFirebaseService.getUserAuthMethodWithEmail(any))
          .thenAnswer((realInvocation) async => ['password']);
      when(mockFirebaseService.reauthenticateWithCredential(
              any, any, any, any, any))
          .thenAnswer((realInvocation) async => true);
      when(mockFirebaseService.updateUserAuth(any, any, any, any, any))
          .thenThrow(Exception());
      final ReturnRepository res = await repository.updateUser(
          bio: 'qwdqwdqwd',
          birth: null,
          currentPassword: 'qwdqwd',
          email: 'qwdqwd',
          gender: 'qwdqwd',
          musicalInterests: [],
          password: 'qwdqwd',
          pseudo: 'qwdqwdq');
      expect(res.status, false);
    });
  });
}
