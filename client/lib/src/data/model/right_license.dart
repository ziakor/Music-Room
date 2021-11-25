import 'dart:convert';
import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

import 'package:music_room/src/bloc/right_license/right_license_bloc.dart';
import 'package:music_room/src/data/model/right_license_time.dart';

import '../../../utils/place_picker/lib/entities/location_result.dart';

class RightLicense extends Equatable {
  final GeoPoint location;
  final RightLicenseTime time;
  final bool onlyInvitedEnabled;
  final bool locationEnabled;
  final bool timeEnabled;

  const RightLicense({
    this.location = const GeoPoint(0, 0),
    this.time = const RightLicenseTime(),
    this.onlyInvitedEnabled = false,
    this.timeEnabled = false,
    this.locationEnabled = false,
  });

  GeoPoint toGeoPoint() {
    return (GeoPoint(location.latitude, location.longitude));
  }

  Map<String, dynamic> toMap() {
    return {
      'location': toGeoPoint(),
      'time': time.toMap(),
      'onlyInvitedEnabled': onlyInvitedEnabled,
      'timeEnabled': timeEnabled,
      'locationEnabled': locationEnabled,
    };
  }

  factory RightLicense.fromMap(Map<String, dynamic> map) {
    return RightLicense(
      location: map['location'],
      time: RightLicenseTime(
        start: map['time']['start'],
        end: map['time']['end'],
      ),
      onlyInvitedEnabled: map['onlyInvitedEnabled'],
      timeEnabled: map['timeEnabled'],
      locationEnabled: map['locationEnabled'],
    );
  }

  RightLicenseState toRightLicenseState() {
    return (RightLicenseState(
        onlyInvitedEnabled: onlyInvitedEnabled,
        locationEnabled: locationEnabled,
        timeEnabled: timeEnabled,
        timeRestrictionStart: TimeOfDay(
          hour: (time.start / 60).floor(),
          minute: (time.start % 60),
        ),
        timeRestrictionEnd: TimeOfDay(
          hour: (time.end / 60).floor(),
          minute: (time.end % 60),
        ),
        locationRestriction: null));
  }

  @override
  List<Object> get props => [
        location,
        time,
        onlyInvitedEnabled,
        locationEnabled,
        timeEnabled,
      ];

  RightLicense copyWith({
    GeoPoint? location,
    RightLicenseTime? time,
    bool? onlyInvitedEnabled,
    bool? locationEnabled,
    bool? timeEnabled,
  }) {
    return RightLicense(
      location: location ?? this.location,
      time: time ?? this.time,
      onlyInvitedEnabled: onlyInvitedEnabled ?? this.onlyInvitedEnabled,
      locationEnabled: locationEnabled ?? this.locationEnabled,
      timeEnabled: timeEnabled ?? this.timeEnabled,
    );
  }
}
