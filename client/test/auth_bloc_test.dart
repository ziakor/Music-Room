import 'package:bloc_test/bloc_test.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dio/dio.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_sign_in_mocks/google_sign_in_mocks.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:music_room/src/bloc/auth/auth_bloc.dart';
import 'package:music_room/src/data/model/_user.dart' as m;
import 'package:music_room/src/data/model/user_firestore.dart';
import 'package:music_room/src/data/repository/user_repository.dart';
import 'package:music_room/src/data/service/api_service.dart';
import 'package:music_room/src/data/service/firebase_service.dart';

import 'mocks/facebook_auth_mock.dart';
import 'mocks/mock.dart';
import 'mocks/user_repository_mock.dart';

@GenerateMocks([UserRepository])
void main() {
  final MockUserRepository mockRepository = MockUserRepository();

  setupFirebaseAuthMocks();
  setUp(() {});
  setUpAll(() async {
    when(mockRepository.currentUser)
        .thenAnswer((realInvocation) => m.User(id: ""));
    when(mockRepository.user)
        .thenAnswer((realInvocation) => Stream.value(m.User(id: "")));
  });

  group('AuthBloc', () {
    test('initial value', () {
      final authBloc = AuthBloc(userRepository: mockRepository);
      expect(authBloc.state, AuthState.unauthenticated());
    });

    blocTest<AuthBloc, AuthState>(
      'should be unauthenticated',
      build: () => AuthBloc(userRepository: mockRepository),
      expect: () => [AuthState.unauthenticated()],
    );
    blocTest<AuthBloc, AuthState>(
      'should be authenticated and firestore is null',
      build: () {
        when(mockRepository.user).thenAnswer(
          (realInvocation) => Stream.value(
            m.User(
                id: "some_random_id",
                pseudo: "",
                email: "dimitrihauet@gmail.com"),
          ),
        );

        return (AuthBloc(userRepository: mockRepository));
      },
      expect: () => [
        AuthState.authenticated(
          m.User(
            id: "some_random_id",
            pseudo: "",
            email: "dimitrihauet@gmail.com",
            gender: "",
            musicalInterests: [],
            bio: "",
          ),
        )
      ],
    );

    blocTest<AuthBloc, AuthState>(
      'should update user with firestore data',
      build: () {
        when(mockRepository.user).thenAnswer(
          (realInvocation) => Stream.value(
            m.User(
                id: "some_random_id",
                pseudo: "",
                email: "dimitrihauet@gmail.com"),
          ),
        );
        when(mockRepository.currentUser).thenReturn(m.User(
            id: "some_random_id", pseudo: "", email: "dimitrihauet@gmail.com"));
        when(mockRepository.getFirestoreUserDataFromId(any)).thenAnswer(
            (realInvocation) async => UserFirestore(
                pseudo: "pseudoTest",
                gender: "Man",
                bio: "bioTest",
                musicalInterests: ["Rap"],
                birth: Timestamp.fromDate(DateTime(2002, 12, 12))));

        return (AuthBloc(userRepository: mockRepository));
      },
      act: (bloc) => bloc.add(AuthDataRequested()),
      expect: () => [
        AuthState.authenticated(
          m.User(
              id: "some_random_id",
              pseudo: "pseudoTest",
              email: "dimitrihauet@gmail.com",
              gender: "Man",
              musicalInterests: ["Rap"],
              bio: "bioTest",
              birth: DateTime(2002, 12, 12)),
        ),
        AuthState.authenticated(m.User(
          id: "some_random_id",
          email: "dimitrihauet@gmail.com",
          pseudo: "",
          birth: null,
          gender: "",
          musicalInterests: [],
          bio: "",
        ))
      ],
    );
  });
}
