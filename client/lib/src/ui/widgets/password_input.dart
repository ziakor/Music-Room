import 'package:flutter/material.dart';

class PasswordInput extends StatefulWidget {
  const PasswordInput(
      {Key? key,
      required this.validationFunc,
      required this.onSavedFunc,
      required this.textFormKey,
      required this.initialValue,
      required this.onChangedFunc,
      required this.labelText})
      : super(key: key);
  final Key textFormKey;
  final String? initialValue;
  final void Function(String?)? onSavedFunc;
  final void Function(String)? onChangedFunc;
  final String labelText;

  final String? Function(String?)? validationFunc;

  @override
  _PasswordInputState createState() => _PasswordInputState();
}

class _PasswordInputState extends State<PasswordInput> {
  final GlobalKey<FormState> formPasswordKey = GlobalKey<FormState>();
  bool _showPassword = false;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Container(
        width: 280,
        constraints: BoxConstraints(minHeight: 60),
        child: Form(
          key: formPasswordKey,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          child: Stack(
            children: [
              TextFormField(
                key: widget.textFormKey,
                autocorrect: false,
                obscureText: _showPassword,
                validator: widget.validationFunc,
                onSaved: widget.onSavedFunc,
                onChanged: widget.onChangedFunc,
                decoration: InputDecoration(
                  suffixIcon: IconButton(
                    onPressed: () => setState(() {
                      _showPassword = !_showPassword;
                    }),
                    icon: Icon(_showPassword
                        ? Icons.visibility_off
                        : Icons.visibility),
                  ),
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
                    borderSide:
                        BorderSide(color: Colors.grey.shade700, width: 1.0),
                  ),
                  filled: true,
                  contentPadding: EdgeInsets.fromLTRB(25, 0, 5, 0),
                  fillColor: Colors.black26,
                  labelStyle: TextStyle(color: Colors.white),
                  errorStyle: TextStyle(
                      fontStyle: FontStyle.italic, fontWeight: FontWeight.w400),
                  labelText: widget.labelText,
                ),
                style: TextStyle(color: Colors.white),
              ),
              Positioned(
                top: 49,
                left: 25,
                child: Text(
                  "At least 8 characters, 1 uppercase, 1 number and 1 symbole",
                  style: TextStyle(color: Colors.white, fontSize: 8),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
