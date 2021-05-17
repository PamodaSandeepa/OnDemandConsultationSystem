import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebaseapp/Animation/animation.dart';
import 'package:firebaseapp/authenticate/reset.dart';
import 'package:firebaseapp/services/auth.dart';
import 'package:firebaseapp/shared/loading.dart';
import 'package:firebaseapp/wrapper.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class SignIn extends StatefulWidget {
  final Function tv;
  //create constructor for the SignIn widget for toggling
  SignIn({this.tv});

  @override
  _SignInState createState() => _SignInState();
}

class _SignInState extends State<SignIn> {
  final AuthService _auth = AuthService(); //create a object AuthService class

  final FirebaseAuth __auth = FirebaseAuth.instance; //FirebaseAuth object

  //-------------------------------------check if there any user
  FirebaseAuth auth = FirebaseAuth.instance;
  Future<void> checkAuthentication() async {
    auth.onAuthStateChanged.listen((user) async {
      if (user != null) {
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => Wrapper()));
      }
    });
  }
  //------------------------------------------------

  //---------------If there is no account for provieded email and password show error message
  showError(String errormessage) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('ERROR'),
            content: Text(
              errormessage,
              style: TextStyle(color: Colors.black54),
            ),
            actions: <Widget>[
              FlatButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text('OK'))
            ],
          );
        });
  }

  //------------------------------------------------------
