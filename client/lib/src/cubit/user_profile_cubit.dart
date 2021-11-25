import 'dart:developer';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:music_room/src/data/model/_user.dart';
import 'package:music_room/src/data/model/return_repository.dart';
import 'package:music_room/src/data/repository/user_repository.dart';

part 'user_profile_state.dart';

class UserProfileCubit extends Cubit<UserProfileState> {
  final UserRepository _userRepository;
  UserProfileCubit(UserRepository userRepository)
      : _userRepository = userRepository,
        super(UserProfileInitial());

  void getUserProfile(String id) async {
    try {
      final ReturnRepository res = await _userRepository.getUserProfileData(id);
      if (res.status == false) {
        emit(UserProfileError('Server error, try again!'));
      }
      emit(GetUserProfile(res.data['user']));
    } catch (e) {
      emit(UserProfileError('Server error, try again!'));
    }
  }

  void addFriend(String friendId) async {
    try {
      final ReturnRepository res = await _userRepository.addFriend(friendId);
      if (res.status == false) {
        emit(UserProfileError('Server error, try again!'));
      }
      emit(UserProfileAddFriend(friendId));
    } catch (e) {
      emit(UserProfileError('Server error, try again!'));
    }
  }

  void removeFriend(String friendId) async {
    try {
      final ReturnRepository res = await _userRepository.removeFriend(friendId);
      if (res.status == false) {
        emit(UserProfileError('Server error, try again!'));
      }
      emit(UserProfileRemoveFriend(friendId));
    } catch (e) {
      emit(UserProfileError('Server error, try again!'));
    }
  }
}
