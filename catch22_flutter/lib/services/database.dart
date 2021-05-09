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
      Future.delayed(const Duration(milliseconds: 1000), () async {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(_auth.getCurrentUser())
            .collection('steps')
            .doc('2021-05-' + day)
            .set({'steps': randNum})
            .then((value) => print('Data Added'))
            .catchError((error) => (print('Error: ' + error)));
      });
    }
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
