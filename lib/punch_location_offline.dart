// Copyright 2017 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:Shrine/database_models/visits_offline.dart';
import 'package:Shrine/globals.dart' as prefix0;
import 'package:Shrine/services/newservices.dart';
import 'package:Shrine/services/services.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

import 'genericCameraClass.dart';
import 'globals.dart';
import 'home.dart';
import 'loggedOut.dart';
import 'login.dart';
import 'offline_attendance_logs.dart';
import 'offline_home.dart';
import 'punch_location_summary_offline.dart';
import 'services/services.dart';

// This app is a stateful, it tracks the user's current choice.
class PunchLocationOffline extends StatefulWidget {
  @override
  _PunchLocationOffline createState() => _PunchLocationOffline();
}

class _PunchLocationOffline extends State<PunchLocationOffline> {
  static const platform = const MethodChannel('location.spoofing.check');
  // StreamLocation sl = new StreamLocation();
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  final _clientname = TextEditingController();
  /*var _defaultimage =
      new NetworkImage("http://ubiattendance.ubihrm.com/assets/img/avatar.png");*/
  var profileimage;
  bool _checkLoaded = true;
  int _currentIndex = 1;
  String userpwd = "new";
  String newpwd = "new";
  int Is_Delete=0;
  bool _visible = true;
  String location_addr = "";
  String location_addr1 = "";
  String streamlocationaddr = "";
  String admin_sts = '0';
  String mail_varified = '1';
  String lat = "";
  String long = "";
  String act = "";
  String act1 = "";
  int alertdialogcount = 0;
  Timer timer;
  Timer timer1;
  int response;
  bool appAlreadyResumed=false;
  String defaultUserImage="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";

  final Widget removedChild = Center();
  String fname = "",
      lname = "",
      empid = "",
      cid = "",
      email = "",
      status = "",
      orgid = "",
      orgdir = "",
      sstatus = "",
      org_name = "",
      desination = "",
      desinationId = "",
      profile
  ;
  String aid = "";
  String client='0';
  String shiftId = "";
  List<Widget> widgets;

  var FakeLocationStatus=0;
  @override
  void initState() {
    super.initState();
    streamlocationaddr=globalstreamlocationaddr;
    //checkLocationEnabled(context);
    initPlatformState();
    // setLocationAddress();
    // startTimer();
    platform.setMethodCallHandler(_handleMethod);
  }

  bool internetAvailable=false;
  String address="";
  Future<dynamic> _handleMethod(MethodCall call) async {
    switch(call.method) {
      case "navigateToPage":
        navigateToPageAfterNotificationClicked(call.arguments["page"].toString(),context);
        break;
      case "locationAndInternet":
        prefix0.locationThreadUpdatedLocation=true;
        // print(call.arguments["internet"].toString()+"akhakahkahkhakha");
        // Map<String,String> responseMap=call.arguments;
        if(call.arguments["TimeSpoofed"].toString()=="Yes"){
          timeSpoofed=true;

        }

        long=call.arguments["longitude"].toString();
        lat=call.arguments["latitude"].toString();


        print(call.arguments["mocked"].toString());


        setState(() {
          assign_lat=double.parse(lat);
          assign_long=double.parse(long);
          if(call.arguments["mocked"].toString()=="Yes"){
            fakeLocationDetected=true;
          }
          else{
            fakeLocationDetected=false;
          }

          long=call.arguments["longitude"].toString();
          lat=call.arguments["latitude"].toString();

          streamlocationaddr=address;

          location_addr=streamlocationaddr;
          location_addr1=streamlocationaddr;


        });
        break;

        return new Future.value("");
    }
  }

