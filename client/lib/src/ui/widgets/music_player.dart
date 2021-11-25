import 'dart:async';
import 'dart:developer';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:marquee/marquee.dart';
import 'package:music_room/src/bloc/room/room_bloc.dart';
import 'package:music_room/src/cubit/room_socket/room_socket_cubit.dart';
import 'package:music_room/src/data/model/current_song.dart';
import 'package:music_room/src/data/model/song.dart';
import 'package:provider/src/provider.dart';

class MusicPlayer extends StatefulWidget {
  const MusicPlayer({
    Key? key,
    required this.id,
    required this.song,
    required this.listenFunc,
    required this.onPlayFunc,
    required this.list,
    required this.onDoubleTapSong,
    required this.hasMusicControl,
    required this.onVote,
    required this.canVote,
    this.sortedByGrade = true,
    required this.isRoom,
  }) : super(key: key);
  final bool isRoom;
  final String id;
  final CurrentSong song;
  final List<Song> list;
  final Function listenFunc;
  final Function(bool status) onPlayFunc;
  final Function(Song song) onDoubleTapSong;
  final Function(int note, String name, String author) onVote;
  final bool hasMusicControl;
  final bool canVote;
  final bool sortedByGrade;
  @override
  _MusicPlayerState createState() => _MusicPlayerState();
}

class _MusicPlayerState extends State<MusicPlayer> {
  late List<Song> _sortedList = widget.list;
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _showList = true;
  bool _playedByMe = false;
  @override
  void initState() {
    super.initState();

    if (widget.song.onPlay == true && widget.song.song.name.isNotEmpty) {
      _audioPlayer
          .seek(Duration(seconds: widget.song.time.toInt()))
          .then((value) => _audioPlayer.play(widget.song.song.url));
    }
  }

  List<Song> _sortSongByGrade(List<Song> initial) {
    List<Song> tmp = List.from(initial);
    tmp.removeWhere((element) =>
        element.author == widget.song.song.author &&
        element.name == widget.song.song.name &&
        widget.song.song.url == element.url);
    tmp.sort((a, b) {
      return _voteNumber(a.grade) >= _voteNumber(b.grade) ? 0 : 1;
    });

    return tmp;
  }

