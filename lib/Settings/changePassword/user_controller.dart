import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebaseapp/models/user.dart';
import 'package:firebaseapp/services/auth.dart';
import 'package:get_it/get_it.dart';

class UserController {
  FirebaseUser _currentUser;
//  AuthService _authRepo = locator.get<AuthService>();
  AuthService _authRepo = AuthService();          //create object of Authservice class

  Future init;

  UserController() {
    init = initUser();
  }

  Future<FirebaseUser> initUser() async {
    _currentUser = await FirebaseAuth.instance.currentUser();
    return _currentUser;
  }

  FirebaseUser get currentUser => _currentUser;

  Future<bool> validateCurrentPassword(String password) async {
    return await _authRepo.validatePassword(password);
  }

  void updateUserPassword(String password) {
    _authRepo.updatePassword(password);
  }
}
