import 'package:cloud_firestore/cloud_firestore.dart';
import 'auth.dart';

class DatabaseService {
  Future newUserData(String userName, String email, String uid) async {
    return await FirebaseFirestore.instance.collection('users').doc(uid).set({
      'userName': userName,
      'email': email,
    });
  }
}
