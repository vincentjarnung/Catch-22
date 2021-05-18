import 'package:catch22_flutter/models/steps_day.dart';
import 'package:catch22_flutter/screens/wrapper.dart';
import 'package:catch22_flutter/services/database.dart';
import 'package:catch22_flutter/shared/button_widget.dart';
import 'package:catch22_flutter/shared/change_date_widget.dart';
import 'package:flutter/material.dart';

class SetStepGoal extends StatefulWidget {
  final String userName;

  SetStepGoal({@required this.userName});
  @override
  _SetStepGoalState createState() => _SetStepGoalState();
}

class _SetStepGoalState extends State<SetStepGoal> {
  DatabaseService _db = DatabaseService();
  List<StepsDayModel> tester = [];
  int avgValue = 0;
  int stepGoal = 0;

  Future _getavgSteps() async {
    return await _db.getDateAndSteps().then((snapshot) {
      for (int i = 0; i < snapshot.length; i++) {
        avgValue += snapshot[i].steps.toInt();
      }
      setState(() {
        avgValue = avgValue ~/ snapshot.length;
        stepGoal = _roundOfNumber((avgValue * 1.1).toInt());
      });
    });
  }

  int _roundOfNumber(int number) {
    int a = number % 500;

    if (a > 0) {
      return (number ~/ 500) * 500 + 500;
    }

    return number;
  }

  @override
  void initState() {
    super.initState();
    _getavgSteps();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          SizedBox(
            height: 90,
          ),
          Text(
            'Welcome ' + widget.userName + '!',
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(50, 50, 50, 30),
            child: Text(
              'Your average step count everyday for the last month was ' +
                  avgValue.toString() +
                  '! What would you like your daily step goal to be?',
              style: TextStyle(fontSize: 18),
              textAlign: TextAlign.center,
            ),
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              const Spacer(flex: 3),
              Text(
                'Step Goal',
                style: TextStyle(fontSize: 25),
                textAlign: TextAlign.center,
              ),
              IconButton(
                  icon: Icon(Icons.info_outline),
                  onPressed: () {
                    _showAlertDialog(context);
                  }),
              const Spacer(flex: 2)
            ],
          ),
          SizedBox(
            height: 20,
          ),
          ChangeDateWidget(
            txt: stepGoal.toString(),
            minus: () {
              setState(() {
                stepGoal -= 500;
              });
            },
            add: () {
              setState(() {
                stepGoal += 500;
              });
            },
          ),
          SizedBox(
            height: 20,
          ),
          ButtonWidget(
            hasBorder: false,
            text: 'Register',
            onClick: () {
              _db.updateStepGoal(stepGoal).whenComplete(() =>
                  Navigator.pushReplacement(context,
                      MaterialPageRoute(builder: (context) => Wrapper())));
            },
            height: 50,
            width: 200,
          )
        ],
      ),
    );
  }

  void _showAlertDialog(BuildContext context) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            content: Container(
              width: 200,
              height: 370,
              child: Column(
                children: [
                  Row(
                    children: [
                      Text(
                        'Step Goal',
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
                        textAlign: TextAlign.start,
                      ),
                      const Spacer(),
                    ],
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Your step goal is at the core of this app. By setting a realistic goal for yourself, we will try to help motivate and reward you for reaching your goals and improving your health! No matter the level of exercise you aim to achieve.\n\nYour step goal can be changed at any time in the app. Beware that you will lose your progress on longer challenges if you change your goal before the achievement has been reached',
                    style: TextStyle(fontSize: 16),
                  ),
                  Row(
                    children: [
                      const Spacer(),
                      TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: Text('Close'))
                    ],
                  )
                ],
              ),
            ),
          );
        });
  }
}
