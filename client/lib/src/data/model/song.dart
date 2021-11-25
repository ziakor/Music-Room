import 'dart:convert';

import 'package:equatable/equatable.dart';

class SongGrade extends Equatable {
  final int note;
  final String fromId;

  SongGrade(this.note, this.fromId);

  Map<String, dynamic> toMap() {
    return {
      'note': note,
      'fromId': fromId,
    };
  }

  factory SongGrade.fromMap(Map<String, dynamic> map) {
    return SongGrade(
      map['note'],
      map['fromId'],
    );
  }

  SongGrade copyWith({
    int? note,
    String? fromId,
  }) {
    return SongGrade(
      note ?? this.note,
      fromId ?? this.fromId,
    );
  }

  @override
  List<Object?> get props => [
        note,
        fromId,
      ];
}

class Song extends Equatable {
  final String name;
  final String image;
  final String author;
  final String url;
  final List<SongGrade> grade;

  const Song(
      {required this.name,
      required this.image,
      required this.author,
      required this.url,
      this.grade = const []});

  static const empty =
      Song(author: "", name: "", url: "", image: '', grade: []);

  Map<String, dynamic> toMap() {
    return {
      'author': author,
      'name': name,
      'url': url,
      'image': image,
      'grade': grade
    };
  }

  Song copyWith(String? name, String? image, String? author, String? url,
      List<SongGrade>? grade) {
    return Song(
      author: author ?? this.author,
      name: name ?? this.name,
      url: url ?? this.url,
      image: image ?? this.image,
      grade: grade ?? this.grade,
    );
  }

  factory Song.fromMap(Map<String, dynamic> map) {
    return Song(
      author: map['author'],
      name: map['name'],
      url: map['url'],
      image: map['image'],
      grade: List<SongGrade>.from(
          map['grade'].map((elem) => SongGrade.fromMap(elem))),
    );
  }

  @override
  List<Object> get props => [
        name,
        image,
        author,
        grade,
        url,
      ];
}
