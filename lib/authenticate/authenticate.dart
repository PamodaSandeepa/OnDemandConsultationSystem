
import 'package:firebaseapp/authenticate/register_start.dart';
import 'package:firebaseapp/authenticate/sign_in.dart';
import 'package:flutter/material.dart';

class Authenticate extends StatefulWidget {
  @override
  _AuthenticateState createState() => _AuthenticateState();
}

class _AuthenticateState extends State<Authenticate> {
  bool showSignIn = true;  //to toggle between login and register pages

  //SignIn or Register
  void toggleview() {
    setState(() =>
        showSignIn = !showSignIn); 
  }

  @override
  Widget build(BuildContext context) {
    if (showSignIn) {
      return SignIn(tv: toggleview);
    } else {
      return Register_Start(tv: toggleview);
    }
  }
}
