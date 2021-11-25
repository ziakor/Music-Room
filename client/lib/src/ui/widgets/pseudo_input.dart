import 'package:flutter/material.dart';
import 'package:music_room/src/bloc/settings/settings_bloc.dart';
import 'package:music_room/src/bloc/signup/signup_bloc.dart';
import 'package:music_room/src/mixins/validation_mixins.dart';
import 'package:provider/provider.dart';

class PseudoInput extends StatefulWidget {
  const PseudoInput(
      {Key? key,
      required this.updateFunc,
      required this.textFormKey,
      required this.initialValue,
      required this.pseudoAvailable})
      : super(key: key);
  final Function(String data) updateFunc;
  final String initialValue;
  final bool? pseudoAvailable;
  final Key textFormKey;
  @override
  _PseudoInputState createState() => _PseudoInputState();
}

class _PseudoInputState extends State<PseudoInput> {
  final GlobalKey<FormState> _formPseudoFieldKey = GlobalKey<FormState>();
  String? _validatePseudo(String? pseudo, bool? pseudoAvailable) {
    if (!ValidationMixin().validatePseudo(pseudo!)) {
      return ("Invalid pseudo");
    }
    if (pseudo.length > 1 && pseudoAvailable == false) {
      return ("This pseudo is already taken");
    }
    return (null);
  }

  Widget _iconAvailable(bool pseudoAvailable) {
    if (pseudoAvailable == true) {
      return (Icon(Icons.check,
          key: Key("IconAvailablePseudoKey"), color: Colors.green.shade700));
    }
    return (Icon(Icons.close,
        key: Key("IconUnavailablePseudoKey"), color: Colors.red.shade700));
  }

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
            initialValue: widget.initialValue,
            key: widget.textFormKey,
            validator: (value) {
              widget.updateFunc(value!);
              final String? str =
                  _validatePseudo(value, widget.pseudoAvailable);
              return (str);
            },
            decoration: InputDecoration(
              suffixIcon: widget.pseudoAvailable == null
                  ? Icon(null)
                  : _iconAvailable(widget.pseudoAvailable!),
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
              errorStyle: TextStyle(
                  fontStyle: FontStyle.italic, fontWeight: FontWeight.w400),
              labelText: 'Pseudo',
            ),
            style: TextStyle(color: Colors.white),
          ),
        ),
      ),
    );
  }
}
