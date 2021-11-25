import 'package:flutter/material.dart';

Future<void> modalDialog(
  BuildContext context,
  Widget? title,
  Widget body,
  List<Widget>? button,
  bool barrierDismissible, {
  Color backgroundColors = Colors.black54,
}) async {
  return showDialog<void>(
    context: context,
    barrierDismissible: barrierDismissible,
    builder: (BuildContext context) {
      return AlertDialog(
        key: Key("showDialogKey"),
        backgroundColor: backgroundColors,
        title: title,
        contentPadding: EdgeInsets.fromLTRB(24, 24, 24, 10),
        shape: OutlineInputBorder(
          borderRadius: const BorderRadius.all(
            Radius.circular(30.0),
          ),
        ),
        content: body,
        actionsPadding: EdgeInsets.only(bottom: 15),
        actions: button,
      );
    },
  );
}