  void _playSong(String url) async {
    setState(() {
      _playedByMe = true;
    });
    widget.onPlayFunc(true);
    _audioPlayer.onAudioPositionChanged.listen(
      (Duration p) {
        widget.listenFunc(p.inSeconds);
      },
    );
    _audioPlayer.onPlayerStateChanged.listen((PlayerState s) async {
      if (s == PlayerState.COMPLETED) {
        await _audioPlayer.stop();
        Timer(Duration(milliseconds: 1000), () {
          int _indexCurrent = _sortedList.indexWhere((element) =>
              element.name == widget.song.song.name &&
              element.author == widget.song.song.author &&
              element.url == widget.song.song.url);
          if (_sortedList.isNotEmpty &&
              _indexCurrent + 1 != _sortedList.length) {
            widget.onDoubleTapSong(
                _sortedList[widget.isRoom ? 0 : _indexCurrent + 1]);
          } else {
            widget.onPlayFunc(false);

            if (widget.isRoom) {
              widget.onDoubleTapSong(Song.empty);
            } else {
              widget.onDoubleTapSong(_sortedList[0]);
            }
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  void _stopSong() async {
    await _audioPlayer.pause();
    widget.onPlayFunc(false);
    setState(() {
      _playedByMe = false;
    });
  }

  int _voteNumber(List<SongGrade> list) {
    int note = 0;
    for (var i = 0; i < list.length; i++) {
      note = note + list[i].note;
    }
    return (note);
  }

  bool _isCurrentSong(Song current, Song inList) {
    if (current.author == inList.author &&
        current.image == inList.image &&
        current.name == inList.name &&
        current.url == inList.url) {
      return true;
    }
    return false;
  }

  String _stringVoteNumber(List<SongGrade> list, int number) {
    var vote = list.where((element) => element.note == number).length;

    return (vote.toString());
  }

  @override
  void deactivate() {
    // TODO: implement deactivate

    if (widget.isRoom == true && _playedByMe == true) {
      context.read<RoomSocketCubit>().playSong(widget.id, false);
    } else if (widget.isRoom == false && _playedByMe == true) {}
    super.deactivate();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.sortedByGrade == true && widget.isRoom == true) {
      setState(() {
        _sortedList = _sortSongByGrade(widget.list);
      });
    } else {
      setState(() {
        _sortedList = widget.list;
      });
    }

    if (widget.song.onPlay == true && widget.song.song.name.isNotEmpty) {
      if (_audioPlayer.state != PlayerState.PLAYING) {
        print(widget.song);

        _audioPlayer
            .seek(
              Duration(
                seconds: widget.song.time.toInt(),
              ),
            )
            .then(
              (value) async => {
                await _audioPlayer.play(widget.song.song.url),
              },
            );
      }
    } else {
      if (_audioPlayer.state == PlayerState.PLAYING) {
        _audioPlayer.pause();
      }
    }
    return Visibility(
      visible: (widget.song.song != Song.empty) || widget.isRoom == false,
      child: AnimatedContainer(
        duration: Duration(milliseconds: 600),
        height: _showList == false
            ? 68
            : widget.song.song != Song.empty
                ? 200
                : 144.4,
        width: MediaQuery.of(context).size.width,
        // color: Colors.red,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Positioned(
              top: 11,
              child: Container(
                color: Colors.black12,
                height: 135,
                width: MediaQuery.of(context).size.width,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _sortedList.length,
                  itemBuilder: (BuildContext context, int index) => Visibility(
                    visible: true,
                    child: GestureDetector(
                      onDoubleTap: widget.hasMusicControl
                          ? () async {
                              if (_sortedList[index] != widget.song) {
                                await _audioPlayer.stop();
                                widget.onDoubleTapSong(_sortedList[index]);
                                if (widget.isRoom == false) {
                                  _playSong(_sortedList[index].url);
                                }
                              }
                            }
                          : null,
                      child: Container(
                        margin: EdgeInsets.fromLTRB(3, 3, 3, 5),
                        width: 130,
                        color:
                            _isCurrentSong(widget.song.song, _sortedList[index])
                                ? Colors.black54
                                : Colors.black12,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Container(
                              width: 150,
                              height: 25,
                              padding: EdgeInsets.fromLTRB(2, 5, 2, 5),
                              child: Marquee(
                                text:
                                    '${_sortedList[index].name} - ${_sortedList[index].author}',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white),
                                crossAxisAlignment: CrossAxisAlignment.center,
                                blankSpace: 20.0,
                                velocity: 60.0,
                                accelerationDuration: Duration(seconds: 1),
                                accelerationCurve: Curves.linear,
                              ),
                            ),
                            Container(
                              width: 75,
                              // margin: EdgeInsets.all(2),
                              child: Image(
                                //!Resize image
                                image: NetworkImage(
                                  _sortedList[index].image,
                                ),
                              ),
                            ),
                            Container(
                              height: 27,
                              child: widget.isRoom == true
                                  ? Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          _stringVoteNumber(
                                              _sortedList[index].grade, 1),
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 14),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 1.0),
                                          child: Container(
                                            width: 25,
                                            child: IconButton(
                                              padding: EdgeInsets.zero,
                                              onPressed: widget.canVote
                                                  ? () {
                                                      widget.onVote(
                                                          1,
                                                          _sortedList[index]
                                                              .name,
                                                          _sortedList[index]
                                                              .author);
                                                    }
                                                  : null,
                                              splashColor: Colors.white,
                                              splashRadius: 20,
                                              icon: Icon(
                                                Icons.thumb_up,
                                                color: widget.canVote
                                                    ? Colors.blue
                                                    : Colors.grey.shade800,
                                                size: 17,
                                              ),
                                            ),
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.fromLTRB(
                                              3, 0, 1, 0),
                                          child: Container(
                                            width: 25,
                                            child: IconButton(
                                              padding: EdgeInsets.zero,
                                              onPressed: widget.canVote
                                                  ? () {
                                                      widget.onVote(
                                                          -1,
                                                          _sortedList[index]
                                                              .name,
                                                          _sortedList[index]
                                                              .author);
                                                    }
                                                  : null,
                                              splashColor: Colors.white,
                                              splashRadius: 20,
                                              icon: Icon(
                                                Icons.thumb_down,
                                                color: widget.canVote
                                                    ? Colors.red
                                                    : Colors.grey.shade800,
                                                size: 17,
                                              ),
                                            ),
                                          ),
                                        ),
                                        Text(
                                          _stringVoteNumber(
                                              _sortedList[index].grade, -1),
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 14),
                                        ),
                                      ],
                                    )
                                  : null,
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Visibility(
              visible: widget.song.song != Song.empty,
              child: Positioned(
                bottom: 0,
                child: Container(
                  height: 57.6,
                  color: Color(0xff141414),
                  child: Row(
                    children: [
                      Container(
                        width: 49.6,
                        margin: EdgeInsets.all(4),
                        child: widget.song.song != Song.empty
                            ? Image(
                                //!Resize image
                                image: NetworkImage(widget.song.song.image),
                              )
                            : null,
                      ),
                      Column(
                        children: [
                          Expanded(
                            child: Container(
                              height: 30,
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                children: [
                                  Container(
                                    width: MediaQuery.of(context).size.width *
                                        0.47,
                                    padding: EdgeInsets.fromLTRB(4, 4, 0, 0),
                                    child: Marquee(
                                      text:
                                          "${widget.song.song.name} - ${widget.song.song.author}",
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white),
                                      // scrollAxis: Axis.horizontal,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      blankSpace: 20.0,
                                      velocity: 60.0,
                                      // pauseAfterRound: Duration(seconds: 1),

                                      accelerationDuration:
                                          Duration(seconds: 1),
                                      accelerationCurve: Curves.linear,
                                    ),
                                  ),
                                  SizedBox(
                                    width: 45,
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      IconButton(
                                        padding: EdgeInsets.only(top: 4),
                                        constraints: BoxConstraints(),
                                        onPressed: widget.hasMusicControl
                                            ? () {
                                                if (widget.song.onPlay ==
                                                    true) {
                                                  _stopSong();
                                                } else {
                                                  _playSong(
                                                      widget.song.song.url);
                                                }
                                              }
                                            : null,
                                        icon: Icon(widget.song.onPlay == true
                                            ? Icons.pause_circle
                                            : Icons.play_circle),
                                        splashColor: Colors.yellow,
                                        splashRadius: 15,
                                        color: Colors.blue,
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.only(top: 0),
                            height: 20,
                            width: MediaQuery.of(context).size.width * 0.84,
                            child: Row(
                              children: [
                                Container(
                                  width:
                                      MediaQuery.of(context).size.width * 0.75,
                                  child: SliderTheme(
                                    data: SliderThemeData(
                                        thumbColor: Colors.green,
                                        thumbShape: RoundSliderThumbShape(
                                            enabledThumbRadius: 7)),
                                    child: Slider(
                                      min: 0,
                                      max: 30,
                                      value: widget.song.time,
                                      onChanged: (data) {},
                                      thumbColor: Colors.black,
                                      inactiveColor: Colors.grey.shade900,
                                    ),
                                  ),
                                ),
                                Text(widget.song.time.toInt().toString(),
                                    style: TextStyle(color: Colors.white)),
                              ],
                            ),
                          )
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Visibility(
              visible: widget.song.song != Song.empty || widget.isRoom == false,
              child: Positioned(
                top: -14,
                child: IconButton(
                  splashRadius: 20,
                  onPressed: () {
                    setState(() {
                      _showList = !_showList;
                    });
                  },
                  icon: Icon(
                    _showList == false ? Icons.add_circle : Icons.remove_circle,
                    color: Colors.grey.shade600,
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
