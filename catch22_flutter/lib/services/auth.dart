import 'package:catch22_flutter/models/simple_user.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'database.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  //Sign In
  Future signIn(String email, String password) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
          email: email, password: password);
      User user = userCredential.user;
      return (_userFromFirebaseUser(user));
    } catch (e) {
      print(e.toString());
      return null;
    }
  }

  String getCurrentUser() {
    User fUser = _auth.currentUser;
    String uid = fUser.uid;
    return uid;
  }

  Stream<User> get user {
    return _auth.idTokenChanges();
  }

  SimpleUser _userFromFirebaseUser(User user) {
    return user != null ? SimpleUser(uid: user.uid) : null;
  }

  String _getCurrentUser() {
    User fUser = _auth.currentUser;
    return fUser.uid;
  }

  //Register
  Future createUser(
      String userName, String email, String password, int stepGoal) async {
    try {
      UserCredential userCredential = await _auth
          .createUserWithEmailAndPassword(email: email, password: password);
      User user = userCredential.user;

      await DatabaseService().newUserData(userName, email, user.uid, stepGoal);

      return (_userFromFirebaseUser(user));
    } catch (e) {
      print(e.toString());
      return null;
    }
  }

  //Sign out
  Future signOut() async {
    try {
      return await _auth.signOut();
    } catch (e) {
      print(e.toString());
      return null;
    }
  }
}