//----------------------------------------------------------------------------------------------calculate ratings-pamo
  var ids = [];
  final response = FirebaseDatabase.instance.reference().child('Consultants');
  Future<void> getConsultantIdNames() async {
    await response.once().then((DataSnapshot snapshot) {
      Map<dynamic, dynamic> values = snapshot.value;
      if (values == null) {
        return;
      }
      for (String key in values.keys) {
        ids.add(key);
      }
    });

    print(ids);
  }

  var emails = [];
  Future<void> getEmailNames() async {
    for (int i = 0; i < ids.length; i++) {
      await response
          .child('${ids[i]}')
          .child('email')
          .once()
          .then((DataSnapshot snapshot) {
        if (snapshot.value == null) {
          return;
        }
        emails.add(snapshot.value);
      });
    }

    print(emails);
  }

  Future<void> getConsultantEmails() async {
    await getConsultantIdNames();
    await getEmailNames();
  }

  void initState() {
    super.initState();
    getConsultantEmails();
  }

  //-------------------------------------------------------------------------------------------------------
  final _formkey =
      GlobalKey<FormState>(); //help the validate email and password

  bool loading = false; //for loading screen

  //text field state
  String email = '';
  String password = '';
  String error = '';

  //-----------------------User Interface
  @override
  Widget build(BuildContext context) {
    return loading
        ? Loading()
        : Scaffold(
            //if loading is true then return the loading screen else back to current page
            backgroundColor: Colors.blue[100],
            body: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                    gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        colors: [
                      Colors.blue[900],
                      Colors.blue[600],
                      Colors.blue[400]
                    ])),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      SizedBox(
                        height: 60,
                      ),
                      Padding(
                        padding: EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            FadeAnimation(
                                1,
                                Text(
                                  "Login",
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 50),
                                )),
                            SizedBox(
                              height: 10,
                            ),
                            FadeAnimation(
                                1.3,
                                Text(
                                  "Welcome Back",
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 18),
                                )),
                          ],
                        ),
                      ),
                      SizedBox(height: 20),
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(30),
                                  topRight: Radius.circular(30))),
                          child: SingleChildScrollView(
                              child: Column(
                            children: [
                              FadeAnimation(
                                1.4,
                                Container(
                                    padding: EdgeInsets.symmetric(
                                        vertical: 20.0, horizontal: 30.0),
                                    child: Form(
                                      key: _formkey,
                                      child: Column(
                                        children: <Widget>[
                                          SizedBox(
                                            height: 70.0,
                                          ),
                                          TextFormField(
                                            decoration: InputDecoration(
                                              hintText: 'E-mail',
                                              prefixIcon: Icon(Icons.person),
                                              fillColor: Colors.white,
                                              filled: true,
                                              enabledBorder: OutlineInputBorder(
                                                  borderSide: BorderSide(
                                                      color: Colors.white,
                                                      width: 3.0)),
                                              focusedBorder: OutlineInputBorder(
                                                  borderSide: BorderSide(
                                                      color: Colors.pinkAccent,
                                                      width: 2.0)),
                                            ),
                                            //validation
                                            validator: (val) {
                                              if (val.isEmpty) {
                                                return 'Enter an email';
                                              } else {
                                                return null;
                                              }
                                            }, //Empty or not
                                            onChanged: (val) {
                                              //val means current value in form field
                                              setState(() => email = val);
                                            },
                                          ),
                                          SizedBox(
                                            height: 20.0,
                                          ),
                                          TextFormField(
                                            decoration: InputDecoration(
                                              hintText: 'Password',
                                              prefixIcon: Icon(Icons.lock),
                                              fillColor: Colors.white,
                                              filled: true,
                                              enabledBorder: OutlineInputBorder(
                                                  borderSide: BorderSide(
                                                      color: Colors.white,
                                                      width: 3.0)),
                                              focusedBorder: OutlineInputBorder(
                                                  borderSide: BorderSide(
                                                      color: Colors.pinkAccent,
                                                      width: 2.0)),
                                            ),
                                            //validation
                                            validator: (val) => val.length < 6
                                                ? 'Enter an password 6+ chars long'
                                                : null,
                                            obscureText: true, //don't see text
                                            onChanged: (val) {
                                              setState(() => password = val);
                                            },
                                          ),
                                        ],
                                      ),
                                    )),
                              ),
                              SizedBox(
                                height: 20,
                              ),
                              FadeAnimation(
                                  1.5,
                                  TextButton(
                                    onPressed: () => Navigator.of(context).push(
                                      MaterialPageRoute(
                                          builder: (context) => ResetScreen()),
                                    ),
                                    child: Text(
                                      "Forgot Password?",
                                      style: TextStyle(color: Colors.grey),
                                    ),
                                  )),
                              FadeAnimation(
                                1.6,
                                Container(
                                  padding: EdgeInsets.all(20.0),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: ButtonTheme(
                                          height: 50,
                                          child: RaisedButton(
                                              shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          20)),
                                              onPressed: () async {
                                                if (_formkey.currentState
                                                    .validate()) {
                                                  //valid or not
                                                  setState(() {
                                                    loading =
                                                        true; //if accept validation rules loading become true
                                                  });
                                                  bool validMail = false;
                                                  for (int i = 0;
                                                      i < emails.length;
                                                      i++) {
                                                    if (email == emails[i]) {
                                                      validMail = true;
                                                    }
                                                  }
                                                  if (validMail == false) {
                                                    setState(() {
                                                      loading = false;
                                                    });
                                                    error =
                                                        'Please supply a valid registered email';
                                                    showError(error);
                                                  } else {
                                                    dynamic result = await _auth
                                                        .signInWithEmailAndPassword(
                                                            email, password);

                                                    if (result == null) {
                                                      setState(() {
                                                        setState(() {
                                                          loading = false;
                                                        });
                                                        error =
                                                            'Could not sign in with those credentials. Try again!';
                                                        showError(error);
                                                      });
                                                    } else {
                                                      //else  signInWithEMailAndPassword Sucess
                                                      await checkAuthentication();
                                                    }
                                                  }
                                                }
                                              },
                                              color: Colors.blue,
                                              child: Text(
                                                'Log In',
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 20.0,
                                                ),
                                              )),
                                        ),
                                      ),
                                      SizedBox(width: 10.0),
                                      Expanded(
                                        child: ButtonTheme(
                                          height: 50,
                                          child: RaisedButton(
                                            shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(20)),
                                            onPressed: () async {
                                              widget.tv();
                                            },
                                            color: Colors.blue,
                                            child: Text(
                                              'Register',
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 20.0,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              SizedBox(
                                height: 20.0,
                              )
                            ],
                          )),
                        ),
                      ),
                    ])));
  }
}
