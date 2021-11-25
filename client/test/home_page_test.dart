import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:music_room/src/bloc/auth/auth_bloc.dart';
import 'package:music_room/src/data/model/_user.dart';
import 'package:music_room/src/data/repository/user_repository.dart';
import 'package:music_room/src/page/home/home.dart';
import 'package:music_room/src/page/home/home_page.dart';
import 'package:music_room/src/page/home/users_list.dart';
import 'package:music_room/src/page/home/playlist/playlist.dart';
import 'package:music_room/src/page/home/room/room.dart';
import 'package:vrouter/vrouter.dart';

import 'mocks/user_repository_mock.dart';

@GenerateMocks([UserRepository])
void main() {
  final MockUserRepository mockRepository = MockUserRepository();
  group('HomePageTest', () {
    when(mockRepository.currentUser)
        .thenReturn(User(id: 'some-uid', email: 'test@gmail.com'));
    when(mockRepository.user)
        .thenAnswer((realInvocation) => Stream.value(User(id: 'd')));
    when(mockRepository.getFirestoreUserDataFromId(any))
        .thenAnswer((realInvocation) async => null);
    testWidgets('initial should be Home', (WidgetTester tester) async {
      await tester.pumpWidget(
        VRouter(
          initialUrl: "/",
          routes: [
            VWidget(
                path: "/",
                widget: BlocProvider(
                  create: (context) => AuthBloc(userRepository: mockRepository),
                  child: HomePage(),
                )),
          ],
          debugShowCheckedModeBanner: false,
        ),
      );
      await tester.pumpAndSettle();
      expect(find.byType(HomePage), findsOneWidget);
      expect(find.byType(Home), findsOneWidget);
    });

    testWidgets('should change to Message', (WidgetTester tester) async {
      await tester.pumpWidget(
        VRouter(
          initialUrl: "/home",
          routes: [
            VWidget(
                path: "/home",
                widget: BlocProvider(
                  create: (context) => AuthBloc(userRepository: mockRepository),
                  child: HomePage(),
                )),
          ],
          debugShowCheckedModeBanner: false,
        ),
      );
      await tester.pumpAndSettle();
      final messageButton = find.byIcon(Icons.sms);
      await tester.tap(messageButton);
      await tester.pumpAndSettle();

      expect(find.byType(HomePage), findsOneWidget);
      expect(find.byType(Messenger), findsOneWidget);
    });

    testWidgets('should change to Room', (WidgetTester tester) async {
      await tester.pumpWidget(
        VRouter(
          initialUrl: "/home",
          routes: [
            VWidget(
                path: "/home",
                widget: BlocProvider(
                  create: (context) => AuthBloc(userRepository: mockRepository),
                  child: HomePage(),
                )),
          ],
          debugShowCheckedModeBanner: false,
        ),
      );
      await tester.pumpAndSettle();
      final roomButtom = find.byIcon(Icons.headset);
      await tester.tap(roomButtom);
      await tester.pumpAndSettle();

      expect(find.byType(HomePage), findsOneWidget);
      expect(find.byType(Room), findsOneWidget);
    });

    testWidgets('should change to Playlist', (WidgetTester tester) async {
      await tester.pumpWidget(
        VRouter(
          initialUrl: "/home",
          routes: [
            VWidget(
                path: "/home",
                widget: BlocProvider(
                  create: (context) => AuthBloc(userRepository: mockRepository),
                  child: HomePage(),
                )),
          ],
          debugShowCheckedModeBanner: false,
        ),
      );
      await tester.pumpAndSettle();
      final playlistButton = find.byIcon(Icons.library_music);
      await tester.tap(playlistButton);
      await tester.pumpAndSettle();

      expect(find.byType(HomePage), findsOneWidget);
      expect(find.byType(Playlist), findsOneWidget);
    });
  });
}
