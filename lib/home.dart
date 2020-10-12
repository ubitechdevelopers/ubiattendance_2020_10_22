// Copyright 2017 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.
import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:ui';
import 'package:Shrine/addEmployee.dart';
import 'package:Shrine/database_models/attendance_offline.dart';
import 'package:Shrine/database_models/visits_offline.dart';
import 'package:Shrine/globals.dart' as globals;
import 'package:Shrine/model/shared.dart';
import 'package:Shrine/model/timeinout.dart';
import 'package:Shrine/myleave.dart';
import 'package:Shrine/reports.dart';
import 'package:Shrine/services/gethome.dart';
import 'package:Shrine/services/newservices.dart';
import 'package:Shrine/services/saveimage.dart';
import 'package:Shrine/services/services.dart';
import 'package:Shrine/timeoff_list.dart';
import 'package:Shrine/userviewShiftPlanner.dart';
//import 'package:Shrine/userviewShiftPlanner.dart';
import 'package:connectivity/connectivity.dart';
import 'package:device_info/device_info.dart';
import 'package:dio/dio.dart';
import 'package:easy_dialog/easy_dialog.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:geocoder/geocoder.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:launch_review/launch_review.dart';
import 'package:location/location.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:rounded_modal/rounded_modal.dart';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:store_redirect/store_redirect.dart';

import 'Bottomnavigationbar.dart';
import 'ShiftPlannerList.dart';
import 'askregister.dart';
import 'attendance_summary.dart';
import 'bulkatt.dart';
import 'covid19servey.dart';
import 'database_models/qr_offline.dart';
import 'drawer.dart';
import 'every7dayscovidsurvey.dart';
import 'faceIdScreen.dart';
import 'globals.dart';
import 'globals.dart';
import 'globals.dart';
import 'leave_summary.dart';
import 'location_tracking/home_view.dart';
import "offline_home.dart";
import 'payment.dart';
import 'punchlocation.dart';
import 'punchlocation_summary.dart';
import 'services/services.dart';
import 'settings.dart';
import 'timeoff_summary.dart';
import 'avatar_glow.dart';
import 'super_tooltip.dart';
import 'services/services.dart';

// This app is a stateful, it tracks the user's current choice.
class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with WidgetsBindingObserver {
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey(debugLabel: "Main Navigator");
  static const platform = const MethodChannel('location.spoofing.check');
  AppLifecycleState state;

  // StreamLocation sl = new StreamLocation();
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  GlobalKey _keyRed = GlobalKey();
  GlobalKey _keyBlue = GlobalKey();

  /*var _defaultimage =
      new NetworkImage("http://ubiattendance.ubihrm.com/assets/img/avatar.png");*/
  var profileimage;
  var Rating;
  bool FirstAttendance=false;
  bool RateusDialogShown=false;
  bool FeedbackDialogShown=false;
  bool FiveStarRating=false;
  String datetoShowFeedbackDialog='';
  String dateShowedFeedbackDialog='';
  String datetoShowRatingDialog='';
  String dateShowedRatingDialog='';
  bool isRestriction=false; // First Restriction while marking attendance in face recognition
  bool _checkLoaded = true;
  int _currentIndex = 1;
  String userpwd = "new";
  String newpwd = "new";
  int Is_Delete = 0;
  bool _visible = true;
  String buysts = '0';
  String admin_sts = '0';
  bool glow = true;
  String mail_varified = '1';
 // String AbleTomarkAttendance = '0';
  String act = "";
  String act1 = "";
  int alertdialogcount = 0;
  Timer timer;
  Timer timer1;
  Timer timerrefresh;
  int response;
  String Password_sts='';
  String changepasswordStatus ='';
  String covid_first="0";
  String covid_second="0";
 // var workingHoursTimer;
  final Widget removedChild = Center();
  String fname = "",
      lname = "",
      empid = "",
      email = "",
      status = "",
      orgid = "",
      orgdir = "",
      sstatus = "",
      org_name = "",
      desination = "",
      desinationId = "",
      profile;
  bool issave = false;
  String areaStatus = '0';
  String aid = "";
  String shiftId = "";
  List<Widget> widgets;
  bool refreshsts = false;
  bool fakeLocationDetected = false;
  bool offlineDataSaved = false;
  bool internetAvailable = true;
  String address = '';
  String createdDate = "";
  String dateShowed = "";
  String dateShowedCovidSurvey='';
  String datetoShowCovidSurvey='';
  var currDate = DateTime.now();
  var now = new DateTime.now();
  var formatter = new DateFormat('yyyy-MM-dd');
  var ReferrerNotificationList = new List(5);
  var ReferrerenceMessagesList = new List(7);
  var token = "";
  final _formKey = GlobalKey<FormState>();
  final _oldPass = TextEditingController();
  final _newPass = TextEditingController();
  FocusNode __oldPass = new FocusNode();
  FocusNode __newPass = new FocusNode();


  showInSnackBarforTimeInOut(var val1,var val2,var val3) {

    showModalBottomSheet(
        context: context,
        backgroundColor:const Color(0xFF0E3311).withOpacity(0.0) ,
        builder: (builder) {
          return Container(
            //color:const Color(0xFF0E3311).withOpacity(0.5),
            height:200,
            padding: new EdgeInsets.fromLTRB(10.0, 20.0, 5.0, 16.0),
            child: new Stack(
              children: <Widget>[
                new Container(
                  child: Container(
                    padding: new EdgeInsets.fromLTRB(70.0, 20.0, 16.0, 10.0),
                    //constraints: new BoxConstraints.expand(),
                    child: new Column(
                      // mainAxisAlignment: MainAxisAlignment.spaceEvenly,   //to align from start
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        new Container(height: 3.0),
                        new Text("Time: "+val1, style: TextStyle(fontSize: 22,color: Colors.white,fontWeight: FontWeight.bold),textAlign: TextAlign.center,),
                        new Container(height: 6.0),
                        Container(
                          //margin: new EdgeInsets.fromLTRB(32.0, 1.0, 16.0, 16.0),
                          child: val3.toString().length >=170 ? new Text(val3.toString().substring(0,170),style: TextStyle(fontSize: 14,color: Colors.white),):new Text(val3.toString(),style: TextStyle(fontSize: 14,color: Colors.white),),


                        ),


                        /* new Container(
                          margin: new EdgeInsets.symmetric(vertical: 8.0),
                          height: 2.0,
                          width: 18.0,
                          color: new Color(0xff00c6ff)
                      ),*/
                        /* new Row(
                        children: <Widget>[
                          new Image.asset("'assets/avatar.png'", height: 12.0),
                          new Container(width: 8.0),
                          new Text("planet.distance",
                            style: regularTextStyle,
                          ),
                          new Container(width: 24.0),
                          new Image.asset("'assets/avatar.png'", height: 12.0),
                          new Container(width: 8.0),
                          new Text("planet.gravity",
                            style: regularTextStyle,
                          ),
                        ],
                      ),*/
                      ],
                    ),
                  ),
                  height: 150.0,
                  width: 350,
                  margin: new EdgeInsets.only(left: 46.0),
                  decoration: new BoxDecoration(
                    //color: Color.fromRGBO(0, 0, 0, 0.5),
                    //color: Color.fromRGBO(199, 130, 10, 0.6),
                    //  color: Color.fromRGBO(2, 112, 85, 0.6),
                    // color: Colors.orangeAccent[200],
                    //color: Colors.teal[500],
                    color: Color.fromRGBO(255, 177, 33, 0.8),
                    shape: BoxShape.rectangle,
                    borderRadius: new BorderRadius.circular(8.0),
                    /*boxShadow: <BoxShadow>[
                    new BoxShadow(
                      color: Colors.black54,
                      blurRadius: 5.0,
                      offset: new Offset(0.0, 10.0),
                    ),
                  ],*/
                  ),
                ),
                Container(
                  margin: new EdgeInsets.symmetric(vertical: 13.0),
                  alignment: FractionalOffset.centerLeft,
                  child: Container(
                    //   foregroundDecoration: BoxDecoration(color:Colors.yellow ),
                      width: MediaQuery.of(context).size.height * .13,
                      height: MediaQuery.of(context).size.height * .13,
                      decoration: new BoxDecoration(
                          shape: BoxShape.circle,
                          image: new DecorationImage(
                            fit: BoxFit.cover,

                            image: facerecognition.toString()=='1'?(val2!=null?new NetworkImage(val2):AssetImage('assets/avatar.png')):MemoryImage(base64Decode(globals.PictureBase64Att)),
                            //image: AssetImage('assets/avatar.png')
                          ))),
                ),
              ],
            ),
          );
        });
    Future.delayed(const Duration(seconds: 3), () {
      Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => HomePage())
      );
    });
  }



  var tooltiptimein = SuperTooltip(
    popupDirection: TooltipDirection.up,
    arrowTipDistance: 20.0,
    //x: ab,
    //y: cd,
    //arrowLength: 40.0,
    //top: 150.0,
    //right: 150.0,
    // left: 50.0,
    //bottom: 100.0,
    //showCloseButton: ShowCloseButton.outside,
    hasShadow: true,

    content: new Material(
        child: Container(
      width: 250.0,
      height: 110.0,
      child: Padding(
          padding: const EdgeInsets.all(11.0),
          child: Column(
            //mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              Text(
                "Punch your \'Time In\'",
                style: TextStyle(fontSize: 20),
              ),
              SizedBox(
                height: 10,
              ),
              RaisedButton(
                color: globals.buttoncolor,
                child: Text(
                  'OK',
                  style: TextStyle(color: Colors.white),
                ),
                onPressed: () async {
                  var prefs = await SharedPreferences.getInstance();
                  //print('jshjsh');
                  // prefs.setInt("TimeInToolTipShown",1);
                  SuperTooltip.a.close();

                  istooltiptimeinshown = true;
                },
              ),
            ],
          )),
    )),
  );

  int callbackCalled = 0;

  bool textPostionGotten = false;

  var id='0';

  stopWorkingHoursTimer() {
    //workingHoursTimer.cancel();
  }

  static var tooltiptimeout = SuperTooltip(
    popupDirection: TooltipDirection.up,
    arrowTipDistance: 20.0,
    x: -200,
    y: -380,
    //arrowLength: 40.0,
    //top: 50.0,
    //right: 1.0,
    // left: 50.0,
    //bottom: 100.0,
    //showCloseButton: ShowCloseButton.outside,
    hasShadow: false,
    content: new Material(
        child: Container(
      width: 250.0,
      height: 100.0,
      child: Padding(
          padding: const EdgeInsets.all(0.0),
          child: Column(
            //mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              Text(
                "Welcome to ubiAttendance\n Click here to mark time out",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
              ),
              RaisedButton(
                child: Text('Next'),
                onPressed: () {
                  //print('jshjsh');

                  SuperTooltip.a.close();
                  //tooltipClicked(SuperTooltip.ctx);
                  istooltiponeshown = true;
                },
              ),
            ],
          )),
    )),
  );

  static var tooltipone = SuperTooltip(
    popupDirection: TooltipDirection.up,
    arrowTipDistance: 20.0,
    x: ef,
    y: gh,
    //arrowLength: 40.0,
    //top: 50.0,
    //right: 1.0,
    // left: 50.0,
    //bottom: 100.0,
    //showCloseButton: ShowCloseButton.outside,
    hasShadow: false,
    content: new Material(
        child: Container(
      width: 300.0,
      height: 90.0,
      child: Padding(
          padding: const EdgeInsets.all(0.0),
          child: Column(
            //mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              Text(
                "Try adding an employee",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
              ),
              RaisedButton(
                color: globals.buttoncolor,
                child: Text(
                  'OK',
                  style: TextStyle(color: Colors.white),
                ),
                onPressed: () async {
                  //print('jshjsh');

                  SuperTooltip.a.close();
                  //tooltiptimeinClicked(SuperTooltip.ctx);
                  // istooltiptimeinshown=true;
                },
              ),
            ],
          )),
    )),
  );

  static var tooltiptwo = SuperTooltip(
    popupDirection: TooltipDirection.up,
    arrowTipDistance: 20.0,
    x: -70,
    y: -30,
    //arrowLength: 40.0,
    //top: 50.0,
    //right: 1.0,
    // left: 50.0,
    //bottom: 100.0,
    //showCloseButton: ShowCloseButton.outside,
    hasShadow: false,
    content: new Material(
        child: Container(
      width: 300.0,
      height: 150.0,
      child: Padding(
        padding: const EdgeInsets.all(0.0),
        child: Column(
          children: <Widget>[
            Text(
              "You can setup the Departments, Designations & Shifts",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
            ),
            RaisedButton(
              child: Text("Next"),
              onPressed: () {
                SuperTooltip.a.close();
                tooltiptwoClicked(SuperTooltip.ctx);
                istooltiptwoshown = true;
              },
            ),
          ],
        ),
      ),
    )),
  );

  bool companyFreshlyRegistered = false;

  bool attendanceNotMarkedButEmpAdded = false;

  String loggedInSince = '';

  static tooltiptimeinClicked(context) async {
    // HomePage h=new HomePage();
    // Navigator.of(context).push(new MaterialPageRoute(builder: (BuildContext context) => AddEmployee(),maintainState: false));
    //Future.delayed(Duration(seconds: 1), () => SuperTooltip.tooltiptwo.show(context));
    SharedPreferences prefs = await SharedPreferences.getInstance();

    var admin_sts_static = prefs.getString('sstatus').toString() ?? '0';
    print('hello' + admin_sts_static);
    if (admin_sts_static == '1' || admin_sts_static == '2') {
      tooltipone.showtool(context);
    }
  }

  static tooltipClicked(context) async {
    // HomePage h=new HomePage();
    // Navigator.of(context).push(new MaterialPageRoute(builder: (BuildContext context) => AddEmployee(),maintainState: false));
    //Future.delayed(Duration(seconds: 1), () => SuperTooltip.tooltiptwo.show(context));
    //tooltiptwo.show(context);
  }

  static tooltiptwoClicked(var context) async {
    //HomePage h=new HomePage();
    Navigator.of(context).push(new MaterialPageRoute(
        builder: (BuildContext context) => Settings(), maintainState: false));
  }

