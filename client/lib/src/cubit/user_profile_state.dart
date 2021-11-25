part of 'user_profile_cubit.dart';

abstract class UserProfileState extends Equatable {
  const UserProfileState();

  @override
  List<Object> get props => [];
}

class UserProfileInitial extends UserProfileState {}

class GetUserProfile extends UserProfileState {
  final User userProfile;

  GetUserProfile(this.userProfile);
}

class UserProfileError extends UserProfileState {
  final String error;

  UserProfileError(this.error);
}

class UserProfileAddFriend extends UserProfileState {
  final String friendId;

  UserProfileAddFriend(this.friendId);
}

class UserProfileRemoveFriend extends UserProfileState {
  final String friendId;

  UserProfileRemoveFriend(this.friendId);
}
