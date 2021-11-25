import 'package:flutter/material.dart';
import 'package:music_room/src/ui/widgets/list_playlist.dart';
import 'package:music_room/src/ui/widgets/list_rooms.dart';

class Home extends StatelessWidget {
  const Home({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        color: Colors.black87,
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).orientation == Orientation.portrait
            ? MediaQuery.of(context).size.height - 110
            : MediaQuery.of(context).size.height,
        child: Column(
          children: [
            Expanded(flex: 5, child: ListRoom()),
            Expanded(
              flex: 5,
              child: ListPlaylist(),
            )
          ],
        ),
      ),
    );
  }
}