//  static tooltiptimeinClicked(context) async{
//    // HomePage h=new HomePage();
//    // Navigator.of(context).push(new MaterialPageRoute(builder: (BuildContext context) => AddEmployee(),maintainState: false));
//    Future.delayed(Duration(seconds: 3), () => tooltiptimeout.show(context));
//    //tooltiptimeout.show(context);
//
//  }

  FirebaseMessaging _firebaseMessaging = FirebaseMessaging();

  @override
  void initState() {
    print('aintitstate');
    super.initState();

    WidgetsBinding.instance.addObserver(this);
    checknetonpage(context);
    initPlatformState();
    //setLocationAddress();
    // startTimer();
    platform.setMethodCallHandler(_handleMethod);
    print('areaSts---->>>>'+areaSts);


  }

  _getPositions() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    // var timeInToolTipShown=prefs.getInt("TimeInToolTipShown")??0;
    _afterLayoutAddEmp();
    if (_keyRed != null) if (_keyRed.currentContext != null) {
      textPostionGotten = true;
      final RenderBox renderBoxRed = _keyRed.currentContext.findRenderObject();
      final positionRed = renderBoxRed.localToGlobal(Offset.zero);
      final sizeRed = renderBoxRed.size;
      print("POSITION of Red: $positionRed ");
      print("Size of Red: $sizeRed");

      print(positionRed);
      double a = positionRed.dx;
      double b = positionRed.dy;

      double e = sizeRed.height;
      double f = sizeRed.width;

      print("this is $a and this is $b");
      setState(() {
        ab = a + (f / 2);
        cd = b + 2 * e;
      });

      var prefs = await SharedPreferences.getInstance();
      var companyFreshlyRegistered =
          prefs.getBool("companyFreshlyRegistered") ?? false;
      var firstAttendanceMarked =
          prefs.getBool("firstAttendanceMarked") ?? false;
      // print(companyFreshlyRegistered.toString()+"companyFreshlyRegistered");
      // print(firstAttendanceMarked.toString()+"firstAttendanceMarked");
      if (!timeInToolTipShown) if (companyFreshlyRegistered) if (!firstAttendanceMarked) {
        Future.delayed(
            Duration(seconds: 1), () => tooltiptimein.show(context, ab, cd));
        globals.timeInToolTipShown = true;
      }
    }
  }

  _afterLayout(_) {
    print("after layout" + _keyRed.currentContext.toString());
    _getPositions();
    //getPositionofFAB();
  }

  _afterLayoutAddEmp() {
    getPositionofFAB();
  }

  void getPositionofFAB() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    var admin_sts = prefs.getString('sstatus').toString() ?? '0';

    if ((admin_sts == '1' || admin_sts == '2')) {
      if (_keyBlue != null) if (_keyBlue.currentContext != null) {
        textPostionGotten = true;
        final RenderBox renderBoxBlue =
            _keyBlue.currentContext.findRenderObject();
        final positionBlue = renderBoxBlue.localToGlobal(Offset.zero);
        final sizeBlue = renderBoxBlue.size;
        print("POSITION of Blue: $positionBlue ");
        print("Size of Blue: $sizeBlue");
        double c = positionBlue.dx;
        double d = positionBlue.dy;
        double g = sizeBlue.height;
        double h = sizeBlue.width;

        setState(() {
          ef = c + (h / 2);
          gh = d + (g / 2);
        });

        var prefs = await SharedPreferences.getInstance();
        var companyFreshlyRegistered =
            prefs.getBool("companyFreshlyRegistered") ?? false;
        var firstAttendanceMarked =
            prefs.getBool("firstAttendanceMarked") ?? false;
        var employeeAdded = prefs.getBool("EmployeeAdded") ?? false;

        print('companyFreshlyRegistered' +
            companyFreshlyRegistered.toString() +
            'firstAttendanceMarked' +
            firstAttendanceMarked.toString() +
            "EmployeeAdded" +
            employeeAdded.toString());
        if (!globals
            .addEmpToolTipShown) if (companyFreshlyRegistered) if (firstAttendanceMarked) if (!employeeAdded) {
          tooltiptimeinClicked(context);
          globals.addEmpToolTipShown = true;
        }
      }
    }
  }

  void firebaseCloudMessaging_Listeners() async {
    var serverConnected = await checkConnectionToServer();

    if (serverConnected == 1) {
      var prefs = await SharedPreferences.getInstance();
      var country = prefs.getString("CountryName") ?? '';
      var orgTopic = prefs.getString("OrgTopic") ?? '';
      var isAdmin = admin_sts = prefs.getString('sstatus').toString() ?? '0';
      var employeeTopic = prefs.getString("EmployeeTopic") ?? '';
      //_firebaseMessaging.subscribeToTopic('101');
       //_firebaseMessaging.subscribeToTopic('test123456');



      if (isAdmin == '1') {
        _firebaseMessaging.subscribeToTopic('admin');
        print("Admin topic subscribed");
      } else {
        print("employee topic subscribed");
        if (orgTopic.isNotEmpty)
          _firebaseMessaging.subscribeToTopic('employee');
      }
      if (globals.globalEmployeeTopic.isNotEmpty) {
       // _firebaseMessaging.unsubscribeFromTopic(employeeTopic.replaceAll(' ', ''));
        _firebaseMessaging
            .subscribeToTopic(globals.globalEmployeeTopic.replaceAll(' ', ''));

        print('globals.globalEmployeeTopic' + globals.globalEmployeeTopic.toString());

        prefs.setString("EmployeeTopic", globals.globalEmployeeTopic);
      } else {
        if (employeeTopic.isNotEmpty)
          _firebaseMessaging.subscribeToTopic(employeeTopic.replaceAll(' ', ''));
        print('globals.globalEMployeeTopic11111' + employeeTopic);
      }

      if (globals.globalOrgTopic.isNotEmpty) {
        _firebaseMessaging.unsubscribeFromTopic(orgTopic.replaceAll(' ', ''));
        _firebaseMessaging
            .subscribeToTopic(globals.globalOrgTopic.replaceAll(' ', ''));

        print('globals.globalOrgTopic' + globals.globalOrgTopic.toString());

        prefs.setString("OrgTopic", globals.globalOrgTopic);
      } else {
        if (orgTopic.isNotEmpty)
          _firebaseMessaging.subscribeToTopic(orgTopic.replaceAll(' ', ''));
        print('globals.globalOrgTopic11111' + orgTopic);
      }

      if (globals.globalCountryTopic.isNotEmpty) {
        _firebaseMessaging.unsubscribeFromTopic(country.replaceAll(' ', ''));
        _firebaseMessaging
            .subscribeToTopic(globals.globalCountryTopic.replaceAll(' ', ''));
        prefs.setString("CountryName", globals.globalCountryTopic);
      } else {
        if (country.isNotEmpty)
          _firebaseMessaging.subscribeToTopic(country.replaceAll(' ', ''));
      }

      if (globals.currentOrgStatus.isNotEmpty) {
        var previousOrgStatus = prefs.get("CurrentOrgStatus") ?? '';
        if (previousOrgStatus.isNotEmpty)
          _firebaseMessaging
              .unsubscribeFromTopic(previousOrgStatus.replaceAll(' ', ''));
        _firebaseMessaging
            .subscribeToTopic(globals.currentOrgStatus.replaceAll(' ', ''));

        prefs.setString("CurrentOrgStatus", globals.currentOrgStatus);
        globals.currentOrgStatus = '';
      }
      _firebaseMessaging.getToken().then((token) {
        _firebaseMessaging.subscribeToTopic("AllOrg");
        // _firebaseMessaging.subscribeToTopic("UBI101");
        _firebaseMessaging.subscribeToTopic("AllCountry");

        // print('country subscribed'+country);

        this.token = token;

        // sendPushNotification("https://fcm.googleapis.com/fcm/send", token.toString(),"This is notification from mobile","Mobile Notification");

        // print("token--------------->"+token.toString()+"-------------"+country);
      });

      _firebaseMessaging.configure(
        onMessage: (Map<String, dynamic> message) async {
          print('on message $message' + message['data'].isEmpty.toString());
//{notification: {title: ABC has marked his Time In, body: null}, data: {}}
          cameraChannel.invokeMethod("showNotification", {
            "title": message['notification']['title'] == null
                ? ''
                : message['notification']['title'].toString(),
            "description": message['notification']['body'] == null
                ? ''
                : message['notification']['body'].toString(),
            "pageToOpenOnClick":
                message['data'].isEmpty ? '' : message['data']['pageToNavigate']
          });
        },
        onResume: (Map<String, dynamic> message) async {
          print('on resume $message');
          print(message['data']['body']);
          var navigate =
              message['data'].isEmpty ? '' : message['data']['pageToNavigate'];
          navigateToPageAfterNotificationClicked(navigate, context);

        },
        onLaunch: (Map<String, dynamic> message) async {
          print('on launch $message');
          var navigate =
              message['data'].isEmpty ? '' : message['data']['pageToNavigate'];
          navigateToPageAfterNotificationClicked(navigate, context);
          print(message['data']['body']);
          /*
          if(message['data']['body']=='10'){
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => Reports()),
            );
//            navigatorKey.currentState.push(
//                MaterialPageRoute(builder: (_) => Reports())
//            );
          }else if(message['data']['body']=='20'){
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => TimeOffList()),
            );
//            navigatorKey.currentState.push(
//                MaterialPageRoute(builder: (_) => TimeOffList())
//            );
          }
          */


        },
      );

/*
      _firebaseMessaging.configure(
        onMessage: (Map<String, dynamic> message) async {
          print('on message $message'+message['data'].isEmpty.toString());
//{notification: {title: ABC has marked his Time In, body: null}, data: {}}
          cameraChannel.invokeMethod("showNotification",{"title":message['notification']['title']==null?'':message['notification']['title'].toString(),"description":message['notification']['body']==null?'':message['notification']['body'].toString(),"pageToOpenOnClick":message['data'].isEmpty?'':message['data']['pageToNavigate']});

        },
        onResume: (Map<String, dynamic> message) async {
          print('on resume $message');
//        var navigate=message['data'].isEmpty?'':message['data']['pageToNavigate'];
//        navigateToPageAfterNotificationClicked(navigate, context);
          /*
        navigatorKey.currentState.push(
            MaterialPageRoute(builder: (_) => Reports())
        );
        */
          setState(() {
            id=message['data']['body'];
          });
          if(id=='123'){
            navigatorKey.currentState.push(
                MaterialPageRoute(builder: (_) =>
                    TimeOffList()
                )
            );
          }else{
            navigatorKey.currentState.push(
                MaterialPageRoute(builder: (_) =>
                    Reports()
                )
            );

          }
        },
        onLaunch: (Map<String, dynamic> message) async {
          print('on launch $message');
//        var navigate=message['data'].isEmpty?'':message['data']['pageToNavigate'];
//        navigateToPageAfterNotificationClicked(navigate, context);
          setState(() {
            id=message['data']['id'];
          });
          if(id=='123'){
            navigatorKey.currentState.push(
                MaterialPageRoute(builder: (_) =>
                    TimeOffList()
                )
            );
          }else{
            navigatorKey.currentState.push(
                MaterialPageRoute(builder: (_) =>
                    Reports()
                )
            );

          }
        },
      );
      */
    }
  }

  syncOfflineQRData() async {
    address = await getAddressFromLati(
        globals.assign_lat.toString(), globals.assign_long.toString());
    print(address +
        "xnjjjjjjlllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllll");

    int serverAvailable = await checkConnectionToServer();
    if (serverAvailable == 1) {
      /*****************************For Attendances***********************************************/

      QROffline qrOffline = new QROffline.empty();

      List<QROffline> qrs = await qrOffline.select();

      List<Map> jsonList = [];
      if (qrs.isNotEmpty) {
        for (int i = 0; i < qrs.length; i++) {
          var address = await getAddressFromLati(qrs[i].Latitude, qrs[i].Longitude);
          print(address);
          jsonList.add({
            "Id": qrs[i].Id,
            "SupervisorId": qrs[i].SupervisorId,
            "Action": qrs[i].Action, // 0 for time in and 1 for time out
            "Date": qrs[i].Date,
            "OrganizationId": qrs[i].OrganizationId,
            "PictureBase64": qrs[i].PictureBase64,
            "Latitude": qrs[i].Latitude,
            "Longitude": qrs[i].Longitude,
            "Time": qrs[i].Time,
            "UserName": qrs[i].UserName,
            "Password": qrs[i].Password,
            "FakeLocationStatus": qrs[i].FakeLocationStatus,
            "FakeTimeStatus": qrs[i].FakeTimeStatus,
            "Address": address,
            "Geofence": qrs[i].Geofence,
            "appVersion": qrs[i].appVersion
          });
        }
        var jsonList1 = json.encode(jsonList);
        //LogPrint('response1: ' + jsonList1.toString());
        //LogPrint(attendances);
        FormData formData = new FormData.from({"data": jsonList1});

        Dio dioForSavingOfflineAttendance = new Dio();
        dioForSavingOfflineAttendance
            .post(path + "saveOfflineQRData", data: formData)
            .then((responseAfterSavingOfflineData) async {
          var response = json.decode(responseAfterSavingOfflineData.toString());

          print(
              '--------------------- Data Syncing Response--------------------------------');
          print(responseAfterSavingOfflineData);

          print(
              '--------------------- Data Syncing Response--------------------------------');
          for (int i = 0; i < response.length; i++) {
            var map = response[i];
            map.forEach((localDbId, status) {
              QROffline qrOffline = QROffline.empty();
              print(status);
              qrOffline.delete(int.parse(localDbId));
            });
          }
        });
      } else {
        if (mounted) {
          setState(() {
            //  offlineDataSaved=true;
          });
        }
      }
    }

    /*****************************For Attendances***********************************************/
  }

  Future<dynamic> _handleMethod(MethodCall call) async {
    print('justtesting');
    switch (call.method) {
      case "navigateToPage":
        navigateToPageAfterNotificationClicked(
            call.arguments["page"].toString(), context);
        break;
      case "locationAndInternet":
        locationThreadUpdatedLocation = true;
        // print(call.arguments["internet"].toString()+"akhakahkahkhakha");
        // Map<String,String> responseMap=call.arguments;
        if (call.arguments["internet"].toString() == "Internet Not Available") {
          internetAvailable = false;
          print("internet nooooot aaaaaaaaaaaaaaaaaaaaaaaavailable");
          //Navigator.of(context).pushReplacement(new MaterialPageRoute(builder: (BuildContext context) => OfflineHomePage(),maintainState: false));
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => OfflineHomePage()),
            (Route<dynamic> route) => false,
          );
        }
        var long = call.arguments["longitude"].toString();
        var lat = call.arguments["latitude"].toString();
        //lat=assign_lat.toString();
        //long=assign_long.toString();
        assign_lat = double.parse(lat);
        assign_long = double.parse(long);
        address = await getAddressFromLati(lat, long);
        print(address +
            "xnjjjjjjlllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllll");
        globalstreamlocationaddr = address;
        print(call.arguments["mocked"].toString());
        //getAreaStatus();
        print('areasts----->'+globals.areaSts);

        getAreaStatus().then((res) {
          // print('called again');
          print('testagain');
          if (mounted) {
            setState(() {
              areaSts = res.toString();
              print('response'+res.toString());
              if (areaId != 0 && geoFence == 1) {
                AbleTomarkAttendance = areaSts;
                print('insideable to markatt --------->>>>');
                print('insideabletoatt'+areaId.toString());
              }
            });
          }
        }).catchError((onError) {
          print('Exception occured in clling function.......');
          print(onError);
        });

        setState(() {
          if (call.arguments["mocked"].toString() == "Yes") {
            fakeLocationDetected = true;
          } else {
            fakeLocationDetected = false;
          }
          if (call.arguments["TimeSpoofed"].toString() == "Yes") {
            timeSpoofed = true;
          }
        });
        break;

        return new Future.value("");
    }
  }

  syncVisits(visits) async {
    for (int i = 0; i < visits.length; i++) {
      if (visits[i].VisitInLatitude.isEmpty) visits[i].VisitInLatitude = "0.0";
      if (visits[i].VisitOutLatitude.isEmpty)
        visits[i].VisitOutLatitude = "0.0";
      if (visits[i].VisitInLongitude.isEmpty)
        visits[i].VisitInLongitude = "0.0";
      if (visits[i].VisitOutLongitude.isEmpty)
        visits[i].VisitOutLongitude = "0.0";

      var VisitInaddress = await getAddressFromLati_offline(
          double.parse(visits[i].VisitInLatitude),
          double.parse(visits[i].VisitInLongitude));
      print("-------------------------------jhkhk--------------------------");
      print(visits[i].VisitOutLatitude + "   ");
      print(visits[i].VisitOutLongitude);
      var VisitOutaddress = await getAddressFromLati_offline(
          double.parse(visits[i].VisitOutLatitude),
          double.parse(visits[i].VisitOutLongitude));
      // print(address);
      List<Map> jsonList = [];
      jsonList.add({
        'Id': visits[i].Id,
        'EmployeeId': visits[i].EmployeeId,
        'VisitInLatitude': visits[i].VisitInLatitude,
        'VisitInLongitude': visits[i].VisitInLongitude,
        'VisitInTime': visits[i].VisitInTime,
        'VisitInDate': visits[i].VisitInDate,
        'VisitOutLatitude': visits[i].VisitOutLatitude,
        'VisitOutLongitude': visits[i].VisitOutLongitude,
        'VisitOutTime': visits[i].VisitOutTime,
        'VisitOutDate': visits[i].VisitOutDate,
        'ClientName': visits[i].ClientName,
        'VisitInDescription': visits[i].VisitInDescription,
        'VisitOutDescription': visits[i].VisitOutDescription,
        'OrganizationId': visits[i].OrganizationId,
        'Skipped': visits[i].Skipped,
        'VisitInImage': visits[i].VisitInImage,
        'VisitOutImage': visits[i].VisitOutImage,
        'VisitInAddress': VisitInaddress,
        'VisitOutAddress': VisitOutaddress,
        'FakeLocationStatusVisitIn': visits[i].FakeLocationStatusVisitIn,
        'FakeLocationStatusVisitOut': visits[i].FakeLocationStatusVisitOut,
        'FakeVisitInTimeStatus': visits[i].FakeVisitInTimeStatus,
        'FakeVisitOutTimeStatus': visits[i].FakeVisitOutTimeStatus
      });

      var jsonList1 = json.encode(jsonList);
      LogPrint('response1: ' + jsonList1.toString());
      //LogPrint(attendances);
      FormData formData = new FormData.from({"data": jsonList1});

      Dio dioForSavingOfflineAttendance = new Dio();
      dioForSavingOfflineAttendance
          .post(globals.path + "saveOfflineVisits", data: formData)
          .then((responseAfterSavingOfflineData) async {
        var response = json.decode(responseAfterSavingOfflineData.toString());

        print(
            '--------------------- Visit Syncing Response--------------------------------');
        LogPrint(responseAfterSavingOfflineData);

        print(
            '--------------------- Visit Syncing Response--------------------------------');
        for (int i = 0; i < response.length; i++) {
          var map = response[i];
          map.forEach((localDbId, status) {
            VisitsOffline visitsOffline = VisitsOffline.empty();
            print(status);
            visitsOffline.delete(int.parse(localDbId));
          });
        }
        setState(() {
          offlineDataSaved = true;
        });
      });
    }
  }

  syncOfflineData() async {
    int serverAvailable = await checkConnectionToServer();
    if (serverAvailable == 1) {

     /*  sync only  image code  */
      SaveImage saveImage = new SaveImage();
      saveImage.SendTempimage(context , false);

      /*****************************For Attendances***********************************************/
      await syncOfflineQRData();

      AttendanceOffline attendanceOffline = new AttendanceOffline.empty();
      VisitsOffline visitsOffline = VisitsOffline.empty();

      List<AttendanceOffline> attendances = await attendanceOffline.select();
      List<VisitsOffline> visits = await visitsOffline.select();

      List<Map> jsonList = [];
      List<Map> jsonListVisits = [];
      if (visits.isNotEmpty) {
        await syncVisits(visits);
      } else {
        offlineDataSaved = true;
      }
      if (attendances.isNotEmpty) {
        for (int i = 0; i < attendances.length; i++) {
          var address = await getAddressFromLati_offline(
              double.parse(attendances[i].Latitude),
              double.parse(attendances[i].Longitude));
          print(address);
          jsonList.add({
            "Id": attendances[i].Id,
            "UserId": attendances[i].UserId,
            "Action": attendances[i].Action, // 0 for time in and 1 for time out
            "Date": attendances[i].Date,
            "OrganizationId": attendances[i].OrganizationId,
            "PictureBase64": attendances[i].PictureBase64,
            "Latitude": attendances[i].Latitude,
            "Longitude": attendances[i].Longitude,
            "Time": attendances[i].Time,
            "FakeLocationStatus": attendances[i].FakeLocationStatus,
            "FakeTimeStatus": attendances[i].FakeTimeStatus,
            "Address": address,
            "Geofence": attendances[i].Geofence,
            "appVersion": attendances[i].TimeInOutAppVersion
          });
        }
        var jsonList1 = json.encode(jsonList);
        //LogPrint('response1: ' + jsonList1.toString());
        //LogPrint(attendances);
        FormData formData = new FormData.from({"data": jsonList1});

        Dio dioForSavingOfflineAttendance = new Dio();
        dioForSavingOfflineAttendance
            .post(globals.path + "saveOfflineData", data: formData)
            .then((responseAfterSavingOfflineData) async {

          print(
              '--------------------- Data Syncing Response--------------------------------');
          LogPrint(responseAfterSavingOfflineData);

          var response = json.decode(responseAfterSavingOfflineData.toString());



          print(
              '--------------------- Data Syncing Response--------------------------------');
          for (int i = 0; i < response.length; i++) {
            var map = response[i];
            map.forEach((localDbId, status) {
              AttendanceOffline attendanceOffline = AttendanceOffline.empty();
              print(status);
              attendanceOffline.delete(int.parse(localDbId));
            });
          }
          setState(() {
            offlineDataSaved = true;
          });

          Home ho = new Home();

          act = await ho.checkTimeIn(empid, orgdir,context);
          print("Action from check time in");
          ho.managePermission(empid, orgdir, desinationId);

          setState(() {
            act1 = act;
          });
        });
      } else {
        if (mounted) {
          setState(() {
            offlineDataSaved = true;
          });
        }
      }
    }

    Home ho = new Home();
    act = await ho.checkTimeIn(empid, orgdir,context);
    print("Action from check time in1");
    if (timeoutdate == 'nextdate' && act == 'TimeOut') dialogwidget(context);
    ho.managePermission(empid, orgdir, desinationId);
    if (mounted) {
      setState(() {
        act1 = act;
      });
    }

    /*****************************For Attendances***********************************************/
  }

  static void LogPrint(Object object) async {
    int defaultPrintLength = 1020;
    if (object == null || object.toString().length <= defaultPrintLength) {
      print(object);
    } else {
      String log = object.toString();
      int start = 0;
      int endIndex = defaultPrintLength;
      int logLength = log.length;
      int tmpLogLength = log.length;
      while (endIndex < logLength) {
        print(log.substring(start, endIndex));
        endIndex += defaultPrintLength;
        start += defaultPrintLength;
        tmpLogLength -= defaultPrintLength;
      }
      if (tmpLogLength > 0) {
        print(log.substring(start, logLength));
      }
    }
  }

  timerResumePause() async {
    //print("app resumed paused home");
    SystemChannels.lifecycle.setMessageHandler((msg) async {
      print("app resumed paused home");
      if (msg == 'AppLifecycleState.resumed') {
        //startWorkingHoursTimer();
        print("app resumed and timer started");
      }

      if (msg == 'AppLifecycleState.paused') {
        //stopWorkingHoursTimer();
        print("app paused and timer stopped");
      }
    });
  }

  void didChangeAppLifecycleState(AppLifecycleState appLifecycleState) {
    /*
    setState(() {
      state = appLifecycleState;
      if(state==AppLifecycleState.resumed){
        //print('WidgetsBindingObserver called');

        if(timerrefresh.isActive){
          timerrefresh.cancel();
        }
        if(refreshsts) {
          //timerrefresh.cancel();
          if(timerrefresh.isActive){
            timerrefresh.cancel();
          }
          refreshsts=false;
          print('WidgetsBindingObserver called refreshsts false');
          initPlatformState();
          setLocationAddress();
          startTimer();
        }
      }else if(state==AppLifecycleState.paused){
       // print('AppLifecycleState.paused');

        const tenSec = const Duration(seconds: 180);
        timerrefresh = new Timer.periodic(tenSec, (Timer t) {
          print('refreshsts true');
          refreshsts=true;
          timerrefresh.cancel();
        });
      }
    });*/
  }