  @override
  void dispose() {
    super.dispose();
    //  timer.cancel();
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
        if (streamlocationaddr == ''&& varCheckNet==0) {
          print('again');
          timer.cancel();
       //   sl.startStreaming(5);
        //  startTimer();
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

  // Platform messages are asynchronous, so we initialize in an async method.
  initPlatformState() async {
    appResumedPausedLogic(context);
    /*await availableCameras();*/
    final prefs = await SharedPreferences.getInstance();

    response = prefs.getInt('response') ?? 0;


    if (response == 1) {
     // Loc lock = new Loc();
     // location_addr = await lock.initPlatformState();
      if(prefs.getInt("OfflineModePermission")!=1){


        //Navigator.popUntil(context, ModalRoute.withName('/'));
        Navigator.pop(context,true);// It worked for me instead of above line

        Navigator.push(context, MaterialPageRoute(builder: (context) => LoginPage()));
      }

      int serverConnected;
      /*
      SystemChannels.lifecycle.setMessageHandler((msg)async{
        if(msg=='AppLifecycleState.resumed' )
        {
          print("------------------------------------ App Resumed-----------------------------");
          serverConnected= await checkConnectionToServer();
          if(serverConnected==1){
            Navigator.push(context, MaterialPageRoute(builder: (context) => HomePage()));
          }
          else{
            Navigator.push(context, MaterialPageRoute(builder: (context) => PunchLocationOffline()));
          }

        }
        if(msg=='AppLifecycleState.paused' ){
          appAlreadyResumed=false;
        }

      });*/
      serverConnected= await checkConnectionToServer();
      if(serverConnected==1){
        Navigator.push(context, MaterialPageRoute(builder: (context) => HomePage()));
      }

      int Id = int.parse(prefs.getString("empid"))??0;
      if(Id==0){
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => LoggedOut()),
        );

      }// //print(act);
      ////print("this is-----> "+act);
      ////print("this is main "+location_addr);
      setState(() {
        // //print("1-"+profile);
        // //print("2-"+_checkLoaded.toString());

        shiftId = prefs.getString('shiftId') ?? "";
        ////print("this is set state "+location_addr1);
        // //print(act1);

      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return getmainhomewidget();
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
    return new WillPopScope(
        onWillPop: () async => true,
        child: new Scaffold(
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
          bottomNavigationBar:
          Hero(
              tag: "bottom",
              child:BottomNavigationBar(
                currentIndex: _currentIndex,
                type: BottomNavigationBarType.fixed,
                backgroundColor: appcolor,
                onTap: (newIndex) {
                  if(newIndex==0){
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => OfflineAttendanceLogs()),
                    );
                    return;
                  }else
                  if(newIndex==1){
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => OfflineHomePage()),
                    );
                    return;
                  }
                  if(newIndex==2){
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => PunchLocationSummaryOffline()),
                    );
                    return;
                  }
                  /*else if(newIndex == 3){
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => Notifications()),
                );

              }*/
                  setState((){_currentIndex = newIndex;});

                }, // this will be set when a new tab is tapped
                items: [

                  BottomNavigationBarItem(
                    icon: new Icon(Icons.art_track,color: Colors.white,),
                    title: new Text('Logs',style: TextStyle(color: Colors.white)),
                  ),
                  BottomNavigationBarItem(
                    icon: new Icon(Icons.home,color: Colors.white,),
                    title: new Text('Home',style: TextStyle(color: Colors.white)),
                  ),
                  BottomNavigationBarItem(
                      icon: Icon(Icons.location_on,color: Colors.white,),
                      title: Text('Visits',style: TextStyle(color: Colors.white),)
                  ),
                  /*  BottomNavigationBarItem(
                  icon: Icon(
                    Icons.notifications
                    ,color: Colors.black54,
                  ),
                  title: Text('Notifications',style: TextStyle(color: Colors.black54))),*/
                ],
              )),


