import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_sign_in_mocks/google_sign_in_mocks.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:music_room/src/data/service/firebase_service.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart' as fa;
import 'mocks/facebook_auth_mock.dart';
import 'mocks/firebase_auth_mock.dart';
import 'mocks/firebase_firestore_mock.dart';
import 'mocks/mock.dart';
import 'package:firebase_auth_mocks/src/mock_user_credential.dart';
import 'package:music_room/src/data/model/_user.dart' as m;

@GenerateMocks([User])
void main() {
  group('FirebaseService', () {
    late MockGoogleSignIn googleSignIn;
    late MockFirebaseAuth auth;
    late FacebookAuth facebookSignIn;
    setupFirebaseAuthMocks();
    setUp(() {
      googleSignIn = MockGoogleSignIn();
      facebookSignIn = MockFacebookAuth();
      auth = MockFirebaseAuth();
    });
    setUpAll(() async {
      await Firebase.initializeApp();
    });
    group('updateUserFirestore', () {
      test('add a data with success', () async {
        final FakeFirebaseFirestore firestore = FakeFirebaseFirestore();
        await firestore.collection('Users').doc('123456').set({
          "pseudo": "ziakor",
          "gender": "Man",
          "code": "",
          "messengerIds": [],
          "bio": "ziakor",
          "birth": Timestamp.fromDate(DateTime(1993))
        });

        final FirebaseService firebaseService =
            FirebaseService(auth, firestore, googleSignIn, facebookSignIn);

        expect(
            await firebaseService.updateUserFirestore(
                "123456", {"pseudo": "salsifiTif"}, true),
            true);
      });
      test('throw an error', () async {
        final FakeFirebaseFirestore firestore = FakeFirebaseFirestore();

        final FirebaseService firebaseService =
            FirebaseService(auth, firestore, googleSignIn, facebookSignIn);

        expect(
            await firebaseService.updateUserFirestore(
                "", {"pseudo": "salsifiTif"}, true),
            false);
      });
    });
    group('getFirestoreUserFromPseudo', () {
      test('find data', () async {
        final FakeFirebaseFirestore firestore = FakeFirebaseFirestore();
        final FirebaseService firebaseService =
            FirebaseService(auth, firestore, googleSignIn, facebookSignIn);
        await firestore.collection('Users').doc('UidDoc').set({
          'pseudo': 'Bob',
        });
        final snapshot =
            await firebaseService.getFirestoreUserFromPseudo("Bob");
        expect(snapshot, isNot(null));
      });
      test('don\'t find data', () async {
        final FakeFirebaseFirestore firestore = FakeFirebaseFirestore();
        final FirebaseService firebaseService =
            FirebaseService(auth, firestore, googleSignIn, facebookSignIn);
        await firestore.collection('Users').doc('UidDoc').set({
          'pseudo': 'Bob',
        });
        final snapshot = await firebaseService.getFirestoreUserFromPseudo("");
        expect(snapshot, null);
      });
      test('throw error', () async {
        final MockFirebaseFirestore firestore = MockFirebaseFirestore();
        final FirebaseService firebaseService =
            FirebaseService(auth, firestore, googleSignIn, facebookSignIn);

        when(firestore.collection('Users')).thenThrow(ServerError());
        expect(() async => await firebaseService.getFirestoreUserFromPseudo(""),
            throwsA(isA<ServerError>()));
      });
    });
    group('signupWithEmailAndPassword', () {
      test('create an account successfully', () async {
        final FakeFirebaseFirestore firestore = FakeFirebaseFirestore();
        final FirebaseAuth mockAuth = MockFirebaseAuth();

        final FirebaseService firebaseService =
            FirebaseService(mockAuth, firestore, googleSignIn, facebookSignIn);

        final String email = "dimitrihauet@gmail.com";
        when(mockAuth.createUserWithEmailAndPassword(
                email: "dimitrihauet@gmail.com", password: "ZAazerty59"))
            .thenAnswer(
          (realInvocation) async => MockUserCredential(
            false,
            mockUser: fa.MockUser(
              email: email,
              displayName: "ziakor",
              uid: "some-uid",
            ),
          ),
        );

        final user = await firebaseService.signupWithEmailAndPassword(
            "dimitrihauet@gmail.com", "ZAazerty59");
        expect(user, isNot(null));
      });
      test('throw a server error', () async {
        final FakeFirebaseFirestore firestore = FakeFirebaseFirestore();
        final FirebaseAuth mockAuth = MockFirebaseAuth();

        final FirebaseService firebaseService =
            FirebaseService(mockAuth, firestore, googleSignIn, facebookSignIn);

        when(mockAuth.createUserWithEmailAndPassword(
                email: "dimitrihauet@gmail.com", password: "ZAazerty59"))
            .thenThrow(ServerError());

        expect(
            () async => await firebaseService.signupWithEmailAndPassword(
                "dimitrihauet@gmail.com", "ZAazerty59"),
            throwsA(isA<ServerError>()));
      });

      test('throw a signup error weak password', () async {
        final FakeFirebaseFirestore firestore = FakeFirebaseFirestore();
        final FirebaseAuth mockAuth = MockFirebaseAuth();

        final FirebaseService firebaseService =
            FirebaseService(mockAuth, firestore, googleSignIn, facebookSignIn);

        when(mockAuth.createUserWithEmailAndPassword(
                email: "dimitrihauet@gmail.com", password: "ZAazerty59"))
            .thenThrow(FirebaseAuthException(code: 'weak-password'));

        expect(
            () async => await firebaseService.signupWithEmailAndPassword(
                "dimitrihauet@gmail.com", "ZAazerty59"),
            throwsA(isA<SignupFailure>()));
      });

      test('throw a signup email-already-in-use', () async {
        final FakeFirebaseFirestore firestore = FakeFirebaseFirestore();
        final FirebaseAuth mockAuth = MockFirebaseAuth();

        final FirebaseService firebaseService =
            FirebaseService(mockAuth, firestore, googleSignIn, facebookSignIn);

        when(mockAuth.createUserWithEmailAndPassword(
                email: "dimitrihauet@gmail.com", password: "ZAazerty59"))
            .thenThrow(FirebaseAuthException(code: 'email-already-in-use'));

        expect(
            () async => await firebaseService.signupWithEmailAndPassword(
                "dimitrihauet@gmail.com", "ZAazerty59"),
            throwsA(isA<SignupFailure>()));
      });
    });

    group('signupWithGoogle', () {
      test('should return pseudo and uid', () async {
        final FakeFirebaseFirestore firestore = FakeFirebaseFirestore();
        final FirebaseService firebaseService = FirebaseService(
            fa.MockFirebaseAuth(), firestore, googleSignIn, facebookSignIn);
        final res = await firebaseService.signWithGoogle();
        expect(res, isNotNull);
      });
      test('should throw an error', () async {
        final FakeFirebaseFirestore firestore = FakeFirebaseFirestore();
        final FirebaseService firebaseService = FirebaseService(
            fa.MockFirebaseAuth(), firestore, googleSignIn, facebookSignIn);
        googleSignIn.setIsCancelled(true);

        expect(() async => await firebaseService.signWithGoogle(),
            throwsA(isA<SignupFailure>()));
      });
    });
    group('signupWithFacebook', () {
      final tUser = fa.MockUser(
        isAnonymous: false,
        uid: 'T3STU1D',
        email: 'bob@thebuilder.com',
        displayName: 'Bob Builder',
        phoneNumber: '0601050401',
        photoURL: 'http://photos.url/bobbie.jpg',
        refreshToken: 'some_long_token',
      );
      test('should return pseudo and uid', () async {
        final FakeFirebaseFirestore firestore = FakeFirebaseFirestore();
        final FirebaseService firebaseService = FirebaseService(
            fa.MockFirebaseAuth(mockUser: tUser, signedIn: true),
            firestore,
            googleSignIn,
            facebookSignIn);
        when(facebookSignIn.login())
            .thenAnswer((realInvocation) async => LoginResult(
                  status: LoginStatus.success,
                  accessToken: AccessToken(
                      applicationId: '',
                      declinedPermissions: [],
                      expires: DateTime.now(),
                      grantedPermissions: [],
                      isExpired: false,
                      lastRefresh: DateTime.now(),
                      token: '',
                      userId: ''),
                ));
        expect(await firebaseService.signWithFacebook(),
            {"pseudo": "Bob Builder", "uid": "T3STU1D"});
      });

      test('should throw an error', () {
        final FakeFirebaseFirestore firestore = FakeFirebaseFirestore();
        final MockFirebaseAuth _auth = MockFirebaseAuth();
        final FirebaseService firebaseService =
            FirebaseService(_auth, firestore, googleSignIn, facebookSignIn);
        when(facebookSignIn.login())
            .thenAnswer((realInvocation) async => LoginResult(
                  status: LoginStatus.success,
                  accessToken: AccessToken(
                      applicationId: '',
                      declinedPermissions: [],
                      expires: DateTime.now(),
                      grantedPermissions: [],
                      isExpired: false,
                      lastRefresh: DateTime.now(),
                      token: '',
                      userId: ''),
                ));
        when(_auth.signInWithCredential(any)).thenThrow(Exception());
        expect(() async => await firebaseService.signWithFacebook(),
            throwsA(isA<SignupFailure>()));
      });
    });

    group('signinWithEmailAndPassword', () {
      final tUser = fa.MockUser(
        isAnonymous: false,
        uid: 'T3STU1D',
        email: 'bob@thebuilder.com',
        displayName: 'Bob Builder',
        phoneNumber: '0601050401',
        photoURL: 'http://photos.url/bobbie.jpg',
        refreshToken: 'some_long_token',
      );
      test('should not throw an error', () async {
        final FakeFirebaseFirestore firestore = FakeFirebaseFirestore();
        final FirebaseService firebaseService = FirebaseService(
            fa.MockFirebaseAuth(mockUser: tUser),
            firestore,
            googleSignIn,
            facebookSignIn);
        firebaseService.signinWithEmailAndPassword("ziakor", "ZAazerty59@");
        expect(
            () async => await firebaseService.signinWithEmailAndPassword(
                "ziakor", "ZAazerty59@"),
            returnsNormally);
      });

      test('should not throw a server error', () async {
        final FakeFirebaseFirestore firestore = FakeFirebaseFirestore();
        final FirebaseAuth mockAuth = MockFirebaseAuth();

        final FirebaseService firebaseService =
            FirebaseService(mockAuth, firestore, googleSignIn, facebookSignIn);
        when(mockAuth.signInWithEmailAndPassword(
                email: "dimitrihauet@gmail.com", password: "ZAazerty59@"))
            .thenAnswer((realInvocation) async => MockUserCredential(false,
                mockUser: fa.MockUser(
                    email: "dimitrihauet@gmail.com", displayName: "ziakor")));
        expect(
            () async => await firebaseService.signinWithEmailAndPassword(
                "dimitrihauet@gmail.com", "ZAazerty59@"),
            returnsNormally);
      });
      test('should  throw a server error', () async {
        final FakeFirebaseFirestore firestore = FakeFirebaseFirestore();
        final FirebaseAuth mockAuth = MockFirebaseAuth();

        final FirebaseService firebaseService =
            FirebaseService(mockAuth, firestore, googleSignIn, facebookSignIn);
        when(mockAuth.signInWithEmailAndPassword(
                email: "dimitrihauet@gmail.com", password: "ZAazerty59@"))
            .thenThrow(ServerError());
        expect(
            () async => await firebaseService.signinWithEmailAndPassword(
                "dimitrihauet@gmail.com", "ZAazerty59@"),
            throwsA(isA<ServerError>()));
      });

      test('should  throw a LoginWithEmailAndPasswordError user not found',
          () async {
        final FakeFirebaseFirestore firestore = FakeFirebaseFirestore();
        final FirebaseAuth mockAuth = MockFirebaseAuth();

        final FirebaseService firebaseService =
            FirebaseService(mockAuth, firestore, googleSignIn, facebookSignIn);
        when(mockAuth.signInWithEmailAndPassword(
                email: "dimitrihauet@gmail.com", password: "ZAazerty59@"))
            .thenThrow(FirebaseAuthException(code: "user-not-found"));
        expect(
            () async => await firebaseService.signinWithEmailAndPassword(
                "dimitrihauet@gmail.com", "ZAazerty59@"),
            throwsA(isA<SigninFailure>()));
      });
      test('should  throw a LoginWithEmailAndPasswordError wrong password',
          () async {
        final FakeFirebaseFirestore firestore = FakeFirebaseFirestore();
        final FirebaseAuth mockAuth = MockFirebaseAuth();

        final FirebaseService firebaseService =
            FirebaseService(mockAuth, firestore, googleSignIn, facebookSignIn);
        when(mockAuth.signInWithEmailAndPassword(
                email: "dimitrihauet@gmail.com", password: "ZAazerty59@"))
            .thenThrow(FirebaseAuthException(code: "wrong-password"));
        expect(
            () async => await firebaseService.signinWithEmailAndPassword(
                "dimitrihauet@gmail.com", "ZAazerty59@"),
            throwsA(isA<SigninFailure>()));
      });

      test('should  get a user with email not verified', () async {
        final tUser = fa.MockUser(
          isAnonymous: false,
          uid: 'T3STU1D',
          email: 'bob@thebuilder.com',
          displayName: 'Bob Builder',
          phoneNumber: '0601050401',
          photoURL: 'http://photos.url/bobbie.jpg',
          isEmailVerified: false,
          refreshToken: 'some_long_token',
        );
        final FakeFirebaseFirestore firestore = FakeFirebaseFirestore();
        final FirebaseAuth mockAuth =
            fa.MockFirebaseAuth(mockUser: tUser, signedIn: false);

        final FirebaseService firebaseService =
            FirebaseService(mockAuth, firestore, googleSignIn, facebookSignIn);

        expect(
            () async => await firebaseService.signinWithEmailAndPassword(
                "dimitrihauet@gmail.com", "ZAazerty59@"),
            throwsA(isA<SigninFailure>()));
      });
    });
    group('sendVerificationEmail', () {
      test('should send email with success', () async {
        final FakeFirebaseFirestore firestore = FakeFirebaseFirestore();
        final FirebaseAuth mockAuth = fa.MockFirebaseAuth(
            signedIn: true,
            mockUser: fa.MockUser(email: "dimitrihauet@gmail.com"));

        final FirebaseService firebaseService =
            FirebaseService(mockAuth, firestore, googleSignIn, facebookSignIn);
        expect(() async => await firebaseService.sendVerificationEmail(),
            returnsNormally);
      });
      test('should throw a server error', () async {
        final FakeFirebaseFirestore firestore = FakeFirebaseFirestore();
        final FirebaseAuth mockAuth = fa.MockFirebaseAuth();
        final FirebaseService firebaseService =
            FirebaseService(mockAuth, firestore, googleSignIn, facebookSignIn);

        expect(() async => await firebaseService.sendVerificationEmail(),
            throwsA(isA<ServerError>()));
      });
    });

    group('currentUser', () {
      test('should return a Firebase user', () {
        final FakeFirebaseFirestore firestore = FakeFirebaseFirestore();
        final FirebaseAuth mockAuth = fa.MockFirebaseAuth(
            signedIn: true,
            mockUser: fa.MockUser(email: "dimitrihauet@gmail.com"));

        final FirebaseService firebaseService =
            FirebaseService(mockAuth, firestore, googleSignIn, facebookSignIn);

        expect(firebaseService.currentUser(),
            fa.MockUser(email: "dimitrihauet@gmail.com"));
      });
      test('should null', () {
        final FakeFirebaseFirestore firestore = FakeFirebaseFirestore();
        final FirebaseAuth mockAuth = fa.MockFirebaseAuth();

        final FirebaseService firebaseService =
            FirebaseService(mockAuth, firestore, googleSignIn, facebookSignIn);

        expect(firebaseService.currentUser(), null);
      });
    });
    group('toUser', () {
      test('should return id, email and pseudo of Firebase user', () {
        final FakeFirebaseFirestore firestore = FakeFirebaseFirestore();
        final FirebaseAuth mockAuth = fa.MockFirebaseAuth(
            signedIn: true,
            mockUser: fa.MockUser(email: "dimitrihauet@gmail.com"));

        final FirebaseService firebaseService =
            FirebaseService(mockAuth, firestore, googleSignIn, facebookSignIn);

        expect(
            firebaseService
                .toUser(fa.MockUser(email: "dimitrihauet@gmail.com")),
            m.User(
                id: "some_random_id",
                pseudo: null,
                email: "dimitrihauet@gmail.com"));
      });
    });
    group('onAuthStateChange', () {
      test('should return User', () {
        final FakeFirebaseFirestore firestore = FakeFirebaseFirestore();
        final FirebaseAuth mockAuth = fa.MockFirebaseAuth(signedIn: false);

        final FirebaseService firebaseService =
            FirebaseService(mockAuth, firestore, googleSignIn, facebookSignIn);

        firebaseService.onAuthStateChange().listen((event) {
          expect(event, isNotNull);
        });

        mockAuth.signInWithEmailAndPassword(
            email: "dimitrihauet@gmail.com", password: "ZAazerty59");
      });
    });

    group('getUserAuthMethodWithEmail', () {
      test('should return empty list', () async {
        final FakeFirebaseFirestore firestore = FakeFirebaseFirestore();
        final FirebaseAuth mockAuth = MockFirebaseAuth();

        final FirebaseService firebaseService =
            FirebaseService(mockAuth, firestore, googleSignIn, facebookSignIn);
        when(mockAuth.fetchSignInMethodsForEmail("test@gmail.com"))
            .thenAnswer((realInvocation) async => ["password"]);

        final res =
            await firebaseService.getUserAuthMethodWithEmail("test@gmail.com");
        expect(res, ["password"]);
      });
    });

    // group('reauthenticateWithCredential', () {
    //   test('signinMethods empty should return false', () async {
    //     final FakeFirebaseFirestore firestore = FakeFirebaseFirestore();
    //     final FirebaseAuth mockAuth = MockFirebaseAuth();

    //     final FirebaseService firebaseService =
    //         FirebaseService(mockAuth, firestore, googleSignIn, facebookSignIn);

    //     final bool res = await firebaseService.reauthenticateWithCredential(
    //         [], "email", "password", "accessToken", "idToken");
    //     expect(res, false);
    //   });
    //   test('password should return true', () async {
    //     final FakeFirebaseFirestore firestore = FakeFirebaseFirestore();
    //     final FirebaseAuth mockAuth =
    //         fa.MockFirebaseAuth(signedIn: true, mockUser: fa.MockUser());

    //     final FirebaseService firebaseService =
    //         FirebaseService(mockAuth, firestore, googleSignIn, facebookSignIn);
    //     when(mockAuth.currentUser!.reauthenticateWithCredential(
    //             AuthCredential(providerId: '', signInMethod: '')))
    //         .thenAnswer((realInvocation) async => MockUserCredential(false));
    //     final bool res = await firebaseService.reauthenticateWithCredential(
    //         ['password'],
    //         "test@gmail.com",
    //         "password",
    //         "accessToken",
    //         "idToken");
    //     expect(res, true);
    //   });
    //   // test('google should return true', () async {
    //   //   final FakeFirebaseFirestore firestore = FakeFirebaseFirestore();
    //   //   final FirebaseAuth mockAuth = MockFirebaseAuth();

    //   //   final FirebaseService firebaseService =
    //   //       FirebaseService(mockAuth, firestore, googleSignIn, facebookSignIn);

    //   //   final bool res = await firebaseService.reauthenticateWithCredential(
    //   //       ['google.com'],
    //   //       "test@gmail.com",
    //   //       "password",
    //   //       "accessToken",
    //   //       "idToken");
    //   //   expect(res, true);
    //   // });
    //   // test('google should return true', () async {
    //   //   final FakeFirebaseFirestore firestore = FakeFirebaseFirestore();
    //   //   final FirebaseAuth mockAuth = MockFirebaseAuth();

    //   //   final FirebaseService firebaseService =
    //   //       FirebaseService(mockAuth, firestore, googleSignIn, facebookSignIn);
    //   //   when(facebookSignIn.login()).thenAnswer((realInvocation) async =>
    //   //       LoginResult(
    //   //           status: LoginStatus.success,
    //   //           accessToken: AccessToken(
    //   //               declinedPermissions: [],
    //   //               grantedPermissions: [],
    //   //               userId: "uid",
    //   //               expires: DateTime(2025),
    //   //               lastRefresh: DateTime.now(),
    //   //               token: "token",
    //   //               applicationId: "applicationId",
    //   //               isExpired: false)));
    //   //   final bool res = await firebaseService.reauthenticateWithCredential(
    //   //       ['facebook.com'],
    //   //       "test@gmail.com",
    //   //       "password",
    //   //       "accessToken",
    //   //       "idToken");
    //   //   expect(res, true);
    //   // });
    // });
    // group('updateUserAuth', () {
    //   test('should update user and return true', () async {
    //     final FakeFirebaseFirestore firestore = FakeFirebaseFirestore();
    //     final FirebaseAuth mockAuth = MockFirebaseAuth();

    //     final FirebaseService firebaseService =
    //         FirebaseService(mockAuth, firestore, googleSignIn, facebookSignIn);
    //     when(mockAuth.currentUser).thenReturn(expected;);
    //     final bool res = await firebaseService.updateUserAuth('some-uid',
    //         'test@gmail.com', 'newTest@gmail.com', 'password', 'newpassowrd');
    //     expect(res, true);
    //   });
    // });
  });
}
