import 'package:flutter/material.dart';

class InputForm extends StatelessWidget {
  const InputForm({
    Key? key,
    required this.controller,
    this.hintLabel,
    this.obscureText = false,
    this.textColor,
    this.autoValidateMode,
    this.validationFunction,
    this.onChanged,
  }) : super(key: key);

  final TextEditingController controller;
  final String? hintLabel;
  final bool obscureText;
  final Color? textColor;
  final AutovalidateMode? autoValidateMode;
  final String? Function(String? value)? validationFunction;
  final void Function(String? value)? onChanged;

  UnderlineInputBorder getBorder(Color? color) {
    return UnderlineInputBorder(
      borderSide: BorderSide(
        color: color ?? Colors.white,
        width: 3,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(5, 0, 5, 0),
      child: TextFormField(
        maxLines: 1,
        onChanged: onChanged,
        maxLength: 50,
        autovalidateMode: autoValidateMode ?? AutovalidateMode.disabled,
        validator: validationFunction ??
            (value) {
              return null;
            },
        obscureText: obscureText,
        controller: controller,
        style: Theme.of(context).textTheme.bodyText1,
        decoration: InputDecoration(
            enabledBorder: getBorder(textColor),
            errorBorder: getBorder(Colors.red),
            helperText: "",
            labelText: hintLabel,
            labelStyle: TextStyle(
              color: textColor ?? Colors.white70,
              fontSize: 15,
            ),
            counterText: ""),
      ),
    );
  }
}
