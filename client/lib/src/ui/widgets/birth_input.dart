import 'package:flutter/material.dart';

class BirthInput extends StatefulWidget {
  const BirthInput({
    Key? key,
    required this.updateFunc,
    required this.formKey,
    required this.value,
  }) : super(key: key);
  final Function(DateTime data) updateFunc;
  final DateTime? value;
  final Key formKey;
  @override
  _BirthInputState createState() => _BirthInputState();
}

class _BirthInputState extends State<BirthInput> {
  final TextEditingController _formBirthFieldControllerKey =
      TextEditingController();

  final FocusNode _formBirthFieldNode = FocusNode();

  void _selectDateOfBirth(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: widget.value ?? DateTime(1980, 11, 9),
      firstDate: DateTime(1900),
      lastDate: DateTime(2022),
    );
    if (picked != null) {
      _formBirthFieldControllerKey.text =
          "${picked.year}/${picked.month}/${picked.day}";
      widget.updateFunc(picked);
    }
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
            readOnly: true,
            key: widget.formKey,
            controller: _formBirthFieldControllerKey
              ..text = widget.value != null
                  ? "${widget.value!.year}/${widget.value!.month}/${widget.value!.day}"
                  : "",
            focusNode: _formBirthFieldNode,
            onTap: () {
              _formBirthFieldNode.unfocus();
              _selectDateOfBirth(context);
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
              errorStyle: TextStyle(
                  fontStyle: FontStyle.italic, fontWeight: FontWeight.w400),
              labelText: 'Date of birth',
            ),
            style: TextStyle(color: Colors.white),
          ),
        ),
      ),
    );
  }
}
