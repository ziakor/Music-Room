import 'package:flutter/material.dart';
import 'package:music_room/src/bloc/settings/settings_bloc.dart';
import 'package:music_room/src/mixins/validation_mixins.dart';
import 'package:provider/provider.dart';

class EmailInput extends StatefulWidget {
  const EmailInput({
    Key? key,
    required this.updateFunc,
    required this.formKey,
    required this.initialValue,
  }) : super(key: key);
  final Function(String data) updateFunc;
  final String initialValue;
  final Key formKey;
  @override
  _EmailInputState createState() => _EmailInputState();
}

class _EmailInputState extends State<EmailInput> {
  String? _validateEmail(String? email) {
    if (email != null) {
      if (email.isEmpty) return ("Please enter your email");
      if (!ValidationMixin().validateEmail(email)) return ("Invalid email");
    }
    return (null);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Container(
        width: 280,
        child: Form(
          autovalidateMode: AutovalidateMode.onUserInteraction,
          child: TextFormField(
            initialValue: widget.initialValue,
            keyboardType: TextInputType.emailAddress,
            key: widget.formKey,
            validator: (value) {
              final String? str = _validateEmail(value);
              if (str != null) {
                widget.updateFunc("");
                return (str);
              }
              widget.updateFunc(value!);
              return (null);
            },
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
              contentPadding: EdgeInsets.fromLTRB(25, 0, 5, 0),
              fillColor: Colors.black26,
              labelStyle: TextStyle(color: Colors.white),
              labelText: 'Email',
            ),
            style: TextStyle(color: Colors.white),
          ),
        ),
      ),
    );
  }
}
