import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

class UserFirestore extends Equatable {
  final String pseudo;
  final String gender;
  final Timestamp birth;
  final String code;
  final String bio;
  final List<String> musicalInterests;
  final GeoPoint location;
  final List<String> friends;

  const UserFirestore(
      {this.pseudo = "",
      this.code = "",
      this.gender = "",
      required this.birth,
      this.bio = "",
      this.musicalInterests = const [],
      this.location = const GeoPoint(0, 0),
      this.friends = const []});

  Map<String, dynamic> toMap() {
    return {
      'pseudo': pseudo,
      'gender': gender,
      'birth': birth,
      'code': code,
      'bio': bio,
      'musicalInterests': musicalInterests,
      'location': location,
      'friends': friends,
    };
  }

  factory UserFirestore.fromMap(Map<String, dynamic> map) {
    return UserFirestore(
      pseudo: map['pseudo'],
      gender: map['gender'],
      birth: map['birth'],
      code: map['code'],
      bio: map['bio'],
      musicalInterests: List<String>.from(map['musicalInterests']),
      location: map['location'],
      friends: List<String>.from(map['friends']),
    );
  }

  @override
  List<Object?> get props => [
        pseudo,
        gender,
        birth,
        code,
        bio,
        musicalInterests,
        location,
        friends,
      ];
}
