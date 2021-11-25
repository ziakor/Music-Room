import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';
import 'package:music_room/src/data/model/return_repository.dart';
import 'package:music_room/src/data/model/_user.dart';
import 'package:music_room/src/data/repository/user_repository.dart';
import 'package:music_room/src/mixins/validation_mixins.dart';
import 'package:music_room/utils/place_picker/lib/entities/location_result.dart';
part 'settings_event.dart';
part 'settings_state.dart';

class SettingsBloc extends Bloc<SettingsEvent, SettingsState> {
  SettingsBloc({required UserRepository userRepository})
      : _userRepository = userRepository,
        super(SettingsState());

  // @override
  // void onTransition(Transition<SettingsEvent, SettingsState> transition) {
  //   print(transition);
  //   super.onTransition(transition);
  // }

  final UserRepository _userRepository;

  @override
  Stream<SettingsState> mapEventToState(
    SettingsEvent event,
  ) async* {
    if (event is UpdatePseudo) {
      yield await _mapStateToPseudoUpdated(event.pseudo);
    } else if (event is UpdateEmail) {
      yield state.copyWith(
          email: event.email,
          buttonStatus: _isSomethingUpdated(email: event.email));
    } else if (event is UpdateCurrentPassword) {
      yield state.copyWith(
        currentPassword: event.currentPassword,
        buttonStatus: _isSomethingUpdated(),
      );
    } else if (event is UpdateNewPassword) {
      yield state.copyWith(
          newPassword: event.newPassword,
          buttonStatus: _isSomethingUpdated(newPassword: event.newPassword));
    } else if (event is UpdateBio) {
      yield state.copyWith(
          bio: event.bio, buttonStatus: _isSomethingUpdated(bio: event.bio));
    } else if (event is UpdateGender) {
      yield state.copyWith(
          gender: event.gender,
          buttonStatus: _isSomethingUpdated(gender: event.gender));
    } else if (event is UpdateBirth) {
      yield state.copyWith(
          birth: event.birth,
          buttonStatus: _isSomethingUpdated(birth: event.birth));
    } else if (event is UpdateMusicalInterests) {
      yield state.copyWith(
          musicalInterests: event.musicalInterests, buttonStatus: true);
    } else if (event is UpdateError) {
      yield state.copyWith(error: "");
    } else if (event is UpdateSendForm) {
      yield await _mapStateToFormSended();
    } else if (event is UpdateLocation) {
      yield state.copyWith(
          location: GeoPoint(event.location.latLng!.latitude,
              event.location.latLng!.longitude),
          buttonStatus: _isSomethingUpdated(
              location: GeoPoint(event.location.latLng!.latitude,
                  event.location.latLng!.longitude)));
    } else if (event is LinkToGoogle) {
      final res = await _userRepository.linkToGoogle();
      if (res.status == true) {
        yield state.copyWith(
            status: true, error: 'account linked with success');
      }
      yield state.copyWith(status: false, error: res.message);
    }
  }

  Future<SettingsState> linkToGoogle() async {
    final res = await _userRepository.linkToGoogle();
    if (res.status == true) {
      return state.copyWith(status: true, error: 'account linked with success');
    }
    return state.copyWith(status: false, error: res.message);
  }

  bool _isSomethingUpdated({
    String? email,
    String? pseudo,
    String? bio,
    String? newPassword,
    String? gender,
    DateTime? birth,
    GeoPoint? location,
  }) {
    return ((email ?? state.email).isNotEmpty ||
        (pseudo ?? state.pseudo).isNotEmpty ||
        (bio ?? state.bio).isNotEmpty ||
        (newPassword ?? state.newPassword).isNotEmpty ||
        (gender ?? state.gender).isNotEmpty ||
        (birth ?? state.birth) != null ||
        (location != GeoPoint(0, 0)));
  }

  Future<SettingsState> _mapStateToPseudoUpdated(String pseudo) async {
    try {
      final bool pseudoIsAvailable =
          await _userRepository.checkPseudoAvailable(pseudo);
      return (state.copyWith(
          pseudo: pseudoIsAvailable == true ? pseudo : "",
          pseudoAvailable:
              ValidationMixin().validatePseudo(pseudo) && pseudoIsAvailable,
          buttonStatus:
              _isSomethingUpdated(pseudo: pseudo) && pseudoIsAvailable));
    } catch (e) {
      return (state.copyWith(
          pseudo: "",
          pseudoAvailable: false,
          status: false,
          error: "Server error, try again."));
    }
  }

  Future<SettingsState> _mapStateToFormSended() async {
    if ((state.email.isNotEmpty || state.newPassword.isNotEmpty) &&
        state.currentPassword.isEmpty) {
      return (state.copyWith(
          status: false,
          error:
              "To update your email or password, you must enter your current password."));
    }
    final ReturnRepository updateResponse = await _userRepository.updateUser(
      bio: state.bio.isNotEmpty ? state.bio : null,
      birth: state.birth,
      email: state.email.isNotEmpty ? state.email : null,
      gender: state.gender.isNotEmpty ? state.gender : null,
      musicalInterests: state.musicalInterests,
      password: state.newPassword.isNotEmpty ? state.newPassword : null,
      currentPassword: state.currentPassword,
      pseudo: state.pseudo.isNotEmpty ? state.pseudo : null,
      location: state.location != GeoPoint(0, 0) ? state.location : null,
    );

    if (updateResponse.status == false) {
      return (state.copyWith(status: false, error: updateResponse.message));
    }
    return (state.copyWith(status: true));
  }
}
