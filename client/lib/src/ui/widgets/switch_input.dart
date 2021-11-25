import 'package:flutter/material.dart';

class SwitchInput extends StatefulWidget {
  const SwitchInput({
    Key? key,
    required this.onChangedFunc,
    required this.label,
    required this.trueValue,
    required this.falseValue,
    required this.value,
    this.width = 286,
    this.switchPadding = const EdgeInsets.fromLTRB(25, 0, 0, 0),
  }) : super(key: key);
  final Function(bool value) onChangedFunc;
  final String label;
  final String trueValue;
  final String falseValue;
  final bool value;
  final double width;
  final EdgeInsetsGeometry switchPadding;
  @override
  _SwitchInputState createState() => _SwitchInputState();
}

class _SwitchInputState extends State<SwitchInput> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(10, 0, 0, 0),
      width: widget.width,
      child: Row(
        children: [
          Text(
            widget.label,
            style: TextStyle(color: Colors.white, fontSize: 18),
          ),
          Text(
            widget.value == true ? widget.trueValue : widget.falseValue,
            style: TextStyle(color: Colors.white, fontSize: 18),
          ),
          Padding(
            padding: widget.switchPadding,
            child: Transform.scale(
                scale: 1.3,
                child: Switch(
                    value: widget.value,
                    onChanged: (value) => widget.onChangedFunc(value))),
          )
        ],
      ),
    );
  }
}
