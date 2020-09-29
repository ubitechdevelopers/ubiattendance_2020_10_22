// Copyright 2017 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:Shrine/globals.dart' as prefix0;
import 'package:Shrine/model/timeinout.dart';
import 'package:Shrine/services/gethome.dart';
import 'package:Shrine/services/newservices.dart';
import 'package:Shrine/services/saveimage.dart';
import 'package:Shrine/services/services.dart';
import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

import 'Bottomnavigationbar.dart';
import 'askregister.dart';
import 'drawer.dart';
import 'globals.dart';
import 'home.dart';
import 'offline_home.dart';
import 'punchlocation_summary.dart';
import 'services/services.dart';
// This app is a stateful, it tracks the user's current choice.
class PunchLocation extends StatefulWidget {
  @override
  _PunchLocation createState() => _PunchLocation();
}

class _PunchLocation extends State<PunchLocation> {
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
      profile;

  String aid = "";
  String client='0';
  String shiftId = "";

  List<Widget> widgets;

var FakeLocationStatus=0;
  @override
  void initState() {
    super.initState();
    checkNetForOfflineMode(context);
    appResumedPausedLogic(context);
    streamlocationaddr=globalstreamlocationaddr;
    initPlatformState();
  //  setLocationAddress();
   // startTimer();
    platform.setMethodCallHandler(_handleMethod);
  }
  bool internetAvailable=true;
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
        if(call.arguments["internet"].toString()=="Internet Not Available")
        {
          internetAvailable=false;
          print("internet nooooot aaaaaaaaaaaaaaaaaaaaaaaavailable");

          Navigator
              .of(context)
              .pushReplacement(new MaterialPageRoute(builder: (BuildContext context) => OfflineHomePage()));

        }
        long=call.arguments["longitude"].toString();
        lat=call.arguments["latitude"].toString();
        assign_lat=double.parse(lat);
        assign_long=double.parse(long);
        address=await getAddressFromLati(lat, long);
        globalstreamlocationaddr=address;
        print(call.arguments["mocked"].toString());