/*
  startTimer() {
    const fiveSec = const Duration(seconds: 2);
    int count = 0;
    // print('called timer');
    timer = new Timer.periodic(fiveSec, (Timer t) {
      //print("timmer is running");
      count++;
      //print("timer counter" + count.toString());
     // setLocationAddress();
      if (stopstreamingstatus) {
        t.cancel();
        //print("timer canceled");
      }
      /*  if(count==5){
        t.cancel();
      }*/
    });
  }

  startTimer1() {
    const fiveSec = const Duration(seconds: 1);
    int count = 0;
    timer1 = new Timer.periodic(fiveSec, (Timer t) {
      print("timer is running");
    });
  }

  setLocationAddress() async {

    //print('called');
    getAreaStatus().then((res) {
      // print('called again');
      if (mounted) {
        setState(() {
          areaStatus = res.toString();
        });
      }
    }).catchError((onError) {
      print('Exception occured in clling function.......');
      print(onError);
    });
    if (mounted) {
      setState(() {
        streamlocationaddr = globalstreamlocationaddr;
        print('loc: ' + streamlocationaddr);
        if (list != null && list.length > 0) {
          lat = list[list.length - 1].latitude.toString();
          long = list[list.length - 1].longitude.toString();
          if (streamlocationaddr == '') {
            streamlocationaddr = lat + ", " + long;
          }
        }
        if (streamlocationaddr == '') {
          print('again');
          timer.cancel();
        //  sl.startStreaming(5);
         // startTimer();
        }
        //print("home addr" + streamlocationaddr);
        //print(lat + ", " + long);

        //print(stopstreamingstatus.toString());
      });
    }
  }
