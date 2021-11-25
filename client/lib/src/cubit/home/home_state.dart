part of 'home_cubit.dart';

@immutable
abstract class HomeState extends Equatable {
  final int index;
  HomeState({this.index = 0});
}

class HomeInitial extends HomeState {
  HomeInitial({required index}) : super(index: index);
  @override
  List<Object?> get props => [index];
}

class HomeChange extends HomeState {
  HomeChange({required int index}) : super(index: index);
  @override
  List<Object?> get props => [index];
}
