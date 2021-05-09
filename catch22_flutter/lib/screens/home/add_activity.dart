import 'package:catch22_flutter/models/sports.dart';
import 'package:catch22_flutter/screens/home/bottom_navigation_bar.dart';
import 'package:catch22_flutter/screens/home/home.dart';
import 'package:catch22_flutter/services/database.dart';
import 'package:catch22_flutter/shared/button_widget.dart';
import 'package:catch22_flutter/shared/change_date_widget.dart';
import 'package:catch22_flutter/shared/constants/color_constants.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_date_pickers/flutter_date_pickers.dart' as dp;
import 'package:flutter_date_pickers/flutter_date_pickers.dart';
import 'package:intl/intl.dart';

class AddActivity extends StatefulWidget {
  @override
  _AddActivityState createState() => _AddActivityState();
}

class _AddActivityState extends State<AddActivity> {
  DatabaseService _db = DatabaseService();

  List<SportsModel> _sport = [
    SportsModel(3000, 'Badminton'),
    SportsModel(5000, 'Basketball'),
    SportsModel(5000, 'Handball'),
    SportsModel(3000, 'Padell'),
    SportsModel(5000, 'Soccer'),
    SportsModel(4000, 'Tennis'),
  ];
  DateTime _firstDate = DateTime.now().subtract(Duration(days: 350));
  DateTime _lastDate = DateTime.now().add(Duration(days: 350));
  DateTime _selectedDate = DateTime.now();
  Color selectedDateStyleColor = Colors.blue;
  Color selectedSingleDateDecorationColor = Colors.red;
  bool _sel = false;
  int _selSportValue = 0;
  List<DropdownMenuItem<SportsModel>> _dropdownMenuItems;
  SportsModel _selectedItem;
  String error = '';

  void initState() {
    super.initState();
    _dropdownMenuItems = buildDropDownMenuItems(_sport);
  }

  List<DropdownMenuItem<SportsModel>> buildDropDownMenuItems(List listItems) {
    // ignore: deprecated_member_use
    List<DropdownMenuItem<SportsModel>> items = List();
    for (SportsModel listItem in listItems) {
      items.add(
        DropdownMenuItem(
          child: Text(
            listItem.name,
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
          ),
          value: listItem,
        ),
      );
    }
    return items;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    Color bodyTextColor = Theme.of(context).accentTextTheme.bodyText1?.color;
    if (bodyTextColor != null) selectedDateStyleColor = bodyTextColor;

    selectedSingleDateDecorationColor = Theme.of(context).accentColor;
  }

  void _showAlertDialog(BuildContext context) {
    showDialog(
        barrierDismissible: false,
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            content: Container(
              width: 200,
              height: 120,
              child: Column(
                children: [
                  Text(
                    'From this activity you have now earned ' +
                        _selSportValue.toString() +
                        ' extra steps to ' +
                        DateFormat('EEEE').format(_selectedDate) +
                        ' ' +
                        DateFormat('yyyy-MM-dd').format(_selectedDate),
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 18),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  ButtonWidget(
                    text: 'Yaaay!',
                    hasBorder: false,
                    height: 30,
                    width: 100,
                    onClick: () {
                      _db.addActivity(
                          DateFormat('yyyy-MM-dd').format(_selectedDate),
                          _selSportValue);
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => BottomNavBar()));
                    },
                  ),
                ],
              ),
            ),
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    dp.DatePickerRangeStyles styles = dp.DatePickerRangeStyles(
      selectedDateStyle: Theme.of(context)
          .accentTextTheme
          .bodyText1
          ?.copyWith(color: selectedDateStyleColor),
      selectedSingleDateDecoration: BoxDecoration(
          color: selectedSingleDateDecorationColor, shape: BoxShape.circle),
    );
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(
          onPressed: () {
            Navigator.push(context,
                MaterialPageRoute(builder: (context) => BottomNavBar()));
          },
        ),
        title: Text('Add Activity'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            children: [
              SizedBox(
                height: 30,
              ),
              DropdownButton(
                hint: Text('Select an Activity',
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
                value: _selectedItem,
                items: _dropdownMenuItems,
                onChanged: (value) {
                  setState(() {
                    _selectedItem = value;
                    _selSportValue = value.value;
                    _sel = true;
                    print(_selSportValue);
                  });
                },
              ),
              SizedBox(
                height: 30,
              ),
              Text('Estimated Steps'),
              ChangeDateWidget(
                txt: _selSportValue.toString(),
                add: () {
                  setState(() {
                    _selSportValue += 500;
                  });
                },
                minus: () {
                  setState(() {
                    _selSportValue -= 500;
                  });
                },
              ),
              SizedBox(
                height: 30,
              ),
              Container(
                height: 300,
                width: 300,
                child: dp.DayPicker.single(
                  selectedDate: _selectedDate,
                  onChanged: _onSelectedDateChanged,
                  firstDate: _firstDate,
                  lastDate: _lastDate,
                  datePickerStyles: styles,
                  datePickerLayoutSettings: dp.DatePickerLayoutSettings(
                      maxDayPickerRowCount: 2,
                      showPrevMonthEnd: true,
                      showNextMonthStart: true),
                ),
              ),
              SizedBox(
                height: 20,
              ),
              ButtonWidget(
                hasBorder: false,
                text: 'Add Steps',
                width: 200,
                onClick: () {
                  if (_selSportValue != 0) {
                    /*_db.addActivity(
                      DateFormat('yyyy-MM-dd').format(_selectedDate),
                      _selSportValue);*/
                    _showAlertDialog(context);
                  } else {
                    setState(() {
                      error = 'Please select an Activity';
                    });
                  }
                },
              ),
              SizedBox(height: 10),
              Text(
                error,
                style: TextStyle(color: Colors.red, fontSize: 18),
              )
            ],
          ),
        ),
      ),
    );
  }

  void _onSelectedDateChanged(DateTime newDate) {
    setState(() {
      _selectedDate = newDate;
      print(_selectedDate);
      print(DateFormat('yyyy-MM-dd').format(_selectedDate));
    });
  }
}
