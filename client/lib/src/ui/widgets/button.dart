import 'package:flutter/material.dart';

class Button extends StatefulWidget {
  const Button(
      {Key? key,
      required this.text,
      required this.buttonKey,
      required this.onSubmitFunc,
      required this.isEnabled})
      : super(key: key);
  final String text;
  final Key buttonKey;
  final Function onSubmitFunc;
  final bool isEnabled;
  @override
  _ButtonState createState() => _ButtonState();
}

class _ButtonState extends State<Button> {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 280,
      height: 50,
      child: ElevatedButton(
        key: Key("SubmitButtonKey"),
        onPressed: widget.isEnabled ? () => widget.onSubmitFunc() : null,
        child: Text(
          "Confirm",
          style: TextStyle(fontSize: 22),
        ),
        style: ButtonStyle(
          shape: MaterialStateProperty.all<RoundedRectangleBorder>(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(25.0),
            ),
          ),
          backgroundColor: MaterialStateProperty.all(Colors.black26),
        ),
      ),
    );
  }
}
