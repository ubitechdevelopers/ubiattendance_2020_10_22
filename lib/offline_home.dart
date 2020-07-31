// Copyright 2017 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:Shrine/database_models/attendance_offline.dart';
import 'package:Shrine/genericCameraClass.dart';
import 'package:Shrine/globals.dart' as prefix0;
import 'package:Shrine/home.dart';
import 'package:Shrine/loggedOut.dart';
import 'package:Shrine/login.dart';
import 'package:Shrine/services/services.dart';
import 'package:barcode_scan/barcode_scan.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

import 'database_models/qr_offline.dart';
import 'globals.dart';
import 'offline_attendance_logs.dart';
import 'punch_location_summary_offline.dart';


// This app is a stateful, it tracks the user's current choice.
class OfflineHomePage extends StatefulWidget {
  @override
  _OfflineHomePageState createState() => _OfflineHomePageState();
}

class _OfflineHomePageState extends State<OfflineHomePage>{
  //AppLifecycleState state;
  var _context1;
  // StreamLocation sl = new StreamLocation();
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  /*var _defaultimage =
      new NetworkImage("http://ubiattendance.ubihrm.com/assets/img/avatar.png");*/



  String attendanceFound='Time In Not Marked';
  //bool _visible = true;

  String act = "";
  String act1 = "";
  Timer timer;
  String LocationLatitude='';
  String LocationLongitude='';
  bool timeInClicked=false,timeOutClicked=false;
  bool loading=false;
  Timer timer1;
  // Timer timerrefresh;
  String fname = "",
      lname = "",
      empid = "",
      email = "",
      orgid = "",
      org_name = "",
      latit = "",
      longi = "";
  bool appAlreadyResumed=false;
  String areaStatus='0';
  bool locationFetchedLocal=false;
  bool issave = false;
  List<Widget> widgets;
  bool refreshsts=false;

  bool internetAvailable=false;
  int _currentIndex=1;

  @override
  void initState() {
    print('offline home aintitstate');
    super.initState();
    print("-----------------------Context-----------------------");
    print(context);
    _context1=context;
    //checkLocationEnabled(context);
    // WidgetsBinding.instance.addObserver(this);
    //checknetonpage(context);

    initPlatformState();
    // setLocationAddress();
    // startTimer();
    platform.setMethodCallHandler(_handleMethod);

  }
  static const platform = const MethodChannel('location.spoofing.check');

  String address="";
  Future<dynamic> _handleMethod(MethodCall call) async {
    switch(call.method) {
      case "navigateToPage":
        navigateToPageAfterNotificationClicked(call.arguments["page"].toString(),context);
        break;
      case "locationAndInternet":
      // print(call.arguments["internet"].toString()+"akhakahkahkhakha");
      // Map<String,String> responseMap=call.arguments;
        prefix0.locationThreadUpdatedLocation=true;
        if(call.arguments["TimeSpoofed"].toString()=="Yes"){
          timeSpoofed=true;

        }

        var long=call.arguments["longitude"].toString();
        var lat=call.arguments["latitude"].toString();
        assign_lat=double.parse(lat);
        assign_long=double.parse(long);
        print(call.arguments["mocked"].toString());
        getAreaStatus().then((res) {
          // print('called again');
          if (mounted) {
            setState(() {
              assign_lat=double.parse(lat);
              assign_long=double.parse(long);
              areaStatus = res.toString();
            });
          }
        }).catchError((onError) {
          print('Exception occured in clling function.......');
          print(onError);
        });

        setState(() {

          if(call.arguments["mocked"].toString()=="Yes"){
            fakeLocationDetected=true;
          }
          else{
            fakeLocationDetected=false;
          }



        });
        break;

        return new Future.value("");
    }
  }


