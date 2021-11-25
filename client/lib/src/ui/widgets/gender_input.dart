import 'package:flutter/material.dart';
import 'package:music_room/src/bloc/settings/settings_bloc.dart';
import 'package:music_room/src/bloc/signup/signup_bloc.dart';
import 'package:provider/provider.dart';

class GenderInput extends StatefulWidget {
  const GenderInput({
    Key? key,
    required this.updateFunc,
    required this.currentValue,
  }) : super(key: key);
  final Function(String data) updateFunc;

  final String currentValue;
  @override
  _GenderInputState createState() => _GenderInputState();
}

class _GenderInputState extends State<GenderInput> {
  int gendervalue(String gender) {
    switch (gender) {
      case "Man":
        return (0);
      case "Woman":
        return (1);
      case "Non-binary":
        return (2);
      default:
        return (-1);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Container(
        height: 55,
        child: Stack(
          children: [
            Container(
              width: 284,
              margin: EdgeInsets.only(top: 5),
              decoration: BoxDecoration(
                color: Colors.black26,
                borderRadius: const BorderRadius.all(
                  Radius.circular(30.0),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.max,
                children: [
                  Radio(
                      key: Key("ManRadioKey"),
                      value: 0,
                      groupValue: gendervalue(widget.currentValue),
                      activeColor: Colors.grey.shade700,
                      onChanged: (value) => widget.updateFunc("Man")),
                  Text(
                    "Man",
                    style: TextStyle(color: Colors.white),
                  ),
                  Radio(
                      key: Key("WomanRadioKey"),
                      value: 1,
                      groupValue: gendervalue(widget.currentValue),
                      activeColor: Colors.grey.shade700,
                      onChanged: (value) => widget.updateFunc("Woman")),
                  Text("Woman", style: TextStyle(color: Colors.white)),
                  Radio(
                    value: 2,
                    key: Key("NonBinaryRadioKey"),
                    groupValue: gendervalue(widget.currentValue),
                    activeColor: Colors.grey.shade700,
                    onChanged: (value) => widget.updateFunc("Non-binary"),
                  ),
                  Text(
                    "NB",
                    style: TextStyle(color: Colors.white),
                  )
                ],
              ),
            ),
            Positioned(
              child: Text(
                "Gender",
                style: TextStyle(color: Colors.white, fontSize: 13),
              ),
              top: -2.5,
              left: 27,
            )
          ],
        ),
      ),
    );
  }
}