          body: IndexedStack(
            index: _currentIndex,
            children: <Widget>[
              underdevelopment(),
              mainbodyWidget(),
              //(false) ? mainbodyWidget() : refreshPageWidgit(),
              underdevelopment()
            ],
          ),
        ));
  }


  refreshPageWidgit() {
    if (prefix0.assign_lat!=0.0) {
      return new Container(
        child: Center(
          child: new Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    SizedBox(width: 20.0,),
                    Icon(
                      Icons.all_inclusive,
                      color: appcolor,
                    ),
                    Text(
                      " Fetching location, please wait..",
                      style: new TextStyle(fontSize: 20.0, color: appcolor),
                    )
                  ]),
              SizedBox(height: 15.0),
              Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    SizedBox(width: 20.0,),
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
                    ),

                  ]),

              FlatButton(
                child: new Text(
                  "Fetch Location now",
                  style: new TextStyle(
                      color: appcolor, decoration: TextDecoration.underline),
                ),
                onPressed: () {
                  //   sl.startStreaming(5);
                  //   startTimer();
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => OfflineHomePage()),
                  );
                },
              ),
            ],
          ),
        ),
      );
    } else {
      return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
                'Location permission is restricted from app settings, click "Open Settings" to allow permission.',
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
                      "Poor network connection.",
                      style: new TextStyle(fontSize: 20.0, color: appcolor),
                    ),
                  ]),
              SizedBox(height: 5.0),
              FlatButton(
                child: new Text(
                  "Refresh location",
                  style: new TextStyle(
                      color: appcolor, decoration: TextDecoration.underline),
                ),
                onPressed: () {
                  //sl.startStreaming(5);
                  //   startTimer();
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => PunchLocationOffline()),
                  );
                },
              ),
            ]),
      ),
    );
  }

  mainbodyWidget() {
    ////to do check act1 for poor network connection


    return SafeArea(
      child: ListView(
        physics: NeverScrollableScrollPhysics(),
        children: <Widget>[
          Container(
            padding: EdgeInsets.only(top:12.0,bottom: 2.0),
            child:Center(
              child:Text('Punch Visit',
                  style: new TextStyle(fontSize: 22.0,color:appcolor)),
            ),
          ),
          Container(
            // foregroundDecoration: BoxDecoration(color:Colors.red ),
            height: MediaQuery.of(context).size.height * 0.80,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                SizedBox(height: MediaQuery.of(context).size.height * .06),
                //Image.asset('assets/logo.png',height: 150.0,width: 150.0),
                // SizedBox(height: 5.0),
                getClients_DD(),
                SizedBox(height: 35.0),
                SizedBox(height: MediaQuery.of(context).size.height * .01),
                // SizedBox(height: MediaQuery.of(context).size.height*.01),
                (prefix0.assign_lat == 0.0) ? loader() : getMarkAttendanceWidgit(),
              ],
            ),
          ),
        ],
      ),
    );

  }

  getMarkAttendanceWidgit() {
    return Container(
      child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            SizedBox(height: 35.0),
            getwidget(location_addr1),
          ]),
    );

  }
  getwidget(String addrloc) {
    if (addrloc != "Location not fetched.") {
      return Column(children: [
        ButtonTheme(
          minWidth: 120.0,
          height: 45.0,
          child: getVisitInButton(),
        ),
        SizedBox(height: MediaQuery.of(context).size.height * .04),
        Container(
            color: appcolor.withOpacity(0.1),
            height: MediaQuery.of(context).size.height * .15,
            child:
            Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              FlatButton(
                child: new Text('You are at: ' + assign_lat.toString()+','+assign_long.toString(),
                    textAlign: TextAlign.center,
                    style: new TextStyle(fontSize: 14.0)),
                onPressed: () {
                  launchMap(lat, long);

                },
              ),
              new Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    new Text('Location not correct? ',style: TextStyle(color: appcolor),),
                    SizedBox(width: 5.0,),
                    new InkWell(
                      child: new Text(
                        "Refresh location",
                        style: new TextStyle(
                            color: appcolor,
                            decoration: TextDecoration.underline),
                      ),
                      onTap: () {
                        //    startTimer();
                        //sl.startStreaming(5);
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (context) => PunchLocationOffline()),
                        );
                      },
                    )
                  ],
                ),
              ),
            ])),
      ]);
    } else {
      return Column(children: [
        Text(
            'Location permission is restricted from app settings, click "Open Settings" to allow permission.',
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
    return Container(width: 0.0, height: 0.0);
  }

  getVisitInButton() {
    return RaisedButton(
      child: Text('VISIT IN',
          style: new TextStyle(fontSize: 22.0, color: Colors.white)),
      color: buttoncolor,
      onPressed: () async{
        if(_clientname.text.trim()=='') {
          showInSnackBar('Please insert client name first');
          return false;
        }else
          {
            var prefs= await SharedPreferences.getInstance();
            prefix0.showAppInbuiltCamera=prefs.getBool("showAppInbuiltCamera")??true;
            prefix0.showAppInbuiltCamera?saveVisitInOfflineAppCamera(): saveVisitInOffline();
          }

      },
    );
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

  /************************************* for app camera ********************************************/




  saveVisitInOfflineAppCamera() async {
    //sl.startStreaming(5);
    print("inside savevisit in offline method");
    client = _clientname.text;
    final prefs = await SharedPreferences.getInstance();
    int UserId = int.parse(prefs.getString("empid")) ?? 0;
    String Date;
    String OrganizationId = prefs.getString("orgid") ?? "0";
    String PictureBase64;
    int IsSynced;
    String Latitude;
    String Longitude;
    String Time;
    File img = null;
    imageCache.clear();
    var imageRequired = prefs.getInt("VisitImageRequired")??0;
    if (imageRequired == 1) {
      // cameraChannel.invokeMethod("cameraOpened");
      prefix0.globalCameraOpenedStatus=true;
      Navigator.push(context, new MaterialPageRoute(
        builder: (BuildContext context) => new TakePictureScreen(),
        fullscreenDialog: true,)
      )
          .then((img) async {
        prefix0.globalCameraOpenedStatus=false;
        if (img != null) {
          List<int> imageBytes = await img.readAsBytes();
          PictureBase64 = base64.encode(imageBytes);
          //sl.startStreaming(5);

          print("--------------------Image---------------------------");
          print(PictureBase64);

          var now = new DateTime.now();
          var formatter = new DateFormat('yyyy-MM-dd');

          Date = formatter.format(now);
          Time = DateFormat("H:mm:ss").format(now);
          Latitude = assign_lat.toString();
          Longitude = assign_long.toString();
          print("--------------------Lati Longi---------------------------");
          print(Latitude+" ,,  "+Longitude);
          var FakeLocationStatus = 0;
          if (fakeLocationDetected)
            FakeLocationStatus = 1;
          VisitsOffline visitIn = VisitsOffline(
              null,


              UserId,
              Latitude,
              Longitude,
              Time,
              Date,

              "",
              "",
              '00:00:00',
              "",
              client,
              "",
              "",
              OrganizationId,
              0,
              PictureBase64,
              defaultUserImage,
              FakeLocationStatus,
              0,
              timeSpoofed?1:0,
              0
          );
          int savedVisitId = await visitIn.save();
          prefs.setInt("savedVisitId", savedVisitId);

          print("---------------Visit in saved offline---------------");
          // cameraChannel.invokeMethod("cameraClosed");
          img.deleteSync();
          imageCache.clear();
          // ignore: deprecated_member_use
          showDialog(context: context, child:
          new AlertDialog(
            content: new Text(
                "Visit punched successfully. It will be synced when you are online"),
          )
          );
          Navigator.pushReplacement(context,
              new MaterialPageRoute(
                  builder: (BuildContext context) {
                    return new PunchLocationSummaryOffline();
                  }
              )
          );
        }
      });
    }
    else{
      // sl.startStreaming(5);
      print("--------------------Image---------------------------");


      var now = new DateTime.now();
      var formatter = new DateFormat('yyyy-MM-dd');

      Date = formatter.format(now);
      Time = DateFormat("H:mm:ss").format(now);
      Latitude = assign_lat.toString();
      Longitude = assign_long.toString();
      var FakeLocationStatus = 0;
      if (fakeLocationDetected)
        FakeLocationStatus = 1;

      VisitsOffline visitIn = VisitsOffline(
          null, UserId, Latitude, Longitude, Time, Date, "", "", '00:00:00', "", client, "", "", OrganizationId, 0, defaultUserImage, defaultUserImage, FakeLocationStatus, 0, timeSpoofed?1:0, 0
      );
      int savedVisitId= await visitIn.save();
      prefs.setInt("savedVisitId",savedVisitId);


      print("---------------Visit in saved offline---------------");

      // ignore: deprecated_member_use
      showDialog(context: context, child:
      new AlertDialog(
        content: new Text(
            "Visit punched successfully. It will be synced when you are online"),
      )
      );
      Navigator.pushReplacement(context,
          new MaterialPageRoute(
              builder: (BuildContext context) {
                return new PunchLocationSummaryOffline();
              }
          )
      );
    }


  }








  /*************************************************************************************************/




  saveVisitInOffline() async {
    //sl.startStreaming(5);
    print("inside savevisit in offline method");
    client = _clientname.text;
    final prefs = await SharedPreferences.getInstance();
    int UserId = int.parse(prefs.getString("empid")) ?? 0;
    String Date;
    String OrganizationId = prefs.getString("orgid") ?? "0";
    String PictureBase64;
    int IsSynced;
    String Latitude;
    String Longitude;
    String Time;
    File img = null;
    imageCache.clear();
    var imageRequired = prefs.getInt("VisitImageRequired")??0;
    if (imageRequired == 1) {
      cameraChannel.invokeMethod("cameraOpened");
      prefix0.globalCameraOpenedStatus=true;

      ImagePicker.pickImage(
          source: ImageSource.camera, maxWidth: 200.0, maxHeight: 200.0)
          .then((img) async {

        prefix0.globalCameraOpenedStatus=false;
        if (img != null) {
          List<int> imageBytes = await img.readAsBytes();
          PictureBase64 = base64.encode(imageBytes);
          //sl.startStreaming(5);

          print("--------------------Image---------------------------");
          print(PictureBase64);

          var now = new DateTime.now();
          var formatter = new DateFormat('yyyy-MM-dd');

          Date = formatter.format(now);
          Time = DateFormat("H:mm:ss").format(now);
          Latitude = assign_lat.toString();
          Longitude = assign_long.toString();
          print("--------------------Lati Longi---------------------------");
          print(Latitude+" ,,  "+Longitude);
          var FakeLocationStatus = 0;
          if (fakeLocationDetected)
            FakeLocationStatus = 1;
          VisitsOffline visitIn = VisitsOffline(
              null,


              UserId,
              Latitude,
              Longitude,
              Time,
              Date,

              "",
              "",
              '00:00:00',
              "",
              client,
              "",
              "",
              OrganizationId,
              0,
              PictureBase64,
              defaultUserImage,
              FakeLocationStatus,
              0,
              timeSpoofed?1:0,
              0
          );
          int savedVisitId = await visitIn.save();
          prefs.setInt("savedVisitId", savedVisitId);

          print("---------------Visit in saved offline---------------");
          cameraChannel.invokeMethod("cameraClosed");
          img.deleteSync();
          imageCache.clear();
          // ignore: deprecated_member_use
          showDialog(context: context, child:
          new AlertDialog(
            content: new Text(
                "Visit punched successfully. It will be synced when you are online"),
          )
          );
          Navigator.pushReplacement(context,
              new MaterialPageRoute(
                  builder: (BuildContext context) {
                    return new PunchLocationSummaryOffline();
                  }
              )
          );
        }
      });
    }
    else{
      // sl.startStreaming(5);
      print("--------------------Image---------------------------");


      var now = new DateTime.now();
      var formatter = new DateFormat('yyyy-MM-dd');

      Date = formatter.format(now);
      Time = DateFormat("H:mm:ss").format(now);
      Latitude = assign_lat.toString();
      Longitude = assign_long.toString();
      var FakeLocationStatus = 0;
      if (fakeLocationDetected)
        FakeLocationStatus = 1;

      VisitsOffline visitIn = VisitsOffline(
          null, UserId, Latitude, Longitude, Time, Date, "", "", '00:00:00', "", client, "", "", OrganizationId, 0, defaultUserImage, defaultUserImage, FakeLocationStatus, 0, timeSpoofed?1:0, 0
      );
      int savedVisitId= await visitIn.save();
      prefs.setInt("savedVisitId",savedVisitId);


      print("---------------Visit in saved offline---------------");

      // ignore: deprecated_member_use
      showDialog(context: context, child:
      new AlertDialog(
        content: new Text(
            "Visit punched successfully. It will be synced when you are online"),
      )
      );
      Navigator.pushReplacement(context,
          new MaterialPageRoute(
              builder: (BuildContext context) {
                return new PunchLocationSummaryOffline();
              }
          )
      );
    }


  }




/*  saveImage() async {

      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => CameraApp()),
      );

  }*/

  resendVarification() async{
    NewServices ns= new NewServices();
    bool res = await ns.resendVerificationMail(orgid);
    if(res){
      showDialog(
          context: context,
          builder: (context) => AlertDialog(
              content: Row( children:<Widget>[
                Text("Verification link has been sent to \nyour organization's registered \nEmail."),
              ]
              )
          )
      );
    }
  }

////////////////////////////////////////////////////////////
  Widget getClients_DD() {

    return Center(
      child: Form(
        child: TextFormField(
          controller: _clientname,

          keyboardType: TextInputType.text,

          decoration: InputDecoration(
              labelText: 'Client Name',
              prefixIcon: Padding(
                padding: EdgeInsets.all(0.0),
                child: Icon(
                  Icons.supervised_user_circle,
                  color: Colors.grey,
                ), // icon is 48px widget.
              )
          ),

        ),
      ),
    );

  }
////////////////////////////////////////////////////////////
}