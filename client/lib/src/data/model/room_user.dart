import 'dart:convert';

import 'package:equatable/equatable.dart';

class RoomUser extends Equatable {
  final String id;
  final String pseudo;
  final String role;
  final bool isInvited;

  RoomUser({
    required this.id,
    required this.pseudo,
    required this.role,
    required this.isInvited,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'pseudo': pseudo,
      'role': role,
      'isInvited': isInvited,
    };
  }

  factory RoomUser.fromMap(Map<String, dynamic> map) {
    return RoomUser(
      id: map['id'],
      pseudo: map['pseudo'],
      role: map['role'],
      isInvited: map['isInvited'],
    );
  }

  RoomUser copyWith({
    String? id,
    String? pseudo,
    String? role,
    bool? isInvited,
  }) {
    return RoomUser(
      id: id ?? this.id,
      pseudo: pseudo ?? this.pseudo,
      role: role ?? this.role,
      isInvited: isInvited ?? this.isInvited,
    );
  }

  @override
  // TODO: implement props
  List<Object> get props => [id, pseudo, role, isInvited];
}