*/
  launchMap(String lat, String long) async {
    String url = "https://maps.google.com/?q=" + lat + "," + long;
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      //print('Could not launch $url');
    }
  }
  void showReferralReminder() async{

    var prefs=await SharedPreferences.getInstance();

    String referrerId=prefs.getString("referrerId")??"0";

    String ReferralValidTo=prefs.getString("ReferralValidTo")??"0000-00-00";
    var currDate=DateTime.now();

    if(referrerId!='0'&&ReferralValidTo!='0000-00-00'){
      if(DateTime.parse("ReferralValidTo").day==(currDate.day+2))
      {
        EasyDialog(
            title: Text(
              "Reminder",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 30,
              ),
              textAlign: TextAlign.center,
            ),
            description: Text(
              "Get 10% off your first purchase of ubiAttendance. Hurry! Offer ends in 2 days"
                  .toString(),
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
              ),
            ),
            height: 220,
            contentList: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  SizedBox(
                    height: 40,
                  ),
                  RaisedButton(
                    child: Text(
                      "GO!",
                      style: TextStyle(color: Colors.white),
                    ),
                    onPressed: () {
                      navigateToPaymentsPage();
                    },
                    color: Colors.green,
                  ),
                  SizedBox(
                    width: 10,
                    height: 10,
                  ),
                ],
              )
            ]).show(context);
      }
    }
  }

  void deviceverification() async{

    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
    print('Running on ${androidInfo.brand}');
    print('Running on ${androidInfo.model}');
    String devicename= androidInfo.model;
    String devicebrand= androidInfo.brand;
    devicenamebrand = devicebrand+' '+devicename;




    var prefs = await SharedPreferences.getInstance();
    //deviceid= prefs.getString("deviceid") ?? '';
    print('thisisdeviceid'+deviceid);
    String deviceidmobile=prefs.getString("deviceid")??"";
    bool deviceVerifyPopupShown=prefs.getBool("deviceVerifyPopupShown")??false;
    print('thisisdeviceidmobile'+deviceidmobile);
    if(deviceidmobile=='' && globals.deviceverification==1) {
      const chars = "abcdefghijklmnopqrstuvwxyz0123456789";

      String RandomString(int strlen) {
        Random rnd = new Random(new DateTime.now().millisecondsSinceEpoch);
        String result = "";
        for (var i = 0; i < strlen; i++) {
          result += chars[rnd.nextInt(chars.length)];
        }
        return result;
      }

      print("RandomString:"+RandomString(60));
      deviceidmobile= RandomString(60);
      prefs.setString("deviceid",deviceidmobile);
    }

    if(deviceid=='' && globals.deviceverification==1){

      const chars = "abcdefghijklmnopqrstuvwxyz0123456789";

      String RandomString(int strlen) {
        Random rnd = new Random(new DateTime.now().millisecondsSinceEpoch);
        String result = "";
        for (var i = 0; i < strlen; i++) {
          result += chars[rnd.nextInt(chars.length)];
        }
        return result;
      }


      print("RandomString:"+RandomString(60));
      deviceidmobile= RandomString(60);
      if(deviceVerifyPopupShown==false && deviceid=='') {
        // if(deviceid=='') {
        //
        EasyDialog(
            title: Text(
              'This Mobile Device has been registered as your Device ID',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
              textAlign: TextAlign.center,
            ),
            description: Text(
              devicebrand+" "+devicename,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
              ),
            ),
            height: 180,
            contentList: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  SizedBox(
                    height: 40,
                  ),

                  SizedBox(
                    width: 10,
                    height: 10,
                  ),
                ],
              )
            ]).show(context);

        prefs.setBool("deviceVerifyPopupShown",true);
        prefs.setString("deviceid",deviceidmobile);
        storeDeviceInfo(empid, deviceidmobile, devicebrand+' '+devicename);
      }
    }
  }


  showReferralPopup(BuildContext context, String cDateS) async {


    if(globals.currentOrgStatus=="TrialOrg"){

      showTrialReferralPopup(context,cDateS);

    }

    else
    if(globals.currentOrgStatus=="PremiumCustomizedOrg")
    {
      int dateToSend = 0;


      var prefs = await SharedPreferences.getInstance();
      var buyStatus = int.parse(prefs.get("buysts") ?? "123455");
      var createdDate = DateTime.parse("2019-12-26");

      //print(">>>>----- current org status"+globals.currentOrgStatus);


      var startDate =
      DateTime.parse(prefs.get("ReferralValidFrom") ?? "2019-12-26");
      var endDate = DateTime.parse(prefs.get("ReferralValidTo") ?? "2019-12-26");

/*
        var startDate =
        DateTime.parse( "2020-02-22");
        var endDate = DateTime.parse("2020-02-29");
*/


      var currDate = DateTime.now();
      dateShowed = prefs.getString('date') ?? "2010-10-10";

      var referralValidForDays=endDate.difference(currDate).inDays;


      print("datetime.parse" + dateShowed);
      // print("hello"+dateShowed);
      var referrerAmt = prefs.getString("ReferrerDiscount") ?? "1%";
      var referrenceAmt = prefs.getString("ReferrenceDiscount") ?? "1%";
      ReferrerNotificationList[0] = {
        "title": "Win Win Deal",
        "description":
        "Refer our App and get ${referrerAmt} off on your next payment. Hurry! Offer ends in ${referralValidForDays} days"
      };
      ReferrerNotificationList[1] = {
        "title": "Refer and Earn",
        "description":
        "Invite your friends to try ubiAttendance. Get ${referrerAmt} Off when they pay.. Hurry! Offer ends in ${referralValidForDays} days"
      };
      ReferrerNotificationList[2] = {
        "title": "Discounts that count",
        "description":
        "For every organization you refer which pays up for our Premium plan, we will give you both ${referrerAmt}/ ${referrenceAmt} off. Hurry! Offer ends in ${referralValidForDays} days"
      };
      ReferrerNotificationList[3] = {
        "title": "${referrerAmt} Off every Payment",
        "description":
        "Tell Your friends about ubiAttendance & get ${referrerAmt} Discount when he pays. Hurry! Offer ends in ${referralValidForDays} days"
      };
      ReferrerNotificationList[4] = {
        "title": "Discounts to smile about",
        "description":
        "Give managers the gift of ease in recording attendance and get ${referrerAmt} off on your next purchase. Hurry! Offer ends in ${referralValidForDays} days"
      };

      var referrerName = "";
      var validity = prefs.getString("ReferralValidity");

      var rng = new Random();
      var referrerRandom = rng.nextInt(4);
      double height = 220;
      if (referrerRandom == 2 || referrerRandom == 4) height = 260;
      if (referrerRandom == 0) height = 170;

      print("----> currdate" + currDate.toString());

      if (createdDate == '') {
        dateToSend = 12;
      }
      // if(buyStatus!=0){  // for trial popup that should show on the seventh day of purchase

      //print("difference dates"+currDate.difference(cDate).inDays.toString());
      //print("created date"+createdDate);

      // } // for other organizations i.e pop up for every created date day of the month
      // else{
      dateToSend = createdDate.day;
      print('startDate');
      print(startDate);
//      print(currDate);
//      print(prefs.getString('date'));
      //print("----> currdate"+((DateTime.parse(dateShowed).day==startDate.day)&&(DateTime.parse(dateShowed).month==startDate.month)&&(DateTime.parse(dateShowed).year==startDate.year)).toString());
      if (//currDate.isAfter(startDate) && currDate.isBefore(endDate) ||
      (currDate.day == startDate.day &&
          currDate.month == startDate.month &&
          currDate.year == startDate.year) ||
          (currDate.day == endDate.subtract(new Duration(days: 2)).day &&
              currDate.month == endDate.month &&
              currDate.year == endDate.year)) {

        print("inside referral check");
        //        prefs.setString('date',currDate.toString());
        // var newDate = new DateTime(startDate.year, startDate.month, startDate.day+3);
        //if (currDate.isAfter(newDate) && currDate.isBefore(endDate)) {
//        prefs.setString('date', newDate.toString());
//        print("hello");
//        print(prefs.getString('date'));
        print(currDate);
        //if(((DateTime.parse(dateShowed).day==currDate.day)&&(DateTime.parse(dateShowed).month==currDate.month)&&(DateTime.parse(dateShowed).year==currDate.year))){
        //var newDate = new DateTime(currDate.year, currDate.month, currDate.day+3);
        //var newDate = currDate.add(new Duration(days: 3));
        dateShowed = currDate.toString();
        prefs.setString('date', dateShowed);
        print("hello" + currDate.toString());
        EasyDialog(
            title: Text(
              ReferrerNotificationList[referrerRandom]['title'].toString(),
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 30,
              ),
              textAlign: TextAlign.center,
            ),
            description: Text(
              ReferrerNotificationList[referrerRandom]['description']
                  .toString(),
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
              ),
            ),
            height: height,
            contentList: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  SizedBox(
                    height: 40,
                  ),
                  RaisedButton(
                    child: Text(
                      "GO!",
                      style: TextStyle(color: Colors.white),
                    ),
                    onPressed: () {
                      generateAndShareReferralLink();
                    },
                    color: Colors.green,
                  ),
                  SizedBox(
                    width: 10,
                    height: 10,
                  ),
                ],
              )
            ]).show(context);
      }
    }
    else{
     // showOtherReferralPopup(context,cDateS);
    }
    // }
  }


  void showTrialReferralPopup(BuildContext context, String cDateS) async {
    int dateToSend = 0;
    var prefs = await SharedPreferences.getInstance();

    var createdDate = DateTime.parse(cDateS);

    //print(">>>>----- current org status"+globals.currentOrgStatus);

    var currDate = DateTime.now();
    dateShowed = prefs.getString('TrailReferralShownDate') ?? "2010-10-10";

    print("datetime.parse" + dateShowed);
    // print("hello"+dateShowed);
    var referrerAmt = prefs.getString("ReferrerDiscount") ?? "1%";
    var referrenceAmt = prefs.getString("ReferrenceDiscount") ?? "1%";
    ReferrerNotificationList[0] = {
      "title": "Win Win Deal",
      "description":
      "Refer our App and get ${referrerAmt} off on your next payment. Hurry! Offer ends in 10 days"
    };
    ReferrerNotificationList[1] = {
      "title": "Refer and Earn",
      "description":
      "Invite your friends to try ubiAttendance. Get ${referrerAmt} Off when they pay. Hurry! Offer ends in 10 days"
    };
    ReferrerNotificationList[2] = {
      "title": "Discounts that count",
      "description":
      "For every organization you refer which pays up for our Premium plan, we will give you both ${referrerAmt}/ ${referrenceAmt} off. Hurry! Offer ends in 10 days"
    };
    ReferrerNotificationList[3] = {
      "title": "${referrerAmt} Off every Payment",
      "description":
      "Tell Your friends about ubiAttendance & get ${referrerAmt} Discount when he pays. Hurry! Offer ends in 10 days"
    };
    ReferrerNotificationList[4] = {
      "title": "Discounts to smile about",
      "description":
      "Give managers the gift of ease in recording attendanceand get ${referrerAmt} off on your next purchase. Hurry! Offer ends in 10 days"
    };

    var referrerName = "";
    var validity = prefs.getString("ReferralValidity");

    var rng = new Random();
    var referrerRandom = rng.nextInt(4);
    double height = 220;
    if (referrerRandom == 2 || referrerRandom == 4) height = 260;
    if (referrerRandom == 0) height = 170;

    print("----> currdate" + currDate.toString());

    if (createdDate == '') {
      dateToSend = 12;
    }
    // if(buyStatus!=0){  // for trial popup that should show on the seventh day of purchase

    //print("difference dates"+currDate.difference(cDate).inDays.toString());
    //print("created date"+createdDate);

    // } // for other organizations i.e pop up for every created date day of the month
    // else{
    dateToSend = createdDate.day;
    print('startDate');

//      print(currDate);
//      print(prefs.getString('date'));
    //print("----> currdate"+((DateTime.parse(dateShowed).day==startDate.day)&&(DateTime.parse(dateShowed).month==startDate.month)&&(DateTime.parse(dateShowed).year==startDate.year)).toString());
    if (currDate.day!=DateTime.parse(dateShowed).day&&
        (currDate.day == (createdDate.add(Duration(days: 7)).day) &&
            currDate.month == createdDate.month &&
            currDate.year == createdDate.year) ) {
      print(">>>--- inside trial popup condition check");
      var nextValidity=new DateTime(currDate.year, currDate.month, currDate.add(Duration(days: 10)).day);
      //        prefs.setString('date',currDate.toString());
      // var newDate = new DateTime(startDate.year, startDate.month, startDate.day+3);
      //if (currDate.isAfter(newDate) && currDate.isBefore(endDate)) {
//        prefs.setString('date', newDate.toString());
//        print("hello");
//        print(prefs.getString('date'));

      //if(((DateTime.parse(dateShowed).day==currDate.day)&&(DateTime.parse(dateShowed).month==currDate.month)&&(DateTime.parse(dateShowed).year==currDate.year))){
      //var newDate = new DateTime(currDate.year, currDate.month, currDate.day+3);

      dateShowed = currDate.toString();
      prefs.setString('TrailReferralShownDate', dateShowed);
      prefs.setString("ReferralValidFrom", cDateS);
      prefs.setString("ReferralValidTo", DateFormat("yyyy-MM-dd").format(nextValidity));

      print("hello" + currDate.toString());

      EasyDialog(
          title: Text(
            ReferrerNotificationList[referrerRandom]['title'].toString(),
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 30,
            ),
            textAlign: TextAlign.center,
          ),
          description: Text(
            ReferrerNotificationList[referrerRandom]['description']
                .toString(),
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
            ),
          ),
          height: height,
          contentList: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                SizedBox(
                  height: 40,
                ),
                RaisedButton(
                  child: Text(
                    "GO!",
                    style: TextStyle(color: Colors.white),
                  ),
                  onPressed: () {
                    generateAndShareReferralLink();
                  },
                  color: Colors.green,
                ),
                SizedBox(
                  width: 10,
                  height: 10,
                ),
              ],
            )
          ]).show(context);
    }

  }

  void showOtherReferralPopup(BuildContext context, String cDateS) async{
    int dateToSend = 0;
    var prefs = await SharedPreferences.getInstance();

    var createdDate = DateTime.parse(cDateS);

    //print(">>>>----- current org status"+globals.currentOrgStatus);




    var currDate = DateTime.now();
    dateShowed = prefs.getString('TrailReferralShownDate') ?? "2010-10-10";

    print("datetime.parse" + dateShowed);
    // print("hello"+dateShowed);
    var referrerAmt = prefs.getString("ReferrerDiscount") ?? "1%";
    var referrenceAmt = prefs.getString("ReferrenceDiscount") ?? "1%";
    ReferrerNotificationList[0] = {
      "title": "Win Win Deal",
      "description":
      "Refer our App and get ${referrerAmt} off on your next payment. Hurry! Offer ends in 10 days"
    };
    ReferrerNotificationList[1] = {
      "title": "Refer and Earn",
      "description":
      "Invite your friends to try ubiAttendance. Get ${referrerAmt} Off when they pay. Hurry! Offer ends in 10 days"
    };
    ReferrerNotificationList[2] = {
      "title": "Discounts that count",
      "description":
      "For every organization you refer which pays up for our Premium plan, we will give you both ${referrerAmt}/ ${referrenceAmt} off. Hurry! Offer ends in 10 days"
    };
    ReferrerNotificationList[3] = {
      "title": "${referrerAmt} Off every Payment",
      "description":
      "Tell Your friends about ubiAttendance & get ${referrerAmt} Discount when he pays. Hurry! Offer ends in 10 days"
    };
    ReferrerNotificationList[4] = {
      "title": "Discounts to smile about",
      "description":
      "Give managers the gift of ease in recording attendanceand get ${referrerAmt} off on your next purchase. Hurry! Offer ends in 10 days"
    };

    var referrerName = "";
    var validity = prefs.getString("ReferralValidity");

    var rng = new Random();
    var referrerRandom = rng.nextInt(4);
    double height = 220;
    if (referrerRandom == 2 || referrerRandom == 4) height = 260;
    if (referrerRandom == 0) height = 170;

    print("----> currdate" + currDate.toString());

    if (createdDate == '') {
      dateToSend = 12;
    }
    // if(buyStatus!=0){  // for trial popup that should show on the seventh day of purchase

    //print("difference dates"+currDate.difference(cDate).inDays.toString());
    //print("created date"+createdDate);

    // } // for other organizations i.e pop up for every created date day of the month
    // else{
    dateToSend = createdDate.day;
    print('startDate');

//      print(currDate);
//      print(prefs.getString('date'));
    //print("----> currdate"+((DateTime.parse(dateShowed).day==startDate.day)&&(DateTime.parse(dateShowed).month==startDate.month)&&(DateTime.parse(dateShowed).year==startDate.year)).toString());
    if (currDate.day!=DateTime.parse(dateShowed).day&&
        (currDate.day == (createdDate.day) ) ) {
      print("inside refer");

      var nextValidity=new DateTime(currDate.year, currDate.month, currDate.add(Duration(days: 10)).day);
      //        prefs.setString('date',currDate.toString());
      // var newDate = new DateTime(startDate.year, startDate.month, startDate.day+3);
      //if (currDate.isAfter(newDate) && currDate.isBefore(endDate)) {
//        prefs.setString('date', newDate.toString());
//        print("hello");
//        print(prefs.getString('date'));

      //if(((DateTime.parse(dateShowed).day==currDate.day)&&(DateTime.parse(dateShowed).month==currDate.month)&&(DateTime.parse(dateShowed).year==currDate.year))){
      //var newDate = new DateTime(currDate.year, currDate.month, currDate.day+3);

      dateShowed = currDate.toString();
      prefs.setString('TrailReferralShownDate', dateShowed);
      prefs.setString("ReferralValidFrom", DateFormat("yyyy-MM-dd").format(currDate));
      prefs.setString("ReferralValidTo", DateFormat("yyyy-MM-dd").format(nextValidity));

      print("hello" + currDate.toString());

      EasyDialog(
          title: Text(
            ReferrerNotificationList[referrerRandom]['title'].toString(),
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 30,
            ),
            textAlign: TextAlign.center,
          ),
          description: Text(
            ReferrerNotificationList[referrerRandom]['description']
                .toString(),
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
            ),
          ),
          height: height,
          contentList: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                SizedBox(
                  height: 40,
                ),
                RaisedButton(
                  child: Text(
                    "GO!",
                    style: TextStyle(color: Colors.white),
                  ),
                  onPressed: () {
                    generateAndShareReferralLink();
                  },
                  color: Colors.green,
                ),
                SizedBox(
                  width: 10,
                  height: 10,
                ),
              ],
            )
          ]).show(context);
    }


  }



  // Platform messages are asynchronous, so we initialize in an async method.
  initPlatformState() async {
    /*await availableCameras();*/
    checknetonpage(context);
    //checkLocationEnabled(context);
    appResumedPausedLogic(context);
    timerResumePause();
    cameraChannel.invokeMethod("openLocationDialog");
    //sendPushNotification('ABC has marked his Time In','','ALL_ORG');

    //showEmailVerificationReminder();

    //showAddingShiftReminder();
    var prefs = await SharedPreferences.getInstance();

    startWorkingHoursTimer();

    setState(() {
      companyFreshlyRegistered =
          prefs.getBool("companyFreshlyRegistered") ?? false;
      FirstAttendance =
          prefs.getBool("FirstAttendance") ?? false;
      FiveStarRating =
          prefs.getBool("FiveStarRating") ?? false;
      RateusDialogShown =
          prefs.getBool("RateusDialogShown") ?? false;
      FeedbackDialogShown =
          prefs.getBool("FeedbackDialogShown") ?? false;
      Rating= prefs.getDouble('Rating') ?? 0.0;
      DateTime date = new DateTime(currDate.year, currDate.month, currDate.day);
       datetoShowFeedbackDialog=prefs.getString("datetoShowFeedbackDialog") ?? date.toString();
       dateShowedFeedbackDialog=prefs.getString("dateShowedFeedbackDialog") ?? '';
       datetoShowRatingDialog=prefs.getString("datetoShowRatingDialog") ?? date.toString();
       dateShowedRatingDialog=prefs.getString("dateShowedRatingDialog") ?? '';
       isRestriction=prefs.getBool('isRestricttion') ?? false;

    });

    Future.delayed(const Duration(milliseconds: 3000), () {
// Here you can write your code
      if (mounted)
        setState(() {
          locationThreadUpdatedLocation = locationThreadUpdatedLocation;
        });
    });
    SystemChannels.lifecycle.setMessageHandler((msg) async {});

    setState(() {
      glow = prefs.getBool('glow') ?? true;
      attendanceNotMarkedButEmpAdded =
          prefs.getBool('attendanceNotMarkedButEmpAdded') ?? false;
      print('is tool tip status' + glow.toString());
    });

    empid = prefs.getString('empid') ?? '';
    orgdir = prefs.getString('orgdir') ?? '';
    desinationId = prefs.getString('desinationId') ?? '';
    response = prefs.getInt('response') ?? 0;
    buysts = prefs.getString('buysts') ?? '0';


    getAreaStatus().then((res) {
      // print('called again');
      print('home dot dart');
      if (mounted) {
        setState(() {
          areaSts = res.toString();
          if (areaId != 0 && geoFence == 1)
            AbleTomarkAttendance = res.toString();
        });
      }
    }).catchError((onError) {
      print('Exception occured in clling function.......');
      print(onError);
    });

    if (response == 1) {
      // Loc lock = new Loc();

      await syncOfflineData();
      // //print(act);
      ////print("this is-----> "+act);
      ////print("this is main "+location_addr);
      prefs = await SharedPreferences.getInstance();
      var netAvailable = 0;
      netAvailable = await checkNet();
      if (mounted && netAvailable == 1) {
        setState(() {
          Is_Delete = prefs.getInt('Is_Delete') ?? 0;
          newpwd = prefs.getString('newpwd') ?? "";
          userpwd = prefs.getString('usrpwd') ?? "";
          print("New pwd" + newpwd + "  User ped" + userpwd);

          admin_sts = prefs.getString('sstatus').toString() ?? '0';
          covid_second = prefs.getString('covid_second') ?? '';
          covid_first = prefs.getString('covid_first') ?? '0';
          //glow= prefs.getBool('tool');
          mail_varified = prefs.getString('mail_varified').toString() ?? '0';
          alertdialogcount = globalalertcount;
          print('aid again');
          response = prefs.getInt('response') ?? 0;
          fname = prefs.getString('fname') ?? '';
          lname = prefs.getString('lname') ?? '';
          empid = prefs.getString('empid') ?? '';
          email = prefs.getString('email') ?? '';
          status = prefs.getString('status') ?? '';
          orgid = prefs.getString('orgid') ?? '';
          orgdir = prefs.getString('orgdir') ?? '';
          org_name = prefs.getString('org_name') ?? '';
          desination = prefs.getString('desination') ?? '';
          profile = prefs.getString('profile') ?? '';
          createdDate = prefs.getString('CreatedDate') ?? '';


          if (referralNotificationShown == false && admin_sts == '1') {
            showReferralPopup(context, createdDate);
            referralNotificationShown = true;
          }
          showReferralReminder();
          print("Profile Image" + profile);
          profileimage = new NetworkImage(profile);
          setaddress();
          // _checkLoaded = false;
          // //print("1-"+profile);
          profileimage
              .resolve(new ImageConfiguration())
              .addListener(new ImageStreamListener((_, __) {
            if (mounted) {
              setState(() {
                _checkLoaded = false;
              });
            }
          }));
          // //print("2-"+_checkLoaded.toString());
          shiftId = prefs.getString('shiftId') ?? "";
          aid = prefs.getString('aid') ?? "";
          print('aid again' + aid);
          print('act again' + aid);
          ////print("this is set state "+location_addr1);
          act1 = act;
          print(act1);
        });
      }
    }
    appResumedPausedLogic(context);

    if ((admin_sts == '1' || admin_sts == '2') && (istooltiponeshown != true)) {
      //if(istooltiponeshown!=true){
      //Future.delayed(Duration(seconds: 1), () => tooltipone.show(context));
      //Future.delayed(Duration(seconds: 1), () => tooltiptimein.show(context));
      print(istooltiponeshown);
      // istooltiponeshown=true;
      print(istooltiponeshown);
    }
    // glow= prefs.getBool('tool');
    //if(glow!=true){
    //Future.delayed(Duration(seconds: 1), () => tooltiptimein.show(context));
    //}
    deviceverification();

    firebaseCloudMessaging_Listeners();
    Password_sts = prefs.getString('password_sts') ?? '0';
    changepasswordStatus = prefs.getString('admin_password_sts') ?? '0';
    print(changepasswordStatus);
    print(Password_sts);
    print("changepasswordStatus");
    FirstAttendance= prefs.getBool('FirstAttendance')?? false;
    FiveStarRating= prefs.getBool('FiveStarRating')?? false;
    RateusDialogShown = prefs.getBool('RateusDialogShown')?? false;
    FeedbackDialogShown = prefs.getBool("FeedbackDialogShown") ?? false;
    Rating= prefs.getDouble('Rating') ?? 0.0;
    String date = formatter.format(now);
    datetoShowFeedbackDialog=prefs.getString("datetoShowFeedbackDialog") ?? date.toString();
    //datetoShowFeedbackDialog='2020-09-16';

    dateShowedFeedbackDialog=prefs.getString("dateShowedFeedbackDialog") ?? '';
    datetoShowRatingDialog=prefs.getString("datetoShowRatingDialog") ?? date.toString();
    dateShowedRatingDialog=prefs.getString("dateShowedRatingDialog") ?? '';
    //dateShowedFeedbackDialog='2020-09-15';
    print('Over here--------------->>>>>>>>>>>>>>');
    print(FirstAttendance.toString()+'------------>>>>one');
    print(FiveStarRating.toString()+'-------->>>second');
    print((FirstAttendance && !FiveStarRating).toString()+'------->>>third');
    print((FirstAttendance&& RateusDialogShown && !FiveStarRating).toString()+'--------->>>>>fourth');
    print(RateusDialogShown.toString()+'five---------->>>>>>');
    print(datetoShowFeedbackDialog.toString()+'six---------->>>>>>');
    print(dateShowedFeedbackDialog.toString()+'seven---------->>>>>>');
    print(FirstAttendance&& RateusDialogShown && !FiveStarRating && dateShowedFeedbackDialog!=date.toString()+'------->>>>>eight');
    print((datetoShowFeedbackDialog.toString()==date.toString()).toString()+'--------->>>Nine');
    print(date.toString()+'Ten');
    print(datetoShowRatingDialog.toString()+'Eleven<----------');
    print(dateShowedRatingDialog.toString()+'Twelve<----------');

    if(FirstAttendance && !FiveStarRating && !RateusDialogShown && dateShowedRatingDialog!=date.toString()) {
      if(datetoShowRatingDialog.toString()==date.toString()) {
        showRateUsDialog();
      }
    }else if(FirstAttendance&& RateusDialogShown && !FiveStarRating && dateShowedFeedbackDialog!=date.toString()){
      if(datetoShowFeedbackDialog.toString()==date.toString()) {
        showfeedbackDialog();
      }
    }
  }


  setaddress() async {
    globalstreamlocationaddr = await getAddressFromLati(
        globals.assign_lat.toString(), globals.assign_long.toString());

    var serverConnected = await checkConnectionToServer();
    if (serverConnected != 0) if (globals.assign_lat == 0.0 ||
        globals.assign_lat == null ||
        !locationThreadUpdatedLocation) {
      cameraChannel.invokeMethod("openLocationDialog");
      /*
      showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return WillPopScope(
                onWillPop: () {},
                child: new AlertDialog(
            title: new Text(""),
            content: new Text("Sorry we can't continue without GPS"),
            actions: <Widget>[
              RaisedButton(
                child: new Text(
                  "Turn On",
                  style: new TextStyle(
                    color: Colors.white,
                  ),
                ),
                color: Colors.orangeAccent,
                onPressed: () async{
                  cameraChannel.invokeMethod("openLocationDialog");
                  //openLocationSetting();
                },
              ),
              RaisedButton(
                child: new Text(
                  "Done",
                  style: new TextStyle(
                    color: Colors.white,
                  ),
                ),
                color: Colors.orangeAccent,
                onPressed: () {
                  cameraChannel.invokeMethod("startAssistant");
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => HomePage()),
                  );
                 /*
                  Navigator.of(context, rootNavigator: true)
                      .pop();
*/
                },
              ),
            ],
          ));});

       */
    }
    print("addon enabled"+(persistedface=='0'&& facerecognition.toString()=='1').toString());
    if(persistedface.toString()=='0'&& facerecognition.toString()=='1'){
      Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => FaceIdScreen()), (Route<dynamic> route) => false,);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!textPostionGotten) {
      WidgetsBinding.instance.addPostFrameCallback(_afterLayout);
    }

    // mail verify code .... comment by sohan
   /* (mail_varified == '0' && alertdialogcount == 0 && admin_sts == '1')
        ? Future.delayed(Duration.zero, () => _showAlert(context))
        : "";*/

    return (response == 0 ||
            userpwd != newpwd ||
            Is_Delete != 0 ||
            orgid == '10932')
        ? new AskRegisterationPage()
        : getmainhomewidget();
    /* return MaterialApp(
      home: (response==0) ? new AskRegisterationPage() : getmainhomewidget(),
    );*/
  }

  void showInSnackBar(String value) {
    final snackBar = SnackBar(
        content: Text(
      value,
      textAlign: TextAlign.center,
    ));
    _scaffoldKey.currentState.showSnackBar(snackBar);
  }

  getmainhomewidget() {
    return MaterialApp(
        navigatorKey: navigatorKey,
        home:Stack(
      children: <Widget>[
        new WillPopScope(
            onWillPop: () async => true,
            child: new Scaffold(
              backgroundColor: Colors.white,
              key: _scaffoldKey,
              appBar: AppBar(
                title: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    new Text(org_name, style: new TextStyle(fontSize: 20.0)),
                  ],
                ),
                automaticallyImplyLeading: false,
                backgroundColor: appcolor,
                // backgroundColor: Color.fromARGB(255,63,163,128),
              ),
              //bottomSheet: getQuickLinksWidget(),
              persistentFooterButtons: <Widget>[
                quickLinkList1(),
              ],

              bottomNavigationBar: Bottomnavigationbar(),

              endDrawer: new AppDrawer(),
              body:
              (act1 == '') ? Center(child: loader()) : checkalreadylogin(),
              floatingActionButton: (((companyFreshlyRegistered &&
                  !attendanceNotMarkedButEmpAdded) &&
                  glow) &&
                  (admin_sts == '1' || admin_sts == '2'))
                  ? Container(
                alignment: Alignment(1.55, 1.25),
                child: (admin_sts == '1' || admin_sts == '2')
                    ? AvatarGlow(
                  glowColor: Colors.blue,
                  child: new FloatingActionButton(
                    mini: false,
                    key: _keyBlue,
                    backgroundColor: buttoncolor,
                    onPressed: () {
                      print('hellowassup' +
                          (((!companyFreshlyRegistered &&
                              attendanceNotMarkedButEmpAdded) ||
                              !glow) &&
                              (admin_sts == '1' ||
                                  admin_sts == '2'))
                              .toString());
                      print('!companyFreshlyRegistered' +
                          (companyFreshlyRegistered == false)
                              .toString());
                      print('attendanceNotMarkedButEmpAdded' +
                          attendanceNotMarkedButEmpAdded
                              .toString());

                      print('!glow' + (glow == false).toString());

                      if (((globals.registeruser) >=
                          (globals.userlimit + 5)) &&
                          buysts != '0')
                        showDialogWidget(
                            "You have registered 5 users more than your User limit. Kindly pay for the Additional Users or delete the Inactive users");
                      else
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => AddEmployee()),
                        );
                      // tooltiptwo.close();
                      istooltiponeshown = true;
                      print(istooltiponeshown);
                    },
                    tooltip: 'Add Employee',
                    child: new Icon(Icons.person_add),
                  ),
                  endRadius: 90.0,
                )
                    : new Center(),
              )
                  : (admin_sts == '1' || admin_sts == '2')
                  ? new FloatingActionButton(
                mini: false,
                //key: _keyBlue,
                backgroundColor: buttoncolor,
                onPressed: () {
                  //sendNotificationtouser();
                  // return false;

                  print('hello');
                  print(glow);
                  _getPositions();
                  if (((globals.registeruser) >=
                      (globals.userlimit + 5)) &&
                      buysts != '0')
                    showDialogWidget(
                        "You have registered 5 users more than your User limit. Kindly pay for the Additional Users or delete the Inactive users");
                  else
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => AddEmployee()),
                    );
                },
                tooltip: 'Add Employee',
                child: new Icon(Icons.person_add),
              )
                  : Container(),
            )), // First child
        // BlurryEffect(0.5,0.1,Colors.grey.shade200)    //  Second Child
      ],
    ));
  }

  checkalreadylogin() {
    ////print("---->"+response.toString());
    if (response == 1) {
      return new IndexedStack(
        index: _currentIndex,
        children: <Widget>[
          underdevelopment(),
          (globalstreamlocationaddr != "Location not fetched." ||
                  globals.globalstreamlocationaddr.isNotEmpty)
              ? mainbodyWidget()
              : refreshPageWidgit(),
          //(false) ? mainbodyWidget() : refreshPageWidgit(),
          underdevelopment()
        ],
      );
    } else {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => AskRegisterationPage()),
        (Route<dynamic> route) => false,
      );
    }

    /* if(userpwd!=newpwd){
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => AskRegisterationPage()),
            (Route<dynamic> route) => false,
      );
    }*/
  }

  refreshPageWidgit() {
    print('thisisglobalstreamaddr---->>>>'+globalstreamlocationaddr);
    if (globals.globalstreamlocationaddr.isNotEmpty) {
      print('thisisglobalstreamaddr---->>>>'+globalstreamlocationaddr);
      return new Container(
        child: Center(
          child: new Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    SizedBox(
                      width: 20.0,
                    ),
                    /*
                    Icon(
                      Icons.all_inclusive,
                      color: Colors.teal,
                    ),
                    Text(
                      "Sorry! can't fetch location. \nPlease check if GPS is enabled on your device",
                      style: new TextStyle(fontSize: 20.0, color: Colors.red),
                    )*/
                    Container(
                      decoration: new ShapeDecoration(
                        shape: new RoundedRectangleBorder(
                            borderRadius: new BorderRadius.circular(13.0)),
                        color: Colors.red,
                      ),
                      child: Text(
                        '\nProblem Getting Location! Please turn on GPS and try again.',
                        textAlign: TextAlign.center,
                        style:
                            new TextStyle(color: Colors.white, fontSize: 15.0),
                      ),
                      width: 220.0,
                      height: 90.0,
                    ),
                  ]),
              SizedBox(height: 15.0),
              Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    SizedBox(
                      width: 20.0,
                    ),
                    /*
                    Text(
                      "Note: ",
                      style: new TextStyle(
                          fontSize: 15.0,
                          color: Colors.black,
                          fontWeight: FontWeight.bold),
                      textAlign: TextAlign.right,
                    ),
                    Text(
                      " If Location not being fetched automatically?",
                      style: new TextStyle(fontSize: 12.0, color: Colors.black),
                      textAlign: TextAlign.left,
                    ),*/
                    /* new InkWell(
                      child: new Text(
                        "Fetch Location now",
                        style: new TextStyle(
                            color: Colors.teal,
                            decoration: TextDecoration.underline),
                      ),
                      onTap: () {
                        sl.startStreaming(5);
                        startTimer();
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => HomePage()),
                        );
                      },
                    )*/
                  ]),
              FlatButton(
                child: new Text(
                  "Try now",
                  style: new TextStyle(
                      color: appcolor, decoration: TextDecoration.underline),
                ),
                onPressed: () {
                  //  sl.startStreaming(5);
                  // startTimer();
                  cameraChannel.invokeMethod("startAssistant");
                  /* Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => HomePage()),
                  );*/
                },
              ),
            ],
          ),
        ),
      );
    } else {
      return Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Text('Kindly allow location permission from settings',
            textAlign: TextAlign.center,
            style: new TextStyle(fontSize: 14.0, color: Colors.red)),
        RaisedButton(
          child: Text('Open Settings'),
          onPressed: () {
            PermissionHandler().openAppSettings();
          },
        ),
      ]);
    }
      /*
      return Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Text('Kindly refresh the page to fetch the location.',
            textAlign: TextAlign.center,
            style: new TextStyle(fontSize: 14.0, color: Colors.red)),
        RaisedButton(
          child: Text('Refresh'),
          color: globals.buttoncolor,
          onPressed: () {
            cameraChannel.invokeMethod("startAssistant");
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => HomePage()),
            );
          },
        ),
      ]);
    }

       */
  }

  loader() {
    return new Container(
      child: Center(
        child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              Image.asset('assets/spinner.gif', height: 50.0, width: 50.0),
            ]),
      ),
    );
  }

  underdevelopment() {
    return new Container(
      child: Center(
        child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              Icon(
                Icons.android,
                color: appcolor,
              ),
              Text(
                "Under development",
                style: new TextStyle(fontSize: 30.0, color: appcolor),
              )
            ]),
      ),
    );
  }

  poorNetworkWidget() {
    return Container(
      child: Center(
        child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Icon(
                      Icons.error,
                      color: appcolor,
                    ),
                    Text(
                      " Poor network connection.",
                      style: new TextStyle(fontSize: 20.0, color: appcolor),
                    ),
                  ]),
              SizedBox(height: 5.0),
              FlatButton(
                child: new Text(
                  "Refresh Page",
                  style: new TextStyle(
                      color: appcolor, decoration: TextDecoration.underline),
                ),
                onPressed: () {
                  // sl.startStreaming(5);
                  // startTimer();
                  cameraChannel.invokeMethod("startAssistant");
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => HomePage()),
                  );
                },
              ),
            ]),
      ),
    );
  }

  mainbodyWidget() {
    ////to do check act1 for poor network connection
    if(globalstreamlocationaddr == "Location not fetched."){
      return Padding(
        padding: const EdgeInsets.only(left:45.0),
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
           Text('Kindly allow location permission from settings',
                textAlign: TextAlign.center,
                style: new TextStyle(fontSize: 14.0, color: Colors.red)),
              RaisedButton(
                child: Text('Open Settings'),
                onPressed: () {
                  PermissionHandler().openAppSettings();
                },
              )],),
      );




    }

    if (act1 == "Poor network connection") {
      return poorNetworkWidget();
    } else {
      return ListView(
        physics: NeverScrollableScrollPhysics(),
        children: <Widget>[
          Container(
            // foregroundDecoration: BoxDecoration(color:Colors.red ),
            height: MediaQuery.of(context).size.height * 0.80,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                SizedBox(height: MediaQuery.of(context).size.height * .06),
                new GestureDetector(
                  onTap: () {
                    // profile navigation
                    /* Navigator.push(context, MaterialPageRoute(builder: (context) => ProfilePage()));*/
                  },
                  child: new Stack(children: <Widget>[
                    Container(
                        //   foregroundDecoration: BoxDecoration(color:Colors.yellow ),
                        width: MediaQuery.of(context).size.height * .16,
                        height: MediaQuery.of(context).size.height * .16,
                        decoration: new BoxDecoration(
                            shape: BoxShape.circle,
                            image: new DecorationImage(
                              fit: BoxFit.fill,
                              image: _checkLoaded
                                  ? AssetImage('assets/avatar.png')
                                  : profileimage,
                              //image: AssetImage('assets/avatar.png')
                            ))),
                    /*new Positioned(
                    left: MediaQuery.of(context).size.width*.14,
                    top: MediaQuery.of(context).size.height*.11,
                    child: new RawMaterialButton(
                      onPressed: () {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => ProfilePage()));
                      },
                      child: new Icon(
                        Icons.edit,
                        size: 18.0,
                      ),
                      shape: new CircleBorder(),
                      elevation: 0.5,
                      fillColor: Colors.teal,
                      padding: const EdgeInsets.all(1.0),
                    ),
                  ),*/
                  ]),
                ),
                SizedBox(height: MediaQuery.of(context).size.height * .02),

                Text(fname.toUpperCase() + " " + lname.toUpperCase(),
                    key: _keyRed,
                    textAlign: TextAlign.center,
                    style: new TextStyle(
                      color: Colors.black87,
                      fontSize: 18.0,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 3.0,
                    )),

                SizedBox(height: MediaQuery.of(context).size.height * .01),
                // SizedBox(height: MediaQuery.of(context).size.height*.01),
                (act1 == '') ? loader() : getMarkAttendanceWidgit(),
              ],
            ),
          ),
        ],
      );
    }
  }

  getMarkAttendanceWidgit() {
    if (act1 == "Imposed") {
      return getAlreadyMarkedWidgit();
    } else {
      return Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            /* Text('Mark Attendance',
                style: new TextStyle(fontSize: 30.0, color: Colors.teal)),
            SizedBox(height: 10.0),*/
            getwidget(globals.globalstreamlocationaddr),
            //    SizedBox(height: MediaQuery.of(context).size.height*.1),
            /*      Container(
            //foregroundDecoration: BoxDecoration(color:Colors.green ),
            margin: EdgeInsets.only(bottom:MediaQuery.of(context).size.height*0),
            //padding: EdgeInsets.only(top:MediaQuery.of(context).size.height*0.02,bottom:MediaQuery.of(context).size.height*0.02),
              height: MediaQuery.of(context).size.height*.10,
              color: Colors.teal.withOpacity(0.8),
              child: Column(
                  children:[
                    SizedBox(height: 10.0,),
                    getQuickLinksWidget()
                  ]),
            ),
         */
          ]);
    }
  }

  Widget quickLinkList1() {
    return Container(
      // color: appcolor,

      width: MediaQuery.of(context).size.width * 0.95,
      // padding: EdgeInsets.only(top:MediaQuery.of(context).size.height*0.03,bottom:MediaQuery.of(context).size.height*0.03, ),
      child: getBulkAttnWid(),
    );
  }

  Widget getBulkAttnWid() {
    List<Widget> widList = List<Widget>();

    if (bulkAttn.toString() == '1' && (admin_sts == '1' || admin_sts == '2')) {
      widList.add(Container(
        padding: EdgeInsets.only(top: 5.0),
        constraints: BoxConstraints(
          maxHeight: 50.0,
          minHeight: 20.0,
        ),
        child: new GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => Bulkatt()),
              );
            },
            child: Column(
              children: [
                Icon(
                  const IconData(0xe81d, fontFamily: "CustomIcon"),
                  size: 30.0,
                  color: iconcolor,
                ),
                Text('Group',
                    textAlign: TextAlign.center,
                    style: new TextStyle(fontSize: 12.0, color: iconcolor)),
              ],
            )),
      ));
    }

    if(globals.ShiftPlanner==1) {
      widList.add(Container(
        padding: EdgeInsets.only(top: 5.0),
        constraints: BoxConstraints(
          maxHeight: 50.0,
          minHeight: 20.0,
        ),
        child: new GestureDetector(
            onTap: () {

              admin_sts == '1' || admin_sts == '2'?
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => shiftPlannerList()),
              ): Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => userViewShiftPlanner()),
              );

            },
            child: Column(
              children: [
                Icon(
                  const IconData(0xe80e, fontFamily: "CustomIcon"),
                  size: 29.0,
                  color: iconcolor,
                ),
                admin_sts == '1' || admin_sts == '2'? Text('Shift Planner',
                    textAlign: TextAlign.center,
                    style: new TextStyle(fontSize: 12.0, color: iconcolor)):Text('Shifts ',
                    textAlign: TextAlign.center,
                    style: new TextStyle(fontSize: 12.0, color: iconcolor)),
              ],
            ),
        ),
      ));
    }


    /*widList.add(Container(
      padding: EdgeInsets.only(top: 5.0),
      constraints: BoxConstraints(
        maxHeight: 50.0,
        minHeight: 20.0,
      ),
      child: new GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => MyApp()),
            );
          },
          child: Column(
            children: [
              Icon(
                const IconData(0xe81c, fontFamily: "CustomIcon"),
                size: 30.0,
                color: iconcolor,
              ),
              Text('Log',
                  textAlign: TextAlign.center,
                  style: new TextStyle(fontSize: 12.0, color: iconcolor)),
            ],
          )),
    ));*/

    if (visitpunch.toString() == '1') {
      widList.add(Container(
        padding: EdgeInsets.only(top: 5.0),
        constraints: BoxConstraints(
          maxHeight: 50.0,
          minHeight: 20.0,
        ),
        child: new GestureDetector(
            onTap: () {
              /*showInSnackBar("Under development.");*/
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => PunchLocationSummary()),
              );
            },
            child: Column(
              children: [
                Icon(
                  const IconData(0xe821, fontFamily: "CustomIcon"),
                  size: 30.0,
                  color: iconcolor,
                ),
                Text('Visits',
                    textAlign: TextAlign.center,
                    style: new TextStyle(fontSize: 12.0, color: iconcolor)),
              ],
            )),
      ));
    }

    if (timeOff.toString() == '1'&&shiftType.toString()!='3') {
      widList.add(Container(
        padding: EdgeInsets.only(top: 5.0),
        constraints: BoxConstraints(
          maxHeight: 50.0,
          minHeight: 20.0,
        ),
        child: new GestureDetector(
            onTap: () {
              //  //print('----->>>>>'+getOrgPerm(1).toString());
              getOrgPerm(1).then((res) {
                {
                  //   //print('----->>>>>'+res.toString());
                  if (res) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => TimeoffSummary()),
                    );
                  } else
                    showInSnackBar('Please buy this feature');
                }
              });

            },
            child: Column(
              children: [
                Icon(
                  const IconData(0xe818, fontFamily: "CustomIcon"),
                  size: 30.0,
                  color: iconcolor,
                ),
                Text(' Time Off',
                    textAlign: TextAlign.center,
                    style: new TextStyle(fontSize: 12.0, color: iconcolor)),
              ],
            )),
      ));
    }
    if (BasicLeave.toString() == '1') {
      widList.add(Container(
        padding: EdgeInsets.only(top: 5.0),
        constraints: BoxConstraints(
          maxHeight: 50.0,
          minHeight: 20.0,
        ),
        child: new GestureDetector(
            onTap: () {
              /*showInSnackBar("Under development.");*/
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => MyLeave()),
              );
            },
            child: Column(
              children: [
              Image.asset(
              'assets/leave-icon.png', height: 30.0, width: 30.0,color: Colors.black45,),
                Text('Leave',
                    textAlign: TextAlign.center,
                    style: new TextStyle(fontSize: 12.0, color: iconcolor)),
              ],
            )),
      ));
    }

    /* widList.add();
    widList.add();*/
    return (Row(
      children: widList,
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
    ));
  }

  List<GestureDetector> quickLinkList() {
    List<GestureDetector> list = new List<GestureDetector>();
    // //print("permission list-->>>>>>"+data.toString());
    list.add(new GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => MyApp()),
          );
        },
        child: Column(
          children: [
            Icon(
              Icons.calendar_today,
              size: 30.0,
              color: Colors.white,
            ),
            Text('Attendance',
                textAlign: TextAlign.center,
                style: new TextStyle(fontSize: 15.0, color: Colors.white)),
          ],
        )));

    if (punchlocation_permission == 1) {
      list.add(new GestureDetector(
          onTap: () {
            /*showInSnackBar("Under development.");*/
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => PunchLocation()),
            );
          },
          child: Column(
            children: [
              Icon(
                Icons.add_location,
                size: 30.0,
                color: Colors.white,
              ),
              Text('Visits',
                  textAlign: TextAlign.center,
                  style: new TextStyle(fontSize: 15.0, color: Colors.white)),
            ],
          )));
    }

    if (timeoff_permission == 1) {
      list.add(new GestureDetector(
          onTap: () {
            //  //print('----->>>>>'+getOrgPerm(1).toString());
            getOrgPerm(1).then((res) {
              {
                //   //print('----->>>>>'+res.toString());
                if (res) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => TimeoffSummary()),
                  );
                } else
                  showInSnackBar('Please buy this feature');
              }
            });
          },
          child: Column(
            children: [
              Icon(
                Icons.access_alarm,
                size: 30.0,
                color: Colors.white,
              ),
              Text('Time Off',
                  textAlign: TextAlign.center,
                  style: new TextStyle(fontSize: 15.0, color: Colors.white)),
            ],
          )));
    }

    if (leave_permission == 1) {
      list.add(new GestureDetector(
          onTap: () {
            getOrgPerm(1).then((res) {
              {
                //   //print('----->>>>>'+res.toString());
                if (res) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => LeaveSummary()),
                  );
                } else
                  showInSnackBar('Please buy this feature');
              }
            });
          },
          child: Column(
            children: [
              Icon(
                Icons.exit_to_app,
                size: 30.0,
                color: Colors.white,
              ),
              Text('Leave',
                  textAlign: TextAlign.center,
                  style: new TextStyle(fontSize: 15.0, color: Colors.white)),
            ],
          )));
    }
    return list;
  }

  getQuickLinksWidget() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: quickLinkList(),
    );
  }

  getAlreadyMarkedWidgit() {
    return Column(children: <Widget>[
      SizedBox(height: MediaQuery.of(context).size.height * .05),
      Padding(
        padding: const EdgeInsets.only(left: 8.0, right: 8.0),
        child: Card(
          elevation: 0.0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: BorderSide(
              color: Colors.amber.withOpacity(0.5),
              width: 2,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Container(
              child: Text(
                ' Attendance has been marked. Thank You!',
                textAlign: TextAlign.center,
                style: new TextStyle(
                    color: Colors.amber,
                    fontSize: 18.0,
                    letterSpacing: 2.0,
                    fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ),
      ),
    ]);
  }

  getwidget(String addrloc) {
    if (addrloc != "Location could not be fetched.") {
      return Column(children: [
        ButtonTheme(
          minWidth: 120.0,
          height: 45.0,
          child: getTimeInOutButton(),
        ),
        SizedBox(height: MediaQuery.of(context).size.height * .04),
        Padding(
          padding: const EdgeInsets.only(left: 8.0, right: 8.0),
          child: Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
              side: BorderSide(
                color: Colors.grey.withOpacity(0.5),
                width: 1,
              ),
            ),
            elevation: 0.0,
            borderOnForeground: true,
            clipBehavior: Clip.antiAliasWithSaveLayer,
            child: Padding(
              padding: const EdgeInsets.only(left:5.0,right:5.0),
              child: Container(
                  color: Colors.white,
                  height: MediaQuery.of(context).size.height * .18,
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (loggedInSince.isNotEmpty)
                          Text(
                            loggedInSince,
                            style: TextStyle(color: Colors.green),
                          ),
                        FlatButton(
                          child: new Text(
                              globals.globalstreamlocationaddr != null
                                  ? 'You are at: '+globals.globalstreamlocationaddr
                                  : "Location could not be fetched",
                              textAlign: TextAlign.center,
                              style: new TextStyle(
                                  fontSize: 14.0, color: Colors.black54)),
                          onPressed: () {
                            launchMap(globals.assign_lat.toString(),
                                globals.assign_long.toString());
                            /* Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => HomePage()),
                        );*/
                          },
                        ),
                        new Center(
                          child: Padding(
                            padding: const EdgeInsets.only(top: 5.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                new InkWell(
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: <Widget>[
                                      Icon(
                                        const IconData(0xe81a,
                                            fontFamily: "CustomIcon"),
                                        size: 15.0,
                                        color: Colors.teal,
                                      ),
                                      Text("  "),
                                      Text(
                                        "Refresh Location", // main  widget
                                        style: new TextStyle(
                                            color: appcolor,
                                            decoration: TextDecoration.none),
                                      ),
                                    ],
                                  ),
                                  onTap: () {
                                    //  startTimer();
                                    //  sl.startStreaming(5);
                                    cameraChannel
                                        .invokeMethod("startAssistant");
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => HomePage()),
                                    );
                                  },
                                )
                              ],
                            ),
                          ),
                        ),
//                    SizedBox(
//                      height: 5.0,
//                    ),
                        if (fakeLocationDetected)
                          Container(
                            padding: EdgeInsets.all(5.0),
                            decoration: BoxDecoration(
                              color: Color(0xfffc6203),
                              //  border: Border(left: 1.0,right: 1.0,top: 1.0,bottom: 1.0),
                            ),
                            child: Text(
                              'Fake Location',
                              style: TextStyle(
                                  fontSize: 16.0,
                                  color: Colors.amber,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 1.0),
                            ),
                          )
                        else
                          (areaId != 0 && geoFence == 1)
                              ? areaSts == '0'
                                  ? Container(
                                      padding:
                                          EdgeInsets.only(top: 5.0, right: 5.0),
                                      child: Text(
                                        ' Outside Geofence ',
                                        style: TextStyle(
                                            fontSize: 16.0,
                                            color: Colors.white,
                                            backgroundColor: Colors.red,
                                            fontWeight: FontWeight.w600,
                                            letterSpacing: 1.0),
                                      ),
                                    )
                                  : Container(
                                      padding: EdgeInsets.all(5.0),
                                      child: Text(
                                        ' Within Geofence ',
                                        style: TextStyle(
                                            fontSize: 16.0,
                                            color: Colors.white,
                                            backgroundColor: Colors.green,
                                            fontWeight: FontWeight.w600,
                                            letterSpacing: 1.0),
                                      ),
                                    )
                              : Center(),
                      ])),
            ),
          ),
        ),
      ]);
    } else {
      return Column(children: [
        Text('Kindly refresh the page to fetch the location',
            textAlign: TextAlign.center,
            style: new TextStyle(fontSize: 14.0, color: Colors.red)),
        RaisedButton(
          child: Text('Refresh'),
          color: globals.buttoncolor,
          onPressed: () {
            cameraChannel.invokeMethod("startAssistant");
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => HomePage()),
            );
          },
        ),
      ]);
    }
  }

  getTimeInOutButton() {
    if (act1 == 'TimeIn') {
      return RaisedButton(
        elevation: 0.0,
        highlightElevation: 0.0,
        highlightColor: Colors.transparent,
        disabledElevation: 0.0,
        focusColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
//          side: BorderSide( color: Colors.green.withOpacity(0.5), width: 2,),
        ),
        clipBehavior: Clip.antiAlias,
        child: Text('TIME IN',
            style: new TextStyle(
                fontSize: 18.0, color: Colors.white, letterSpacing: 2)),
        color: globals.buttoncolor,
        onPressed: () async {
          globals.globalCameraOpenedStatus = true;
          // if(changepasswordStatus == '0' || changepasswordStatus == '')
          //saveImage();
          print('covidfirst'+covid_first);
          print('covidfirst'+covid_second);
          print('covidfirst'+covidsurvey.toString());

          if(covid_first=='1' && globals.covidsurvey==1)
          {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => Every7dayscovidsurvey()), (Route<dynamic> route) => true,
            );
          }
          else if(covid_second=='1'  && globals.covidsurvey==1)
          {

              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => Covid19serve()), (Route<dynamic> route) => true,
              );

          }else if(changepasswordStatus == '1') {
            if (Password_sts == '0')
              _onAlertWithCustomContentPressed(context);
            if (Password_sts == '1')
              saveImage();
          }
          else{
            saveImage();
          }

          //Navigator.pushNamed(context, '/home');
        },
      );
    } else if (act1 == 'TimeOut') {
      return RaisedButton(
        clipBehavior: Clip.antiAlias,
        elevation: 0.0,
        highlightElevation: 0.0,
        highlightColor: Colors.transparent,
        disabledElevation: 50.0,
        focusColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
//          side: BorderSide( color: Colors.red.withOpacity(0.5), width: 2,),
        ),
        child: Text('TIME OUT',
            style: new TextStyle(
                fontSize: 18.0, color: Colors.white, letterSpacing: 2)),
        color: globals.buttoncolor,
        onPressed: () async {
          globals.globalCameraOpenedStatus = true;
          // //print("Time out button pressed");
          saveImage();
        },
      );
    }
  }

  Text getText(String addrloc) {
    if (addrloc != "PermissionStatus.deniedNeverAsk") {
      return Text('You are at: ' + addrloc,
          textAlign: TextAlign.center, style: new TextStyle(fontSize: 14.0));
    } else {
      return new Text(
          'Location access is denied. Enable the access through the settings.',
          textAlign: TextAlign.center,
          style: new TextStyle(fontSize: 14.0, color: Colors.red));
      /*return new  Text('Location is restricted from app settings, click here to allow location permission and refresh', textAlign: TextAlign.center, style: new TextStyle(fontSize: 14.0,color: Colors.red));*/
    }
  }

  void startLiveLocationTracking() {

    HomeViewState tracker=HomeViewState();
    tracker.initState();
    tracker.onClickEnable(true);
    tracker.onClickChangePace();
    //tracker.onEnabledChange(true);

  }
  void stopLiveLocationTracking() {

    HomeViewState tracker=HomeViewState();
    tracker.initState();
    tracker.onClickEnable(false);
    //tracker.onClickChangePace();
    //tracker.onEnabledChange(true);

  }






  saveImage() async {
    timeWhenButtonPressed = DateTime.now();
    //  sl.startStreaming(5);
    print('aidId' + aid);
    var FakeLocationStatus = 0;


    if(globals.geoFence==1) {
      if (areaSts == '0') {
        if(areaId==0 || areaId.toString()==""){
          geofence = "";
        }else{
          geofence = "Outside Geofence";
        }

        print('thisisgeofencefortesting123---->>>>'+geofence);
        print('thisisabletomarkatt---->>>>'+ableToMarkAttendance.toString());

        if(ableToMarkAttendance==1) {
          print('thisisgeofencefortesting456---->>>>'+geofence);
          await showDialog(
              context: context,
              // ignore: deprecated_member_use
              child: new AlertDialog(
                //title: new Text("Warning!"),
                content: new Text(
                    "You Can't punch Attendance Outside Geofence."),
              ));
          return null;
        }

      } else {
        geofence = "Within Geofence";
        print('thisisgeofencefortesting789---->>>>'+geofence);
      }
    }
    print('thisisgeofencefortesting---->>>>'+geofence);

    if(globals.departmentid==1||globals.departmentid==0){
      await showDialog(
          context: context,
          // ignore: deprecated_member_use
          child: new AlertDialog(
            //title: new Text("Warning!"),
            content: new Text("Department has not been assigned"),
          ));
      return null;
    }
    if(globals.designationid==0){
      await showDialog(
          context: context,
          // ignore: deprecated_member_use
          child: new AlertDialog(
            //title: new Text("Warning!"),
            content: new Text("Designation has not been assigned"),
          ));
      return null;
    }
    print("ssssssssssssssssshift"+shiftId.toString());
    if(globals.shiftId==''||globals.shiftId==null||globals.shiftId=='0'){
      await showDialog(
          context: context,
          // ignore: deprecated_member_use
          child: new AlertDialog(
            //title: new Text("Warning!"),
            content: new Text("Shift has not been assigned"),
          ));
      return null;
    }


    if (AbleTomarkAttendance != '1' &&
        globals.ableToMarkAttendance == 1 &&
        geoFence == 1) {
      await showDialog(
          context: context,
          // ignore: deprecated_member_use
          child: new AlertDialog(
            //title: new Text("Warning!"),
            content: new Text("You Can't punch Attendance from Outside Geofence"),
          ));
      return null;
    }

    if (fakeLocationDetected) {
      FakeLocationStatus = 1;
    }
    MarkTime mk = new MarkTime(
        empid,
        globals.globalstreamlocationaddr,
        aid,
        act1,
        shiftId,
        orgdir,
        globals.assign_lat.toString(),
        assign_long.toString(),
        FakeLocationStatus,
        globalcity);

    var connectivityResult = await (new Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.mobile ||
        connectivityResult == ConnectivityResult.wifi) {
      /* Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => CameraExampleHome()),
      );*/
      SaveImage saveImage = new SaveImage();
      Map issave;
     var prefs = await SharedPreferences.getInstance();
     isRestriction=prefs.getBool('isRestriction') ?? false;
      globals.showAppInbuiltCamera =
          prefs.getBool("showAppInbuiltCamera") ?? true;
      issave = globals.showAppInbuiltCamera
          ? await saveImage.saveTimeInOutImagePickerAppCamera(mk, context)
          : await saveImage.saveTimeInOutImagePicker(mk, context);
      print(issave);
      if (issave['status'] == 3)  {
        globals.timeWhenButtonPressed = null;
        showDialog(
            context: context,
            // ignore: deprecated_member_use
            child: new AlertDialog(
              title: new Text(""),
              content: new Text(
                  "Sorry you have taken more time than expected to mark attendance. Please mark again!"),
            ));
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => HomePage()),
        );
      }

      if(issave['status']== 6){
        showDialog(
            context: context,
            // ignore: deprecated_member_use
            child: new AlertDialog(
              backgroundColor: Colors.redAccent,
              content: new Text("Attendance selfie does not match with the registered Face ID. Try Again!",style: TextStyle(color: Colors.white),),
            ));
      }
          else if (issave['status'] == 1 || issave['status']==2)  {
        // Sync image
        saveImage.SendTempimage(context , true);
        if(act1=='TimeIn'){
          if(locationTrackingAddon=='1'){
           // startLiveLocationTracking();
          }

          print("This is time in block " + act1);
          var prefs = await SharedPreferences.getInstance();

          String InPushNotificationStatus =
              await prefs.getString("InPushNotificationStatus") ?? '0';
          var empId = prefs.getString('empid') ?? '';
          var orgId = prefs.getString("orgid") ?? '';
          var eName = prefs.getString('fname') ?? 'User';
          var formatter = new DateFormat('HH:mm');
          var date= formatter.format(DateTime.now());
          String topic = empId + 'TI' + orgId;
          if (InPushNotificationStatus == '1') {
//            sendPushNotification(eName + ' has marked Time In at '+ date, '',
//                '\'' + topic + '\' in topics');
            sendPushNotification(
                eName + ' has marked Time In at '+ date, '',
                '(\'' + globals.globalOrgTopic +
                    '\' in topics) && (\'admin\' in topics)');
          }
          if (FakeLocationStatus==1) {
            if(FakeLocation==5|| FakeLocation==13 || FakeLocation==7|| FakeLocation==15){
              String subject="Fake Location";
              String content= eName + ' has punched Time In from a spoofed location';
              sendMailByAppToAdmin(subject, content);
            }
            if(FakeLocation==9|| FakeLocation==13 || FakeLocation==11|| FakeLocation==15) {
              sendPushNotification(
                  eName + ' has punched Time In from a spoofed location', '',
                  '(\'' + globals.globalOrgTopic +
                      '\' in topics) && (\'admin\' in topics)');
            }
          }
        }
        else{
         // stopLiveLocationTracking();
          print("This is time timeout block"+ act1);
          var prefs = await SharedPreferences.getInstance();

          String OutPushNotificationStatus =
              await prefs.getString("OutPushNotificationStatus") ?? '0';
          var empId = prefs.getString('empid') ?? '';
          var orgId = prefs.getString("orgid") ?? '';
          var eName = prefs.getString('fname') ?? 'User';
          var formatter = new DateFormat('HH:mm');
          var date= formatter.format(DateTime.now());
          String topic = empId + 'TO' + orgId;
          if (OutPushNotificationStatus == '1') {
//            sendPushNotification(eName + ' has marked Time Out at '+ date, '',
//                '\'' + topic + '\' in topics');
            sendPushNotification(
                eName + ' has marked Time Out at '+ date, '',
                '(\'' + globals.globalOrgTopic +
                    '\' in topics) && (\'admin\' in topics)');

            print('\'' + topic + '\' in topics');
          }
          if (FakeLocationStatus==1) {
            if(FakeLocation==5|| FakeLocation==13 || FakeLocation==7|| FakeLocation==15){
              String subject="Fake Location";
              String content= eName + ' has punched Time Out from a spoofed location';
              sendMailByAppToAdmin(subject, content);
            }
            if(FakeLocation==9|| FakeLocation==13 || FakeLocation==11|| FakeLocation==15) {
              sendPushNotification(
                  eName + ' has punched Time Out from a spoofed location', '',
                  '(\'' + globals.globalOrgTopic +
                      '\' in topics) && (\'admin\' in topics)');
            }
          }

        }

        if (mounted) {
          setState(() {
            act1 = "";
          });
        }
        //var prefs = await SharedPreferences.getInstance();
        prefs.setBool("firstAttendanceMarked", true);
        prefs.setBool("FirstAttendance", true);

        //prefs.setBool("companyFreshlyRegistered",false );

        showInSnackBarforTimeInOut(issave['TimeInOut'],issave['EntryExitImage'],issave['checkInOutLoc'],);
        /*
        showDialog(
            context: context,
            // ignore: deprecated_member_use
            child: new AlertDialog(
              content: new Text("Attendance marked successfully!"),
            ));
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => MyApp()),
        );*/
        if (mounted) {
          setState(() {
            act1 = act;
          });
        }
      } else if(issave['status']==4){
        showDialog(
            context: context,
            // ignore: deprecated_member_use
            child: new AlertDialog(
              content: new Text("Selfie was not captured. Please change your Camera from Settings."),
            ));
        if (mounted) {
          setState(() {
            act1 = act;
          });
        }
      }
      else{      //

        showDialog(
            context: context,
            // ignore: deprecated_member_use
            child: new AlertDialog(
              content: new Text("Selfie was not captured. Please change your Camera from Settings."),
            ));


      }
    } else {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      int offlinemode = prefs.getInt("OfflineModePermission");
      if (offlinemode == 1) {
        print("Routing");
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => OfflineHomePage()),
          (Route<dynamic> route) => false,
        );
      } else {
        showDialog(
            context: context,
            // ignore: deprecated_member_use
            child: new AlertDialog(
              content: new Text("Internet connection not found!."),
            ));
      }
    }

    /*SaveImage saveImage = new SaveImage();
    bool issave = false;
    setState(() {
      act1 = "";
    });
    issave = await saveImage.saveTimeInOut(mk);
    ////print(issave);
    if (issave) {

      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => MyApp()),
      );
      setState(() {
        act1 = act;
      });
    } else {
      setState(() {
        act1 = act;
      });
    }*/
  }

  void dialogwidget(BuildContext context) async{
    print("Sohan patel");
    showDialog(
        context: context,
        barrierDismissible: false,
        // ignore: deprecated_member_use
        child: new AlertDialog(
          content: new Text('Your Time Out was not punched Yesterday. Kindly contact Admin to regularize Attendance'),
          actions: <Widget>[
            /*
            RaisedButton(
              child: Text(
                ' Yes ',
                style: TextStyle(color: Colors.white),
              ),
              color: Colors.amber,
              onPressed: () {
                Navigator.of(context, rootNavigator: true).pop();
              },
            ),
            FlatButton(
              child: Text(' No '),
              shape: Border.all(),
              onPressed: () async {
                Navigator.of(context, rootNavigator: true).pop();
                Home ho = new Home();
                print("Test");
                await ho.updateTimeOut(empid, orgdir);
                act = await ho.checkTimeIn(empid, orgdir,context);
                print("Action from check time in1");
                if (timeoutdate == 'nextdate' && act == 'TimeOut')
                  dialogwidget(context);
                ho.managePermission(empid, orgdir, desinationId);

                setState(() {
                  act1 = act;
                });
              },
            ), */
          ],

        ));
    Home ho = new Home();
    await ho.updateTimeOut(empid, orgdir);
  }