  /* void didChangeAppLifecycleState(AppLifecycleState appLifecycleState) {
    setState(() {
      state = appLifecycleState;
      if(state==AppLifecycleState.resumed){
        //print('WidgetsBindingObserver called');
        timerrefresh.cancel();
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
    });
  }*/
/*
  startTimer()  {
    const fiveSec = const Duration(seconds: 5);
    int count = 0;
    // print('called timer');
    timer = new Timer.periodic(fiveSec, (Timer t) async {
      //print("timmer is running");
      count++;
      //print("timer counter" + count.toString());
   //   setLocationAddress();
      if (stopstreamingstatus) {
        t.cancel();
        //print("timer canceled");
      }
/*
      int serverConnected;
      serverConnected= await checkConnectionToServer();
      if(serverConnected==1){
        Navigator.push(context, MaterialPageRoute(builder: (context) => HomePage()));
      }
*/

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
        if (streamlocationaddr == '' && varCheckNet==0) {
          print('again');
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

    cameraChannel.invokeMethod("openLocationDialog");
    final prefs = await SharedPreferences.getInstance();

    DateTime myDatetime = DateTime.parse("2018-07-10 12:04:35");
    print(myDatetime.toIso8601String());

    //  StreamLocation sl = new StreamLocation();

    Future.delayed(const Duration(milliseconds: 3000), () {

// Here you can write your code
      if(mounted)
        setState(() {
          prefix0.locationThreadUpdatedLocation=prefix0.locationThreadUpdatedLocation;
        });

    });

    // Loc lock = new Loc();
    // String location_addr111 = await lock.initPlatformState();
    int off= prefs.getInt("OfflineModePermission")??0;
    //var isAlreadyLoggedIn=prefs.getInt("response")??0;
    if(off!=1){


      //Navigator.popUntil(context, ModalRoute.withName('/'));
      // Navigator.pop(context,true);// It worked for me instead of above line
      Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => LoginPage()), (Route<dynamic> route) => false,);
     // Navigator.push(context, MaterialPageRoute(builder: (context) => LoginPage()));
    }


    int serverConnected;
    /*
    SystemChannels.lifecycle.setMessageHandler((msg)async{
      if(msg=='AppLifecycleState.resumed' )
      {
        print("------------------------------------ App Resumed-----------------------------");
        serverConnected= await checkConnectionToServer();
        if(isAlreadyLoggedIn==1){
          if(serverConnected==1){
            Navigator.push(context, MaterialPageRoute(builder: (context) => HomePage()));
          }
          else{

            Navigator.push(context, MaterialPageRoute(builder: (context) => OfflineHomePage()));

          }
        }


      }
      if(msg=='AppLifecycleState.paused' ){
        appAlreadyResumed=false;
      }

    });*/
    serverConnected= await checkConnectionToServer();
    //if(isAlreadyLoggedIn==1)
    if(serverConnected==1){
      //Navigator.push(context, MaterialPageRoute(builder: (context) => HomePage()));
      Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => HomePage()), (Route<dynamic> route) => false,);
    }
    AttendanceOffline ao = AttendanceOffline.empty();
    int Id = int.parse(prefs.getString("empid")??"0");
    if(Id==0){
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => LoggedOut()),
      );

    }
    var attendanceFound1 = await ao.findCurrentDateAttendance(Id);
    print('--------------------------Attendance Found:'+attendanceFound1.toString());
    if(mounted)
      setState(() {
        fname = prefs.getString('fname') ?? "";

        org_name=prefs.getString("org_name") ?? "";
        attendanceFound=attendanceFound1;
      });
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




  }

  @override
  Widget build(BuildContext context) {
    if(prefix0.assign_long==0.0||prefix0.assign_long==null||!prefix0.locationThreadUpdatedLocation){
      return noLocationWidget();
    }
    else
      return  getmainhomewidget();
    /*return Scaffold(
        appBar: AppBar(
          // Here we take the value from the MyHomePage object that was created by
          // the App.build method, and use it to set our appbar title.
          title: Text('Offline Page'),
        ),
        body: Container(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              verticalDirection: VerticalDirection.down,
              children: <Widget>[
                Text('Offline Page'),


              ],
            )));
*/
/*
    (mail_varified=='0' && alertdialogcount==0 && admin_sts=='1')?Future.delayed(Duration.zero, () => _showAlert(context)):"";

    return (response == 0 || userpwd!=newpwd || Is_Delete!=0) ? new AskRegisterationPage() : getmainhomewidget();
*/
    /* return MaterialApp(
      home: (response==0) ? new AskRegisterationPage() : getmainhomewidget(),
    );*/
  }


  @override
  void dispose() {
    // WidgetsBinding.instance.removeObserver(this);
    super.dispose();
    // timer.cancel();
    /* if(timerrefresh.isActive){
      timerrefresh.cancel();
    }*/
  }

  noLocationWidget(){
    cameraChannel.invokeMethod("openLocationDialog");
    return new WillPopScope(
        onWillPop: ()async => true,
        child: new Scaffold(
            key: _scaffoldKey,
            appBar: AppBar(
              actions: [

                RaisedButton.icon(
                    color:Colors.teal,
                    onPressed: (){
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => OfflineAttendanceLogs()),
                      );
                    },
                    icon: Icon(Icons.assignment,color: Colors.white,),

                    label: Text('Logs',style: new TextStyle(color: Colors.white))),
                /*
            RaisedButton.icon(
            color:Colors.teal,
            onPressed: (){
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => PunchLocationSummaryOffline()),
              );
            },
            icon: Icon(Icons.assignment,color: Colors.white,),

            label: Text('Visits',style: new TextStyle(color: Colors.white)))
*/
              ],
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  new Text(org_name, style: new TextStyle(fontSize: 20.0)),
                ],
              ),
              automaticallyImplyLeading: false,
              backgroundColor: Colors.teal,
              // backgroundColor: Color.fromARGB(255,63,163,128),
            ),
            //bottomSheet: getQuickLinksWidget(),





            /* endDrawer: new AppDrawer(),*/
            body: Scaffold(
                body: new Container(
                  decoration: new BoxDecoration(),
                  child: new Center(
                      child: MergeSemantics(
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: <Widget>[
                              Card(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.stretch,
                                  children: <Widget>[
                                    /*
                                  Padding(
                                      padding: EdgeInsets.fromLTRB(20, 10.0, 20.0, 20.0),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.center,

                                        children: <Widget>[
                                          SizedBox(
                                            height: 20.0,
                                          ),
                                          Text(
                                            "Sorry We can't continue without GPS."
                                             ,style: TextStyle(color: Colors.red,fontSize: 18,),
                                            textAlign: TextAlign.center,

                                          ),
                                          SizedBox(
                                            height: 20.0,
                                          ),
                                          Row(
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              children: <Widget>[
                                                ButtonBar(
                                                  children: <Widget>[
                                                    FlatButton(
                                                      child: Text('Turn On' ,style: TextStyle(color: Colors.green),),
                                                      shape: Border.all(color: Colors.green),
                                                      onPressed: () {
                                                        cameraChannel.invokeMethod("openLocationDialog");
                                                        //openLocationSetting();

                                                      },
                                                    ),
                                                    new RaisedButton(
                                                      child: new Text(
                                                        "Done",
                                                        style: new TextStyle(
                                                          color: Colors.white,
                                                        ),
                                                      ),
                                                      color: Colors.orangeAccent,
                                                      onPressed: () {
                                                        cameraChannel.invokeMethod("startAssistant");
                                                        Navigator.push(
                                                          context,
                                                          MaterialPageRoute(builder: (context) => OfflineHomePage()),
                                                        );
                                                      },
                                                    ),
                                                  ],
                                                ),
                                             ]),

                                        ],
                                      )),*/
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      )),
                ))
        ));
  }

  getmainhomewidget() {
    return new WillPopScope(
        onWillPop: ()async => true,
        child: new Scaffold(
          key: _scaffoldKey,
          appBar: AppBar(
            actions: [
/*
              RaisedButton.icon(
                  color:appcolor,
                  onPressed: (){
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => OfflineAttendanceLogs()),
                    );
                  },
                  icon: Icon(Icons.assignment,color: Colors.white,),

                  label: Text('Logs',style: new TextStyle(color: Colors.white))),*/
              /*
            RaisedButton.icon(
            color:appcolor,
            onPressed: (){
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => PunchLocationSummaryOffline()),
              );
            },
            icon: Icon(Icons.assignment,color: Colors.white,),

            label: Text('Visits',style: new TextStyle(color: Colors.white)))
*/
            ],
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

                  if(newIndex==3){

                    markAttByQROffline(context);
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
                      icon: Icon(Icons.assignment,color: Colors.white,),
                      title: Text('Logs',style: new TextStyle(color: Colors.white)),
                  ),
                  BottomNavigationBarItem(
                    icon: new Icon(Icons.home,color: Colors.white,),
                    title: new Text('Home',style: TextStyle(color: Colors.white)),
                  ),

                  BottomNavigationBarItem(
                      icon: Icon(Icons.location_on,color: Colors.white,),
                      title: Text('Visits',style: TextStyle(color: Colors.white),)
                  ),
                  BottomNavigationBarItem(
                      icon: Icon(Icons.burst_mode,color: Colors.white,),
                      title: Text('Group QR',style: TextStyle(color: Colors.white),)
                  ),


                  /*  BottomNavigationBarItem(
                  icon: Icon(
                    Icons.notifications
                    ,color: Colors.black54,
                  ),
                  title: Text('Notifications',style: TextStyle(color: Colors.black54))),*/
                ],
              ))
          ,


          /* endDrawer: new AppDrawer(),*/
          body:  loading ? loader():getMainOfflineHomeWidget(),
        ));
  }
  markAttByQROffline(BuildContext context){
    showDialog(
        context: context,

        builder: (context) => AlertDialog(

            content: Container(
                height: MediaQuery.of(context).size.height * 0.18,
                child: Column(children: <Widget>[
                  Container(
                      width: MediaQuery.of(context).size.width * 0.6,
                      child: Text(
                          "")),
                  new Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        ButtonBar(
                          children: <Widget>[
                            FlatButton(
                              child: Text('Time In' ,style: TextStyle(color: Colors.green),),
                              shape: Border.all(color: Colors.green),
                              onPressed: ()async {
                                prefix0.globalCameraOpenedStatus=true;
                                timeInPressedTime=DateTime.now();

                                Navigator.of(context, rootNavigator: true)
                                    .pop();
                                var prefs= await SharedPreferences.getInstance();
                                prefix0.showAppInbuiltCamera=prefs.getBool("showAppInbuiltCamera")??true;

                                showAppInbuiltCamera?saveOfflineQrAppCamera(0):saveOfflineQr(0);

                              },
                            ),
                            new RaisedButton(
                              child: new Text(
                                "Time Out",
                                style: new TextStyle(
                                  color: Colors.white,
                                ),
                              ),
                              color: Colors.green,
                              onPressed: ()async {
                                prefix0.globalCameraOpenedStatus=true;
                                timeOutPressedTime=DateTime.now();

                                Navigator.of(context, rootNavigator: true)
                                    .pop();
                                var prefs= await SharedPreferences.getInstance();
                                prefix0.showAppInbuiltCamera=prefs.getBool("showAppInbuiltCamera")??true;

                                showAppInbuiltCamera?saveOfflineQrAppCamera(1):saveOfflineQr(1);
                              },
                            ),
                          ],
                        ),
                      ])
                ]))));
  }


  /********************** for inbuilt caera***************************/


  saveOfflineQrAppCamera(int action) async{
    final prefs = await SharedPreferences.getInstance();
    int UserId = int.parse(prefs.getString("empid")??"0") ?? 0;
    int Action = action; // 0 for time in and 1 for time out
    String Date;
    int OrganizationId = int.parse(prefs.getString("orgid")??"0") ?? 0;
    String PictureBase64;
    int IsSynced;
    String Latitude;
    String Longitude;
    String Time;
    String actionString=(action==0)?"Time In":"Time Out";
    File img = null;
    imageCache.clear();
    prefix0.globalCameraOpenedStatus=true;
    scan().then((onValue){

      print("******************** QR value **************************");
      print(onValue);
      print("******************** QR value **************************");
      //return false;
      if(onValue!='error') {
        prefix0.globalCameraOpenedStatus=false;
        List splitstring = onValue.split("ykks==");
        var UserName=splitstring[0];
        var Password=splitstring[1];

        var imageRequired = prefs.getInt("ImageRequired");
        if (imageRequired == 1) {
          prefix0.globalCameraOpenedStatus=true;
          // cameraChannel.invokeMethod("cameraOpened");
          Navigator.push(context, new MaterialPageRoute(
            builder: (BuildContext context) => new TakePictureScreen(),
            fullscreenDialog: true,)
          ).then((img) async {

            if (img != null) {
              prefix0.globalCameraOpenedStatus=false;
              List<int> imageBytes = await img.readAsBytes();
              PictureBase64 = base64.encode(imageBytes);

              print("--------------------Image---------------------------");
              print(PictureBase64);

              print("--------------------Image---------------------------");

              var now;
              if(action==0){
                now=timeInPressedTime;
              }
              else{
                now=timeOutPressedTime;
              }
              var formatter = new DateFormat('yyyy-MM-dd');

              Date = formatter.format(now);
              Time = DateFormat("H:mm:ss").format(now);


              print("--------------------Date Time---------------------------");
              print(Date + " " + Time);

              print("--------------------Date Time---------------------------");

              Latitude = await assign_lat.toString();
              Longitude = await assign_long.toString();
              var FakeLocationStatus=0;
              if(fakeLocationDetected)
                FakeLocationStatus=1;

              // print(lat+"lalalal"+long+location_addr);

              IsSynced = 0;


              QROffline qrOffline = new QROffline(
                  null,
                  UserId,
                  Action,
                  Date,
                  OrganizationId,
                  PictureBase64,
                  IsSynced,
                  Latitude,
                  Longitude,
                  Time,
                  UserName,
                  Password,
                  FakeLocationStatus,
                  timeSpoofed?1:0
              );
              qrOffline.save();
              timeInPressedTime=null;
              timeOutPressedTime=null;
              // cameraChannel.invokeMethod("cameraClosed");
              img.deleteSync();
              imageCache.clear();

              /*
              SimpleDialog(
                children: <Widget>[
                  Text( actionString+" is marked. It will be synced when you are online"),
                ],
              );
              Scaffold.of(context)
                  .showSnackBar(
                  SnackBar(content: Text("Attendance marked")));
              */
              /*
               */
              Future.delayed(const Duration(milliseconds: 2000), () {
                // ignore: deprecated_member_use
                showDialog(context: context, child:
                new AlertDialog(
                  content: new Text(
                      actionString +
                          " is marked. It will be synced when you are online"),
                )
                );
                setState(() {
                  prefix0.locationThreadUpdatedLocation=prefix0.locationThreadUpdatedLocation;
                });
              });
              print("-----------------------Context-----------------------");
              print(context);

              Navigator
                  .of(context)
                  .push(
                MaterialPageRoute(builder: (context) => OfflineHomePage()),
              );




            }
            else {
              prefix0.globalCameraOpenedStatus=false;
              setState(() {
                // timeInClicked = false;
                // timeOutClicked = false;
              });
            }
          });
        }
        else {
          var now;
          if(action==0){
            now=timeInPressedTime;
          }
          else{
            now=timeOutPressedTime;
          }
          var formatter = new DateFormat('yyyy-MM-dd');

          Date = formatter.format(now);
          Time = DateFormat("H:mm:ss").format(now);


          print("--------------------Date Time---------------------------");
          print(Date + " " + Time);

          print("--------------------Date Time---------------------------");

          Latitude = assign_lat.toString();
          Longitude = assign_long.toString();

          // print(lat+"lalalal"+long+location_addr);

          IsSynced = 0;
          var FakeLocationStatus=0;
          if(fakeLocationDetected)
            FakeLocationStatus=1;
          QROffline qrOffline = new QROffline(
              null,
              UserId,
              Action,
              Date,
              OrganizationId,
              '',
              IsSynced,
              Latitude,
              Longitude,
              Time,
              UserName,
              Password,
              FakeLocationStatus,
              timeSpoofed?1:0
          );
          qrOffline.save();

          timeInPressedTime=null;
          timeOutPressedTime=null;
          Future.delayed(const Duration(milliseconds: 2000), () {
            // ignore: deprecated_member_use
            showDialog(context: context, child:
            new AlertDialog(
              content: new Text(
                  actionString +
                      " is marked. It will be synced when you are online"),
            )
            );
            setState(() {
              prefix0.locationThreadUpdatedLocation=prefix0.locationThreadUpdatedLocation;
            });
          });
          print("-----------------------Context-----------------------");
          print(context);

          Navigator
              .of(context)
              .push(
            MaterialPageRoute(builder: (context) => OfflineHomePage()),
          );



/*
          showDialog(context: context, child:
          new AlertDialog(
            content: new Text(
                "Attendance marked successfully and will be synced when you get connected!"),
          )
          );


          print("-----------------------Context-----------------------");
          print(context);
          Navigator
              .of(context)
              .push(
            MaterialPageRoute(builder: (context) => OfflineHomePage()),
          );
  */      }

      }else {
        prefix0.globalCameraOpenedStatus=false;
        setState(() {
          // loader = false;
        });
      }
    });

  }











  /*******************************************************************/









  saveOfflineQr(int action) async{
    final prefs = await SharedPreferences.getInstance();
    int UserId = int.parse(prefs.getString("empid")??"0") ?? 0;
    int Action = action; // 0 for time in and 1 for time out
    String Date;
    int OrganizationId = int.parse(prefs.getString("orgid")??"0") ?? 0;
    String PictureBase64;
    int IsSynced;
    String Latitude;
    String Longitude;
    String Time;
    String actionString=(action==0)?"Time In":"Time Out";
    File img = null;
    imageCache.clear();
    prefix0.globalCameraOpenedStatus=true;
    scan().then((onValue){

      print("******************** QR value **************************");
      print(onValue);
      print("******************** QR value **************************");
      //return false;
      if(onValue!='error') {
        prefix0.globalCameraOpenedStatus=false;
        List splitstring = onValue.split("ykks==");
        var UserName=splitstring[0];
        var Password=splitstring[1];

        var imageRequired = prefs.getInt("ImageRequired");
        if (imageRequired == 1) {
          prefix0.globalCameraOpenedStatus=true;
          cameraChannel.invokeMethod("cameraOpened");

          ImagePicker.pickImage(
              source: ImageSource.camera, maxWidth: 200.0, maxHeight: 200.0)
              .then((img) async {

            if (img != null) {
              prefix0.globalCameraOpenedStatus=false;
              List<int> imageBytes = await img.readAsBytes();
              PictureBase64 = base64.encode(imageBytes);

              print("--------------------Image---------------------------");
              print(PictureBase64);

              print("--------------------Image---------------------------");

              var now;
              if(action==0){
                now=timeInPressedTime;
              }
              else{
                now=timeOutPressedTime;
              }
              var formatter = new DateFormat('yyyy-MM-dd');

              Date = formatter.format(now);
              Time = DateFormat("H:mm:ss").format(now);


              print("--------------------Date Time---------------------------");
              print(Date + " " + Time);

              print("--------------------Date Time---------------------------");

              Latitude = await assign_lat.toString();
              Longitude = await assign_long.toString();
              var FakeLocationStatus=0;
              if(fakeLocationDetected)
                FakeLocationStatus=1;

              // print(lat+"lalalal"+long+location_addr);

              IsSynced = 0;


              QROffline qrOffline = new QROffline(
                  null,
                  UserId,
                  Action,
                  Date,
                  OrganizationId,
                  PictureBase64,
                  IsSynced,
                  Latitude,
                  Longitude,
                  Time,
                  UserName,
                  Password,
                  FakeLocationStatus,
                  timeSpoofed?1:0
              );
              qrOffline.save();
              timeInPressedTime=null;
              timeOutPressedTime=null;
              cameraChannel.invokeMethod("cameraClosed");
              img.deleteSync();
              imageCache.clear();

              /*
              SimpleDialog(
                children: <Widget>[
                  Text( actionString+" is marked. It will be synced when you are online"),
                ],
              );
              Scaffold.of(context)
                  .showSnackBar(
                  SnackBar(content: Text("Attendance marked")));
              */
              /*
               */
              Future.delayed(const Duration(milliseconds: 2000), () {
                // ignore: deprecated_member_use
                showDialog(context: context, child:
                new AlertDialog(
                  content: new Text(
                      actionString +
                          " is marked. It will be synced when you are online"),
                )
                );
                setState(() {
                  prefix0.locationThreadUpdatedLocation=prefix0.locationThreadUpdatedLocation;
                });
              });
              print("-----------------------Context-----------------------");
              print(context);

              Navigator
                  .of(context)
                  .push(
                MaterialPageRoute(builder: (context) => OfflineHomePage()),
              );




            }
            else {
              prefix0.globalCameraOpenedStatus=false;
              setState(() {
                // timeInClicked = false;
                // timeOutClicked = false;
              });
            }
          });
        }
        else {
          var now;
          if(action==0){
            now=timeInPressedTime;
          }
          else{
            now=timeOutPressedTime;
          }
          var formatter = new DateFormat('yyyy-MM-dd');

          Date = formatter.format(now);
          Time = DateFormat("H:mm:ss").format(now);


          print("--------------------Date Time---------------------------");
          print(Date + " " + Time);

          print("--------------------Date Time---------------------------");

          Latitude = assign_lat.toString();
          Longitude = assign_long.toString();

          // print(lat+"lalalal"+long+location_addr);

          IsSynced = 0;
          var FakeLocationStatus=0;
          if(fakeLocationDetected)
            FakeLocationStatus=1;


          QROffline qrOffline = new QROffline(
              null,
              UserId,
              Action,
              Date,
              OrganizationId,
              '',
              IsSynced,
              Latitude,
              Longitude,
              Time,
              UserName,
              Password,
              FakeLocationStatus,
              timeSpoofed?1:0
          );
          qrOffline.save();

          timeInPressedTime=null;
          timeOutPressedTime=null;
          Future.delayed(const Duration(milliseconds: 2000), () {
            // ignore: deprecated_member_use
            showDialog(context: context, child:
            new AlertDialog(
              content: new Text(
                  actionString +
                      " is marked. It will be synced when you are online"),
            )
            );
            setState(() {
              prefix0.locationThreadUpdatedLocation=prefix0.locationThreadUpdatedLocation;
            });
          });
          print("-----------------------Context-----------------------");
          print(context);

          Navigator
              .of(context)
              .push(
            MaterialPageRoute(builder: (context) => OfflineHomePage()),
          );



/*
          showDialog(context: context, child:
          new AlertDialog(
            content: new Text(
                "Attendance marked successfully and will be synced when you get connected!"),
          )
          );


          print("-----------------------Context-----------------------");
          print(context);
          Navigator
              .of(context)
              .push(
            MaterialPageRoute(builder: (context) => OfflineHomePage()),
          );
  */      }

      }else {
        prefix0.globalCameraOpenedStatus=false;
        setState(() {
          // loader = false;
        });
      }
    });

  }
  String barcode = "";
  Future scan() async {
    try {
      String barcode = await BarcodeScanner.scan();
      setState(() => this.barcode = barcode);
      return barcode;
    } on PlatformException catch (e) {
      if (e.code == BarcodeScanner.CameraAccessDenied) {
        setState(() {
          this.barcode = 'The user did not grant the camera permission!';
        });
        return "pemission denied";
      } else {
        setState(() => this.barcode = 'Unknown error: $e');
        return "error";
      }
    } on FormatException{
      setState(() => this.barcode = 'null (User returned using the "back"-button before scanning anything. Result)');
      return "error";
    } catch (e) {
      setState(() => this.barcode = 'Unknown error: $e');
      return "error";
    }
  }

  getMainOfflineHomeWidget(){
    return SafeArea(
      child: ListView(
        physics: NeverScrollableScrollPhysics(),
        children: <Widget>[
          Container(
            // foregroundDecoration: BoxDecoration(color:Colors.red ),
            height: MediaQuery.of(context).size.height * 0.80,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                SizedBox(height: MediaQuery.of(context).size.height * .02),

                SizedBox(height: MediaQuery.of(context).size.height * .01),

                //Image.asset('assets/logo.png',height: 150.0,width: 150.0),
                // SizedBox(height: 5.0),
                Text("Offline Attendance", style: new TextStyle(fontSize: 26.0,color: appcolor, )),
                SizedBox(height: MediaQuery.of(context).size.height * .03),
                Text("Hi " + fname, style: new TextStyle(fontSize: 22.0)),

                SizedBox(height: MediaQuery.of(context).size.height * .0),
                Image.asset('assets/icons8-offline-100.png', height: 150.0, width: 150.0),
                // SizedBox(height: MediaQuery.of(context).size.height*.01),
                getOfflineWidgit(),
              ],
            ),
          ),
        ],
      ),
    );
  }
  getOfflineWidgit() {

    if (assign_long!=null||!assign_long.isNaN) {
      return Column(children: [
        ButtonTheme(
          minWidth: 120.0,
          height: 45.0,
          child: getOfflineTimeInOutButton(),
        ),
        SizedBox(height: MediaQuery.of(context).size.height * .06),
        if(attendanceFound!='Both Marked')
          Container(
            color: appcolor.withOpacity(0.1),
            height: MediaQuery.of(context).size.height * .15,
            child:
            Column(
                crossAxisAlignment: CrossAxisAlignment.center,

                children: [
                  FlatButton(
                    child: new Text('You are at: ' + assign_lat.toString()+','+assign_long.toString(),
                        textAlign: TextAlign.center,
                        style: new TextStyle(fontSize: 14.0)),
                    onPressed: () {
                      launchMap(assign_lat.toString(), assign_long.toString());
                      /* Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => HomePage()),
                  );*/
                    },
                  ),
                  new Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        /* new Text('Want to go online? ',style: TextStyle(color: Colors.teal),),
                      SizedBox(width: 5.0,),*/
                        new InkWell(
                          child: new Text(
                            "Go Online", // main  widget
                            style: new TextStyle(
                                color: appcolor,
                                decoration: TextDecoration.underline),
                          ),

                          onTap: () {
                            goOnline();
                          },
                        )
                      ],
                    ),
                  ),
                  SizedBox(height: 5.0,),

                ]),)
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
  }

  goOnline() async
  {
    int serverConnected;
    setState(() {
      loading=true;
    });
    checkConnectionToServer().then((serverConnected){

      if(serverConnected==1){
        //Navigator.of(context).popUntil(ModalRoute.withName("/home"));
        setState(() {
          loading=false;
        });

        Navigator.pushAndRemoveUntil(context,MaterialPageRoute(builder: (context) => HomePage()), (Route<dynamic> route) => false,);

      }
      else{
        setState(() {
          loading=false;
        });
        // ignore: deprecated_member_use
        showDialog(context: context, child:
        new AlertDialog(
          content: new Text("Sorry You are not connected to internet!"),
        )
        );
      }
    });

  }

  getOfflineTimeInButton()  {
    // for disabled time in

    if (attendanceFound=="Time In Marked"){
      return ButtonTheme(
        minWidth: 130.0,
        height: 50.0,


        child: RaisedButton(
          onPressed: () {},
          child: Text('TIME IN',
              style: new TextStyle(fontSize: 22.0,)),
          color: Colors.grey,
        ),
      );
    }
    else {

// for enabled time in
      return ButtonTheme(
          minWidth: 130.0,
          height: 50.0,

          child: RaisedButton(
            child: Text('TIME IN',
                style: new TextStyle(fontSize: 22.0, color: Colors.green)),
            shape: Border.all(color: Colors.green),
            color: timeInClicked?Colors.grey:Colors.white,
            onPressed: ()async {
              var prefs= await SharedPreferences.getInstance();
              prefix0.showAppInbuiltCamera=prefs.getBool("showAppInbuiltCamera")??true;

              if(prefix0.showAppInbuiltCamera)
              {
                globalCameraOpenedStatus=true;
                timeInPressedTime=DateTime.now();
                if(!timeInClicked){
                  saveOfflineAttendanceAppCamera(0);
                  setState(() {
                    timeInClicked =true;
                  });
                }
              }
              else{
                globalCameraOpenedStatus=true;
                timeInPressedTime=DateTime.now();
                if(!timeInClicked){
                  saveOfflineAttendance(0);
                  setState(() {
                    timeInClicked =true;
                  });
                }

              }

              // //print("Time out button pressed");
              //    saveImage();
              //Navigator.pushNamed(context, '/home');
            },
          ));
    }

  }

  getOfflineTimeInOutButton(){
    // if (act1 == 'TimeIn') {
    if(attendanceFound=='Both Marked'){
      return getAlreadyMarkedWidgit();
    }
    else {
      return Column(
        children: <Widget>[
          new ButtonTheme.bar(
            child: new ButtonBar(
              alignment: MainAxisAlignment.center,
              children: <Widget>[
                getOfflineTimeInButton(),
                ButtonTheme(
                    minWidth: 130.0,
                    height: 50.0,

                    child: RaisedButton(
                      child: Text('TIME OUT',
                          style: new TextStyle(fontSize: 22.0, color: Colors.white)),
                      color: timeOutClicked?Colors.grey:Colors.green,
                      onPressed: () async{
                        var prefs= await SharedPreferences.getInstance();
                        prefix0.showAppInbuiltCamera=prefs.getBool("showAppInbuiltCamera")??true;

                        if(prefix0.showAppInbuiltCamera)
                        {
                          prefix0.globalCameraOpenedStatus=true;
                          timeOutPressedTime=DateTime.now();
                          if(!timeOutClicked){
                            saveOfflineAttendanceAppCamera(1);
                            setState(() {
                              timeOutClicked=true;
                            });
                          }
                        }
                        else
                        {
                          prefix0.globalCameraOpenedStatus=true;
                          timeOutPressedTime=DateTime.now();
                          if(!timeOutClicked){
                            saveOfflineAttendance(1);
                            setState(() {
                              timeOutClicked=true;
                            });
                          }
                        }


                      },
                    )
                ),
              ],
            ),
          ),
          //
          // ,
          /*
          ButtonTheme(
              minWidth: 130.0,
              height: 50.0,

              child: RaisedButton(
                child: Text('TIME OUT',
                    style: new TextStyle(fontSize: 22.0, color: Colors.white)),
                color: timeOutClicked?Colors.grey:Colors.orangeAccent,
                onPressed: () {
                  if(!timeOutClicked){
                    saveOfflineAttendance(1);
                    setState(() {
                      timeOutClicked=true;
                    });
                  }
                  // //print("Time out button pressed");
                  //    saveImage();
                  //Navigator.pushNamed(context, '/home');
                },
              )
          ), SizedBox(height: MediaQuery
              .of(context)
              .size
              .height * .01),*/
          /*ButtonTheme(
              minWidth: 130.0,
              height: 50.0,

              child: RaisedButton(
                child: Text('LOGOUT',
                    style: new TextStyle(fontSize: 22.0, color: Colors.white)),
                color: Colors.orangeAccent,
                onPressed: () {
                  logout();
                  // //print("Time out button pressed");
                  //    saveImage();
                  //Navigator.pushNamed(context, '/home');
                },
              )
          )*/
        ],
      );

      /* return RaisedButton(
        child: Text('TIME IN',
            style: new TextStyle(fontSize: 22.0, color: Colors.white)),
        color: Colors.orangeAccent,
        onPressed: () {
          // //print("Time out button pressed");
      //    saveImage();
          //Navigator.pushNamed(context, '/home');
        },
      );*/
      // }
    }
  }

  logout() async{
    final prefs = await SharedPreferences.getInstance();
    prefs.remove('response');
    prefs.remove('fname');
    prefs.remove('lname');
    prefs.remove('empid');
    prefs.remove('email');
    prefs.remove('status');
    prefs.remove('sstatus');
    prefs.remove('orgid');
    prefs.remove('orgdir');
    prefs.remove('sstatus');
    prefs.remove('org_name');
    prefs.remove('destination');
    prefs.remove('profile');
    prefs.remove('latit');
    prefs.remove('longi');
    prefs.remove('aid');
    prefs.remove('shiftId');
    prefs.remove('OfflineModePermission');
    prefs.remove('ImageRequired');
    department_permission = 0;
    designation_permission = 0;
    leave_permission = 0;
    shift_permission = 0;
    timeoff_permission = 0;
    punchlocation_permission = 0;
    employee_permission = 0;
    permission_module_permission = 0;
    report_permission = 0;
    Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => LoginPage()), (Route<dynamic> route) => false,);
    /*
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => LoginPage()),
    );*/
    /*
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => LoginPage()), (Route<dynamic> route) => false,
    );*/
    //Navigator.pushNamed(context, '/home');
    // Navigator.pushNamed(context, '/home');
  }

  //////////////////////////////////////////////////////////////////
  deleteLastTimeIn() async{
    AttendanceOffline a=AttendanceOffline.empty();
    final prefs=await SharedPreferences.getInstance();

    int deleted=await a.deleteCurrentDateTimeIn(int.parse(prefs.getString("empid"))??0);

  }
  deleteLastTimeOut() async{
    AttendanceOffline a=AttendanceOffline.empty();
    final prefs=await SharedPreferences.getInstance();

    int deleted=await a.deleteCurrentDateTimeOut(int.parse(prefs.getString("empid"))??0);

  }

  void timeInAlreadyMarkedDialog() {
    // flutter defined function
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return AlertDialog(
          title: new Text("You have already punched Time In."),
          content: new Text("Do you want to delete the previous Time In?"),
          actions: <Widget>[
            // usually buttons at the bottom of the dialog
            new FlatButton(
              child: new Text("Yes"),
              onPressed: () {
                deleteLastTimeIn();
                Navigator.of(context).push(
                    new MaterialPageRoute(
                        builder: (BuildContext context) {
                          return new OfflineHomePage();
                        }
                    )
                );

              },
            ),
            new FlatButton(
              child: new Text("No"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }


  void timeOutMarkedPreviously() {
    // flutter defined function
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return AlertDialog(
          title: new Text("You have already marked Time Out."),
          content: new Text("Do you want to delete the previous Time Out?"),
          actions: <Widget>[
            // usually buttons at the bottom of the dialog
            new FlatButton(
              child: new Text("Yes"),
              onPressed: () {

                deleteLastTimeOut();
                Navigator.of(context).push(
                    new MaterialPageRoute(
                        builder: (BuildContext context) {
                          return new OfflineHomePage();
                        }
                    )
                );
              },
            ),
            new FlatButton(
              child: new Text("No"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
  void timeOutAlreadyMarked() {
    // flutter defined function
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return AlertDialog(
          title: new Text("You have already punched Time Out."),
          content: new Text("Do you want to delete the previous Time Out?"),
          actions: <Widget>[
            // usually buttons at the bottom of the dialog
            new FlatButton(
              child: new Text("Yes"),
              onPressed: () {
                deleteLastTimeOut();
                Navigator.of(context).push(
                    new MaterialPageRoute(
                        builder: (BuildContext context) {
                          return new OfflineHomePage();
                        }
                    )
                );
              },
            ),
            new FlatButton(
              child: new Text("No"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
  startTimeOutNotificationWorker() async{
    final prefs = await SharedPreferences.getInstance();
    String ShiftTimeOut=await prefs.getString("ShiftTimeOut")??"18:00:00";

    cameraChannel.invokeMethod("startTimeOutNotificationWorker",{"ShiftTimeOut":ShiftTimeOut});
  }

  /************************************ for app camera*******************************************/


  saveOfflineAttendanceAppCamera(int actionPressed) async {

    if(actionPressed==0&&showTimeOutNotification){
      startTimeOutNotificationWorker();
    }

    final prefs = await SharedPreferences.getInstance();
    int UserId = int.parse(prefs.getString("empid")) ?? 0;
    int Action = actionPressed; // 0 for time in and 1 for time out
    String Date;
    int OrganizationId = int.parse(prefs.getString("orgid")) ?? 0;
    String PictureBase64;
    int IsSynced;
    String Latitude;
    String Longitude;
    String Time;
    String actionString=(actionPressed==0)?"Time In":"Time Out";
    File img = null;
    imageCache.clear();
    //img = await ImagePicker.pickImage(source: ImageSource.camera,maxWidth: 250.0, maxHeight: 250.0);
    if(actionPressed==0 && attendanceFound=="Time In Marked"){
      timeInAlreadyMarkedDialog();
    }
    else if(actionPressed==0 && attendanceFound=="Time In Marked"){
      //Show dialog for time out marked before time in do you want to discard previous time out
      timeOutMarkedPreviously();
    }
    else if(actionPressed==1 && (attendanceFound=="Only Time Out Marked"||attendanceFound=="Both Marked")){
      // Show dialog for time out already marked
      timeOutAlreadyMarked();
    }
    else{
      var imageRequired = prefs.getInt("ImageRequired");
      if (imageRequired == 1) {
        print("-----------------------Context before-----------------------");
        print(context);
        // cameraChannel.invokeMethod("cameraOpened");
        Navigator.push(context, new MaterialPageRoute(
          builder: (BuildContext context) => new TakePictureScreen(),
          fullscreenDialog: true,)
        )
            .then((img) async {
          prefix0.globalCameraOpenedStatus=false;
          if (img != null) {

            List<int> imageBytes = await img.readAsBytes();
            PictureBase64 = base64.encode(imageBytes);
            /* sl.startStreaming(5);
            if (list != null && list.length > 0) {
              lat = list[list.length - 1].latitude.toString();
              long = list[list.length - 1].longitude.toString();
              if (streamlocationaddr == '') {
                streamlocationaddr = lat + ", " + long;
              }
            }
            if (streamlocationaddr == '' && varCheckNet==0) {
              print('again');
              sl.startStreaming(5);
              startTimer();
            }
            */
            print("--------------------Image---------------------------");
            print(PictureBase64);

            print("--------------------Image---------------------------");

            var now;
            if(actionPressed==0){
              now=timeInPressedTime;
            }
            else{
              now=timeOutPressedTime;
            }
            var formatter = new DateFormat('yyyy-MM-dd');

            Date = formatter.format(now);
            Time = DateFormat("H:mm:ss").format(now);


            print("--------------------Date Time---------------------------");
            print(Date + " " + Time);

            print("--------------------Date Time---------------------------");

            Latitude = await assign_lat.toString();
            Longitude = await assign_long.toString();
            var FakeLocationStatus=0;
            if(fakeLocationDetected)
              FakeLocationStatus=1;

            // print(lat+"lalalal"+long+location_addr);

            IsSynced = 0;


            AttendanceOffline attendanceOffline = new AttendanceOffline(
                null,
                UserId,
                Action,
                Date,
                OrganizationId,
                PictureBase64,
                IsSynced,
                Latitude,
                Longitude,
                Time,
                FakeLocationStatus,
                timeSpoofed?1:0
            );
            attendanceOffline.save();
            timeInPressedTime=null;
            timeOutPressedTime=null;
            // cameraChannel.invokeMethod("cameraClosed");
            img.deleteSync();
            imageCache.clear();

            // ignore: deprecated_member_use
            showDialog(context: context, child:
            new AlertDialog(
              content: new Text(
                  actionString+" is marked. It will be synced when you are online"),
            )
            );
            print("-----------------------Context-----------------------");
            print(context);
            Navigator

                .push(context,
              MaterialPageRoute(builder: (context) => OfflineHomePage()),
            );
          }
          else {
            setState(() {
              timeInClicked = false;
              timeOutClicked = false;
            });
          }
        });
      }
      else {
        var now;
        if(actionPressed==0){
          now=timeInPressedTime;
        }
        else{
          now=timeOutPressedTime;
        }
        var formatter = new DateFormat('yyyy-MM-dd');

        Date = formatter.format(now);
        Time = DateFormat("H:mm:ss").format(now);


        print("--------------------Date Time---------------------------");
        print(Date + " " + Time);

        print("--------------------Date Time---------------------------");

        Latitude = await assign_lat.toString();
        Longitude = await assign_long.toString();

        // print(lat+"lalalal"+long+location_addr);

        IsSynced = 0;
        var FakeLocationStatus=0;
        if(fakeLocationDetected)
          FakeLocationStatus=1;


        AttendanceOffline attendanceOffline = new AttendanceOffline(
            null,
            UserId,
            Action,
            Date,
            OrganizationId,
            '',
            IsSynced,
            Latitude,
            Longitude,
            Time,
            FakeLocationStatus,
            timeSpoofed?1:0
        );
        attendanceOffline.save();

        timeInPressedTime=null;
        timeOutPressedTime=null;

        // ignore: deprecated_member_use
        showDialog(context: context, child:
        new AlertDialog(
          content: new Text(
              "Attendance marked successfully and will be synced when you get connected!"),
        )
        );
        print("-----------------------Context-----------------------");
        print(context);
        Navigator

            .push(context,
          MaterialPageRoute(builder: (context) => OfflineHomePage()),
        );
      }

    }

  }




  /**********************************************************************************************/

  saveOfflineAttendance(int actionPressed) async {

    if(actionPressed==0&&showTimeOutNotification){
      startTimeOutNotificationWorker();
    }

    final prefs = await SharedPreferences.getInstance();
    int UserId = int.parse(prefs.getString("empid")) ?? 0;
    int Action = actionPressed; // 0 for time in and 1 for time out
    String Date;
    int OrganizationId = int.parse(prefs.getString("orgid")) ?? 0;
    String PictureBase64;
    int IsSynced;
    String Latitude;
    String Longitude;
    String Time;
    String actionString=(actionPressed==0)?"Time In":"Time Out";
    File img = null;
    imageCache.clear();
    //img = await ImagePicker.pickImage(source: ImageSource.camera,maxWidth: 250.0, maxHeight: 250.0);
    if(actionPressed==0 && attendanceFound=="Time In Marked"){
      timeInAlreadyMarkedDialog();
    }
    else if(actionPressed==0 && attendanceFound=="Time In Marked"){
      //Show dialog for time out marked before time in do you want to discard previous time out
      timeOutMarkedPreviously();
    }
    else if(actionPressed==1 && (attendanceFound=="Only Time Out Marked"||attendanceFound=="Both Marked")){
      // Show dialog for time out already marked
      timeOutAlreadyMarked();
    }
    else{
      var imageRequired = prefs.getInt("ImageRequired");
      if (imageRequired == 1) {
        print("-----------------------Context before-----------------------");
        print(context);
        cameraChannel.invokeMethod("cameraOpened");

        ImagePicker.pickImage(
            source: ImageSource.camera, maxWidth: 200.0, maxHeight: 200.0)
            .then((img) async {

          prefix0.globalCameraOpenedStatus=false;
          if (img != null) {

            List<int> imageBytes = await img.readAsBytes();
            PictureBase64 = base64.encode(imageBytes);
            /* sl.startStreaming(5);
            if (list != null && list.length > 0) {
              lat = list[list.length - 1].latitude.toString();
              long = list[list.length - 1].longitude.toString();
              if (streamlocationaddr == '') {
                streamlocationaddr = lat + ", " + long;
              }
            }
            if (streamlocationaddr == '' && varCheckNet==0) {
              print('again');
              sl.startStreaming(5);
              startTimer();
            }
            */
            print("--------------------Image---------------------------");
            print(PictureBase64);

            print("--------------------Image---------------------------");

            var now;
            if(actionPressed==0){
              now=timeInPressedTime;
            }
            else{
              now=timeOutPressedTime;
            }
            var formatter = new DateFormat('yyyy-MM-dd');

            Date = formatter.format(now);
            Time = DateFormat("H:mm:ss").format(now);


            print("--------------------Date Time---------------------------");
            print(Date + " " + Time);

            print("--------------------Date Time---------------------------");

            Latitude = await assign_lat.toString();
            Longitude = await assign_long.toString();
            var FakeLocationStatus=0;
            if(fakeLocationDetected)
              FakeLocationStatus=1;

            // print(lat+"lalalal"+long+location_addr);

            IsSynced = 0;


            AttendanceOffline attendanceOffline = new AttendanceOffline(
                null,
                UserId,
                Action,
                Date,
                OrganizationId,
                PictureBase64,
                IsSynced,
                Latitude,
                Longitude,
                Time,
                FakeLocationStatus,
                timeSpoofed?1:0
            );
            attendanceOffline.save();
            timeInPressedTime=null;
            timeOutPressedTime=null;
            cameraChannel.invokeMethod("cameraClosed");
            img.deleteSync();
            imageCache.clear();

            // ignore: deprecated_member_use
            showDialog(context: context, child:
            new AlertDialog(
              content: new Text(
                  actionString+" is marked. It will be synced when you are online"),
            )
            );
            print("-----------------------Context-----------------------");
            print(context);
            Navigator

                .push(context,
              MaterialPageRoute(builder: (context) => OfflineHomePage()),
            );
          }
          else {
            setState(() {
              timeInClicked = false;
              timeOutClicked = false;
            });
          }
        });
      }
      else {
        var now;
        if(actionPressed==0){
          now=timeInPressedTime;
        }
        else{
          now=timeOutPressedTime;
        }
        var formatter = new DateFormat('yyyy-MM-dd');

        Date = formatter.format(now);
        Time = DateFormat("H:mm:ss").format(now);


        print("--------------------Date Time---------------------------");
        print(Date + " " + Time);

        print("--------------------Date Time---------------------------");

        Latitude = await assign_lat.toString();
        Longitude = await assign_long.toString();

        // print(lat+"lalalal"+long+location_addr);

        IsSynced = 0;
        var FakeLocationStatus=0;
        if(fakeLocationDetected)
          FakeLocationStatus=1;


        AttendanceOffline attendanceOffline = new AttendanceOffline(
            null,
            UserId,
            Action,
            Date,
            OrganizationId,
            '',
            IsSynced,
            Latitude,
            Longitude,
            Time,
            FakeLocationStatus,
            timeSpoofed?1:0
        );
        attendanceOffline.save();

        timeInPressedTime=null;
        timeOutPressedTime=null;

        // ignore: deprecated_member_use
        showDialog(context: context, child:
        new AlertDialog(
          content: new Text(
              "Attendance marked successfully and will be synced when you get connected!"),
        )
        );
        print("-----------------------Context-----------------------");
        print(context);
        Navigator

            .push(context,
          MaterialPageRoute(builder: (context) => OfflineHomePage()),
        );
      }

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


  getAlreadyMarkedWidgit() {
    return Column(children: <Widget>[
      SizedBox(
        height: 27.0,
      ),
      Container(
        decoration: new ShapeDecoration(
            shape: new RoundedRectangleBorder(
                borderRadius: new BorderRadius.circular(13.0)),
            color: appcolor),
        child: Text(
          '\nToday\'s attendance has been marked!',
          textAlign: TextAlign.center,
          style: new TextStyle(color: Colors.white, fontSize: 15.0),
        ),
        width: 220.0,
        height: 70.0,
      ),
      SizedBox(
        height: 50.0,
      ),
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          /* new Text('Want to go online? ',style: TextStyle(color: Colors.teal),),
                      SizedBox(width: 5.0,),*/
          new InkWell(
            child: new Text(
              "Go Online", // main  widget
              style: new TextStyle(
                  color: appcolor,
                  decoration: TextDecoration.underline),
            ),

            onTap: () {
              goOnline();
            },
          )
        ],
      ),
      /*
      ButtonTheme(
          minWidth: 130.0,
          height: 50.0,

          child: RaisedButton(
            child: Text('LOGOUT',
                style: new TextStyle(fontSize: 22.0, color: Colors.white)),
            color: Colors.orangeAccent,
            onPressed: () {
              logout();
              // //print("Time out button pressed");
              //    saveImage();
              //Navigator.pushNamed(context, '/home');
            },
          )
      )*/
      /*SizedBox(height: MediaQuery.of(context).size.height*.25),
          Container(
            height: MediaQuery.of(context).size.height*.10,
            color: Colors.teal.withOpacity(0.8),
            child: Column(
                children:[
                  SizedBox(height: 10.0,),
                  getQuickLinksWidget()
                ]
            ),
          )*/
    ]);
  }


/*
  mainbodyWidget() {
    ////to do check act1 for poor network connection

    if (act1 == "Poor network connection") {
      return poorNetworkWidget();
    } else {
      return SafeArea(
        child: ListView(
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
                          width: MediaQuery.of(context).size.height * .18,
                          height: MediaQuery.of(context).size.height * .18,
                          decoration: new BoxDecoration(
                              shape: BoxShape.circle,
                              image: new DecorationImage(
                                fit: BoxFit.fill,
                                image:_checkLoaded ? AssetImage('assets/avatar.png') : profileimage,
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
                  SizedBox(height: MediaQuery.of(context).size.height * .01),
                  //Image.asset('assets/logo.png',height: 150.0,width: 150.0),
                  // SizedBox(height: 5.0),
                  Text("Hi " + fname, style: new TextStyle(fontSize: 16.0)),

                  SizedBox(height: MediaQuery.of(context).size.height * .01),
                  // SizedBox(height: MediaQuery.of(context).size.height*.01),
                  (act1 == '') ? loader() : getMarkAttendanceWidgit(),
                ],
              ),
            ),
          ],
        ),
      );
    }
  }
  getwidget(String addrloc) {
    if (addrloc != "PermissionStatus.deniedNeverAsk") {
      return Column(children: [
        ButtonTheme(
          minWidth: 120.0,
          height: 45.0,
          child: getTimeInOutButton(),
        ),
        SizedBox(height: MediaQuery.of(context).size.height * .04),
        Container(
            color: Colors.teal.withOpacity(0.1),
            height: MediaQuery.of(context).size.height * .15,
            child:
            Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              FlatButton(
                child: new Text('You are at: ' + streamlocationaddr,
                    textAlign: TextAlign.center,
                    style: new TextStyle(fontSize: 14.0)),
                onPressed: () {
                  launchMap(lat, long);
                  /* Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => HomePage()),
                  );*/
                },
              ),
              new Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    new Text('Location not correct? ',style: TextStyle(color: Colors.teal),),
                    SizedBox(width: 5.0,),
                    new InkWell(
                      child: new Text(
                        "Refresh location", // main  widget
                        style: new TextStyle(
                            color: Colors.teal,
                            decoration: TextDecoration.underline),
                      ),
                      onTap: () {
                        startTimer();
                        sl.startStreaming(5);
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => HomePage()),
                        );
                      },
                    )
                  ],
                ),
              ),
              SizedBox(height: 5.0,),
              areaId!=0 && geoFence==1? areaStatus=='0'?Container(
                padding: EdgeInsets.only(left: 10.0,right: 10.0),
                decoration: BoxDecoration(
                  color: Colors.red,
                  //  border: Border(left: 1.0,right: 1.0,top: 1.0,bottom: 1.0),
                ),
                child:Text('Outside fenced area',style: TextStyle(fontSize: 20.0,color: Colors.white),),
              ):
              Container(
                padding: EdgeInsets.only(left: 10.0,right: 10.0),
                decoration: BoxDecoration(
                  color: Colors.green,
                  //  border: Border(left: 1.0,right: 1.0,top: 1.0,bottom: 1.0),
                ),
                child:Text('Within fenced area',style: TextStyle(fontSize: 20.0,color: Colors.white),),
              ):Center(),
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
            SimplePermissions.openSettings();
          },
        ),
      ]);
    }
    return Container(width: 0.0, height: 0.0);
  }
  getTimeInOutButton() {
    if (act1 == 'TimeIn') {
      return RaisedButton(
        child: Text('TIME IN',
            style: new TextStyle(fontSize: 22.0, color: Colors.white)),
        color: Colors.orangeAccent,
        onPressed: () {
          // //print("Time out button pressed");
          saveImage();
          //Navigator.pushNamed(context, '/home');
        },
      );
    } else if (act1 == 'TimeOut') {
      return RaisedButton(
        child: Text('TIME OUT',
            style: new TextStyle(fontSize: 22.0, color: Colors.white)),
        color: Colors.orangeAccent,
        onPressed: () {
          // //print("Time out button pressed");
          saveImage();
        },
      );
    }
  }
*/
//////////////////////////////////////////////////////////////////
}
