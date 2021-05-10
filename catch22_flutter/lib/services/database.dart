import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'auth.dart';
import 'dart:math';

class DatabaseService {
  AuthService _auth = AuthService();

  Future newUserData(
      String userName, String email, String uid, int stepGoal) async {
    return await FirebaseFirestore.instance.collection('users').doc(uid).set({
      'userName': userName,
      'email': email,
      'stepGoal': stepGoal,
      'activities': []
    });
  }

  Future updateStepGoal(int stepGoal) async {
    return await FirebaseFirestore.instance
        .collection('users')
        .doc(_auth.getCurrentUser())
        .update({'stepGoal': stepGoal});
  }

  Future addActivity(String date, int steps) async {
    return await FirebaseFirestore.instance
        .collection('users')
        .doc(_auth.getCurrentUser())
        .collection('steps')
        .doc(date)
        .update({'steps': FieldValue.increment(steps)});
  }

  Future newActivity(
      String name, int goal, bool isStep, String endDate, String code) async {
    print(name);
    print(getUserName());
    await FirebaseFirestore.instance.collection('activities').doc(name).set({
      'goal': goal,
      'isStep': isStep,
      'endDate': endDate,
      'code': code
    }).whenComplete(() {
      return FirebaseFirestore.instance
          .collection('activities')
          .doc(name)
          .collection('members')
          .doc(_auth.getCurrentUser())
          .set({'userName': 'vincent'});
    });
  }

  Future joinActivity(String name) async {
    return await FirebaseFirestore.instance
        .collection('users')
        .doc(_auth.getCurrentUser())
        .update({
      'activities': FieldValue.arrayUnion([name])
    });
  }

  Future getUserName() async {
    String userName;
    DocumentReference docRef = FirebaseFirestore.instance
        .collection('users')
        .doc(_auth.getCurrentUser());
    await docRef.get().then((value) {
      userName = value.data()['userName'].toString();
    });
    return userName;
  }

  Future setSteps() async {
    for (int i = 1; i < 32; i++) {
      String day;
      Random random = new Random();
      int randNum = random.nextInt(5000) + 5000; // from 10 upto 99 included

      if (i < 10) {
        day = '0' + i.toString();
      } else {
        day = i.toString();
      }

      await FirebaseFirestore.instance
          .collection('users')
          .doc(_auth.getCurrentUser())
          .collection('steps')
          .doc('2021-05-' + day)
          .set({'steps': randNum})
          .then((value) => print('Data Added'))
          .catchError((error) => (print('Error: ' + error)));
    }
  }

  Future<bool> usernameCheck(String username) async {
    final result = await FirebaseFirestore.instance
        .collection('users')
        .where('userName', isEqualTo: username)
        .get();
    return result.docs.isEmpty;
  }

  Future<List<dynamic>> groups() async {
    DocumentReference docRef = FirebaseFirestore.instance
        .collection("users")
        .doc(_auth.getCurrentUser());
    List<dynamic> activi = List<String>();
    return docRef.get().then((snapshot) {
      if (snapshot.exists) {
        activi = snapshot.data()['activities'].toList();
        print(activi);
      }
      return activi;
    });
  }

  Future<QuerySnapshot> get steps async {
    return await FirebaseFirestore.instance
        .collection('users')
        .doc(_auth.getCurrentUser())
        .collection('steps')
        .get();
  }

  Future<DocumentSnapshot> get user async {
    return await FirebaseFirestore.instance
        .collection('users')
        .doc(_auth.getCurrentUser())
        .get();
  }
}