/*
  saveImage_old() async {
   // sl.startStreaming(5);
var FakeLocationStatus=0;
    if(fakeLocationDetected){
      FakeLocationStatus=1;
    }
    MarkTime mk = new MarkTime(
        empid, streamlocationaddr, aid, act1, shiftId, orgdir, lat, long,FakeLocationStatus
    );
    /* mk1 = mk;*/

    var connectivityResult = await (new Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.mobile ||
        connectivityResult == ConnectivityResult.wifi) {
      /* Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => CameraExampleHome()),
      );*/
      SaveImage saveImage = new SaveImage();
      if (mounted)
        setState(() {
          act1 = "";
        });

      saveTimeInOutImagePicker_new(mk).then((res) {
        /*
           print("res: "+res.toString());
           print("issave: "+issave.toString());
           if (issave==true || res==true) {
             showDialog(context: context, child:
             new AlertDialog(
               content: new Text("Attendance marked successfully!"),
             )
             );
             Navigator.push(
               context,
               MaterialPageRoute(builder: (context) => MyApp()),
             );
             setState(() {
               act1 = act;
             });
           } else {
             showDialog(context: context, child:
             new AlertDialog(
               title: new Text("Warning!"),
               content: new Text("Problem while marking attendance, try again."),
             )
             );
             setState(() {
               act1 = act;
             });
           }*/
      });
    } else {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      int offlinemode=prefs.getInt("OfflineModePermission");
      if(offlinemode==1){
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => OfflineHomePage()),
        );

      }
      else{
        showDialog(
            context: context,
            child: new AlertDialog(
              content: new Text("Internet connection not found!."),
            ));
      }
    }

    /*SaveImage saveImage = new SaveImage();
    bool issave = false;
    setState(() {
      act1 = "";
    });
    issave = await saveImage.saveTimeInOut(mk);
    ////print(issave);
    if (issave) {

      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => MyApp()),
      );
      setState(() {
        act1 = act;
      });
    } else {
      setState(() {
        act1 = act;
      });
    }*/
  }
