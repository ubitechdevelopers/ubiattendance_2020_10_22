import 'dart:convert';
import 'dart:math';

import 'package:Shrine/Image_view.dart';
import 'package:Shrine/attendance_summary.dart';
import 'package:Shrine/services/services.dart';
import 'package:date_util/date_util.dart';
import 'package:flutter/material.dart';
import 'package:flutter_calendar_carousel/flutter_calendar_carousel.dart' show CalendarCarousel;
import 'package:flutter_calendar_carousel/classes/event.dart';
import 'package:flutter_calendar_carousel/classes/event_list.dart';
import 'package:intl/intl.dart' show DateFormat;
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'Bottomnavigationbar.dart';
import 'drawer.dart';
import 'globals.dart' as globals;
import 'package:http/http.dart' as http;
import 'dart:math' as math;

import 'globals.dart';


class MyHomePage1 extends StatefulWidget {

  String Id;
  String Name;
  String ShiftId;
  MyHomePage1(String id, String name, String shiftId){
    Id = id;
    Name = name;
    ShiftId = shiftId;

  }

  @override
  _MyHomePageState createState() => _MyHomePageState(Id, Name, ShiftId);

}


class _MyHomePageState extends State<MyHomePage1> {

  String Id;
  String Name;
  String ShiftId;

  _MyHomePageState(String id, String name, String shiftId){
    Id =id;
    Name = name;
    ShiftId = shiftId;
  }

  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  DateTime _currentDate = DateTime(2020, 7, 3);
  DateTime _currentDate2 = DateTime(2020, 7, 3);
  String _currentMonth = DateFormat.yMMM().format(DateTime(2020, 7, 3));
  //DateTime _targetDateTime = DateTime(2020, 7, 3);
  int _counter = 0;
  var ShiftTimeOut;
  var ShiftTimeIn;
  DateTime now;
  DateTime firstDayOfMonth;
  DateTime firstDayOfMonth123;
  DateTime firstDayOfMonth1;
  DateTime daysgonecalculation;
  DateTime selectedShiftfirstDayOfMonth1;
  DateTime selectedShiftfirstDayOfMonth2;
  DateTime firstDayOfMonth2;
  var _selectedEvents=null;
  List<User> userlist = [];
  DateTime lastDayOfMonth;
  Map<DateTime, List> _events;
  Map<DateTime, List> DaysPass;
  Map<DateTime, List> _holiday ;
  List<Holiday> holidayList = [] ;
  DateTime Holidaydate;
  List<dynamic> holidayDateList = [];
  Map<DateTime, String> holidayNameList = {};
  AnimationController _animationController;
  //List<Shiftplanner> items = null;
  List<shiftplanner1> items = [];
  List<shiftplanner1> items1 = [];
  List<multishift> specialshift = [] ;
  var dateUtility = DateUtil();
  var daysinyear;
  bool leapyear;
  int time = 0;
  Map<DateTime, List> DefaultShiftList = {};
  Map<DateTime, List> weekoff = {};
  Map<DateTime, List> selectedShiftweekoff = {};
  Map<DateTime, List> daysGoneList = {};
  Map<DateTime, List<String>> specialShiftsList = {};
  Map<DateTime, List<String>> removedShiftsList = {};
  List<DateTime> defaultshifts = [];
  List<DateTime> specialshiftdate = [];
  List<DateTime> weekofflist = [];
  List<DateTime> selectShiftweekofflist = [];
  List<String> values = [];
  var onTapListCall = null;
  var _shifts;
  String selectedShiftTiming;
  String selectedShiftName;
  String HoursPerDay;
  String selectedShiftId;
  String shifttype;
  bool shiftPressed = false;
  int shiftColor=0;
  String goneShift;
  String hoursPerDayForFlexi;
  var statusOfShift;
  bool cond = false;
  final _formKey = GlobalKey<FormState>();

  final List<Color> circleColors =
  [     Colors.blue[200], Colors.red[100], Colors.orange[200],
    Colors.tealAccent[100], Colors.purple[100], Colors.yellow[200],Colors.greenAccent[200],Colors.lightBlue[100], Colors.teal[200],
    Colors.green[200],Colors.red[100],Colors.cyan[100],Colors.purple[100],
    Colors.red[200],Colors.lime[200] ];


  /*  final List<Color> circleColors =
  [ Colors.orangeAccent[100],
    Colors.blue[200], Colors.red[100],
    Colors.lime[100], Colors.deepPurple[100],
    Colors.teal[200],Colors.yellow[200],
    Colors.lightBlueAccent[100],Colors.lightBlue[400],
    Colors.cyan[100],Colors.yellow[100],Colors.greenAccent[200],
    Colors.blue[100], Colors.blue[200], Colors.lightBlueAccent[100],Colors.orangeAccent[100],
    Colors.blue[200], Colors.red[100],
    Colors.lime[100], Colors.deepPurple[100],
    Colors.teal[200],Colors.yellow[200],
    Colors.lightBlueAccent[100],Colors.lightBlue[400],
    Colors.cyan[100],Colors.yellow[100],Colors.greenAccent[200],
    Colors.blue[100], Colors.blue[200], Colors.lightBlueAccent[100],Colors.orangeAccent[100],
    Colors.blue[200], Colors.red[100],
    Colors.lime[100], Colors.deepPurple[100],
    Colors.teal[200],Colors.yellow[200],
    Colors.lightBlueAccent[100],Colors.lightBlue[400],
    Colors.cyan[100],Colors.yellow[100],Colors.greenAccent[200],
    Colors.blue[100], Colors.blue[200], Colors.lightBlueAccent[100],Colors.orangeAccent[100],
    Colors.blue[200], Colors.red[100],
    Colors.lime[100], Colors.deepPurple[100],
    Colors.teal[200],Colors.yellow[200],
    Colors.lightBlueAccent[100],Colors.lightBlue[400],
    Colors.cyan[100],Colors.yellow[100],Colors.greenAccent[200],
    Colors.blue[100], Colors.blue[200], Colors.lightBlueAccent[100],Colors.orangeAccent[100],
    Colors.blue[200], Colors.red[100],
    Colors.lime[100], Colors.deepPurple[100],
    Colors.teal[200],Colors.yellow[200],
    Colors.lightBlueAccent[100],Colors.lightBlue[400],
    Colors.cyan[100],Colors.yellow[100],Colors.greenAccent[200],
    Colors.blue[100], Colors.blue[200], Colors.lightBlueAccent[100] ];*/


  final List<Color> specialshiftColor =
  [
    Colors.blue[200], Colors.red[100], Colors.orange[200],
    Colors.tealAccent[100], Colors.purple[100], Colors.yellow[200],Colors.greenAccent[200],Colors.lightBlue[100], Colors.teal[200],
    Colors.green[200],Colors.red[100],Colors.cyan[100],Colors.purple[100],
    Colors.red[200],Colors.lime[200]
  ];

  int _selectedIndex = null;
  List distinctIds=[];
  var ids = [];
  int indexOfColor;
  int indexOfColorforShiftTile;
  int indexOfColorforShiftTile1;
  int _currentIndex = 1;
  int response;
  String _orgName='';
  var defaultShiftTimings='';
  String admin_sts='0';
  ScaffoldState scaffold;
  var daysgone1;
  var daysgone2=0;
  bool timeInPunched=false;
  String AttendanceDate;
  // bool checkStatus = false;
  // final seen = Set<String>();
  // List unique =[];

  daysgone() async{

    while(daysgonecalculation.month != now.month) {
      daysgone1 = dateUtility.daysInMonth(
          daysgonecalculation.month, daysgonecalculation.year);
      daysgonecalculation =
          DateTime(daysgonecalculation.year, daysgonecalculation.month + 1, 1);
      daysgone2= daysgone2+daysgone1;
      print(daysgonecalculation);
      print(daysgone1);
      print(daysgone2);
      print(now);
      print("daysgonecalculation");
    }
    daysgone2 = daysgone2 + now.day;
    print(daysgone2);
    print("daysgone2l,l,");

  }


  @override
  void initState() {

  //  _onAlertShiftPlannerPopup(context);
    getOrgName();
    now = new DateTime.now();
    firstDayOfMonth = new DateTime(now.year , now.month -4 , 1);
    firstDayOfMonth123 = new DateTime(now.year , now.month -4 , 1);
    daysgonecalculation = new DateTime(now.year , now.month -4 , 1);
    //firstDayOfMonth1 = new DateTime(now.year , now.month  , 1);
    daysinyear = dateUtility.daysPastInYear(now.month,0,now.year);
    leapyear = dateUtility.leapYear(now.year);
    daysgone();

    if(leapyear) {
      daysinyear = 366 - daysinyear;
    }
    else{
      daysinyear = 365 - daysinyear;
    }
    _selectedEvents = null;

    super.initState();
    _shifts = getShifts();

    initPlatformState();

  }




  void showInSnackBar(String value) {
    final snackBar = SnackBar(
        duration: Duration(seconds: 5, milliseconds: 500),
        content: Text(value, textAlign: TextAlign.center,));
    _scaffoldKey.currentState.showSnackBar(snackBar);
  }

/*  void showInSnackBarforTimeInOut(String value) {
    final snackBar = SnackBar(
        content: Container(
          height: 100,
          child: Column(
            children: <Widget>[
              Text(value),
            ],

          ),
        ));
    _scaffoldKey.currentState.showSnackBar(snackBar);
  }*/



