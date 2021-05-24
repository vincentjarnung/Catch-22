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

  Future leaveCompGroup(String code) async {
    String userName = await getUserName();
    var val = [code];
    await activitiesCompInstance
        .doc(code)
        .collection('members')
        .doc(userName)
        .collection('steps')
        .get()
        .then((value) {
          for (DocumentSnapshot ds in value.docs) {
            ds.reference.delete();
          }
        })
        .whenComplete(() => activitiesCompInstance
            .doc(code)
            .collection('members')
            .doc(userName)
            .delete()
            .whenComplete(() => usersInstance
                .doc(_auth.getCurrentUser())
                .update({'activities': FieldValue.arrayRemove(val)})))
        .whenComplete(() {
          try {
            var result =
                activitiesCompInstance.doc(code).collection('members').get();
            result.then((value) {
              if (value.docs.length == 0) {
                activitiesCompInstance.doc(code).delete();
              }
            });
          } catch (e) {
            print(e);
            activitiesCompInstance.doc(code).delete();
          }
        });
  }

  Future leaveGroup(String code) async {
    String userName = await getUserName();
    var val = [code];
    await activitiesInstance
        .doc(code)
        .collection('members')
        .doc(userName)
        .delete()
        .whenComplete(() => usersInstance
            .doc(_auth.getCurrentUser())
            .update({'activities': FieldValue.arrayRemove(val)}))
        .whenComplete(() {
      try {
        var result = activitiesInstance.doc(code).collection('members').get();
        result.then((value) {
          print(value.docs.length);
          if (value.docs.length == 0) {
            activitiesInstance.doc(code).delete();
          }
        });
      } catch (e) {
        print(e);
        activitiesInstance.doc(code).delete();
      }
    });
  }

  Future newUserData(
      String userName, String email, String uid, String token) async {
    return await usersInstance.doc(uid).set({
      'userName': userName,
      'email': email,
      'stepGoal': 5000,
      'activities': [],
      'token': token
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
    int diff;
    DateTime now = DateTime.now();
    String date;

    List<StepsDayModel> allData = [];
    try {
      await steps.then((snapshot) {
        snapshot.docs.forEach((doc) {
          allData.add(StepsDayModel(
              date: doc.id,
              steps:
                  (doc.data()['steps'] + doc.data()['addedSteps']).toDouble()));
        });
      }).whenComplete(() {
        diff = now
            .difference(DateTime.parse(allData[allData.length - 1].date))
            .inDays;
        print(diff.toString() + '  test');
        int i = diff;
        if (diff > 0) {
          while (i >= 0) {
            date = DateFormat('yyyy-MM-dd')
                .format(DateTime(now.year, now.month, now.day - i));
            updateSteps(0, date, true);
            allData.add(StepsDayModel(date: date, steps: 0));
            i--;
          }
        }
      });
    } catch (e) {
      allData = [];
    }

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
      setMem(code);
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

  Future<String> getGroupType(code) async {
    String test;
    var group = await activitiesInstance.doc(code).get();
    var groupComp = await activitiesCompInstance.doc(code).get();
    try {
      test = group.data()['groupName'];
      return 'Goal';
    } catch (e) {
      test = groupComp.data()['groupName'];
      return 'Challenge';
    }
  }

  Future<String> getGropEndDate(code) async {
    String test;
    var group = await activitiesInstance.doc(code).get();
    var groupComp = await activitiesCompInstance.doc(code).get();
    try {
      test = group.data()['endDate'];
    } catch (e) {
      test = groupComp.data()['endDate'];
    }
    return test;
  }

  Future setMem(String code) async {
    String userName = await getUserName();
    return await activitiesInstance
        .doc(code)
        .collection('members')
        .doc(userName)
        .set({'userName': userName}).whenComplete(() => setMemStep(code));
  }

  Future setMemStep(String code) async {
    String userName = await getUserName();
    var group = await activitiesInstance.doc(code).get();
    var groupMem = await activitiesInstance
        .doc(code)
        .collection('members')
        .doc(userName)
        .collection('steps')
        .get();
    var curGroup = await activitiesInstance
        .doc(code)
        .collection('members')
        .doc(userName)
        .get();
    int diff;
    String start;
    String lastDate;
    int diffExist;
    int todaySteps = 0;
    try {
      start = group.data()['startDate'];
    } catch (e) {
      return setCompMemStep(code);
    }
    try {
      print(groupMem.docs.last.id + '  id');
      lastDate = groupMem.docs.last.id;
      diffExist = DateTime.parse(lastDate).difference(DateTime.now()).inDays;
      todaySteps = groupMem.docs.last.data()['steps'];
    } catch (e) {}
    print(diffExist.toString() + ' ' + code);
    var userStepsToday = await usersInstance
        .doc(_auth.getCurrentUser())
        .collection('steps')
        .doc(DateFormat('yyyy-MM-dd').format(DateTime.now()))
        .get();
    int userStepsTod =
        userStepsToday.data()['steps'] + userStepsToday.data()['addedSteps'];
    print(userStepsTod);
    print(todaySteps);
    if (diffExist == null) {
      await steps.then((snapshot) {
        snapshot.docs.forEach((doc) async {
          DateTime date = DateTime.parse(doc.id);
          DateTime startDate = DateTime.parse(start);

          diff = date.difference(startDate).inDays;
          print(diff.toString() + ' ' + code);
          if (diff >= 0) {
            var alredyData;
            try {
              alredyData = curGroup.data()[doc.id];
            } catch (e) {
              alredyData = null;
            }

            int uSteps =
                (doc.data()['steps'] + doc.data()['addedSteps']).toInt();
            print(alredyData.toString() + code);
            if (alredyData == null) {
              await activitiesInstance
                  .doc(code)
                  .collection('members')
                  .doc(userName)
                  .collection('steps')
                  .doc(doc.id)
                  .set({'steps': uSteps}).then(
                      (value) => _setGroupSteps(code, uSteps));
            }
          }
        });
      });
    } else if (diffExist < 0) {
      for (; diffExist < 0; diffExist++) {
        DateTime now = DateTime.now();
        String date = DateFormat('yyyy-MM-dd')
            .format(DateTime(now.year, now.month, now.day + (diffExist + 1)));
        var userSteps = await usersInstance
            .doc(_auth.getCurrentUser())
            .collection('steps')
            .doc(date)
            .get();

        await activitiesInstance
            .doc(code)
            .collection('members')
            .doc(userName)
            .collection('steps')
            .doc(date)
            .set({
          'steps': userSteps.data()['steps'] + userSteps.data()['addedSteps']
        }).then((value) => _setGroupSteps(code,
                userSteps.data()['steps'] + userSteps.data()['addedSteps']));
      }
    } else if (diffExist == 0 && userStepsTod > todaySteps) {
      activitiesInstance
          .doc(code)
          .collection('members')
          .doc(userName)
          .collection('steps')
          .doc(DateFormat('yyyy-MM-dd').format(DateTime.now()))
          .update({
        'steps': FieldValue.increment(userStepsTod - todaySteps)
      }).then((value) => _setGroupSteps(code, userStepsTod - todaySteps));
    }
  }

  Future _setGroupSteps(String code, int val) async {
    return await activitiesInstance
        .doc(code)
        .update({'currentSteps': FieldValue.increment(val)});
  }

  Future newCompActivity(String name, String endDate, String code) async {
    await activitiesCompInstance.doc(code).set({
      'groupName': name,
      'endDate': endDate,
      'startDate': DateFormat('yyyy-MM-dd').format(DateTime.now()),
      'code': code,
    }).whenComplete(() async {
      setCompMem(code);
    });
  }

  Future setCompMem(String code) async {
    String userName = await getUserName();
    return await activitiesCompInstance
        .doc(code)
        .collection('members')
        .doc(userName)
        .set({'userName': userName}).whenComplete(() => setCompMemStep(code));
  }

  Future setCompMemStep(String code) async {
    String userName = await getUserName();
    var group = await activitiesCompInstance.doc(code).get();
    var groupMem = await activitiesCompInstance
        .doc(code)
        .collection('members')
        .doc(userName)
        .collection('steps')
        .get();
    var curGroup = await activitiesCompInstance
        .doc(code)
        .collection('members')
        .doc(userName)
        .get();
    int diff;
    String start;
    String lastDate;
    int diffExist;
    int todaySteps = 0;
    try {
      start = group.data()['startDate'];
    } catch (e) {
      return setCompMemStep(code);
    }
    try {
      print(groupMem.docs.last.id + '  id');
      lastDate = groupMem.docs.last.id;
      diffExist = DateTime.parse(lastDate).difference(DateTime.now()).inDays;
      todaySteps = groupMem.docs.last.data()['steps'];
    } catch (e) {}
    print(diffExist.toString() + ' ' + code);
    var userStepsToday = await usersInstance
        .doc(_auth.getCurrentUser())
        .collection('steps')
        .doc(DateFormat('yyyy-MM-dd').format(DateTime.now()))
        .get();
    int userStepsTod =
        userStepsToday.data()['steps'] + userStepsToday.data()['addedSteps'];
    print(userStepsTod);
    print(todaySteps);
    if (diffExist == null) {
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

            int uSteps =
                (doc.data()['steps'] + doc.data()['addedSteps']).toInt();
            print(alredyData.toString() + code);
            if (alredyData == null) {
              await activitiesCompInstance
                  .doc(code)
                  .collection('members')
                  .doc(userName)
                  .collection('steps')
                  .doc(doc.id)
                  .set({'steps': uSteps});
            }
          }
        });
      });
    } else if (diffExist < 0) {
      for (; diffExist < 0; diffExist++) {
        DateTime now = DateTime.now();
        String date = DateFormat('yyyy-MM-dd')
            .format(DateTime(now.year, now.month, now.day + (diffExist + 1)));
        var userSteps = await usersInstance
            .doc(_auth.getCurrentUser())
            .collection('steps')
            .doc(date)
            .get();

        await activitiesInstance
            .doc(code)
            .collection('members')
            .doc(userName)
            .collection('steps')
            .doc(date)
            .set({
          'steps': userSteps.data()['steps'] + userSteps.data()['addedSteps']
        });
      }
    } else if (diffExist == 0 && userStepsTod > todaySteps) {
      activitiesInstance
          .doc(code)
          .collection('members')
          .doc(userName)
          .collection('steps')
          .doc(DateFormat('yyyy-MM-dd').format(DateTime.now()))
          .update({'steps': FieldValue.increment(userStepsTod - todaySteps)});
    }
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

  Stream<DocumentSnapshot> viewActivity(String code) async* {
    yield* activitiesInstance.doc(code).snapshots();
  }

  Future<QuerySnapshot> viewCompActivity(String code) async {
    return activitiesCompInstance.doc(code).collection('members').get();
  }

  Future<QuerySnapshot> viewCompMemActivity(String code, String userName) {
    return activitiesCompInstance
        .doc(code)
        .collection('members')
        .doc(userName)
        .collection('steps')
        .get();
  }

  Future<DocumentSnapshot> viewtodayCompMemActivity(
      String code, String userName) {
    return activitiesCompInstance
        .doc(code)
        .collection('members')
        .doc(userName)
        .collection('steps')
        .doc(DateFormat('yyyy-MM-dd').format(DateTime.now()))
        .get();
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

  Future<QuerySnapshot> userStepsToday(String code) {
    return activitiesInstance.doc(code).collection('members').get();
  }
}