        setState(() {

          if(call.arguments["mocked"].toString()=="Yes"){
            fakeLocationDetected=true;
          }
          else{
            fakeLocationDetected=false;
          }

        });
        break;

    }
  }

  @override
  void dispose() {
    super.dispose();
    timer.cancel();
  }

  /*
  startTimer() {
    const fiveSec = const Duration(seconds: 5);
    int count = 0;
    timer = new Timer.periodic(fiveSec, (Timer t) {
      //print("timmer is running");
      count++;
      //print("timer counter" + count.toString());
    //  setLocationAddress();
      if (stopstreamingstatus) {
        t.cancel();
        //print("timer canceled");
      }
    });
  }

  startTimer1() {
    const fiveSec = const Duration(seconds: 1);
    int count = 0;
    timer1 = new Timer.periodic(fiveSec, (Timer t) {
      print("timmer is running");
    });
  }

  setLocationAddress() async {
    setState(() {
      streamlocationaddr = globalstreamlocationaddr;
      if (list != null && list.length > 0) {
        lat = list[list.length - 1].latitude.toString();
        long = list[list.length - 1].longitude.toString();
        if (streamlocationaddr == '') {
          streamlocationaddr = lat + ", " + long;
        }
      }
      if(streamlocationaddr == ''){
       //sl.startStreaming(5);
      //  startTimer();
      }
      //print("home addr" + streamlocationaddr);
      //print(lat + ", " + long);

      //print(stopstreamingstatus.toString());
    });
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
    empid = prefs.getString('empid') ?? '';
    orgdir = prefs.getString('orgdir') ?? '';
    desinationId = prefs.getString('desinationId') ?? '';
    response = prefs.getInt('response') ?? 0;


    if (response == 1) {
     // Loc lock = new Loc();
      //location_addr = await lock.initPlatformState();
      Home ho = new Home();
      act = await ho.checkTimeIn(empid, orgdir,context);
      ho.managePermission(empid, orgdir, desinationId);
      // //print(act);
      ////print("this is-----> "+act);
      ////print("this is main "+location_addr);
      setState(() {
        Is_Delete = prefs.getInt('Is_Delete') ?? 0;
        newpwd = prefs.getString('newpwd') ?? "";
        userpwd = prefs.getString('usrpwd') ?? "";
        print("New pwd"+newpwd+"  User ped"+userpwd);
        location_addr1 = location_addr;
        admin_sts = prefs.getString('sstatus').toString() ?? '0';
        mail_varified = prefs.getString('mail_varified').toString() ?? '0';
        alertdialogcount = globalalertcount;
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
        profileimage = new NetworkImage(profile);
        // //print("1-"+profile);
        profileimage.resolve(new ImageConfiguration()).addListener(new ImageStreamListener((_, __) {
          if (mounted) {
            setState(() {
              _checkLoaded = false;
            });
          }
        }));
        // //print("2-"+_checkLoaded.toString());

        aid = prefs.getString('aid') ?? "";
        shiftId = prefs.getString('shiftId') ?? "";
        ////print("this is set state "+location_addr1);
        act1 = act;
        // //print(act1);
        streamlocationaddr = globalstreamlocationaddr;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return (response == 0 || userpwd!=newpwd || Is_Delete!=0) ? new AskRegisterationPage() : getmainhomewidget();
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
          backgroundColor: Colors.white,
          key: _scaffoldKey,
          appBar: AppBar(
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                new Text(org_name, style: new TextStyle(fontSize: 20.0)),
              ],
            ),
            leading: IconButton(icon:Icon(Icons.arrow_back),onPressed:(){
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => PunchLocationSummary()),
              );
            },),
            automaticallyImplyLeading: false,
            backgroundColor: appcolor,
            // backgroundColor: Color.fromARGB(255,63,163,128),
          ),


          bottomNavigationBar: Bottomnavigationbar(),
          endDrawer: new AppDrawer(),
          body: (act1 == '') ? Center(child: loader()) : checkalreadylogin(),
        ));
  }

  checkalreadylogin() {

    ////print("---->"+response.toString());
    if (response == 1) {
      return new IndexedStack(
        index: _currentIndex,
        children: <Widget>[
          underdevelopment(),
          (streamlocationaddr != '') ? mainbodyWidget() : refreshPageWidgit(),
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
  }

  refreshPageWidgit() {
    if (location_addr1 != "PermissionStatus.deniedNeverAsk") {
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
                  //sl.startStreaming(5);
            //      startTimer();
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => HomePage()),
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
                'Kindly allow location permission from settings',
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
                  cameraChannel.invokeMethod("startAssistant");

                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => PunchLocation()),
                  );
                },
              ),
            ]),
      ),
    );
  }

  mainbodyWidget() {
    ////to do check act1 for poor network connection

    if (act1 == "Poor network connection") {
      return poorNetworkWidget();
    } else {
      var globals;
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
                  Container(
                    padding: EdgeInsets.only(top:12.0,bottom: 2.0),
                    child:Center(
                      child:Text('Punch Visit',
                          style: new TextStyle(fontSize: 22.0,color:appcolor)),
                    ),
                  ),
                  SizedBox(height: MediaQuery.of(context).size.height * .03),
                  //Image.asset('assets/logo.png',height: 150.0,width: 150.0),
                  // SizedBox(height: 5.0),
                  getClients_DD(),
                  SizedBox(height: 35.0),
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

  getMarkAttendanceWidgit() {
    return Container(
      child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            SizedBox(height: 1.0),
            getwidget(location_addr1),
          ]),
    );

  }
  getwidget(String addrloc) {
    print('insidegetwidgetpunchvisit');
    print(addrloc);
    if (addrloc != "PermissionStatus.deniedNeverAsk" && globalstreamlocationaddr!='Location not fetched.') {
      return Column(children: [
        ButtonTheme(
          minWidth: 120.0,
          height: 45.0,
          child: getVisitInButton(),
        ),
        SizedBox(height: MediaQuery.of(context).size.height * .01),
        Padding(
          padding: const EdgeInsets.only(left:8.0,right: 8.0),
          child: Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
              side: BorderSide( color: Colors.grey.withOpacity(0.5), width: 1,),
            ),
            elevation: 0.0,
            borderOnForeground: true ,
            clipBehavior: Clip.antiAliasWithSaveLayer ,
            child: Padding(
              padding: const EdgeInsets.all(5.0),
              child: Container(
                  color: Colors.white,
                  height: MediaQuery.of(context).size.height * .15,
                  child:
                  Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                    FlatButton(
                      child: new Text(globalstreamlocationaddr,
                          textAlign: TextAlign.center,
                          style: new TextStyle(fontSize: 14.0,color: Colors.black54)),
                      onPressed: () {
                        launchMap(lat, long);

                      },
                    ),
                    new Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[

                          SizedBox(width: 1.0,),
                          new InkWell(
                            child:Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                Padding(
                                  padding: const EdgeInsets.only(right: 8.0),
                                  child: Icon(const IconData(0xe81a, fontFamily: "CustomIcon"),size: 15.0,color: Colors.teal,),
                                ),
                             Text(
                              "Refresh location",
                              style: new TextStyle(
                                  color: appcolor,
                                  decoration: TextDecoration.none),
                            ),
                              ]),
                            onTap: () {
                              //   startTimer();
                              //sl.startStreaming(5);
                              cameraChannel.invokeMethod("startAssistant");
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => PunchLocation()),
                              );
                            },

                          )
                        ],
                      ),
                    ),
                  ])),
            ),
          ),
        ),
      ]);
    } else {
      return Column(children: [
        Text(
            'Kindly allow location permission from settings',
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

  getVisitInButton() {
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
      child: Text('VISIT IN',
          style: new TextStyle(fontSize: 18.0, color: Colors.white)),
      color: buttoncolor,
      onPressed: () {
        globalCameraOpenedStatus=true;
        if(_clientname.text.trim() == '') {
          showInSnackBar('Please enter client name first');
          return false;
        }else
          saveVisitImage();
          return true;
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

  saveVisitImage() async {
   // sl.startStreaming(5);
    client = _clientname.text;
    MarkVisit mk = new MarkVisit(
        empid,client, streamlocationaddr, orgdir, lat, long,FakeLocationStatus);
    /* mk1 = mk;*/
    var prefs = await SharedPreferences.getInstance();
    var orgTopic = prefs.getString("OrgTopic") ?? '';
    var eName = prefs.getString('fname') ?? 'User';
    String topic = orgTopic+'PushNotifications';
    var formatter = new DateFormat('HH:mm');
    var datenew= formatter.format(DateTime.now());

    var connectivityResult = await (new Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.mobile || connectivityResult == ConnectivityResult.wifi) {
      /* Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => CameraExampleHome()),
      );*/
      SaveImage saveImage = new SaveImage();
      bool issave = false;
      setState(() {
        act1 = "";
      });
      var prefs= await SharedPreferences.getInstance();
      var employeeTopic = prefs.getString("EmployeeTopic") ?? '';
      showAppInbuiltCamera=prefs.getBool("showAppInbuiltCamera")??true;
      issave = showAppInbuiltCamera?await saveImage.saveVisitAppCamera(mk,context):await saveImage.saveVisit(mk,context);
      ////print(issave);
      if (issave) {
        if(Visit==9|| Visit==11||Visit==13|| Visit==15) {
          sendPushNotification(
              eName + ' has punched Visit for ' + client + ' at ' + datenew,
              '',
              '(\'' + orgTopic + '\' in topics) && (\'admin\' in topics)');
          print('(\'' + orgTopic + '\' in topics) && (\'admin\' in topics)');
        }
        /*
        if(Visit==10 || Visit==11) {
          sendPushNotification(' Punched Visit for ' + client + ' at ' + datenew,
              '',
              '(\'' + employeeTopic + '\' in topics)');
          print('(\'' + employeeTopic + '\' in topics)');
        }

         */
        // ignore: deprecated_member_use
        showDialog(context: context, child:
        new AlertDialog(
          content: Text("\"Visit In\" punched successfully"),
        )
        );
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => PunchLocationSummary()),
        );
        setState(() {
          act1 = act;
        });
      } else {
        // ignore: deprecated_member_use
        showDialog(context: context, child:
        new AlertDialog(

          content: new Text("Selfie was not captured. Please try again."),
        )
        );
        setState(() {
          act1 = act;
        });
      }
    }else{
      // ignore: deprecated_member_use
      showDialog(context: context, child:
      new AlertDialog(

        content: new Text("Internet connection not found!."),
      )
      );
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
        child: Padding(
          padding: const EdgeInsets.only(left:16.0,right: 16.0,top: 40.0),
          child: TextFormField(
            controller: _clientname,
            keyboardType: TextInputType.text,
            decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide( color: Colors.grey.withOpacity(0.0), width: 1,),
                ),
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
      ),
    );

  }
////////////////////////////////////////////////////////////
}
