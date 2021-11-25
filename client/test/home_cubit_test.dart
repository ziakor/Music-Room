import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:music_room/src/cubit/home/home_cubit.dart';

void main() {
  final HomeCubit homeCubit = HomeCubit();
  group('HomeCubit', () {
    test('initialState', () {
      expect(homeCubit.state, HomeInitial(index: 0));
    });
    blocTest<HomeCubit, HomeState>(
      'emits [MyState] when MyEvent is added.',
      build: () => HomeCubit(),
      act: (cubit) => cubit.changeIndex(1),
      expect: () => [HomeChange(index: 1)],
    );
  });
}
