import 'dart:developer';

import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:meta/meta.dart';
import 'package:music_room/src/data/model/return_repository.dart';
import 'package:music_room/src/data/repository/playlist_repository.dart';
import 'package:music_room/src/data/repository/room_repository.dart';
import 'package:music_room/utils/place_picker/lib/entities/location_result.dart';
part 'right_license_event.dart';
part 'right_license_state.dart';

class RightLicenseBloc extends Bloc<RightLicenseEvent, RightLicenseState> {
  final PlaylistRepository? playlistRepository;
  final RoomRepository? roomRepository;
  final RightLicenseState initial;
  RightLicenseBloc({
    required this.roomRepository,
    required this.playlistRepository,
    required this.initial,
  }) : super(initial);

  @override
  void onTransition(
      Transition<RightLicenseEvent, RightLicenseState> transition) {
    super.onTransition(transition);
  }

  @override
  Stream<RightLicenseState> mapEventToState(
    RightLicenseEvent event,
  ) async* {
    if (event is RightLicenseUpdateVoteOnlyInvited) {
      yield state.copyWith(
          onlyInvitedEnabled: event.voteOnlyInvitedStatus, buttonStatus: true);
    } else if (event is RightLicenseUpdateVoteStartRestriction) {
      yield state.copyWith(
          timeRestrictionStart: event.startTime, buttonStatus: true);
    } else if (event is RightLicenseUpdateVoteEndRestriction) {
      yield state.copyWith(
          timeRestrictionEnd: event.endTime, buttonStatus: true);
    } else if (event is RightLicenseUpdateLocalisationRestriction) {
      yield state.copyWith(
          locationRestriction: event.location, buttonStatus: true);
    } else if (event is RightLicenseUpdateRestrictionVoteLocation) {
      yield state.copyWith(locationEnabled: event.status, buttonStatus: true);
    } else if (event is RightLicenseUpdateRestrictionVoteTime) {
      yield state.copyWith(timeEnabled: event.status, buttonStatus: true);
    } else if (event is RightLicenseSendUpdate) {
      yield await _updateRightLicense(event.id);
    } else if (event is RightLicenseResetError) {
      yield state.copyWith(status: false, error: '');
    }
  }

  Future<RightLicenseState> _updateRightLicense(String id) async {
    if (state.timeRestrictionEnd == null &&
        state.timeRestrictionStart != null) {
      return (state.copyWith(
          status: false,
          error:
              "time Restriction end can not be empty when time restriction start is fill."));
    }
    Map<String, dynamic> data = {};
    data['rightLicense'] = {
      'onlyInvitedEnabled': state.onlyInvitedEnabled,
      'locationEnabled': state.locationEnabled,
      'timeEnabled': state.timeEnabled,
      'time': {
        'start': state.timeRestrictionStart!.hour * 60 +
            state.timeRestrictionStart!.minute,
        'end': state.timeRestrictionEnd!.hour * 60 +
            state.timeRestrictionEnd!.minute
      },
      if (state.locationRestriction != null)
        'location': GeoPoint(state.locationRestriction!.latLng!.latitude,
            state.locationRestriction!.latLng!.longitude),
    };
    if (playlistRepository != null) {
      final ReturnRepository res =
          await playlistRepository!.updatePlaylist(id, data, true);
      if (res.message.isNotEmpty) {
        return (state.copyWith(status: false, error: res.message));
      }
    } else if (roomRepository != null) {
      final ReturnRepository res =
          await roomRepository!.updateRoom(id, data, true);
      if (res.message.isNotEmpty) {
        return (state.copyWith(status: false, error: res.message));
      }
    }
    return (state.copyWith(status: true, error: ""));
  }
}