*/
/*  saveImage() async {

      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => CameraApp()),
      );

  }*/

  resendVarification() async {
    NewServices ns = new NewServices();
    bool res = await ns.resendVerificationMail(orgid);
    if (res) {
      showDialog(
          context: context,
          builder: (context) => AlertDialog(
                  content: Row(children: <Widget>[
                Text(
                    "Verification link has been sent to \nyour organization's registered \nEmail."),
              ])));
    }
  }

 /* void _showAlert(BuildContext context) {
    globalalertcount = 1;
    if (mounted)
      setState(() {
        alertdialogcount = 1;
      });
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
            title: Text("Verify Email"),
            content: Container(
                height: MediaQuery.of(context).size.height * 0.22,
                child: Column(children: <Widget>[
                  Container(
                      width: MediaQuery.of(context).size.width * 0.6,
                      child: Text(
                          "Your organization's Email is not verified. Please verify now.")),
                  new Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: <Widget>[
                        ButtonBar(
                          children: <Widget>[
                            FlatButton(
                              child: Text('Later'),
                              shape: Border.all(color: Colors.black54),
                              onPressed: () {
                                Navigator.of(context, rootNavigator: true)
                                    .pop();
                              },
                            ),
                            new RaisedButton(
                              child: new Text(
                                "Verify",
                                style: new TextStyle(
                                  color: Colors.white,
                                ),
                              ),
                              color: globals.buttoncolor,
                              onPressed: () {
                                Navigator.of(context, rootNavigator: true)
                                    .pop();
                                resendVarification();
                              },
                            ),
                          ],
                        ),
                      ])
                ]))));
  }*/

  //////////////////////////////////////////////////////////////////

  showDialogWidget(String loginstr) {
    return showDialog(
        context: context,
        builder: (context) {
          return new AlertDialog(
            title: new Text(
              loginstr,
              style: TextStyle(fontSize: 15.0),
            ),
            content: ButtonBar(
              children: <Widget>[
                FlatButton(
                  child: Text('Later', style: TextStyle(fontSize: 13.0)),
                  shape: Border.all(),
                  onPressed: () {
                    Navigator.of(context, rootNavigator: true).pop();
                  },
                ),
                RaisedButton(
                  child: Text(
                    'Pay Now',
                    style: TextStyle(color: Colors.white, fontSize: 13.0),
                  ),
                  color: Colors.orangeAccent,
                  onPressed: () {
                    Navigator.of(context, rootNavigator: true).pop();
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => PaymentPage()),
                    );
                  },
                ),
              ],
            ),
          );
        });
  }

  Future<bool> saveTimeInOutImagePicker_new(MarkTime mk) async {
    String base64Image;
    String base64Image1;
    print('saveTimeInOutImagePicker_new CALLED');
    String location = globalstreamlocationaddr;

    String lat = assign_lat.toString();
    String long = assign_long.toString();
    try {
      ///////////////////////////
      StreamLocation sl = new StreamLocation();
      // sl.startStreaming(5);
      Location _location = new Location();

      ////////////////////////////////suumitted block
      File imagei = null;
      imageCache.clear();
      if (globals.attImage == 1) {
        ImagePicker.pickImage(
                source: ImageSource.camera, maxWidth: 200.0, maxHeight: 200.0)
            .then((img) async {
          if (imagei != null) {
            _location.getLocation().then((res) {
              if (res.latitude != '') {
                var addresses = '';
                Geocoder.local
                    .findAddressesFromCoordinates(
                        Coordinates(res.latitude, res.longitude))
                    .then((add) {
                  print(
                      'Location taekn--------------------------------------------------');
                  print(
                      res.latitude.toString() + ' ' + res.longitude.toString());
                  var first = add.first;
                  print("${first.addressLine}");
                  print(
                      'Location taekn--------------------------------------------------');
                  lat = res.latitude.toString();
                  long = res.longitude.toString();

                  //// sending this base64image string +to rest api
                  Dio dio = new Dio();

                  print("saveImage?uid=" +
                      mk.uid +
                      "&location=" +
                      location +
                      "&aid=" +
                      mk.aid +
                      "&act=" +
                      mk.act +
                      "&shiftid=" +
                      mk.shiftid +
                      "&refid=" +
                      mk.refid +
                      "&latit=" +
                      lat +
                      "&longi=" +
                      long);
                  FormData formData = new FormData.from({
                    "uid": mk.uid,
                    "location": location,
                    "aid": mk.aid,
                    "act": mk.act,
                    "shiftid": mk.shiftid,
                    "refid": mk.refid,
                    "latit": lat,
                    "longi": long,
                    "file": new UploadFileInfo(imagei, "image.png"),
                  });
                  print("5");
                  dio
                      .post(globals.path + "saveImage", data: formData)
                      .then((response1) {
                    print('response1: ' + response1.toString());
                    imagei.deleteSync();
                    imageCache.clear();
                    /*getTempImageDirectory();*/
                    Map MarkAttMap = json.decode(response1.data);
                    print('MarkAttMap["status"]: ' +
                        MarkAttMap["status"].toString());
                    if (MarkAttMap["status"] == 1 ||
                        MarkAttMap["status"] == 2) {
                      print("res: " + res.toString());
                      print("issave: " + issave.toString());
                      //     if (issave==true || res==true) {

                      showDialog(
                          context: context,
                          // ignore: deprecated_member_use
                          child: new AlertDialog(
                            content:
                                new Text("Attendance marked successfully !"),
                          ));
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => MyApp()),
                      );
                      if (mounted)
                        setState(() {
                          act1 = act;
                        });
                    } else {
                      showDialog(
                          context: context,
                          // ignore: deprecated_member_use
                          child: new AlertDialog(
                            content: new Text(
                                "Selfie was not captured. Please try again."),
                          ));
                      if (mounted)
                        setState(() {
                          act1 = act;
                        });
                    }
                    /* setState(() {
                        issave=true;
                        print('new issave'+issave.toString());
                      });*/
                  }).catchError((err) {
                    print('Exception in setting data in saveImage' +
                        err.toString());
                    return true;
                  });
                });
              } else {
                showDialog(
                    context: context,
                    // ignore: deprecated_member_use
                    child: new AlertDialog(
                      title: new Text("Warning!"),
                      content: new Text("Location not fetched..."),
                    ));
              }
            });
            //*****
          } else {
            ///////////////////////////// camera closed by pressing back button

            showDialog(
                context: context,
                // ignore: deprecated_member_use
                child: new AlertDialog(
                  title: new Text("Warning!"),
                  content: new Text("Camera closed improperly"),
                ));
            if (mounted)
              setState(() {
                act1 = act;
              });

            ///////////////////////////// camera closed by pressing back button/
            print("6");
            return false;
          }
          return true;
        }).catchError((err) {
          print('Exception Occured in getting FILE' + err.toString());
          return true;
        });
      } else {
        // block for marking attendance without taking the picture
        _location.getLocation().then((res) {
          if (res.latitude != '') {
            var addresses = '';
            Geocoder.local
                .findAddressesFromCoordinates(
                    Coordinates(res.latitude, res.longitude))
                .then((add) {
              print(
                  'Location taekn 2--------------------------------------------------');
              print(res.latitude.toString() + ' ' + res.longitude.toString());
              var first = add.first;
              print("${first.addressLine}");
              print(
                  'Location taekn 2--------------------------------------------------');
              lat = res.latitude.toString();
              long = res.longitude.toString();

              //// sending this base64image string +to rest api
              Dio dio = new Dio();

              print("--saveImage?uid=" +
                  mk.uid +
                  "&location=" +
                  location +
                  "&aid=" +
                  mk.aid +
                  "&act=" +
                  mk.act +
                  "&shiftid=" +
                  mk.shiftid +
                  "&refid=" +
                  mk.refid +
                  "&latit=" +
                  lat +
                  "&longi=" +
                  long);
              FormData formData = new FormData.from({
                "uid": mk.uid,
                "location": location,
                "aid": mk.aid,
                "act": mk.act,
                "shiftid": mk.shiftid,
                "refid": mk.refid,
                "latit": lat,
                "longi": long,
                //   "file": new UploadFileInfo(imagei, "image.png"),
              });
              print("5");
              dio
                  .post(globals.path + "saveImage", data: formData)
                  .then((response1) {
                print('response2: ' + response1.toString());
                //     imagei.deleteSync();
                //    imageCache.clear();
                /*getTempImageDirectory();*/
                Map MarkAttMap = json.decode(response1.data);
                print(
                    'MarkAttMap["status"]: ' + MarkAttMap["status"].toString());
                if (MarkAttMap["status"] == 1 || MarkAttMap["status"] == 2) {
                  print("res: " + res.toString());
                  print("issave: " + issave.toString());
                  //     if (issave==true || res==true) {

                  showDialog(
                      context: context,
                      // ignore: deprecated_member_use
                      child: new AlertDialog(
                        content: new Text("Attendance marked successfully !"),
                      ));
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => MyApp()),
                  );
                  if (mounted)
                    setState(() {
                      act1 = act;
                    });
                } else {
                  showDialog(
                      context: context,
                      // ignore: deprecated_member_use
                      child: new AlertDialog(
                        content: new Text(
                            "Selfie was not captured. Please try again."),
                      ));
                  if (mounted)
                    setState(() {
                      act1 = act;
                    });
                }
                /* setState(() {
                        issave=true;
                        print('new issave'+issave.toString());
                      });*/
              }).catchError((err) {
                print(
                    'Exception in setting data in saveImage' + err.toString());
                return true;
              });
            });
          } else {
            showDialog(
                context: context,
                // ignore: deprecated_member_use
                child: new AlertDialog(
                  title: new Text("Warning!"),
                  content: new Text("Location not fetched..."),
                ));
          }
        });
        //*****

      }
      ////////////////////////////////suumitted block/
      ///////////////////////////
    } catch (e) {
      print(e.toString());
      return false;
    }
  }

  @override
  void dispose() {
   // WidgetsBinding.instance.removeObserver(this);

    //workingHoursTimer.cancel();

    super.dispose();
  }

  void showEmailVerificationReminder() async {
    var prefs = await SharedPreferences.getInstance();
    // var createdDate=DateTime.parse(prefs.getString("CreatedDate")??'2019-01-01');
    var createdDate = DateTime.parse('2020-01-11');
    String mail_varified = await prefs.getString("mail_varified") ?? '0';
    var shown = prefs.getBool("EmailVerifacitaionReminderShown") ?? false;
    var isAdmin = prefs.getString("sstatus") ?? '0';
    var currDate = DateTime.now();

    var threeDayAfterCreated =
        new DateTime(createdDate.year, createdDate.month, createdDate.day + 3);

    if (currDate.isAfter(threeDayAfterCreated) &&
        mail_varified == '0' &&
        !shown &&
        isAdmin == '1') {
      cameraChannel.invokeMethod("showNotification", {
        "title": "Please verify your email address for ubiAttendance",
        "description": ""
      });
      prefs.setBool("EmailVerifacitaionReminderShown", true);

      print("Emil verify notification sent");
    }
  }

  void showAddingShiftReminder() async {
    var prefs = await SharedPreferences.getInstance();
    bool employeeAdded = prefs.getBool("EmployeeAdded");
    bool shiftAdded = prefs.getBool("ShiftAdded");

    if (employeeAdded && !shiftAdded) {
      Future.delayed(Duration(seconds: 1), () => tooltiptwo.showtool(context));
    }
  }

  void startWorkingHoursTimer() async {

    /*
    var prefs = await SharedPreferences.getInstance();

    var timeInTime = prefs.get("TimeInTime") ?? '';
    print(timeInTime + "time in time");
    var currentTime = DateTime.now();
    var loggedInTime;
    if (timeInTime.isNotEmpty) {
      loggedInTime = currentTime.difference(DateTime.parse(timeInTime));
      print(loggedInTime.toString() + "logged in time");

      var i = 0;
      workingHoursTimer = Timer.periodic(Duration(seconds: 1), (timer) {
        //print(DateTime.now());
        setState(() {
          var duration = new Duration(seconds: i);
          print("lllllengthg" + ('01:22:23').length.toString());
          //loggedInSince=(DateTime.parse( ('2020-01-01 0'+loggedInTime.toString().split(".")[0]).length==18?'2020-01-01 '+loggedInTime.toString().split(".")[0]:'2020-01-01 0'+loggedInTime.toString().split(".")[0]).add(duration).toString()).split(" ")[1].split(".")[0];
          loggedInSince = (DateTime.parse(
                      (loggedInTime.toString().split(".")[0]).length == 8
                          ? '2020-01-01 ' +
                              loggedInTime.toString().split(".")[0]
                          : '2020-01-01 0' +
                              loggedInTime.toString().split(".")[0])
                  .add(duration)
                  .toString())
              .split(" ")[1]
              .split(".")[0];
          print('testing date' +
              DateTime.parse(
                      "2020-01-01 0" + loggedInTime.toString().split(".")[0])
                  .toString());
          i++;
        });
      });
    }*/
  }

  _onAlertWithCustomContentPressed(context) {
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
        title: "Change Your Password",
        content: Container(
          child: Form(
            key: _formKey,
            child:Column(
              children: <Widget>[
                TextFormField(
//                  inputFormatters: [
//                    WhitelistingTextInputFormatter(RegExp("[a-zA-Z0-9]")),
//                  ],
                  controller: _oldPass,
                  obscureText: true,

                  onFieldSubmitted: (String value) {
                    FocusScope.of(context).requestFocus(__newPass);
                  },
                  decoration: InputDecoration(
                    // ignore: dead_code
                    //errorText: validatePassword ? "dasdasd" : "dasd" ,
                    icon: Icon(Icons.lock),
                    labelText: 'New Password',
                  ),
                  validator: (value){

//                    Pattern pattern = '[a-zA-Z0-9]';
//                    RegExp regex = new RegExp(pattern);
//                    if (!regex.hasMatch(value))
//                      return 'Password should not contain \nany special chararters';



//                    if(value.contains(RegExp("[a-zA-Z0-9]"))) {
//                      print("special");
//                      return "Password should not contain any special chararters";
//                    }

                    if (value.isEmpty || value==null  ) {
                      return 'Password cannot be blank';
                    }
                  },

                  // password should not contain special char
                ),
                TextFormField(
//                  inputFormatters: [
//                    WhitelistingTextInputFormatter(RegExp("[a-zA-Z0-9]")),
//                  ],
                  controller: _newPass,
                  focusNode: __newPass,
                  obscureText: true,
                  decoration: InputDecoration(
                    icon: Icon(Icons.lock),
                    labelText: 'Confirm Password',
                  ),
                  validator: (value) {

//                    Pattern pattern = 'a-zA-Z0-9';
//                    RegExp regex = new RegExp(pattern);
//                    if (!regex.hasMatch(value))
//                      return 'Password should not contain \nany special characters';


                    if (value.isEmpty || value==null  ) {
                      return 'Password cannot be blank';
                    }

//                    Pattern pattern = 'a-zA-Z0-9';
//                    RegExp regex = new RegExp(pattern);
//                    if (!regex.hasMatch(value))
//                      return 'Password should not contain \nany special characters';

                    if(value.length<6 )
                    {
                      return 'Password must contain atleast \n6 characters';
                    }
                    if(value != _oldPass.text){
                      return 'Password did not match!!!';
                    }

                    Pattern pattern = r'^[a-zA-Z0-9]+$';
                    RegExp regex = new RegExp(pattern);
                    if (!regex.hasMatch(value))
                      return 'Password should not contain \nany special characters';
                  },
                ),
              ],
            ),
          ),
        ),

        buttons: [
          DialogButton(
            width:MediaQuery.of(context).size.width * 0.27,
            color: Colors.orangeAccent,
            onPressed: () {
              if (_formKey.currentState.validate()) {
                if (_oldPass.text == _newPass.text) {
                  setState(() {
                    Password_sts = "1";
                  });
                  firstPassword(_oldPass.text, _newPass.text, Password_sts).then((res) {
                    if(res==1) {
                      showInSnackBar("Password changed successfully");
                    }
                  }).catchError((onError){
                    showInSnackBar("Unable to change password");
                    print(onError);
                  });
                }
              }
              if(Password_sts == "1")
                Navigator.of(context, rootNavigator: true).pop();
            },
            child: Text(
              "SUBMIT",
              style: TextStyle(color: Colors.white, fontSize: 20),
            ),
          )
        ]).show();
  }

  showRateUsDialog()async{
    var prefs= await SharedPreferences.getInstance();
    String date = formatter.format(now);
    var twoDaysFromNow = currDate.add(new Duration(days: 2));
    String date1 = formatter.format(twoDaysFromNow);
    dateShowedRatingDialog = date.toString();
    datetoShowRatingDialog = date1.toString();
    prefs.setString('dateShowedRatingDialog', dateShowedRatingDialog);
    prefs.setString('datetoShowRatingDialog', datetoShowRatingDialog);
    prefs.remove("FirstAttendance");
    //prefs.setBool('RateusDialogShown', true);
    return showDialog(context: context, builder:(context) {

      return new AlertDialog(
        title: new Text(
          'Rate your Experience',textAlign: TextAlign.center,
          style: TextStyle(fontSize: 15.0),),
        content: RatingBar(
          initialRating: Rating,
          minRating: 1,
          direction: Axis.horizontal,
          allowHalfRating: true,
          itemCount: 5,
          itemPadding: EdgeInsets.symmetric(horizontal: 2.0),
          itemBuilder: (context, _) => Icon(
            Icons.star,
            color: Colors.amber,
          ),
          onRatingUpdate: (rating) async{
            print(rating);
            prefs.setBool('RateusDialogShown', true);
            if(rating>3.0){
              print("you are good");
              prefs.setBool("FiveStarRating", true);
              setState(() {
                Rating=rating;
                prefs.setDouble('Rating',Rating);
              });
              print(Rating);
              Navigator.pop(context);
              storeRating(empid,orgid,Rating,'');
              await showDialog(
                  context: context,
                  // ignore: deprecated_member_use
                  child: new AlertDialog(
                  //title: new Text("Warning!"),
                  content: Container(
                    height: MediaQuery.of(context).size.height*0.11,
                    child: Column(
                        children: <Widget>[
                       new Text(
                      "Rate us on Play Store"),
                          Padding(
                            padding: const EdgeInsets.only(top:5.0),
                            child: RaisedButton(elevation: 2.0,
                              highlightElevation: 5.0,
                              highlightColor: Colors.transparent,
                              disabledElevation: 0.0,
                              focusColor: Colors.transparent,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(5),
                              ),
                              color: buttoncolor,
                              child: Text('Go',style: TextStyle(color: Colors.white),),
                              onPressed: (){

                                globals.facebookChannel.invokeMethod("logRateEvent");
                                LaunchReview.launch(
                                    androidAppId: "org.ubitech.attendance"
                                );
                              },
                            ),
                          )
                    ]),
                  ),
            ));

            }else{
              print("you are bad");
              setState(() {
                Rating=rating;
                prefs.setDouble('Rating',Rating);
                prefs.remove("FirstAttendance");
              });
              print(Rating);
              Navigator.pop(context);
              Future.delayed(Duration(seconds: 2), () => showfeedbackDialog());
              //showfeedbackDialog();

            }
          },
        )
      );
    }
    );
  }

  showfeedbackDialog()async {
    var prefs= await SharedPreferences.getInstance();
    String date = formatter.format(now);
    var twoDaysFromNow = currDate.add(new Duration(days: 2));
    String date1 = formatter.format(twoDaysFromNow);
    dateShowedFeedbackDialog = date.toString();
    datetoShowFeedbackDialog = date1.toString();
    prefs.setString('dateShowedFeedbackDialog', dateShowedFeedbackDialog);
    prefs.setString('datetoShowFeedbackDialog', datetoShowFeedbackDialog);
    final FocusNode myFocusNodeFeedback = FocusNode();
    TextEditingController feedbackController = new TextEditingController();
    return showDialog(context: context, builder:(context) {

      return new AlertDialog(
          title: new Text(
            'Help us resolve your Query',textAlign: TextAlign.center,
            style: TextStyle(fontSize: 15.0),),
          content: Container(
            height: MediaQuery.of(context).size.height * 0.3,
            child: new Container(

              decoration: new BoxDecoration(
                  color: globals.buttoncolor.withOpacity(0.1),
                  borderRadius: new BorderRadius.only(
                      topLeft: const Radius.circular(0.0),
                      topRight: const Radius.circular(0.0))),


              alignment: Alignment.topCenter,
              child: Wrap(
                children: <Widget>[
                  RatingBar(
                    initialRating: Rating,
                    minRating: 1,
                    direction: Axis.horizontal,
                    allowHalfRating: true,
                    itemCount: 5,
                    itemPadding: EdgeInsets.symmetric(horizontal: 2.0),
                    itemBuilder: (context, _) => Icon(
                      Icons.star,
                      color: Colors.amber,
                    ),
                    onRatingUpdate: (rating) async{
                      print(rating);
//                      String date = formatter.format(now);
//                      var twoDaysFromNow = currDate.add(new Duration(days: 2));
//                      String date1 = formatter.format(twoDaysFromNow);
//                      dateShowedFeedbackDialog = date.toString();
//                      datetoShowFeedbackDialog = date1.toString();
//                      prefs.setString('dateShowedFeedbackDialog', dateShowedFeedbackDialog);
//                      prefs.setString('datetoShowFeedbackDialog', datetoShowFeedbackDialog);
                      if(rating>3.0){
                        print("you are good");
                        prefs.setBool("FiveStarRating", true);
                        setState(() {
                          Rating=rating;
                          prefs.setDouble('Rating',Rating);
                        });
                        print(Rating);
                        storeRating(empid,orgid,Rating,feedbackController.text);

                        /*
                        Navigator.pop(context);
                        await showDialog(
                            context: context,
                            // ignore: deprecated_member_use
                            child: new AlertDialog(
                              //title: new Text("Warning!"),
                              content: new Text(
                                  "Thanks for Rating Us"),
                            ));

                         */
                      }else{
                        print("you are bad");
                        setState(() {
                          Rating=rating;
                          prefs.setDouble('Rating',Rating);
                          prefs.remove("FirstAttendance");
                        });
                        print(Rating);
                        //Navigator.pop(context);
                       // Future.delayed(Duration(seconds: 3), () => showfeedbackDialog());
                        //showfeedbackDialog();

                      }
                    },
                  ),
                  Container(
                    child: Wrap(children: <Widget>[
                      Padding(
                        padding: EdgeInsets.only(
                            top: 20.0, bottom: 20.0, left: 20.0, right: 20.0),
                        child: TextFormField(
                          focusNode: myFocusNodeFeedback,
                          controller: feedbackController,
                          keyboardType: TextInputType.emailAddress,
                          onFieldSubmitted: (String value) {
                            FocusScope.of(context).requestFocus(myFocusNodeFeedback);
                          },
                          style: TextStyle(
                              fontFamily: "WorkSansSemiBold",
                              fontSize: 16.0,
                              height: 1.0,
                              color: Colors.black),
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            fillColor: Colors.white, filled: true,
                            hintText: "Write here",
                            hintStyle: TextStyle(
                                fontFamily: "WorkSansSemiBold", fontSize: 15.0 ),
                          ),

                          maxLines: 3,
                        ),
                      ),
                      Padding(
                          padding: EdgeInsets.only(
                              top: 10.0, bottom: 0.0, left: 75.0, right: 7.0),
                          child:  ButtonTheme(
                            minWidth: 50.0,
                            child: new RaisedButton(
                              child: new Text('Submit',style: TextStyle(color: Colors.white),),
                              elevation: 2.0,
                              highlightElevation: 5.0,
                              highlightColor: Colors.transparent,
                              disabledElevation: 0.0,
                              focusColor: Colors.transparent,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(5),
                              ),

                              color: buttoncolor,

                              onPressed: () async  {
                                print(feedbackController.text);
                                storeRating(empid,orgid,Rating,feedbackController.text);

                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => HomePage()),
                                );
                                /*
                                showDialog(
                                    context: context,
                                    // ignore: deprecated_member_use
                                    child: new AlertDialog(
                                      content: new Text("Thanks for Rating us!"),
                                    ));

                                 */
                                if(Rating>3.0){
                                await showDialog(
                                    context: context,
                                    // ignore: deprecated_member_use
                                    child: new AlertDialog(
                                      //title: new Text("Warning!"),
                                      content: Container(
                                        height: MediaQuery.of(context).size.height*0.11,
                                        child: Column(
                                            children: <Widget>[
                                              new Text(
                                                  "Rate us on Play Store"),
                                              Padding(
                                                padding: const EdgeInsets.only(top:5.0),
                                                child: RaisedButton(elevation: 2.0,
                                                  highlightElevation: 5.0,
                                                  highlightColor: Colors.transparent,
                                                  disabledElevation: 0.0,
                                                  focusColor: Colors.transparent,
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius: BorderRadius.circular(5),
                                                  ),
                                                  color: buttoncolor,
                                                  child: Text('Go',style: TextStyle(color: Colors.white),),
                                                  onPressed: (){

                                                    globals.facebookChannel.invokeMethod("logRateEvent");
                                                    LaunchReview.launch(
                                                        androidAppId: "org.ubitech.attendance"
                                                    );
                                                  },
                                                ),
                                              )
                                            ]),
                                      ),
                                    ));}



                              },),
                            //borderSide: BorderSide(color: Colors.green[700],),

                            shape: new RoundedRectangleBorder(borderRadius: new BorderRadius.circular(0.0),),

                          )


                      )

                    ],),
                  )
                  ,
                ]),
              ),
            ),

      );
    }
    );
  }


//////////////////////////////////////////////////////////////////
}

class BlurryEffect extends StatelessWidget {
  final double opacity;
  final double blurry;
  final Color shade;

  BlurryEffect(this.opacity, this.blurry, this.shade);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: ClipRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: blurry, sigmaY: blurry),
          child: Container(
            width: double.infinity,
            height: double.infinity,
            decoration: BoxDecoration(color: shade.withOpacity(opacity)),
          ),
        ),
      ),
    );
  }
}
