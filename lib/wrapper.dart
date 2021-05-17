
import 'package:firebaseapp/authenticate/authenticate.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'home/home.dart';
import 'package:firebaseapp/models/user.dart';

/*
class Wrapper extends StatefulWidget {
  @override
  _WrapperState createState() => _WrapperState();
}

class _WrapperState extends State<Wrapper> {
  //-------------------------------get User id
  String id = "";
  FirebaseUser user;
  Future<void> getUserID() async {
    final FirebaseUser userData = await FirebaseAuth.instance.currentUser();
    setState(() {
      user = userData;
      id = userData.uid.toString();
    });
  }
  //----------------------------------------------
  bool disabled = false;
  final mainref = FirebaseDatabase.instance;
  Future<void> getUserData() async {
    final ref = mainref.reference().child('Consultants').child('$id');
    await ref.child('disabled').once().then((DataSnapshot snapshot) {
      setState(() {
        disabled = snapshot.value;
        print(disabled);
      });
    });
  }
  //-----------------------------------------------
  Future<void> getData() async {
    await getUserID();
    await getUserData();
  }
  //-----------------------------------------------

  void initState() {
    super.initState();
    getData();
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<User>(context);
    print(user);

    //return either Home or Authenticate widget
    if (user == null) {
      return Authenticate();
    } else {
      if (disabled == true) {
        return Home();
      } else {
        return Banned();
      }
    }
  }
}
*/
class Wrapper extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final user = Provider.of<User>(context);
    print(user);

    //return either Home or Authenticate widget
    if (user == null) {
      return Authenticate();
    } else {
      return Home();
    }
  }
}
