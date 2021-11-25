import 'package:flutter/material.dart';
import 'package:music_room/src/bloc/settings/settings_bloc.dart';
import 'package:music_room/src/bloc/signup/signup_bloc.dart';
import 'package:music_room/src/mixins/validation_mixins.dart';
import 'package:provider/provider.dart';

class BioInput extends StatefulWidget {
  const BioInput({
    Key? key,
    required this.onChangedFunc,
    required this.textFormKey,
    required this.initialValue,
  }) : super(key: key);
  final Function(String data) onChangedFunc;
  final String initialValue;
  final Key textFormKey;
  @override
  _BioInputState createState() => _BioInputState();
}

class _BioInputState extends State<BioInput> {
  final GlobalKey<FormState> _formPseudoFieldKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Container(
        width: 280,
        child: Form(
          autovalidateMode: AutovalidateMode.onUserInteraction,
          key: _formPseudoFieldKey,
          child: TextFormField(
            textAlign: TextAlign.justify,
            initialValue: widget.initialValue,
            minLines: 1,
            maxLines: 4,
            key: widget.textFormKey,
            onChanged: widget.onChangedFunc,
            decoration: InputDecoration(
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
              labelText: 'Bio',
            ),
            style: TextStyle(color: Colors.white),
          ),
        ),
      ),
    );
  }
}
