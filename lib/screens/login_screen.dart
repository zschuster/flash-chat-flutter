import 'package:flash_chat/components/rounded_button.dart';
import 'package:flutter/material.dart';
import 'package:flash_chat/components/text_fields.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';

import 'chat_screen.dart';

class LoginScreen extends StatefulWidget {
  static const String routeName = 'login_screen';

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  String email;
  String password;
  bool showHUD = false;

  final FirebaseAuth _auth = FirebaseAuth.instance;


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: ModalProgressHUD(
        inAsyncCall: showHUD,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Flexible(
                child: Hero(
                  tag: 'flash_logo',
                  child: Container(
                    height: 200.0,
                    child: Image.asset('images/logo.png'),
                  ),
                ),
              ),
              SizedBox(
                height: 48.0,
              ),
              EmailTextField(
                onChanged: (emailAddress) {
                  email = emailAddress;
                },
              ),
              SizedBox(
                height: 8.0,
              ),
              PasswordTextField(
                onChanged: (pass){
                  password = pass;
                },
              ),
              SizedBox(
                height: 24.0,
              ),
              RoundedButton(
                color: Colors.lightBlueAccent,
                label: 'Log In',
                onPressed: () async {
                  setState(() {
                    showHUD = !showHUD;
                  });
                  try {
                    FirebaseUser user = (await _auth.signInWithEmailAndPassword(email: email, password: password)).user;
                    if (user != null) {
                      Navigator.pushNamed(context, ChatScreen.routeName);
                    }
                  } catch (e) {
                    print(e);
                  }

                  setState(() {
                    showHUD = !showHUD;
                  });
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}


