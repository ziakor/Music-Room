import 'package:flutter/material.dart';

class TextInput extends StatefulWidget {
  const TextInput(
      {Key? key,
      required this.onChangedFunc,
      required this.textFormKey,
      this.initialValue,
      required this.label,
      this.paddingBottomValue = 8.0,
      this.hasSuffixIcon,
      this.textController})
      : super(key: key);
  final Function(String data) onChangedFunc;
  final String? initialValue;
  final Key textFormKey;
  final String label;
  final double paddingBottomValue;
  final Widget? hasSuffixIcon;
  final TextEditingController? textController;
  @override
  _TextInputState createState() => _TextInputState();
}

class _TextInputState extends State<TextInput> {
  final GlobalKey<FormState> _formPseudoFieldKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: widget.paddingBottomValue),
      child: Container(
        width: 270,
        child: Form(
          autovalidateMode: AutovalidateMode.onUserInteraction,
          key: _formPseudoFieldKey,
          child: TextFormField(
            controller: widget.textController,
            textAlign: TextAlign.justify,
            initialValue: widget.initialValue,
            key: widget.textFormKey,
            onChanged: widget.onChangedFunc,
            decoration: InputDecoration(
              suffixIcon: widget.hasSuffixIcon,
              alignLabelWithHint: true,
              border: OutlineInputBorder(
                borderRadius: const BorderRadius.all(
                  Radius.circular(30.0),
                ),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: const BorderRadius.all(
                  Radius.circular(30.0),
                ),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: const BorderRadius.all(
                  Radius.circular(30.0),
                ),
                borderSide: BorderSide(color: Colors.grey.shade700, width: 1.0),
              ),
              filled: true,
              contentPadding: EdgeInsets.fromLTRB(25, 15, 15, 0),
              fillColor: Colors.black26,
              labelStyle: TextStyle(color: Colors.white),
              errorStyle: TextStyle(
                  fontStyle: FontStyle.italic, fontWeight: FontWeight.w400),
              labelText: widget.label,
            ),
            style: TextStyle(color: Colors.white),
          ),
        ),
      ),
    );
  }
}