  getOrgName() async{
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _orgName= prefs.getString('org_name') ?? '';
      admin_sts= prefs.getString('sstatus') ?? '0';
    });
  }



  @override
  // Platform messages are asynchronous, so we initialize in an async method.
  initPlatformState() async {

   /*   getPlannerWiseSummary(now,Id).then((values){
        print("hhkhkjhkhkh");
        print(timeInPunched);
        setState(() {
          userlist = values;
          print(userlist);
          print(userlist.isEmpty);
          if(userlist.isNotEmpty) {
            timeInPunched = true;        //attendance has marked
             print("inside if");
           }
        });
      });*/


    AttendanceDate = DateFormat('yyyy-MM-dd').format(now);
   var userlist1 = await getPlannerWiseSummary(AttendanceDate,Id);

   if(userlist1.isNotEmpty){
     print("hklhhhlkhlhl");
     setState(() {
       timeInPunched = true;
     });
   }



    Future.delayed(const Duration(milliseconds: 1000), () {
    _onAlertShiftPlannerPopup(context);
    });

    defaultShiftTimings = globals.defaultShiftTimings;                     //21 sept

    shiftplanner(Id,defaultShiftTimings).then((EmpList) {
      setState(() {
        print("emplis;lk;k;lt");
        items = EmpList;
      });

      /* DaysPassThisMonth().then((val) => setState(() {
        DaysPass = val;
      }));*/

      getTask().then((val) => setState(() {
        _events = val;
      }));

      getWeekOff().then((val) => setState(() {
        print(val);
        print("ggjkgkjh");
        _holiday = val;
        //print(_holiday.length);
      }));


      getHolidays().then((val) {
        setState(() {
          holidayList = val;
        });

        for (int i = 0; i < holidayList.length; i++) {
          // print("holidaysss");
          if (int.parse(holidayList[i].Days) > 1) {
            Holidaydate = holidayList[i].fromDateFormat;
            holidayNameList.addAll({Holidaydate:holidayList[i].Name});
            print(holidayNameList);
            print("_holidayName");
            holidayDateList.add(Holidaydate);
            _markedDateMap.removeAll(Holidaydate);
            _markedDateMap.add(
              Holidaydate,
              new Event(
                date: Holidaydate,
                title: 'Event 5',
                icon: _holidayIcon(Holidaydate.day.toString()),
              ),
            );
            int days = 0;
            while (days != int.parse(holidayList[i].Days) - 1) {
              print("Event 5");
              print(Holidaydate);
              Holidaydate = Holidaydate.add(Duration(days: 1));
              holidayNameList.addAll({Holidaydate:holidayList[i].Name});

              holidayDateList.add(Holidaydate);
              _markedDateMap.removeAll(Holidaydate);
              _markedDateMap.add(
                Holidaydate,
                new Event(
                  date: Holidaydate,
                  title: 'Event 5',
                  icon: _holidayIcon(Holidaydate.day.toString()),
                ),
              );
              days++;
            }
          }
          else {
            Holidaydate = holidayList[i].fromDateFormat;
            _markedDateMap.removeAll(Holidaydate);
            _markedDateMap.add(
              Holidaydate,
              new Event(
                date: Holidaydate,
                title: 'Event 5',
                icon: _holidayIcon(Holidaydate.day.toString()),
              ),
            );
            holidayDateList.add(Holidaydate);
            holidayNameList.addAll({Holidaydate:holidayList[i].Name});

          }
          print(holidayDateList);
          print("holidayDateList");
        }



      getMultiShiftsList(Id).then((val) {
        setState(() {
          print(val);
          print("special shift");
          specialshift = val;
        });

        for (int i = 0; i < specialshift.length; i++) {

          setState(() {

            ids.add(specialshift[i].shiftid.toString());
            final seen = Set<String>();
            final unique = ids.where((str) => seen.add(str)).toList();
            distinctIds = unique;                   //list of unique shift ids
            indexOfColor = distinctIds.indexOf(specialshift[i].shiftid.toString()) % 12;
           /* print(indexOfColor);
            print(specialshift[i].shiftid.toString());
            print(specialshift[i].shiftdate.toString());
            print(distinctIds);*/
            print("indexOfColorhmfjhfjfj");
          });

          if(specialshift[i].shifttype =='3'){
            print(indexOfColor);
            print(specialshift[i].shiftid.toString());
            print(specialshift[i].shiftdate.toString());
            print("jgjggjgjgjg");
            _markedDateMap.removeAll(specialshift[i].shiftdate);
            _markedDateMap.add(
              specialshift[i].shiftdate,
              new Event(
                date: specialshift[i].shiftdate,
                title: 'Event 5',
                icon: _FlexiIcon(
                    specialshift[i].shiftdate.day.toString(),
                    "Flexi"+specialshift[i].HoursPerDay+"Hrs", indexOfColor),
              ),
            );
          }
          else {
            print(specialshift[i].shiftdate);
            print(specialshift[i].shiftdate.day.toString());
            print(specialshift[i].shiftTiming);
            print("specialshift[i].shiftTiming");
            _markedDateMap.removeAll(specialshift[i].shiftdate);
            _markedDateMap.add(
              specialshift[i].shiftdate,
              new Event(

                date: specialshift[i].shiftdate,
                title: 'Event 5',
                icon: _VerySpecialShift(
                    specialshift[i].shiftdate.day.toString(),
                    specialshift[i].shiftTiming, indexOfColor),
              ),
            );
          }

          if(specialshift[i].weekoffStatus == '1'){
            _markedDateMap.removeAll(specialshift[i].shiftdate);
            _markedDateMap.add(
              specialshift[i].shiftdate,
              new Event(
                date:specialshift[i].shiftdate,
                title: 'Event 5',
                icon: _VerySpecialShift(specialshift[i].shiftdate.day.toString(),
                    "Week off", indexOfColor),
              ),
            );
          }
        }

        for (int i = 0; i < daysgone2-1; i++) {
          bool checkStatus = false;
          bool flexiShift = false;

          for (var j = 0; j < specialshift.length; j++) {
            if(specialshift[j].shiftdate == firstDayOfMonth123) {
              checkStatus = true;                                   //shift was assigned on this date
              if(specialshift[j].shifttype =='3'){
                flexiShift = true;
                hoursPerDayForFlexi =specialshift[j].HoursPerDay;
              }
              print(specialshift[j].shiftdate);
              goneShift = specialshift[j].shiftTiming;
              print(goneShift);
              print("jgjkgkhk");
            }
          }

          if(checkStatus){

            if(flexiShift){

              print("khkhhikhkhiioh");
              daysGoneList.addAll({firstDayOfMonth123: ["Days Gone"]});
              _markedDateMap.removeAll(firstDayOfMonth123);
              _markedDateMap.add(
                firstDayOfMonth123,
                new Event(
                  date: firstDayOfMonth123,
                  title: 'Event 5',
                  icon: _DaysgoneFlexiIcon(firstDayOfMonth123.day.toString(),
                      "Flexi"+hoursPerDayForFlexi+"Hrs",
                      ),
                ),
              );
            }
            else {
              daysGoneList.addAll({firstDayOfMonth123: ["Days Gone"]});
              _markedDateMap.removeAll(firstDayOfMonth123);
              _markedDateMap.add(
                firstDayOfMonth123,
                new Event(
                  date: firstDayOfMonth123,
                  title: 'Event 5',
                  icon: _daysGoneicon3(firstDayOfMonth123.day.toString(),
                      goneShift),
                ),
              );
            }
            firstDayOfMonth123 = firstDayOfMonth123.add(Duration(days: 1));

          }


          else if (weekoff.containsKey(firstDayOfMonth123)) {
            daysGoneList.addAll({firstDayOfMonth123: ["Days Gone"]});
            _markedDateMap.removeAll(firstDayOfMonth123);
            _markedDateMap.add(
              firstDayOfMonth123,
              new Event(
                date: firstDayOfMonth123,
                title: 'Event 5',
                icon: _daysGoneIcon2(firstDayOfMonth123.day.toString(),),
              ),
            );
            firstDayOfMonth123 = firstDayOfMonth123.add(Duration(days: 1));

          }

          else{
            daysGoneList.addAll({firstDayOfMonth123: ["Days Gone"]});

            // firstDayOfMonth123 = firstDayOfMonth123.add(Duration(days: 1));
            _markedDateMap.removeAll(firstDayOfMonth123);
            _markedDateMap.add(
              firstDayOfMonth123,
              new Event(
                date: firstDayOfMonth123,
                title: 'Event 5',
                icon: _daysGoneicon(firstDayOfMonth123.day.toString(),
                    DefaultShiftList.values.elementAt(i).toString()),
              ),
            );
            firstDayOfMonth123 = firstDayOfMonth123.add(Duration(days: 1));

          }


          // print(daysGoneList);
          //  print("Days Gone");
        }
      });
      });

//      print(daysGoneList);
//      print("daysgonelost");

      for (int i = 0; i < weekoff.length; i++) {
        _markedDateMap.removeAll(weekofflist[i]);
        _markedDateMap.add(
          weekofflist[i],
          new Event(
            date: weekofflist[i],
            title: 'Event 5',
            icon:_absentIcon(weekoff.keys.elementAt(i).day.toString()),
          ),
        );
      }

      for (int i = 0; i < DefaultShiftList.length; i++) {
        _markedDateMap.add(
          defaultshifts[i],
          new Event(
            date: defaultshifts[i],
            title: 'Event 5',
            icon:_presentIcon(DefaultShiftList.keys.elementAt(i).day.toString(),DefaultShiftList.values.elementAt(i).toString()),
          ),
        );
      }
    });

    /*Future.delayed(const Duration(milliseconds: 3000), () {
      showInSnackBar("Tap on the shift from top and \nthen tap on dates to assign. ");


    });*/

    final prefs = await SharedPreferences.getInstance();
    response = prefs.getInt('response') ?? 0;

  }

  Widget _holidayIcon(String day) => Container(    /// icon for days gone(present)
    decoration: new BoxDecoration(
      color: Colors.white,
      border: Border.all(
          width: 1, color: Colors.blue[100]       //                     <--- border width here
      ),
      borderRadius: BorderRadius.all(
        Radius.circular(5),
      ),
      image: new DecorationImage(
        fit: BoxFit.cover,
        colorFilter: new ColorFilter.mode(Colors.white.withOpacity(0.9), BlendMode.dstATop),
        image: AssetImage("assets/weekofficon.png"),
      ),
    ),
    child: Center(
      child: Text(
        day,
        style: TextStyle(
          color: Colors.black,fontSize: 16,
        ),
      ),
    ),
  );

  _onAlertShiftPlannerPopup(context) async {
    final prefs = await SharedPreferences.getInstance();
   bool shiftPlannerPop=prefs.getBool("shiftPlannerPop")??false;   //popup

    if (!shiftPlannerPop) {
      var alertStyle = AlertStyle(
        animationType: AnimationType.fromTop,
        isCloseButton: false,
        isOverlayTapDismiss: false,
        descStyle: TextStyle(fontWeight: FontWeight.bold),
        animationDuration: Duration(milliseconds: 400),

      );
      Alert(
          style: alertStyle,
          context: context,
          title: "Tap on the shift from top and \nthen tap on dates to assign.",
          buttons: [
            DialogButton(
              width: MediaQuery
                  .of(context)
                  .size
                  .width * 0.27,
              color: Colors.orangeAccent,
              onPressed: () {
                //final prefs = await SharedPreferences.getInstance();
                // prefs.setBool("shiftPlannerPop",true);
                Navigator.of(context, rootNavigator: true).pop();
              },
              child: Text(
                "OK",
                style: TextStyle(color: Colors.white, fontSize: 20),
              ),
            )
          ]).show();

      /*Future.delayed(const Duration(milliseconds: 8000), () {
      showInSnackBar("Tap on the shift from top and \nthen tap on dates to assign. ");
    });*/
      prefs.setBool("shiftPlannerPop", true);
   }
    else{
      Future.delayed(const Duration(milliseconds: 2000), () {
      showInSnackBar("Tap on the shift from top and \nthen tap on dates to assign. ");
    });
    }
  }

  _onAlertTimeInPunched(date) async {

    var alertStyle = AlertStyle(
        animationType: AnimationType.fromTop,
        isCloseButton: false,
        isOverlayTapDismiss: false,
        descStyle: TextStyle(fontWeight: FontWeight.bold),
        animationDuration: Duration(milliseconds: 400),

      );
      Alert(
          style: alertStyle,
          context: context,
          title: "Time In punched",
          buttons: [
            DialogButton(
              width: MediaQuery
                  .of(context)
                  .size
                  .width * 0.27,
              color: Colors.orangeAccent,
              onPressed: () {
                //final prefs = await SharedPreferences.getInstance();
                // prefs.setBool("shiftPlannerPop",true);
                Navigator.of(context, rootNavigator: true).pop();
              },
              child: Text(
                "OK",
                style: TextStyle(color: Colors.white, fontSize: 20),
              ),
            )
          ]).show();



  }


  Color randomGenerator(int i) {
    return circleColors[i];
  }

  Color randomGenerator1(int i) {
    return specialshiftColor[i];
  }

  Future<Map<DateTime, List>> getTask() async {

    for(int i = 1 ; i<= 366 ; i++){
      /// key is current day of iteration and value is the label shown for default sift
      if(items[0].shifttype.toString() == '3')
      {
        DefaultShiftList.addAll({firstDayOfMonth : ['Flexi('+items[0].HoursPerDay+' Hrs)' ]});
      }
      else {
        DefaultShiftList.addAll({firstDayOfMonth: [items[0].ShiftTimeIn + items[0].ShiftTimeOut]});
      }
      firstDayOfMonth = firstDayOfMonth.add(Duration(days: 1));

    }

    print(DefaultShiftList.containsKey(firstDayOfMonth));
    print(DefaultShiftList.keys.toList());
    print( DefaultShiftList.values.elementAt(0));
    print("-----------890");
    defaultshifts = DefaultShiftList.keys.toList();


    print(DefaultShiftList);
    print("DefaultShiftList123");
    print(defaultshifts[0]);
    print(DefaultShiftList.values);
    print(DefaultShiftList.length);
    print("length");
    print(DefaultShiftList.keys.elementAt(0));
    // '${events.length}'
    print(DefaultShiftList.values.elementAt(0));

    print("DefaultShiftListhh");
    return DefaultShiftList;
    //return weekoff;
  }



  Future<Map<DateTime, List>> getWeekOff() async {


    for (int k = 0; k < items[0].weekofflist.length; k++) {

      firstDayOfMonth1 = new DateTime(now.year , now.month -4 , 1);

      int day1 = int.parse(items[0].weekofflist[k].Day);
      //int day1 = 2;  //day of week

      if(day1>0) {

        if(day1 == 7){
          day1 = 6;
        }
        else if(day1 == 1) {
          day1 = 7;
        }
        else{
          day1--;
        }
      }
      var arr = items[0].weekofflist[k].WeekOff.split(",");
      // var arr = ['1','0','0','0','1'];     //value of weekoffs of one week

      for (int i = 1; i <= 50; i++) {

        while (firstDayOfMonth1.weekday != day1) {
          firstDayOfMonth1 = firstDayOfMonth1.add(Duration(days: 1));
        }
        // firstDayOfMonth1 = firstDayOfMonth1.subtract(Duration(days: 1));

        for (int i = 0; i < 5; i++) {
          if (arr[i] == '1') {
            firstDayOfMonth2 = firstDayOfMonth1.add(Duration(days: 7 * i));
            weekoff.addAll({firstDayOfMonth2: ["WeekOff"]});

          }
        }
        firstDayOfMonth1 = DateTime(firstDayOfMonth1.year, firstDayOfMonth1.month + 1, 1);  //  <--bug here
      }
      weekofflist = weekoff.keys.toList();
    }
    return weekoff;
  }



  Future<Map<DateTime, List>> getSelectedShiftWekoff() async {

    selectedShiftweekoff.clear();

    for (int k = 0; k < items1[0].weekofflist.length; k++) {

      selectedShiftfirstDayOfMonth1 = new DateTime(now.year , now.month  , 1);

      int day1 = int.parse(items1[0].weekofflist[k].Day);
      //int day1 = 2;  //day of week

      if(day1>0) {

        if(day1 == 7){
          day1 = 6;
        }
        else if(day1 == 1) {
          day1 = 7;
        }
        else{
          day1--;
        }
      }
      var arr = items1[0].weekofflist[k].WeekOff.split(",");
      // var arr = ['1','0','0','0','1'];     //value of weekoff of one week

      for (int i = 1; i <= 5; i++) {

        while (selectedShiftfirstDayOfMonth1.weekday != day1) {
          selectedShiftfirstDayOfMonth1 = selectedShiftfirstDayOfMonth1.add(Duration(days: 1));
        }
        // firstDayOfMonth1 = firstDayOfMonth1.subtract(Duration(days: 1));

        for (int i = 0; i < 5; i++) {
          if (arr[i] == '1') {
            selectedShiftfirstDayOfMonth2 = selectedShiftfirstDayOfMonth1.add(Duration(days: 7 * i));
            selectedShiftweekoff.addAll({selectedShiftfirstDayOfMonth2: ["1"]});
          }
        }

        selectedShiftfirstDayOfMonth1 = DateTime(selectedShiftfirstDayOfMonth1.year, selectedShiftfirstDayOfMonth1.month + 1, 1);  //  <--bug here
      }
      selectShiftweekofflist = selectedShiftweekoff.keys.toList();
    }
    print(selectedShiftweekoff);
    print("jijjjljljljl");
    return selectedShiftweekoff;
  }


  /*Future<Map<DateTime, List>> getWeekOff() async {
    print(items[0].weekofflist.length);

    for (int k = 0; k < 1; k++) {

      firstDayOfMonth1 = new DateTime(now.year , now.month  , 1);
      // int day1 = int.parse(items[0].weekofflist[k].Day);
      int day1 = 7;

      if(day1>0) {
        if(day1 == 7){
          day1 = 6;
        }
        else if(day1 == 1) {
          day1 = 7;
        }
        else{
          day1--;
        }
      }
      // var arr = items[0].weekofflist[k].WeekOff.split(",");
      var arr = [0,1,0,1,0];


      for (int i = 1; i <= 20; i++) {

        while (firstDayOfMonth1.weekday  != day1 ) {
          firstDayOfMonth1 = firstDayOfMonth1.add(Duration(days: 1));
        }

        //  firstDayOfMonth1 = firstDayOfMonth1.subtract(Duration(days: 1));  //  <--bug here

        for (int i = 0; i < 5; i++) {
          if (arr[i] == 1) {
            firstDayOfMonth2 = firstDayOfMonth1.add(Duration(days: 7 * i));
            weekoff.addAll({firstDayOfMonth2: ["somya"]});
          }
        }

        firstDayOfMonth1 = DateTime(firstDayOfMonth1.year, firstDayOfMonth1.month + 1, 1);

      }
      weekofflist = weekoff.keys.toList();

    }

    return weekoff;
  }*/

  formatTime(String time){

    if(time.contains(":")){
      var a=time.split(":");
      return a[0]+":"+a[1];
    }
    else return time;

  }


  Widget _presentIcon(String day, String string1) =>    //container for upcoming dates(present)
  Container(
    decoration: BoxDecoration(
      color: Colors.green[100],
      borderRadius: BorderRadius.all(
        Radius.circular(5),
      ),
    ),
    child: Container(
      child: new Column(
        children: <Widget>[
          new Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text(
                  day,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      color: Colors.black, fontSize: 12,fontWeight: FontWeight.bold
                  ),
                ),
              ]
          ),
          SizedBox(height: 1,),
          new Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                !string1.contains("Flexi")?Text(
                  string1.substring(1, 6),
                  style: TextStyle(
                      color: Colors.black, fontSize: 9
                  ),
                ):Text(
                  string1.substring(1, 6),
                  style: TextStyle(
                      color: Colors.black, fontSize: 9
                  ),
                ),
              ]
            ),
          new Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                !string1.contains("Flexi")?Text(
                  string1.substring(9, 14),
                  style: TextStyle(
                      color: Colors.black, fontSize: 9
                  ),
                ):Text(
                  string1.substring(7, 12)+" "+string1.substring(16, 19),
                  style: TextStyle(
                      color: Colors.black, fontSize: 9
                  ),
                ),
              ]
            ),
         ],
       ),
     ),
   );




  Widget _daysGoneicon(String day, String string1) => Container(
    decoration: BoxDecoration(
      color: Colors.grey[400],
      borderRadius: BorderRadius.all(
        Radius.circular(5),
      ),
    ),
    child: Container(
      child:new Column(
        children: <Widget>[
          new Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text(
                  day,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      color: Colors.black,fontSize: 12,fontWeight: FontWeight.bold
                  ),
                ),
              ]
          ),
          SizedBox(height: 1,),
          new Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                !string1.contains("Flexi")?Text(
                  string1.substring(1, 6),
                  style: TextStyle(
                      color: Colors.black, fontSize: 9
                  ),
                ):Text(
                  string1.substring(1, 6),
                  style: TextStyle(
                      color: Colors.black, fontSize: 9
                  ),
                ),
              ]
          ),
          new Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                !string1.contains("Flexi")?Text(
                  string1.substring(9, 14),
                  style: TextStyle(
                      color: Colors.black, fontSize: 9
                  ),
                ):Text(
                  string1.substring(7, 12)+" "+string1.substring(16, 19),
                  style: TextStyle(
                      color: Colors.black, fontSize: 9
                  ),
                ),
              ]
          ),

        ],
      ),
    ),
  );

  Widget _daysGoneicon3(String day, String string1) => Container(
    decoration: BoxDecoration(
      color: Colors.grey[400],
      borderRadius: BorderRadius.all(
        Radius.circular(5),
      ),
    ),
    child: Container(
      child:new Column(
        children: <Widget>[
          new Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text(
                  day,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      color: Colors.black,fontSize: 12,fontWeight: FontWeight.bold
                  ),
                ),
              ]
          ),
          SizedBox(height: 1,),
          new Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text(
                  string1.substring(0,5),
                  style: TextStyle(
                      color: Colors.black,fontSize: 9
                  ),
                ),
              ]
          ),new Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text(
                  string1.substring(8,13),
                  style: TextStyle(
                      color: Colors.black,fontSize: 9
                  ),
                ),
              ]
          ),

        ],
      ),
    ),
  );

  Widget _absentIcon(String day) => Container(
    decoration: BoxDecoration(
      color: Colors.black12,                                             //21 sept
      borderRadius: BorderRadius.all(
        Radius.circular(5),
      ),
    ),
    child: Center(
      child: Text(
        day,
        style: TextStyle(
            color: Colors.black54,fontSize: 12,fontWeight: FontWeight.bold
        ),
      ),
    ),
  );

  Widget _daysGoneIcon2(String day) => Container(
    decoration: BoxDecoration(
      color: Colors.grey[400],
      borderRadius: BorderRadius.all(
        Radius.circular(5),
      ),
    ),
    child: Center(
      child: Text(
        day,
        style: TextStyle(
            color: Colors.black,fontSize: 12,fontWeight: FontWeight.bold
        ),
      ),
    ),
  );

  Widget _eventIcon(String day, String string1, int i) =>
      //print(day);
  //print("day111");
  Container(
    decoration: BoxDecoration(
      color: randomGenerator(i),
      borderRadius: BorderRadius.all(
        Radius.circular(5),
      ),
    ),
    child: Container(
      child: new Column(
        children: <Widget>[
          new Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text(
                  day,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      color: Colors.black, fontSize: 12,fontWeight: FontWeight.bold
                  ),
                ),
              ]
          ),
          SizedBox(height: 1,),
          new Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                string1 != "Week off"?Text(
                  string1.substring(1, 6),
                  style: TextStyle(
                      color: Colors.black, fontSize: 9
                  ),
                ):Text(
                  "Week off",
                  style: TextStyle(
                      color: Colors.black, fontSize: 9
                  ),
                ),
              ]
          ), new Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                string1 != "Week off"?Text(
                  string1.substring(9, 14),
                  style: TextStyle(
                      color: Colors.black, fontSize: 9
                  ),
                ):Text(
                  "",
                  style: TextStyle(
                      color: Colors.black, fontSize: 9
                  ),
                ),
              ]
          ),

        ],
      ),
    ),
  );

  Widget _FlexiIcon(String day, String string1, int i) =>
      Container(
        decoration: BoxDecoration(
          color: randomGenerator1(i),
          borderRadius: BorderRadius.all(
            Radius.circular(5),
          ),
        ),
        child: Container(
          child: new Column(
            children: <Widget>[
              new Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text(
                      day,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          color: Colors.black, fontSize: 12,fontWeight: FontWeight.bold
                      ),
                    ),
                  ]
              ),
              SizedBox(height: 1,),
              new Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text(
                      string1.substring(0, 5),
                      style: TextStyle(
                          color: Colors.black, fontSize: 9
                      ),
                    )
                  ]
              ),
              new Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text(
                      string1.substring(5, 10)+" "+string1.substring(13, 16),
                      style: TextStyle(
                          color: Colors.black, fontSize: 9
                      ),
                    ),
                  ]
              ),

            ],
          ),
        ),
      );

  Widget _DaysgoneFlexiIcon(String day, String string1) =>
      Container(
        decoration: BoxDecoration(
          color: Colors.grey[400],
          borderRadius: BorderRadius.all(
            Radius.circular(5),
          ),
        ),
        child: Container(
          child: new Column(
            children: <Widget>[
              new Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text(
                      day,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          color: Colors.black, fontSize: 12,fontWeight: FontWeight.bold
                      ),
                    ),
                  ]
              ),
              SizedBox(height: 1,),
              new Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text(
                      string1.substring(0, 5),
                      style: TextStyle(
                          color: Colors.black, fontSize: 9
                      ),
                    )
                  ]
              ),
              new Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text(
                      string1.substring(5, 10)+" "+string1.substring(13, 16),
                      style: TextStyle(
                          color: Colors.black, fontSize: 9
                      ),
                    ),
                  ]
              ),

            ],
          ),
        ),
      );


  Widget _VerySpecialShift(String day, String string1, int i) =>
      //print(day);
  //print("day111");
  Container(
    decoration: BoxDecoration(
      color:randomGenerator1(i),
      borderRadius: BorderRadius.all(
        Radius.circular(5),
      ),
    ),
    child: Container(
      child: new Column(
        children: <Widget>[
          new Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text(
                  day,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      color: Colors.black, fontSize: 12,fontWeight: FontWeight.bold
                  ),
                ),
              ]
          ),
          SizedBox(height: 1,),
          new Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                string1 != "Week off"?Text(
                  string1.substring(0, 5),
                  style: TextStyle(
                      color: Colors.black, fontSize: 9
                  ),
                ):Text(
                  "Week off",
                  style: TextStyle(
                      color: Colors.black, fontSize: 9
                  ),
                ),
              ]
          ), new Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                string1 != "Week off"?Text(
                  string1.substring(8,13),
                  style: TextStyle(
                      color: Colors.black, fontSize: 9
                  ),
                ):Text(
                  "",
                  style: TextStyle(
                      color: Colors.black, fontSize: 9
                  ),
                ),
              ]
          ),

        ],
      ),
    ),
  );

  /*@override
  Widget build(BuildContext context) {


    cHeight = MediaQuery.of(context).size.height ;
    _calendarCarouselNoHeader = CalendarCarousel<Event>(
      // width: 400,
      //height: cHeight * 0.75,
      //  daysTextStyle:

      todayButtonColor: Colors.transparent,
      inactiveDaysTextStyle: TextStyle(
        color: Colors.orange,
        fontSize: 17,
      ),
      inactiveWeekendTextStyle: TextStyle(
        color: Colors.orange,
        fontSize: 17,
      ),
      //todayBorderColor: Colors.black,
      todayTextStyle: TextStyle(
        color: Colors.blue,
      ),
      markedDatesMap: _markedDateMap,
      daysHaveCircularBorder: null,
      markedDateShowIcon: true,
      onDayPressed: (date, events) {
        _onDaySelected(date, events);
      },
      showOnlyCurrentMonthDate: true,
      markedDateIconMargin: 0,
      //targetDateTime: DateTime.now(),
      minSelectedDate: DateTime(now.year , now.month  , now.day),
      markedDateIconMaxShown: 1,
      markedDateMoreShowTotal: null,
      markedDateIconBuilder: (event) {
        return event.icon;
      },
    );
    return  getmainhomewidget();
  }*/

  Future<bool> sendToHome() async{
    /*Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => HomePage()),
    );*/
    print("-------> back button pressed");
    /* Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => HomePage()), (Route<dynamic> route) => false,
    );*/
    return false;
  }



  EventList<Event> _markedDateMap = new EventList<Event>(
    events: {},
  );

  CalendarCarousel _calendarCarouselNoHeader;
  double cHeight;



  @override
  Widget build(BuildContext context) {
    //showInSnackBar("guhljlkl");



    cHeight = MediaQuery.of(context).size.height ;
    _calendarCarouselNoHeader = CalendarCarousel<Event>(
      // width: 400,
      height: cHeight * 0.75,
      //  daysTextStyle:

      todayButtonColor: Colors.transparent,
      inactiveDaysTextStyle:  TextStyle(
          color: Colors.black, fontSize: 12,fontWeight: FontWeight.bold
      ),
      weekendTextStyle:  TextStyle(
          color: Colors.black, fontSize: 12,fontWeight: FontWeight.bold
      ),
      daysTextStyle:  TextStyle(
          color: Colors.black, fontSize: 12,fontWeight: FontWeight.bold
      ),
      inactiveWeekendTextStyle: TextStyle(
          color: Colors.black, fontSize: 12,fontWeight: FontWeight.bold
      ),
      prevDaysTextStyle:  TextStyle(
          color: Colors.black, fontSize: 12,fontWeight: FontWeight.bold
      ),
      nextDaysTextStyle:  TextStyle(
          color: Colors.black, fontSize: 12,fontWeight: FontWeight.bold
      ),
      isScrollable: false,
      //todayBorderColor: Colors.black,
      todayTextStyle:  TextStyle(
          color: Colors.black, fontSize: 12,fontWeight: FontWeight.bold
      ),
      markedDatesMap: _markedDateMap,
      headerTextStyle: TextStyle(
        color: globals.appcolor,
        fontSize: 20,
      ),
      //headerText: "ggkj,",
      daysHaveCircularBorder: null,
      markedDateShowIcon: true,
      onDayPressed: (date, events) {

        String Date = DateFormat('yyyy-MM-dd').format(date);

        print(Date);
        print(date);
        print(AttendanceDate);
        print(Date!= AttendanceDate);
        print("Date!= AttendanceDate");

       /* if((timeInPunched == false)  && (Date!= AttendanceDate))
        _onDaySelected(date, events);
        else{
          print(timeInPunched);
          print("timeInPunched");
          _onAlertTimeInPunched(date);
        }*/

        if((timeInPunched == true) && Date == AttendanceDate){
          _onAlertTimeInPunched(date);
        }
        else{
          _onDaySelected(date, events);
        }
      },
      showOnlyCurrentMonthDate: true,
      markedDateIconMargin: 0,
      //targetDateTime: DateTime.now(),
      minSelectedDate: DateTime(now.year , now.month -4 , 1),
      maxSelectedDate:  DateTime(now.year , now.month +6  , now.day),
      markedDateIconMaxShown: 1,
      //markedDateWidget:Positioned(child: Container(color: Colors.blueAccent, height: 50.0, width: 50.0), bottom: 4.0, left: 18.0),
      markedDateMoreShowTotal: null,
      iconColor: globals.appcolor,
      //  weekDayBackgroundColor: Colors.teal[100],
      weekdayTextStyle:TextStyle(
        color: globals.appcolor,
        fontSize: 15,
      ),
      markedDateIconBuilder: (event) {
        return event.icon;
      },
    );

    return new Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[

            new Text(_orgName, style: new TextStyle(fontSize: 20.0)),

            /*  Image.asset(
                    'assets/logo.png', height: 40.0, width: 40.0),*/
          ],
        ),
        leading: IconButton(icon:Icon(Icons.arrow_back),onPressed:(){
          Navigator.pop(context);}),
        backgroundColor: appcolor,
      ),
      bottomNavigationBar:Bottomnavigationbar(),
      endDrawer: new AppDrawer(),
      body: Container(
        child: Column(
          //mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            SizedBox(height: 8.0,),
            ///SizedBox(height: 8.0),
            Center(
              child: Name.length >15?Text( "Shift Planner - "+Name.toString().substring(0,15)+"...",
                style: new TextStyle(fontSize: 25.0, color: appcolor,),)

                  :Text("Shift Planner - "+Name,
                style: new TextStyle(fontSize: 25.0, color: appcolor,),),
            ),
            Divider(height: 10.0,color: Colors.black),
            SizedBox(height: 3.0,),
            Center(
              child: Text("Shifts",textAlign: TextAlign.start,
                style: new TextStyle(fontSize: 20.0, color: appcolor,),)
            ),
            SizedBox(height: 5.0,),

            Container(
              height: 75,
              child: Row(
                children: <Widget>[
                  /* SizedBox(
                  child: Text("<", style: new TextStyle(fontSize: 30, color: globals.appcolor,
                  ),textAlign: TextAlign.center,),
                ),*/
                  /* Container(
                    width: 30.0,
                    // height: 10.0,
                    *//*decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(24.0),
                    color: Colors.white,
                  ),*//*
                    child: Center(
                      child:  new Icon(Icons.keyboard_arrow_left,color: globals.appcolor),
                    ),
                  ),*/
                  SizedBox(
                      width:MediaQuery.of(context).size.width * .96 ,
                      child: getShifttWidget()
                  ),
                  /*Container(
                    width: 30,

                    child: Center(
                      child:  new Icon(Icons.keyboard_arrow_right,color: globals.appcolor),
                    ),
                  ),*/
                ],
              ),
            ),
            Expanded(child: _calendarCarouselNoHeader),
            //markerRepresent(),
            //Expanded(child: userlist.isEmpty?Container(): _buildEventList()),
            //Expanded(child: getShifttWidget()),
          ],
        ),
      ),
    );
  }

  Widget markerRepresent() {
    return new ButtonTheme(
      minWidth: MediaQuery.of(context).size.width*0.8,
      //height: 2.0,
      child:RaisedButton(
        child: Text('Confirm location & Proceed',style: new TextStyle(color: Colors.white,fontSize: 15.0)),
        color: Colors.orangeAccent,
        onPressed: () {

        },

      ),
    );
  }

  void _onDaySelected(DateTime day, List events) {
    print('CALLBACK: _onDaySelected');
    print(day);
    setState(() {
      _selectedEvents = day ;
      /*  getPlannerWiseSummary(_selectedEvents).then((values){
        setState(() {
          userlist = values;

          *//*if(!userlist.isEmpty) {
             print("inside if");
             _buildEventList();
           }*//*
        });
      });*/
    });

    if((shiftPressed == true) && (!daysGoneList.containsKey(_selectedEvents)) ) {

      if (!specialShiftsList.containsKey(_selectedEvents)) {                                //when shift is newly assigned

        if(removedShiftsList.containsKey(_selectedEvents)) {
          removedShiftsList.remove(_selectedEvents);
          print(removedShiftsList);
        }

        if(selectedShiftweekoff.containsKey(_selectedEvents)){
          specialShiftsList.addAll({_selectedEvents: [selectedShiftTiming,selectedShiftName,'1',selectedShiftId,_selectedEvents.toString(),'1',HoursPerDay, shifttype]});
          specialshiftdate = specialShiftsList.keys.toList();
        }

        else{
          specialShiftsList.addAll({_selectedEvents: [selectedShiftTiming,selectedShiftName,'1',selectedShiftId,_selectedEvents.toString(),'0',HoursPerDay, shifttype]});
          specialshiftdate = specialShiftsList.keys.toList();
          print(specialShiftsList);
          print("specialShiftsList");

        }

        for (int i = 0; i < specialShiftsList.length; i++) {
          print(specialShiftsList.values.elementAt(i)[1]);
          print("specialShiftsList.values.elementAt(i)");
          print(i);

          /* if(items[0].shifttype.toString() == '3')
          {
            DefaultShiftList.addAll({firstDayOfMonth : ['Flexi('+items[0].HoursPerDay+' Hrs)' ]});
          }*/

          if (DefaultShiftList.containsKey(_selectedEvents))
            DefaultShiftList.remove(_selectedEvents); //to remove default shifts from the list

          //_markedDateMap.removeAll(day); // to remove icon from the calendar widget

          //  print(specialShiftsList.values.elementAt(0).toString());
          //  print("specialShiftsList.values.elementAt(0).toString()");

          if(selectedShiftweekoff.containsKey(_selectedEvents) ) {
            _markedDateMap.removeAll(day);
            _markedDateMap.add(
              _selectedEvents,
              new Event(
                date: _selectedEvents,
                title: 'Event 5',
                icon: _eventIcon(specialShiftsList.keys
                    .elementAt(i)
                    .day
                    .toString(),
                    "Week off",
                    shiftColor),
              ),
            );
          }

          else {

            if(shifttype=='3'){
              print("hkhlkhlkjl");
              _markedDateMap.removeAll(day);
              _markedDateMap.add(
                specialshiftdate[i],
                new Event(
                  date: specialshiftdate[i],
                  title: 'Event 5',
                  icon: _FlexiIcon(specialShiftsList.keys.elementAt(i).day.toString(),
                      "Flexi"+HoursPerDay+"Hrs",
                      shiftColor),
                ),
              );
            }
            else {
              _markedDateMap.removeAll(day);
              _markedDateMap.add(
                specialshiftdate[i],
                new Event(
                  date: specialshiftdate[i],
                  title: 'Event 5',
                  icon: _eventIcon(specialShiftsList.keys
                      .elementAt(i)
                      .day
                      .toString(),
                      specialShiftsList.values.elementAt(i).toString(),
                      shiftColor),
                ),
              );
            }
          }
        }
      }

      else if(specialShiftsList.containsKey(_selectedEvents)) {

        bool status = true;
        specialShiftsList.forEach((k, v) {

          if(k ==_selectedEvents &&  v[1] != selectedShiftName ) {
            status = false;

            if(removedShiftsList.containsKey(_selectedEvents)) {
              removedShiftsList.remove(_selectedEvents);
              print(removedShiftsList);
            }

            if(selectedShiftweekoff.containsKey(_selectedEvents)){
              specialShiftsList.update(k,(v) => [ selectedShiftTiming,selectedShiftName,'2',selectedShiftId,_selectedEvents.toString(),'1']);
              _markedDateMap.removeAll(day);
              _markedDateMap.add(
                _selectedEvents,
                new Event(
                  date: _selectedEvents,
                  title: 'Event 5',
                  icon: _eventIcon(_selectedEvents.day.toString(),
                      "Week off",
                      shiftColor),
                ),
              );
            }

            else{
              specialShiftsList.update(k,(v) => [ selectedShiftTiming,selectedShiftName,'2',selectedShiftId,_selectedEvents.toString(),'0']);

              if(shifttype=='3'){
                print("hkhlkhlkjl");
                _markedDateMap.removeAll(day);
                _markedDateMap.add(
                  _selectedEvents,
                  new Event(
                    date: _selectedEvents,
                    title: 'Event 5',
                    icon: _FlexiIcon(_selectedEvents.day.toString(),
                        "Flexi"+HoursPerDay+"Hrs",
                        shiftColor),
                  ),
                );
              }
              else {
                _markedDateMap.removeAll(
                    day); // to remove icon from the calendar widget
                _markedDateMap.add(
                  _selectedEvents,
                  new Event(
                    date: _selectedEvents,
                    title: 'Event 5',
                    icon: _eventIcon(_selectedEvents.day.toString(),
                        '[' + selectedShiftTiming + ']', shiftColor),
                  ),
                );
              }
            }

            /*_markedDateMap.removeAll(day); // to remove icon from the calendar widget
            _markedDateMap.add(
              _selectedEvents,
              new Event(
                date: _selectedEvents,
                title: 'Event 5',
                icon: _eventIcon(_selectedEvents.day.toString(), '['+selectedShiftTiming+']',shiftColor),
              ),
            )*/;
          }
          print(status);
          print("status22");

        });

        if(status) {

          if (weekoff.containsKey(_selectedEvents)) {
            specialShiftsList.remove(_selectedEvents);
            removedShiftsList.addAll({_selectedEvents:[selectedShiftTiming,selectedShiftName,'0',selectedShiftId,_selectedEvents.toString(),'0']});
            print(removedShiftsList);
            print("removedlista");

            _markedDateMap.removeAll(day);
            _markedDateMap.add(
              _selectedEvents,
              new Event(
                date: _selectedEvents,
                title: 'Event 5',
                icon: _absentIcon(_selectedEvents.day.toString()),
              ),
            );
          }
          else if(holidayDateList.contains(_selectedEvents)){
            specialShiftsList.remove(_selectedEvents);
            removedShiftsList.addAll({_selectedEvents:[selectedShiftTiming,selectedShiftName,'0',selectedShiftId,_selectedEvents.toString(),'0']});
            _markedDateMap.removeAll(day);
            _markedDateMap.add(
              _selectedEvents,
              new Event(
                date: _selectedEvents,
                title: 'Event 5',
                icon: _holidayIcon(_selectedEvents.day.toString()),
              ),
            );
          }
          else {
            specialShiftsList.remove(_selectedEvents);
            removedShiftsList.addAll({_selectedEvents:[selectedShiftTiming,selectedShiftName,'0',selectedShiftId,_selectedEvents.toString(),'0']});
            print(removedShiftsList);

            DefaultShiftList.addAll({_selectedEvents: [items[0].ShiftTimeIn + items[0].ShiftTimeOut]});
            _markedDateMap.removeAll(day);
            _markedDateMap.add(
              _selectedEvents,
              new Event(
                date: _selectedEvents,
                title: 'Event 5',
                icon: _presentIcon(_selectedEvents.day.toString(),
                    DefaultShiftList.values.elementAt(0).toString()),
              ),
            );
          }
        }
      }
      else{
        //print("hjhkllklhlklkjljlkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkk");
      }

      if(specialShiftsList.containsKey(_selectedEvents) || removedShiftsList.containsKey(_selectedEvents)) {
        var fetchlist1 = specialShiftsList[_selectedEvents] == null?removedShiftsList[_selectedEvents]:specialShiftsList[_selectedEvents] ;
        print(fetchlist1);
        saveMultishifts(fetchlist1,Id ).then((val) => setState(() {
          statusOfShift = val;
          if(statusOfShift["status"] == "Shift is already assigned on this date")
          {
            showInSnackBar("Shift is already assigned on this date");
          }
          //print(_holiday.length);
        }));
        //onTap service call work starts-->
      }
    }

    else{

      if(daysGoneList.containsKey(_selectedEvents) ) {
        _onAlertWithCustomContentPressed(_selectedEvents);
      }


      else{
        List fetchlist2 = ['','','0','', _selectedEvents,'0'];
        saveMultishifts(fetchlist2,Id ).then((val) => setState(() {
          statusOfShift = val;
          if(statusOfShift["status"] == "Shift is already assigned on this date")
          {
            showInSnackBar("Shift is already assigned on this date");
          }
          //print(_holiday.length);
        }));

        if (weekoff.containsKey(_selectedEvents)) {
          _markedDateMap.removeAll(day);
          _markedDateMap.add(
            _selectedEvents,
            new Event(
              date: _selectedEvents,
              title: 'Event 5',
              icon: _absentIcon(_selectedEvents.day.toString()),
            ),
          );
        }
        else if(holidayDateList.contains(_selectedEvents)){
          _markedDateMap.removeAll(day);
          _markedDateMap.add(
            _selectedEvents,
            new Event(
              date: _selectedEvents,
              title: 'Event 5',
              icon: _holidayIcon(_selectedEvents.day.toString()),
            ),
          );

        }
        else{
          _markedDateMap.removeAll(day);
          _markedDateMap.add(
            _selectedEvents,
            new Event(
              date: _selectedEvents,
              title: 'Event 5',
              icon: _presentIcon(_selectedEvents.day.toString(),
                  DefaultShiftList.values.elementAt(0).toString()),
            ),
          );
        }

        /* _markedDateMap.removeAll(day);
      _markedDateMap.add(
        _selectedEvents,
        new Event(
          date: _selectedEvents,
          title: 'Event 5',
          icon: _presentIcon(_selectedEvents.day.toString(),
              DefaultShiftList.values.elementAt(0).toString()),
        ),
      );*/
      }
    }






    //--------------------------------------------------------------------------------------------------------------------//
    /* if(shiftPressed == true) {
      //shiftName = specialShiftsList.values.elementAt(0);
      // print(shiftName);
      print(specialShiftsList.containsValue(selectedShiftName));
      print(specialShiftsList.containsValue(selectedShiftTiming));
      print("-------------------------------125478963254125");
      print(specialShiftsList.containsKey(_selectedEvents));
      print(specialShiftsList);
      print(selectedShiftName);


     // if(specialShiftsList.containsValue(shiftName[1])) {
        print("5akkaaaa");
        if (specialShiftsList.containsKey(_selectedEvents)) {
          print("1akka");
          specialShiftsList.remove(_selectedEvents);
          print("4akkaaa");
          if (weekoff.containsKey(_selectedEvents)) {
            print("3akka");
            _markedDateMap.removeAll(day);
            _markedDateMap.add(
              _selectedEvents,
              new Event(
                date: _selectedEvents,
                title: 'Event 5',
                icon: _absentIcon(_selectedEvents.day.toString()),
              ),
            );
          }
          else {
            print("2akka");
            DefaultShiftList.addAll(
                {
                  _selectedEvents: [
                    items[0].ShiftTimeIn + items[0].ShiftTimeOut
                  ]
                });
            _markedDateMap.removeAll(day);
            _markedDateMap.add(
              _selectedEvents,
              new Event(
                date: _selectedEvents,
                title: 'Event 5',
                icon: _presentIcon(_selectedEvents.day.toString(),
                    DefaultShiftList.values.elementAt(0).toString()),
              ),
            );
          }
        }
   //   }


      else {
        print("inside hulala");
        specialShiftsList.addAll(
            {_selectedEvents: [selectedShiftTiming, selectedShiftName]});
        specialshiftdate = specialShiftsList.keys.toList();

        for (int i = 0; i < specialShiftsList.length; i++) {
        //  shiftName = specialShiftsList.values.elementAt(i);
          if (DefaultShiftList.containsKey(_selectedEvents))
            DefaultShiftList.remove(
                _selectedEvents); //to remove default shifts from the list
          _markedDateMap.removeAll(
              day); // to remove icon from the calendar widget
          _markedDateMap.add(
            specialshiftdate[i],
            new Event(
              date: specialshiftdate[i],
              title: 'Event 5',
              icon: _eventIcon(specialShiftsList.keys
                  .elementAt(i)
                  .day
                  .toString(), specialShiftsList.values.elementAt(i).toString(),
                  shiftColor),
            ),
          );
        }
      }
     // print(shiftName);
     // print("name i ");

    }*/
  }

  _onAlertWithCustomContentPressed(date) async {

    var userlist = await getPlannerWiseSummary(date,Id);

    if (userlist.isNotEmpty){
      var alertStyle = AlertStyle(
        animationType: AnimationType.fromTop,
        isCloseButton: false,
        isOverlayTapDismiss: true,
        descStyle: TextStyle(fontWeight: FontWeight.bold),
        animationDuration: Duration(milliseconds: 400),

      );
      Alert(
          style: alertStyle,
          context: context,
          title: Formatdate(date.toString().substring(0, 10)),
          //desc: "Shift Timings: 09:15 - 10:60",

          //image: ,
          content: Wrap(
            children: <Widget>[
              Container(
                height: MediaQuery
                    .of(context)
                    .size
                    .height * 0.45,
                width: MediaQuery
                    .of(context)
                    .size
                    .width * 0.70,
                child: Column(
                  children: <Widget>[
                    Row(
                      mainAxisAlignment: MainAxisAlignment
                          .end,
                      children: <Widget>[
                      ],
                    ),

                    SizedBox(height: 10.0),
                    /* new Text(
                    snapshot.data[index].Name.toString(),
                    style: TextStyle(
                        color: Colors.black87,
                        fontSize: 18.0,
                        fontWeight: FontWeight.w600
                    ),
                  ),*/
                    SizedBox(height: 10,),
                    Table(
                      defaultVerticalAlignment: TableCellVerticalAlignment
                          .top,
                      columnWidths: {

                        0: FlexColumnWidth(5),
                        // 0: FlexColumnWidth(4.501), // - is ok
                        // 0: FlexColumnWidth(4.499), //- ok as well
                        1: FlexColumnWidth(5),
                        //2: FlexColumnWidth(5),
                      },
                      children: [
                        TableRow(
                            children: [
                              TableCell(
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  mainAxisAlignment: MainAxisAlignment
                                      .spaceAround,
                                  children: <Widget>[
                                    new Text(
                                      "Time In",
                                      style: TextStyle(
                                          color: Colors
                                              .black87,
                                          fontSize: 15.0,
                                          fontWeight: FontWeight
                                              .bold
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              TableCell(

                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  mainAxisAlignment: MainAxisAlignment
                                      .spaceAround,
                                  children: <Widget>[
                                    new Text(
                                      "Time Out",
                                      style: TextStyle(
                                          color: Colors
                                              .black87,
                                          fontSize: 15.0,
                                          fontWeight: FontWeight
                                              .bold
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ]
                        ),
                        TableRow(
                            children: [
                              TableCell(
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  mainAxisAlignment: MainAxisAlignment
                                      .spaceAround,
                                  children: <Widget>[
                                    new Text(
                                      userlist.isEmpty ? "-" : userlist[0]
                                          .TimeIn,
                                      style: TextStyle(
                                          color: Colors
                                              .black87,
                                          fontSize: 15.0,
                                          fontWeight: FontWeight
                                              .w400
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              TableCell(
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  mainAxisAlignment: MainAxisAlignment
                                      .spaceAround,
                                  children: <Widget>[
                                    new Text(
                                      userlist.isEmpty ? "-" : userlist[0]
                                          .TimeOut,
                                      style: TextStyle(
                                          color: Colors
                                              .black87,
                                          fontSize: 15.0,
                                          fontWeight: FontWeight
                                              .w400
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ]
                        ),
                        TableRow(
                            children: [
                              TableCell(
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  mainAxisAlignment: MainAxisAlignment
                                      .spaceAround,
                                  children: <Widget>[
                                    InkWell(
                                      child: Container(
                                          width: 70.0,
                                          height: 70.0,
                                          decoration: new BoxDecoration(
                                              shape: BoxShape.circle,
                                              border: Border.all(
                                                  width: 2, color: Colors.teal//                   <--- border width here
                                              ),
                                              image: new DecorationImage(
                                                  fit: BoxFit.fill,
                                                  image:
//
                                                  userlist.isNotEmpty
                                                      ? NetworkImage(
                                                      userlist[0].EntryImage)
                                                      : AssetImage(
                                                      'assets/avatar.png')
                                              )
                                          )
                                      ),
                                      onTap: () {
                                        if (userlist.isNotEmpty) {
                                          Navigator.of(
                                              context, rootNavigator: true)
                                              .pop();

                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    ImageView(
                                                        myimage: userlist[0]
                                                            .EntryImage,
                                                        org_name: _orgName)),
                                          );
                                        }
                                      },
                                    ),
                                  ],
                                ),
                              ),

                              TableCell(
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  mainAxisAlignment: MainAxisAlignment
                                      .spaceAround,
                                  children: <Widget>[
                                    InkWell(
                                      child: Container(
                                          width: 70.0,
                                          height: 70.0,
//                               child: FadeInImage.assetNetwork(
//                                  placeholder: 'assets/user_profile.png',
//                                  ),
                                          decoration: new BoxDecoration(
                                              border: Border.all(
                                                  width: 2, color: Colors.teal//                   <--- border width here
                                              ),
                                              shape: BoxShape.circle,
                                              image: new DecorationImage(
                                                  fit: BoxFit.fill,
                                                  image:
//                                          AssetImage('assets/user_profile.png'),
//                                            _checkLoaded
//                                                ? AssetImage('assets/imgloader.gif')
//                                                :
                                                  userlist.isNotEmpty
                                                      ? NetworkImage(
                                                      userlist[0].ExitImage)
                                                      : AssetImage(
                                                      'assets/avatar.png')

                                                //_checkLoaded ? AssetImage('assets/avatar.png') : profileimage,
                                              )
                                          )
                                      ),
                                      onTap: () {
                                        if (userlist.isNotEmpty) {
                                          Navigator.of(
                                              context, rootNavigator: true)
                                              .pop();


                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    ImageView(
                                                        myimage: userlist[0]
                                                            .ExitImage,
                                                        org_name: _orgName)),
                                          );
                                        }
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            ]
                        ),
                        //TableRow(),

                        TableRow(
                            children: [
                              TableCell(
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  mainAxisAlignment: MainAxisAlignment
                                      .spaceAround,
                                  children: <Widget>[
                                    Expanded(
                                      flex: 40,
                                      child: new Container(
                                        //color: Colors.red,
                                        padding: new EdgeInsets.only(left: 10.0,
                                            right: 10.0,
                                            top: 10,
                                            bottom: 10),
                                        child: Column(
                                          mainAxisAlignment: MainAxisAlignment
                                              .center,
                                          children: <Widget>[
                                            InkWell(
                                              child: Center(
                                                child: Text(
                                                  userlist.isEmpty
                                                      ? "-"
                                                      : userlist[0].checkInLoc,
                                                  style: TextStyle(
                                                      color: Colors.black54,
                                                      fontSize: 12.0),
                                                  textAlign: TextAlign.center,),
                                              ),
                                              onTap: () {
                                                goToMap(userlist.isEmpty
                                                    ? "-"
                                                    : userlist[0].latit_in,
                                                    userlist.isEmpty
                                                        ? "-"
                                                        : userlist[0].longi_in);
                                              },
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              TableCell(
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  mainAxisAlignment: MainAxisAlignment
                                      .spaceAround,
                                  children: <Widget>[
                                    Expanded(
                                      flex: 40,
                                      child: new Container(
                                        padding: new EdgeInsets.only(left: 10.0,
                                            right: 10.0,
                                            top: 10,
                                            bottom: 10),
                                        child: Column(
                                          mainAxisAlignment: MainAxisAlignment
                                              .center,
                                          children: <Widget>[

                                            InkWell(
                                              child: Center(
                                                child: Text(
                                                  userlist.isEmpty
                                                      ? "-"
                                                      : userlist[0].CheckOutLoc,
                                                  style: TextStyle(
                                                      color: Colors.black54,
                                                      fontSize: 12.0),
                                                  textAlign: TextAlign.center,),
                                              ),
                                              onTap: () {
                                                goToMap(userlist.isEmpty
                                                    ? "-"
                                                    : userlist[0].latit_out,
                                                    userlist.isEmpty
                                                        ? "-"
                                                        : userlist[0]
                                                        .longi_out);
                                              },
                                            ),
                                            /*Container(
                                              padding: EdgeInsets.all(2.0),
                                              color: snapshot.data[index].incolor.toString()=='0'?Colors.red:Colors.green,

                                              child: Text(snapshot.data[index].instatus,
                                                style: TextStyle(fontWeight: FontWeight.bold,fontSize: 12.0,color: Colors.white),
                                              ),
                                            ),*/
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ]
                        ),

/*
                        TableRow(
                            children: [
                              TableCell(
                                child: Row(
                                  //crossAxisAlignment: CrossAxisAlignment.baseline,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: <Widget>[
                                    Align(
                                      alignment: Alignment.centerLeft,

                                      child :Text(
                                        'Logged Hour',textAlign: TextAlign.left,
                                        style: TextStyle(
                                            color: Colors
                                                .black87,
                                            fontSize: 15.0,
                                            fontWeight: FontWeight
                                                .bold
                                        ),
                                      ),
                                    )
                                  ],
                                ),
                              ),
                              TableCell(
                                child: Row(
                                  // crossAxisAlignment: CrossAxisAlignment.end,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: <Widget>[
                                    new Text(
                                      userlist.isEmpty?"-": userlist[0].thours,
                                      style: TextStyle(
                                          color: Colors
                                              .black87,
                                          fontSize: 15.0,
                                          fontWeight: FontWeight
                                              .w400
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ]
                        ),
                        TableRow(
                            children: [
                              TableCell(
                                child: Row(
                                  //   crossAxisAlignment: CrossAxisAlignment.end,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: <Widget>[
                                    Align(
                                      alignment: Alignment.centerLeft,

                                      child :    Text(
                                        'Shift Time In',textAlign: TextAlign.left,
                                        style: TextStyle(
                                            color: Colors
                                                .black87,
                                            fontSize: 15.0,
                                            fontWeight: FontWeight
                                                .bold
                                        ),
                                      ),
                                    )
                                  ],
                                ),
                              ),
                              TableCell(
                                child: Row(
                                  // crossAxisAlignment: CrossAxisAlignment.end,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: <Widget>[
                                    Text(
                                      items[0].ShiftTimeIn.toString().substring(0,5)+'-'+items[0].ShiftTimeOut.toString().substring(0,5)==""?"-"
                                          :items[0].ShiftTimeIn.toString().substring(0,5),
                                      style: TextStyle(
                                          color: Colors
                                              .black87,
                                          fontSize: 15.0,
                                          fontWeight: FontWeight
                                              .w400
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                            ]
                        ),   TableRow(
                            children: [
                              TableCell(
                                child: Row(
                                  //  crossAxisAlignment: CrossAxisAlignment.end,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: <Widget>[
                                    Align(
                                      alignment: Alignment.centerLeft,

                                      child :    Text(
                                        'Shift Time Out',textAlign: TextAlign.left,
                                        style: TextStyle(
                                            color: Colors
                                                .black87,
                                            fontSize: 15.0,
                                            fontWeight: FontWeight
                                                .bold
                                        ),
                                      ),
                                    )
                                  ],
                                ),
                              ),
                              TableCell(
                                child: Row(
                                  // crossAxisAlignment: CrossAxisAlignment.end,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: <Widget>[
                                    Text(
                                      items[0].ShiftTimeIn.toString().substring(0,5)+'-'+items[0].ShiftTimeOut.toString().substring(0,5)==""?"-"
                                          :items[0].ShiftTimeOut.toString().substring(0,5),
                                      style: TextStyle(
                                          color: Colors
                                              .black87,
                                          fontSize: 15.0,
                                          fontWeight: FontWeight
                                              .w400
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                            ]
                        ),
                        TableRow(
                            children: [
                              TableCell(
                                child: Row(
                                  //crossAxisAlignment: CrossAxisAlignment.end,
                                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                                  children: <Widget>[
                                    Align(
                                      alignment: Alignment.centerLeft,

                                      child : Text(
                                        'Overtime',textAlign: TextAlign.left,
                                        style: TextStyle(
                                            color: Colors
                                                .black87,
                                            fontSize: 15.0,
                                            fontWeight: FontWeight
                                                .bold
                                        ),
                                      ),
                                    )
                                  ],
                                ),
                              ),
                              TableCell(
                                child: Row(
                                  // crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: <Widget>[
                                    Text(
                                userlist.isEmpty?"-": userlist[0].overtime,
                                      style: TextStyle(
                                          color: Colors
                                              .black87,
                                          fontSize: 15.0,
                                          fontWeight: FontWeight
                                              .w400
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ]
                        ),*/


                      ],
                    ),
                    //SizedBox(height: 10.0),
                    // Divider(height: MediaQuery.of(context).size.height*.01),
                    //SizedBox(height: 10.0),
                    Divider(color: Colors.black54, height: 1.5,),
                    SizedBox(height: 19,),
                    Container(
                      padding: new EdgeInsets.only(left: 15.0, right: 10.0),
                      decoration: new ShapeDecoration(
                          shape: new RoundedRectangleBorder(
                              borderRadius: new BorderRadius.circular(20.0)),
                          color: Colors.white.withOpacity(0.1)
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: <Widget>[

                          Row(
                            children: <Widget>[
                              Icon(Icons.timelapse, size: 20.0,
                                color: Colors.black54,), SizedBox(width: 5.0),
                              new Text("Shift Timings: ", style: new TextStyle(
                                  fontSize: 15.0,
                                  color: Colors.black87,
                                  fontWeight: FontWeight.bold)),
                              new Text(
                                  userlist.isEmpty ? "-"
                                      : userlist[0].ShiftTimeIn+" - "+userlist[0].ShiftTimeOut,
                                  style: new TextStyle(fontSize: 15.0,
                                      fontWeight: FontWeight.w400)),
                            ],
                          ),
                          SizedBox(height: MediaQuery
                              .of(context)
                              .size
                              .height * .01),
                          Row(
                            children: <Widget>[
                              Icon(Icons.access_time, size: 20.0,
                                color: Colors.black54,), SizedBox(width: 5.0),
                              new Text("Logged Hours: ", style: new TextStyle(
                                  fontSize: 15.0,
                                  color: Colors.black87,
                                  fontWeight: FontWeight.bold)),
                              new Text(
                                  userlist.isEmpty ? "-" : userlist[0].thours,
                                  style: new TextStyle(fontSize: 15.0,
                                      fontWeight: FontWeight.w400)),
                            ],
                          ),
                          /*SizedBox(height: MediaQuery
                              .of(context)
                              .size
                              .height * .01),*/
                          /*Row(
                            children: <Widget>[
                              Icon(Icons.timer, size: 20.0,
                                color: Colors.black54,), SizedBox(width: 5.0),
                              new Text("Shift TimeIn: ", style: new TextStyle(
                                  fontSize: 15.0,
                                  color: Colors.black87,
                                  fontWeight: FontWeight.bold)),
                              new Text(userlist.isEmpty ? "-"
                                  : userlist[0].ShiftTimeIn,
                                  style: new TextStyle(fontSize: 15.0,
                                      fontWeight: FontWeight.w400)),
                            ],
                          ),
                          SizedBox(height: MediaQuery
                              .of(context)
                              .size
                              .height * .01),
                          Row(
                            children: <Widget>[
                              Icon(Icons.timer, size: 20.0,
                                color: Colors.black54,), SizedBox(width: 5.0),
                              new Text("Shift TimeOut: ", style: new TextStyle(
                                  fontSize: 15.0,
                                  color: Colors.black87,
                                  fontWeight: FontWeight.bold)),
                              new Text(userlist.isEmpty ? "-"
                                  : userlist[0].ShiftTimeOut,
                                  style: new TextStyle(fontSize: 15.0,
                                      fontWeight: FontWeight.w400)),
                            ],
                          ),*/
                          SizedBox(height: MediaQuery
                              .of(context)
                              .size
                              .height * .01),
                          Row(
                            children: <Widget>[
                              Icon(Icons.timer, size: 20.0,
                                color: Colors.black54,), SizedBox(width: 5.0),

                              userlist.isEmpty ?new Text("Undertime: ", style: new TextStyle(
                                  fontSize: 15.0,
                                  color: Colors.black87,
                                  fontWeight: FontWeight.bold))

                                  :userlist[0].overtime.contains("-")?new Text("Undertime: ", style: new TextStyle(
                                  fontSize: 15.0,
                                  color: Colors.black87,
                                  fontWeight: FontWeight.bold))

                                  :Text("Overtime: ", style: new TextStyle(
                                  fontSize: 15.0,
                                  color: Colors.black87,
                                  fontWeight: FontWeight.bold)),


                              userlist.isEmpty || userlist[0].overtime=="-" ?new Text('-',style: new TextStyle(fontSize: 15.0,
                                  fontWeight: FontWeight.w400)):userlist[0].overtime.contains("-")?Text(userlist[0].overtime,style: new TextStyle(fontSize: 15.0,
                                  fontWeight: FontWeight.bold,color: Colors.red)):Text(userlist[0].overtime,style: new TextStyle(fontSize: 15.0,
                                  fontWeight: FontWeight.bold,color: Colors.green)),
                              /* new Text(
                                  userlist.isEmpty ? "-" : userlist[0].overtime.contains("-")?Text(userlist[0].overtime,style: new TextStyle(fontSize: 15.0,
                                  fontWeight: FontWeight.bold,color: Colors.red)):
                                 Text( userlist[0].overtime,style: new TextStyle(fontSize: 15.0,
                                      fontWeight: FontWeight.bold,color: Colors.green))),*/
                            ],
                          ),
                          SizedBox(height: MediaQuery
                              .of(context)
                              .size
                              .height * .01),
                        ],

                      ),
                    )
                  ],
                ),
              ),
            ],
          ),

          buttons: [
            DialogButton(
              width: MediaQuery
                  .of(context)
                  .size
                  .width * 0.22,
              color: Colors.orangeAccent,
              onPressed: () {
                Navigator.of(context, rootNavigator: true).pop();
              },
              child:Text(
                "OK",
                style: TextStyle(color: Colors.white, fontSize: 20),
              ),
            )
          ]).show();
    }
    // });
  }

  var loginWidth =0.0;
  Curve _curve = Curves.easeInOut;
  _doanimation(){
    setState(() {
      loginWidth ==0.0? loginWidth =50: loginWidth =0.0;
    });
  }

  Widget _buildEventList() {
    print("inside1236");
    print(_selectedEvents);
    // print(userlist[0].AttendanceDate);
    return Center(
      child: PageView(
        children: <Widget>[
          Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              RaisedButton (
                child: Text(userlist[0].AttendanceDate),
                onPressed: () {
                  setState(() {
                    loginWidth = 250.0;
                  });
                },
              ),
              AnimatedContainer (
                duration: Duration (seconds: 1),
                width: loginWidth,
                height: 40,
                color: Colors.red,
              ),
            ],
          )
        ],
      ),
    );
  }
/* return ListView(
      children: _selectedEvents.map((event) => Container(
        decoration: BoxDecoration(
          border: Border.all(width: 0.8),
          borderRadius: BorderRadius.circular(12.0),
        ),
        margin:
        const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
        child: ListTile(
          title: Text(event.toString().substring(0,5)+' - '+event.toString().substring(8,13),),
          onTap: () => print('$event tapped!'),
        ),
      ))
          .toList(),
    );*/



  getShifttWidget() {

    return new FutureBuilder<List<Shift>>(
        future: _shifts,
        builder: (context, snapshot) {
          if (snapshot.hasData) {

            return new ListView.builder(

                scrollDirection: Axis.horizontal,
                itemCount: snapshot.data.length,
                itemBuilder: (BuildContext context, int index) {
                  cond = false;

                  if(distinctIds.contains(snapshot.data[index].Id.toString())) {
                    cond = true;
                    indexOfColorforShiftTile = distinctIds.indexOf(snapshot.data[index].Id.toString()) % 12;

                  }

                  return  new Column(
                      children: <Widget>[
                        new FlatButton(
                          child : new Row(
                            // crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              new Container(
                                height:  MediaQuery.of(context).size.height*0.09,

                                decoration: BoxDecoration(
                                    border:  _selectedIndex != null && _selectedIndex == index? Border.all(
                                      width: 2, //                   <--- border width here
                                    ): Border.all(
                                      width: 1, //                   <--- border width here
                                    ),

                                    //specialshiftColor[i]

                                    color:  cond?specialshiftColor[indexOfColorforShiftTile]:_selectedIndex != null && _selectedIndex == index? circleColors[shiftColor]
                                        : Colors.grey[200],
                                    borderRadius:BorderRadius.all(
                                      Radius.circular(5),
                                    )
                                ),
                                width: MediaQuery.of(context).size.width*0.30,

                                child: ListTile(
                                  title: _selectedIndex != null && _selectedIndex == index?  Text(snapshot.data[index].Name.toString(),textAlign: TextAlign.center,style: new TextStyle( color: Colors.black,),)
                                      :Text(snapshot.data[index].Name.toString(),textAlign: TextAlign.center,),

                                  subtitle: snapshot.data[index].shifttype.toString()!='3'? _selectedIndex != null && _selectedIndex == index?  new Text(formatTime(snapshot.data[index].TimeIn.toString())+' - '+formatTime(snapshot.data[index].TimeOut.toString()),textAlign: TextAlign.center, style: new TextStyle( color: Colors.black,),)
                                      :new Text(formatTime(snapshot.data[index].TimeIn.toString())+' - '+formatTime(snapshot.data[index].TimeOut.toString()),textAlign: TextAlign.center,)
                                      : _selectedIndex != null && _selectedIndex == index?  new Text(formatTime(snapshot.data[index].HoursPerDay.toString().substring(0,5)+" Hours"),textAlign: TextAlign.center, style: new TextStyle( color: Colors.black,),)
                                      :new Text(formatTime(snapshot.data[index].HoursPerDay.toString().substring(0,5)+" Hours"),textAlign: TextAlign.center,),
                                  dense:true,
                                  onTap: (){
                                    setState(() {

                                      selectedShiftTiming = snapshot.data[index].TimeIn+snapshot.data[index].TimeOut ;
                                      selectedShiftId = snapshot.data[index].Id;
                                      selectedShiftName = snapshot.data[index].Name;
                                      HoursPerDay =snapshot.data[index].HoursPerDay;
                                      shifttype =snapshot.data[index].shifttype;
                                      print(HoursPerDay);
                                      print("HoursPerDay123");
                                      print(shifttype);
                                      indexOfColorforShiftTile1=null;

                                      if(distinctIds.contains(snapshot.data[index].Id.toString())) {
                                        cond = true;
                                        indexOfColorforShiftTile1 = distinctIds.indexOf(snapshot.data[index].Id.toString()) % 12;
                                      }

                                      print(indexOfColorforShiftTile1);
                                      print("indexOfColorforShiftTile1");

                                      shiftplanner(Id,selectedShiftId).then((val) {

                                        setState(() {
                                          items1 = val;
                                          _onSelected(index);
                                          shiftPressed = true;
                                          if(indexOfColorforShiftTile1!=null){
                                            shiftColor = indexOfColorforShiftTile1;
                                          }
                                          else {
                                            print(shiftColor);
                                            print("shiftColor");
                                            shiftColor++;
                                          }
                                          if (shiftColor == 13)
                                            shiftColor = 0;
                                        });

                                        getSelectedShiftWekoff().then((val) => setState(() {
                                          print(val);
                                          print("ggjkgkjh");
                                          _holiday = val;
                                          //print(_holiday.length);
                                        }));
                                      });
                                      /* _onSelected(index);
                                      shiftPressed = true;
                                    *//*  selectedShiftTiming = snapshot.data[index].TimeIn+snapshot.data[index].TimeOut ;
                                      selectedShiftId = snapshot.data[index].Id;
                                      selectedShiftName = snapshot.data[index].Name;*//*
                                      shiftColor++;
                                      if(shiftColor == 4)
                                        shiftColor=0;*/
                                    });

                                  },
                                ),

                              ),
                            ],
                          ),
                          /* onPressed: () {
                            setState(() {

                              shiftPressed = true;
                              selectedShiftTiming = snapshot.data[index].TimeIn+snapshot.data[index].TimeOut ;
                              print(selectedShiftTiming);
                              shiftColor++;
                              if(shiftColor == 3)
                                shiftColor=0;

                            });
                          }*/
                          ),
                        Divider(color: Colors.blueGrey.withOpacity(0.25),height: 0.2,),
                      ]
                  );
                }
            );
          }
          return loader();
        }
    );
  }

  _onSelected(int index) {

    setState(() {
      _selectedIndex = index;
      cond = false;
    });
   // setState(() => _selectedIndex = index);
  }

  loader() {
    return new Container(
      child: Center(
        child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              Image.asset(
                  'assets/spinner.gif', height: 50.0, width: 50.0),
            ]),
      ),
    );
  }

/*  @override
  void dispose(){
    _markedDateMap.clear();
    super.dispose();
  }*/

}

Future<List<User>> getPlannerWiseSummary(attDate,Id) async {

  final prefs = await SharedPreferences.getInstance();
  String empid = prefs.getString('empid') ?? '';
  String orgdir = prefs.getString('orgdir') ?? '';
  print(globals.path+'getPlannerWiseSummary?uid=$Id&refno=$orgdir&attDate=$attDate');
  final response = await http.get(globals.path+'getPlannerWiseSummary?uid=$Id&refno=$orgdir&attDate=$attDate');
  print(response.body);
  List responseJson = json.decode(response.body.toString());
  List<User> userList = createUserList(responseJson);
  return userList;
}


List<User> createUserList(List data){
  List<User> list = new List();
  for (int i = 0; i < data.length; i++) {
    String title = Formatdate(data[i]["AttendanceDate"]);
    print(title);
    print("titile");
    String TimeOut=data[i]["TimeOut"]=="00:00:00"?'-':data[i]["TimeOut"].toString().substring(0,5);
    String TimeIn=data[i]["TimeIn"]=="00:00:00"?'-':data[i]["TimeIn"].toString().substring(0,5);
    String ShiftTimeIn=data[i]["shiftin"]=="00:00:00"?'-':formatTime(data[i]["shiftin"].toString());
    String ShiftTimeOut=data[i]["shiftout"]=="00:00:00"?'-':formatTime(data[i]["shiftout"].toString());
    String thours=data[i]["thours"]=="00:00:00"?'00:00':formatTime(data[i]["thours"].toString());
    String bhour=data[i]["bhour"]==null?'':'Time Off: '+data[i]["bhour"].substring(0,5);
    // String overtime=data[i]["overtime"]=="00:00:00"?'-':data[i]["overtime"];
    String overtime=data[i]["overtime"]==null?'-': formatTime(data[i]["overtime"]);


    String EntryImage=data[i]["EntryImage"]!=''?data[i]["EntryImage"]:'http://ubiattendance.ubihrm.com/assets/img/avatar.png';
    String ExitImage=data[i]["ExitImage"]!=''?data[i]["ExitImage"]:'http://ubiattendance.ubihrm.com/assets/img/avatar.png';
    String checkInLoc=data[i]["checkInLoc"];
    String CheckOutLoc=data[i]["CheckOutLoc"];
    String Latit_in=data[i]["latit_in"].toString();
    String Longi_in=data[i]["longi_in"].toString();
    String Latit_out=data[i]["latit_out"].toString();
    String Longi_out=data[i]["longi_out"].toString();

    String timeindate=data[i]["timeindate"];
    if(timeindate =='0000-00-00')
      timeindate = data[i]["AttendanceDate"];

    String timeoutdate=data[i]["timeoutdate"];
    if(timeoutdate =='0000-00-00')
      timeoutdate=data[i]["AttendanceDate"];
    int id = 0;
    User user = new User(
        AttendanceDate: title,ShiftTimeIn:ShiftTimeIn,ShiftTimeOut:ShiftTimeOut,thours: thours,id: id,overtime:overtime,TimeOut:TimeOut,TimeIn:TimeIn,bhour:bhour,EntryImage:EntryImage,checkInLoc:checkInLoc,ExitImage:ExitImage,CheckOutLoc:CheckOutLoc,latit_in: Latit_in,longi_in: Longi_in,latit_out: Latit_out,longi_out: Longi_out,timeindate: timeindate,timeoutdate: timeoutdate);
    list.add(user);
  }
  return list;
}

class User {
  String AttendanceDate;
  String thours;
  String TimeOut;
  String TimeIn;
  String bhour;
  String EntryImage;
  String checkInLoc;
  String ExitImage;
  String CheckOutLoc;
  String latit_in;
  String longi_in;
  String latit_out;
  String longi_out;
  String timeindate;
  String timeoutdate;
  String overtime;
  String ShiftTimeIn;
  String ShiftTimeOut;
  int id=0;
  User({this.AttendanceDate,this.thours,this.overtime,this.ShiftTimeIn,this.ShiftTimeOut,this.id,this.TimeOut,this.TimeIn,this.bhour,this.EntryImage,this.checkInLoc,this.ExitImage,this.CheckOutLoc,this.latit_in,this.longi_in,this.latit_out,this.longi_out,this.timeindate,this.timeoutdate});
}

formatTime(String time){
  if(time.contains(":")){
    var a=time.split(":");
    return a[0]+":"+a[1];
  }
  else return time;
}