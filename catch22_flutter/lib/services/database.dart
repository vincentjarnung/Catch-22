import 'package:cloud_firestore/cloud_firestore.dart';
import 'auth.dart';

class DatabaseService {
  AuthService _auth = AuthService();
  Future newUserData(
      String userName, String email, String uid, int stepGoal) async {
    return await FirebaseFirestore.instance.collection('users').doc(uid).set({
      'userName': userName,
      'email': email,
      'stepGoal': stepGoal,
    });
  }

  Future updateStepGoal(int stepGoal) async {
    return await FirebaseFirestore.instance
        .collection('users')
        .doc(_auth.getCurrentUser())
        .update({'stepGoal': stepGoal});
  }

  Stream<DocumentSnapshot> get user {
    return FirebaseFirestore.instance
        .collection('users')
        .doc(_auth.getCurrentUser())
        .snapshots();
  }
}
