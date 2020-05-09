import 'package:flutter/material.dart';
import 'package:flash_chat/constants.dart';

class EmailTextField extends StatelessWidget {
  EmailTextField({@required this.onChanged});

  final Function onChanged;

  @override
  Widget build(BuildContext context) {
    return TextField(
      keyboardType: TextInputType.emailAddress,
      textAlign: TextAlign.center,
      onChanged: onChanged,
      decoration: kTextFieldDecoration.copyWith(hintText: 'Enter your email'),
    );
  }
}

class PasswordTextField extends StatelessWidget {
  PasswordTextField({@required this.onChanged});

  final Function onChanged;

  @override
  Widget build(BuildContext context) {
    return TextField(
      obscureText: true,
      textAlign: TextAlign.center,
      onChanged: onChanged,
      decoration: kTextFieldDecoration.copyWith(hintText: 'Enter your password'),
    );
  }
}
