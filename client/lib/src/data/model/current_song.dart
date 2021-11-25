import 'dart:convert';

import 'package:equatable/equatable.dart';
import 'package:music_room/src/data/model/song.dart';

class CurrentSong extends Equatable {
  final Song song;
  final double time;
  final bool onPlay;

  const CurrentSong({
    this.song = Song.empty,
    this.time = 0.0,
    this.onPlay = false,
  });

  static const empty = CurrentSong(
    song: Song.empty,
    time: 0.0,
    onPlay: false,
  );

  CurrentSong copyWith({
    Song? song,
    double? time,
    bool? onPlay,
  }) {
    return CurrentSong(
      song: song ?? this.song,
      time: time ?? this.time,
      onPlay: onPlay ?? this.onPlay,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'song': song.toMap(),
      'time': time,
      'onPlay': onPlay,
    };
  }

  factory CurrentSong.fromMap(Map<String, dynamic> map) {
    return CurrentSong(
      song: Song.fromMap(map['song']),
      time: map['time'].toDouble(),
      onPlay: map['onPlay'],
    );
  }

  @override
  List<Object> get props => [song, time, onPlay];
}
