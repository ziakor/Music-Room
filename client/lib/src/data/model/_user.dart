import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

class User extends Equatable {
  const User(
      {required this.id,
      this.pseudo,
      this.email,
      this.bio,
      this.birth,
      this.gender,
      this.musicalInterests,
      this.location,
      this.friends});

  final String id;
  final String? pseudo;
  final String? email;
  final String? bio;
  final List<String>? musicalInterests;
  final String? gender;
  final DateTime? birth;
  final GeoPoint? location;
  final List<String>? friends;

  static const empty = User(id: '');

  bool get isEmpty => this == User.empty;

  bool get isNotEmpty => this != User.empty;

  User copyWith({
    String? id,
    String? pseudo,
    String? email,
    String? bio,
    List<String>? musicalInterests,
    String? gender,
    DateTime? birth,
    GeoPoint? location,
    List<String>? friends,
  }) {
    return User(
      id: id ?? this.id,
      pseudo: pseudo ?? this.pseudo,
      email: email ?? this.email,
      bio: bio ?? this.bio,
      musicalInterests: musicalInterests ?? this.musicalInterests,
      gender: gender ?? this.gender,
      birth: birth ?? this.birth,
      location: location ?? this.location,
      friends: friends ?? this.friends,
    );
  }

  @override
  List<Object?> get props => [
        id,
        pseudo,
        email,
        bio,
        musicalInterests,
        gender,
        birth,
        location,
        friends,
      ];
}
