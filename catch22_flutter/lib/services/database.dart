import 'package:catch22_flutter/models/steps_day.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:intl/intl.dart';
import 'auth.dart';
import 'dart:math';

class DatabaseService {
  AuthService _auth = AuthService();

  var usersInstance = FirebaseFirestore.instance.collection('users');
  var activitiesInstance = FirebaseFirestore.instance.collection('activities');
  var achievementsInstance =
      FirebaseFirestore.instance.collection('achievements');

  Future newUserData(
      String userName, String email, String uid, int stepGoal) async {
    return await usersInstance.doc(uid).set({
      'userName': userName,
      'email': email,
      'stepGoal': stepGoal,
      'activities': []
    });
  }

  Future updateStepGoal(int stepGoal) async {
    return await usersInstance
        .doc(_auth.getCurrentUser())
        .update({'stepGoal': stepGoal});
  }

  Future updateSteps(int steps, String date, bool isLast) async {
    return await usersInstance
        .doc(_auth.getCurrentUser())
        .collection('steps')
        .doc(date)
        .update({'steps': steps});
  }

  Future addActivity(String date, int steps) async {
    return await usersInstance
        .doc(_auth.getCurrentUser())
        .collection('steps')
        .doc(date)
        .update({'steps': FieldValue.increment(steps)});
  }

  Future getWalkedSteps() async {
    return await usersInstance
        .doc(_auth.getCurrentUser())
        .collection('steps')
        .where('isLast', isEqualTo: true)
        .get();
  }

  Future<List<StepsDayModel>> getDateAndSteps() async {
    List<StepsDayModel> allData = [];
    await steps.then((snapshot) {
      snapshot.docs.forEach((doc) {
        allData.add(
            StepsDayModel(date: doc.id, steps: doc.data()['steps'].toDouble()));
      });
    });
    if (allData.length != 0) {
      print(allData.length);
      DateTime now = DateTime.now();
      DateTime lastDate = DateTime.parse(allData[allData.length - 1].date);
      int diff = now.difference(lastDate).inDays;

      for (int n = 1; n <= diff; n++) {
        String fDate = DateFormat('yyyy-MM-dd')
            .format(DateTime(lastDate.year, lastDate.month, lastDate.day + n));
        allData.add(StepsDayModel(date: fDate, steps: 0));
      }
    }
    return allData;
  }

  Future newActivity(String userName, String name, int goal, bool isStep,
      String endDate, String code) async {
    print(userName);
    await activitiesInstance.doc(name).set({
      'goal': goal,
      'isStep': isStep,
      'endDate': endDate,
      'startDate': DateFormat('yyyy-MM-dd').format(DateTime.now()),
      'code': code,
      'currentSteps': 0
    }).whenComplete(() {
      return activitiesInstance
          .doc(name)
          .collection('members')
          .doc(_auth.getCurrentUser())
          .set({'userName': userName});
    });
  }

  Future jGroup(String groupName, String name) async {
    print(name);
    return await activitiesInstance
        .doc(groupName)
        .collection('members')
        .doc(_auth.getCurrentUser())
        .set({'userName': name});
  }

  Future joinActivity(String name) async {
    return await usersInstance.doc(_auth.getCurrentUser()).update({
      'activities': FieldValue.arrayUnion([name])
    });
  }

  Future setSteps() async {
    for (int i = 0; i < 32; i++) {
      Random random = new Random();
      int randNum = random.nextInt(5000) + 5000; // from 5000 upto 9999 included
      bool isLastAddedData = false;

      String date = DateFormat('yyyy-MM-dd')
          .format(DateTime.now().subtract(Duration(days: i)));
      if (i == 0) {
        randNum = 0;
        isLastAddedData = true;
      }

      await usersInstance
          .doc(_auth.getCurrentUser())
          .collection('steps')
          .doc(date)
          .set({'steps': randNum, 'isLast': isLastAddedData})
          .then((value) => print('Data Added'))
          .catchError((error) => (print('Error: ' + error)));
    }
  }

  Future createFirstAchievement() async {
    return await usersInstance
        .doc(_auth.getCurrentUser())
        .collection('achievements')
        .doc('register')
        .set({
      'date': DateFormat('yyyy-MM-dd').format(DateTime.now()),
      'ref': 'register.png'
    });
  }

  Future<bool> usernameCheck(String username) async {
    final result =
        await usersInstance.where('userName', isEqualTo: username).get();
    return result.docs.isEmpty;
  }

  Future<String> ownAchievementCheck(achievement) async {
    String date;
    final result = await usersInstance
        .doc(_auth.getCurrentUser())
        .collection('achievements')
        .where('ref', isEqualTo: achievement)
        .get();

    result.docs.forEach((element) {
      date = element.data()['date'];
    });
    return date;
  }

  Future<List<dynamic>> groups() async {
    DocumentReference docRef = usersInstance.doc(_auth.getCurrentUser());
    List<dynamic> activi = List<String>();
    return docRef.get().then((snapshot) {
      if (snapshot.exists) {
        activi = snapshot.data()['activities'].toList();
      }
      return activi;
    });
  }

  Future<QuerySnapshot> get steps async {
    return await usersInstance
        .doc(_auth.getCurrentUser())
        .collection('steps')
        .get();
  }

  Future<DocumentSnapshot> get user async {
    return await usersInstance.doc(_auth.getCurrentUser()).get();
  }

  Stream<DocumentSnapshot> get activities async* {
    yield* usersInstance.doc(_auth.getCurrentUser()).snapshots();
  }

  Stream<DocumentSnapshot> viewActivity(String name) async* {
    yield* activitiesInstance.doc(name).snapshots();
  }

  Future<QuerySnapshot> get achievements {
    return achievementsInstance.get();
  }

  Stream<QuerySnapshot> get userAchievements {
    return usersInstance
        .doc(_auth.getCurrentUser())
        .collection('achievements')
        .snapshots();
  }

  Future<String> getAchiImg(String imgName) async {
    final ref = FirebaseStorage.instance.ref().child(imgName);
    String url = await ref.getDownloadURL();
    return url;
  }
}
