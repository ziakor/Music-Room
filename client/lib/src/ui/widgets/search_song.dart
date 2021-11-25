import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:marquee/marquee.dart';
import 'package:music_room/src/cubit/search_song/search_song_cubit.dart';
import 'package:music_room/src/data/model/song.dart';
import 'package:music_room/src/data/repository/playlist_repository.dart';
import 'package:music_room/src/data/repository/room_repository.dart';
import 'package:music_room/src/ui/widgets/text_input.dart';

class SearchSong extends StatefulWidget {
  const SearchSong({
    Key? key,
    required this.roomRepository,
    required this.playlistRepository,
    required this.onAddSong,
    required this.list,
    this.canAddSong = true,
  }) : super(key: key);
  final RoomRepository? roomRepository;
  final PlaylistRepository? playlistRepository;
  final Function(Song) onAddSong;
  final List<Song> list;
  final bool canAddSong;
  @override
  _SearchSongState createState() => _SearchSongState();
}

class _SearchSongState extends State<SearchSong> {
  List<Song> listTrack = [];
  final TextEditingController searchInputController = TextEditingController();

  double _searchContainerSize(int listSize) {
    return (110 + (listSize > 3 ? 60 * 3 : 60 * listSize)).toDouble();
  }

  bool _musicAlreadyInList(Song newSong, List<Song> list) {
    int elem = list.indexWhere((element) =>
        element.name == newSong.name &&
        element.author == newSong.author &&
        element.url == newSong.url);
    return elem != -1;
  }

  @override
  Widget build(BuildContext context) {
    print(searchInputController.text.isNotEmpty);
    return BlocProvider(
      create: (context) => SearchSongCubit(
        playlistRepository: widget.playlistRepository,
        roomRepository: widget.roomRepository,
      ),
      child: BlocConsumer<SearchSongCubit, SearchSongState>(
        listener: (context, state) {
          if (state is SearchSongFind) {
            setState(() {
              listTrack = state.list;
            });
          } else if (state is SearchSongError) {
            setState(() {
              listTrack = [];
            });
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                duration: Duration(seconds: 5),
                content: Text(state.error, style: TextStyle(color: Colors.red)),
              ),
            );
          }
        },
        builder: (context, state) {
          return SingleChildScrollView(
            child: AnimatedContainer(
              duration: Duration(seconds: 1),
              height: listTrack.isEmpty
                  ? 48
                  : _searchContainerSize(listTrack.length),
              width: 270,
              decoration: BoxDecoration(
                color: Colors.black26,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(listTrack.isNotEmpty ? 10 : 30),
                  topRight: Radius.circular(listTrack.isNotEmpty ? 10 : 30),
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 5.0),
                      child: ListView.builder(
                        itemCount: listTrack.length,
                        itemBuilder: (BuildContext context, int index) =>
                            ListTile(
                          minVerticalPadding: 0,
                          contentPadding: EdgeInsets.fromLTRB(5, 5, 0, 0),
                          leading: Container(
                            width: 45,
                            margin: EdgeInsets.all(4),
                            child: Image(
                              image: NetworkImage(listTrack[index].image),
                            ),
                          ),
                          trailing: IconButton(
                            onPressed: !_musicAlreadyInList(
                                        listTrack[index], widget.list) &&
                                    widget.canAddSong
                                ? () {
                                    widget.onAddSong(listTrack[index]);
                                    setState(() {
                                      listTrack = [];
                                    });
                                  }
                                : null,
                            icon: Icon(
                                !_musicAlreadyInList(
                                        listTrack[index], widget.list)
                                    ? Icons.add
                                    : Icons.check,
                                color: widget.canAddSong
                                    ? Colors.green
                                    : Colors.grey),
                          ),
                          title: Container(
                            width: MediaQuery.of(context).size.width * 1,
                            height: 20,
                            padding: EdgeInsets.fromLTRB(4, 4, 0, 0),
                            child: Marquee(
                              text:
                                  "${listTrack[index].name} - ${listTrack[index].author}",
                              style: TextStyle(
                                  fontWeight: FontWeight.normal,
                                  color: Colors.white),
                              // scrollAxis: Axis.horizontal,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              blankSpace: 20.0,
                              velocity: 60.0,
                              // pauseAfterRound: Duration(seconds: 1),
                              accelerationDuration: Duration(seconds: 1),
                              accelerationCurve: Curves.linear,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  TextInput(
                    label: "Song search",
                    textFormKey: Key("SearchSongInputKey"),
                    paddingBottomValue: 0,
                    textController: searchInputController,
                    onChangedFunc: (data) {},
                    hasSuffixIcon: IconButton(
                      onPressed: () {
                        if (searchInputController.text.isNotEmpty) {
                          context
                              .read<SearchSongCubit>()
                              .searchSong(searchInputController.text, 0);
                        } else {
                          setState(() {
                            listTrack = [];
                          });
                        }
                      },
                      icon: Icon(
                        Icons.search,
                        color: Colors.blue,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
