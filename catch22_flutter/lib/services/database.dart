import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
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

  Future newActivity(String userName, String name, int goal, bool isStep,
      String endDate, String code) async {
    print(userName);
    await FirebaseFirestore.instance.collection('activities').doc(name).set({
      'goal': goal,
      'isStep': isStep,
      'endDate': endDate,
      'startDate': DateFormat('yyyy-MM-dd').format(DateTime.now()),
      'code': code,
      'currentSteps': 0
    }).whenComplete(() {
      return FirebaseFirestore.instance
          .collection('activities')
          .doc(name)
          .collection('members')
          .doc(_auth.getCurrentUser())
          .set({'userName': userName});
    });
  }

  Future jGroup(String groupName, String name) async {
    print(name);
    return await FirebaseFirestore.instance
        .collection('activities')
        .doc(groupName)
        .collection('members')
        .doc(_auth.getCurrentUser())
        .set({'userName': name});
  }

  Future joinActivity(String name) async {
    return await FirebaseFirestore.instance
        .collection('users')
        .doc(_auth.getCurrentUser())
        .update({
      'activities': FieldValue.arrayUnion([name])
    });
  }

  Future setSteps() async {
    for (int i = 1; i < 32; i++) {
      Random random = new Random();
      int randNum = random.nextInt(5000) + 5000; // from 5000 upto 9999 included
      String date = DateFormat('yyyy-MM-dd')
          .format(DateTime.now().subtract(Duration(days: i)));

      await FirebaseFirestore.instance
          .collection('users')
          .doc(_auth.getCurrentUser())
          .collection('steps')
          .doc(date)
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

  Stream<DocumentSnapshot> get activities async* {
    yield* FirebaseFirestore.instance
        .collection('users')
        .doc(_auth.getCurrentUser())
        .snapshots();
  }

  Stream<DocumentSnapshot> viewActivity(String name) async* {
    yield* FirebaseFirestore.instance
        .collection('activities')
        .doc(name)
        .snapshots();
  }

  Stream<QuerySnapshot> get achievements {
    return FirebaseFirestore.instance.collection('achievements').snapshots();
  }

  Stream<QuerySnapshot> get userAchievements {
    return FirebaseFirestore.instance
        .collection('users')
        .doc(_auth.getCurrentUser())
        .collection('achievements')
        .snapshots();
  }

  Future<String> getToolImg(String imgName) async {
    final ref = FirebaseStorage.instance.ref().child(imgName);
    String url = await ref.getDownloadURL();
    return url;
  }
}
