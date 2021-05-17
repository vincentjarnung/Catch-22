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
  var activitiesCompInstance =
      FirebaseFirestore.instance.collection('activitiesComp');

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
        .set({'steps': steps, 'isLast': isLast, 'addedSteps': 0});
  }

  Future addActivity(String date, int steps) async {
    return await usersInstance
        .doc(_auth.getCurrentUser())
        .collection('steps')
        .doc(date)
        .update({'addedSteps': FieldValue.increment(steps)});
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
        allData.add(StepsDayModel(
            date: doc.id,
            steps:
                (doc.data()['steps'] + doc.data()['addedSteps']).toDouble()));
      });
    });
    return allData;
  }

  Future newActivity(String name, int goal, String endDate, String code) async {
    await activitiesInstance.doc(code).set({
      'groupName': name,
      'goal': goal,
      'endDate': endDate,
      'startDate': DateFormat('yyyy-MM-dd').format(DateTime.now()),
      'code': code,
      'currentSteps': 0,
      'todaysSteps': 0
    }).whenComplete(() {
      print('done');
      setMemStep(code);
    });
  }

  Future<List> getGroups() async {
    List codes;
    var user = await usersInstance.doc(_auth.getCurrentUser()).get();
    codes = user.data()['activities'];
    print(codes);
    return codes;
  }

  Future<String> getGroupName(String code) async {
    var group = await activitiesInstance.doc(code).get();
    var groupComp = await activitiesCompInstance.doc(code).get();
    try {
      return group.data()['groupName'];
    } catch (e) {
      return groupComp.data()['groupName'];
    }
  }

  Future setMemStep(String code) async {
    String userName = await getUserName();
    var group = await activitiesInstance.doc(code).get();
    var curGroup = await activitiesInstance
        .doc(code)
        .collection('members')
        .doc(userName)
        .get();
    int diff;
    String start;
    try {
      start = group.data()['startDate'];
    } catch (e) {
      return setCompMemStep(code);
    }

    await steps.then((snapshot) {
      snapshot.docs.forEach((doc) async {
        DateTime date = DateTime.parse(doc.id);
        DateTime startDate = DateTime.parse(start);

        diff = date.difference(startDate).inDays;
        if (diff >= 0) {
          var alredyData;
          try {
            alredyData = curGroup.data()[doc.id];
          } catch (e) {
            alredyData = null;
          }

          var uSteps = doc.data()['steps'] + doc.data()['addedSteps'];

          if (alredyData == null) {
            await activitiesInstance
                .doc(code)
                .collection('members')
                .doc(userName)
                .set({doc.id: doc.data()['steps'] + doc.data()['addedSteps']});
            _setGroupSteps(
                code, doc.data()['steps'] + doc.data()['addedSteps']);
          } else if (alredyData < uSteps) {
            await activitiesInstance
                .doc(code)
                .collection('members')
                .doc(userName)
                .update({doc.id: FieldValue.increment(uSteps - alredyData)});
            _setGroupSteps(code, uSteps - alredyData);
          }
        }
      });
    }).whenComplete(() {
      if (diff == -1) {
        activitiesInstance
            .doc(code)
            .collection('members')
            .doc(userName)
            .set({DateFormat('yyyy-MM-dd').format(DateTime.now()): 0});
      }
    });
  }

  Future _setGroupSteps(String code, int val) async {
    return await activitiesInstance
        .doc(code)
        .update({'currentSteps': FieldValue.increment(val)});
  }

  Future newCompActivity(
      String name, bool isStep, String endDate, String code) async {
    await activitiesCompInstance.doc(code).set({
      'groupName': name,
      'endDate': endDate,
      'isStep': isStep,
      'startDate': DateFormat('yyyy-MM-dd').format(DateTime.now()),
      'code': code,
    }).whenComplete(() {
      print('done');
      setCompMemStep(code);
    });
  }

  Future setCompMemStep(String code) async {
    String userName = await getUserName();

    var group = await activitiesCompInstance.doc(code).get();
    var curGroup = await activitiesCompInstance
        .doc(code)
        .collection('members')
        .doc(userName)
        .get();
    int diff;
    String start = group.data()['startDate'];

    await steps.then((snapshot) {
      snapshot.docs.forEach((doc) async {
        DateTime date = DateTime.parse(doc.id);
        DateTime startDate = DateTime.parse(start);

        diff = date.difference(startDate).inDays;
        print(diff);
        if (diff >= 0) {
          var alredyData;
          try {
            alredyData = curGroup.data()[doc.id];
          } catch (e) {
            alredyData = null;
          }

          var uSteps = doc.data()['steps'] + doc.data()['addedSteps'];
          print(alredyData);
          if (alredyData == null) {
            await activitiesCompInstance
                .doc(code)
                .collection('members')
                .doc(userName)
                .set({doc.id: doc.data()['steps'] + doc.data()['addedSteps']});
          } else if (alredyData < uSteps) {
            await activitiesCompInstance
                .doc(code)
                .collection('members')
                .doc(userName)
                .update({doc.id: FieldValue.increment(uSteps - alredyData)});
          }
        }
      });
    }).whenComplete(() {
      if (diff == -1) {
        activitiesInstance
            .doc(code)
            .collection('members')
            .doc(userName)
            .set({DateFormat('yyyy-MM-dd').format(DateTime.now()): 0});
      }
    });
  }

  Future<String> getUserName() async {
    String userName;
    DocumentReference docRef = FirebaseFirestore.instance
        .collection('users')
        .doc(_auth.getCurrentUser());
    await docRef.get().then((value) {
      userName = value.data()['userName'];
    });

    return userName;
  }

  Future joinActivity(String code) async {
    return await usersInstance.doc(_auth.getCurrentUser()).update({
      'activities': FieldValue.arrayUnion([code])
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
          .set({'steps': randNum, 'isLast': isLastAddedData, 'addedSteps': 0})
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
