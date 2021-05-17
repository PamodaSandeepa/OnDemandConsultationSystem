import 'package:firebaseapp/Settings/changePassword/user_controller.dart';
import 'package:firebaseapp/edit_profile/settings.dart';
import 'package:flutter/material.dart';

class ChangePassword extends StatefulWidget {
  @override
  _ChangePasswordState createState() => _ChangePasswordState();
}

class _ChangePasswordState extends State<ChangePassword> {
  var _displayNameController = TextEditingController();
  var _passwordController = TextEditingController();
  var _newPasswordController = TextEditingController();
  var _repeatPasswordController = TextEditingController();

  var _formKey = GlobalKey<FormState>();

  bool checkCurrentPasswordValid = true;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _displayNameController.dispose();
    _passwordController.dispose();
    _newPasswordController.dispose();
    _repeatPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 1,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: Colors.blueAccent,
          ),
          onPressed: () {
            Navigator.of(context).push(MaterialPageRoute(
                builder: (BuildContext context) => SettingsPage()));
          },
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              SizedBox(height: 20.0),
              Flexible(
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: <Widget>[
                      Text(
                        "Change Password",
                        style: TextStyle(
                            fontSize: 25,
                            fontWeight: FontWeight.w500,
                            color: Colors.blueAccent),
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      TextFormField(
                        decoration: InputDecoration(
                          fillColor: Colors.white,
                          labelText: 'Password',
                          enabledBorder: OutlineInputBorder(
                              borderSide:
                                  BorderSide(color: Colors.white, width: 3.0)),
                          focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                  color: Colors.pinkAccent, width: 2.0)),
                          labelStyle: TextStyle(
                              color: Colors.black87,
                              fontSize: 15,
                              fontFamily: 'AvenirLight'),
                          hintText: "Password",
                          errorText: checkCurrentPasswordValid
                              ? null
                              : "Please double check your current password",
                        ),
                        controller: _passwordController,
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      TextFormField(
                        decoration: InputDecoration(
                            fillColor: Colors.white,
                            labelText: 'New Password',
                            enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                    color: Colors.white, width: 3.0)),
                            focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                    color: Colors.pinkAccent, width: 2.0)),
                            labelStyle: TextStyle(
                                color: Colors.black87,
                                fontSize: 15,
                                fontFamily: 'AvenirLight'),
                            hintText: "New Password"),
                        controller: _newPasswordController,
                        validator: (val) => val.length < 6
                            ? 'fl'
                            : null,
                        obscureText: true,
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      TextFormField(
                        decoration: InputDecoration(
                          fillColor: Colors.white,
                          labelText: 'Repeat Password',
                          enabledBorder: OutlineInputBorder(
                              borderSide:
                                  BorderSide(color: Colors.white, width: 3.0)),
                          focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                  color: Colors.pinkAccent, width: 2.0)),
                          labelStyle: TextStyle(
                              color: Colors.black87,
                              fontSize: 15,
                              fontFamily: 'AvenirLight'),
                          hintText: "Repeat Password",
                        ),
                        obscureText: true,
                        controller: _repeatPasswordController,
                        validator: (value) {
                          return _newPasswordController.text ==
                                  value //check repeat password previous entered password
                              ? null
                              : "Please validate your entered password";
                        },
                      )
                    ],
                  ),
                ),
              ),
              SizedBox(height: 10),
              RaisedButton(
                color: Colors.blueAccent,
                padding: EdgeInsets.symmetric(horizontal: 10),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5)),
                onPressed: () async {
                  //      var auth = locator.get<UserController>();
                  UserController auth =
                      UserController(); //creat a object of User controller class
                  checkCurrentPasswordValid =
                      await auth.validateCurrentPassword(
                          _passwordController.text); //true or false

                  setState(() {});

                  if (_formKey.currentState.validate() &&
                      checkCurrentPasswordValid) {
                    auth.updateUserPassword(_newPasswordController.text);
                    Navigator.pop(context);
                  }
                },
                child: Text("Save Password",
                    style: TextStyle(
                        fontSize: 14, letterSpacing: 1, color: Colors.black)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
