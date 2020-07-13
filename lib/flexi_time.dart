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
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

import 'Bottomnavigationbar.dart';
import 'askregister.dart';
import 'drawer.dart';
import 'flexi_list.dart';
import 'globals.dart';
import 'home.dart';
import 'offline_home.dart';
import 'services/services.dart';

// This app is a stateful, it tracks the user's current choice.
class Flexitime extends StatefulWidget {
  @override
  _Flexitime createState() => _Flexitime();
}

class _Flexitime extends State<Flexitime> {
  StreamLocation sl = new StreamLocation();
  static const platform = const MethodChannel('location.spoofing.check');
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  final _clientname = TextEditingController();
  List<Flexi> flexiidsts = null;
  /*var _defaultimage =
      new NetworkImage("http://ubiattendance.ubihrm.com/assets/img/avatar.png");*/
  var profileimage;
  bool _checkLoaded = true;
  int _currentIndex = 1;
  String userpwd = "new";
  String newpwd = "new";
  int Is_Delete=0;
  bool _visible = true;
  String admin_sts = '0';
  String mail_varified = '1';

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
  String flexitimein = "";
  String fid = "";
  String sts ="";

  var FakeLocationStatus=0;
  bool internetAvailable=true;

  @override
  void initState() {
    super.initState();
    checkNetForOfflineMode(context);
    appResumedPausedLogic(context);
    initPlatformState();
    //setLocationAddress();
    //startTimer();

    platform.setMethodCallHandler(_handleMethod);
  }

  String address="";
  Future<dynamic> _handleMethod(MethodCall call) async {
    switch(call.method) {
      case "navigateToPage":
        navigateToPageAfterNotificationClicked(call.arguments["page"].toString(),context);
        break;
      case "locationAndInternet":
        locationThreadUpdatedLocation=true;
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
        var long=call.arguments["longitude"].toString();
        var lat=call.arguments["latitude"].toString();
        assign_lat=double.parse(lat);
        assign_long=double.parse(long);
        address=await getAddressFromLati(lat, long);
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

        /*debugPrint(call.arguments);
        return new Future.value("");*/
    }
  }

  @override
  void dispose() {
    super.dispose();
    //timer.cancel();
  }
  /*
  startTimer() {
    const fiveSec = const Duration(seconds: 5);
    int count = 0;
    timer = new Timer.periodic(fiveSec, (Timer t) {
      //print("timmer is running");
      count++;
      //print("timer counter" + count.toString());
      setLocationAddress();
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
  */
/*
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
        sl.startStreaming(5);
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

    /*await availableCameras();*/
    final prefs = await SharedPreferences.getInstance();
    empid = prefs.getString('empid') ?? '';
    orgdir = prefs.getString('orgdir') ?? '';
    desinationId = prefs.getString('desinationId') ?? '';
    response = prefs.getInt('response') ?? 0;
    /* flexitimein= await checkTimeinflexi();
    print(flexitimein);
    print("---");
    setState(() {
      flexitimein = flexitimein;
    });*/
    checkTimeinflexi().then((EmpList) {
      setState(() {
        flexiidsts = EmpList;
        fid = flexiidsts[0].fid;
        flexitimein = flexiidsts[0].sts;

        print("id and sts");
        print(fid);
        print(flexitimein);

      });
    });

    if (response == 1) {
     // Loc lock = new Loc();

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
            leading: IconButton(
                icon: Icon(Icons.arrow_back),
                onPressed: () {
                  Navigator.pop(context);
                }),
            automaticallyImplyLeading: false,
            backgroundColor: appcolor,
            // backgroundColor: Color.fromARGB(255,63,163,128),
          ),

          persistentFooterButtons: <Widget>[
            quickLinkList1(),

          ],
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
          (globalstreamlocationaddr != ''||prefix0.globalstreamlocationaddr.isNotEmpty||prefix0.globalstreamlocationaddr!=null) ? mainbodyWidget() : refreshPageWidgit(),
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
    if (globalstreamlocationaddr != ''||prefix0.globalstreamlocationaddr.isNotEmpty||prefix0.globalstreamlocationaddr!=null) {
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
                      color: appcolor, decoration: TextDecoration.none),
                ),
                onPressed: () {
                  //  sl.startStreaming(5);
                  //  startTimer();
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
                      color: appcolor, decoration: TextDecoration.none),
                ),
                onPressed: () {
                  //  sl.startStreaming(5);
                  // startTimer();
                  // cameraChannel.invokeMethod("startAssistant");
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => Flexitime()),
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
                  SizedBox(height: MediaQuery.of(context).size.height * .03),
                  Text("Flexi Time", style: new TextStyle(fontSize: 22.0,fontWeight: FontWeight.bold,color: appcolor)),
                  SizedBox(height: MediaQuery.of(context).size.height * .03),
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
                      fillColor: appcolor,
                      padding: const EdgeInsets.all(1.0),
                    ),
                  ),*/
                    ]),
                  ),

                  //Image.asset('assets/logo.png',height: 150.0,width: 150.0),
                  // SizedBox(height: 5.0),
                  // getClients_DD(),

                  SizedBox(height: MediaQuery.of(context).size.height * .02),

                  Text(fname.toUpperCase() +" "+lname.toUpperCase(), style: new TextStyle(

                    color: Colors.black87,
                    fontSize: 18.0,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 3.0,

                  )
                  ),
                  // SizedBox(height: 35.0),
                  //SizedBox(height: MediaQuery.of(context).size.height * .01),
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
  Widget quickLinkList1() {
    return Container(
      color: Colors.white.withOpacity(0.8),

      width: MediaQuery.of(context).size.width * 0.95,
      // padding: EdgeInsets.only(top:MediaQuery.of(context).size.height*0.03,bottom:MediaQuery.of(context).size.height*0.03, ),
      child: getBulkAttnWid(),
    );
  }
  getMarkAttendanceWidgit() {
    return Container(
      child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            SizedBox(height: 20.0),
            getwidget(prefix0.globalstreamlocationaddr),
          ]),
    );

  }
  getwidget(String addrloc) {
    if (addrloc != "PermissionStatus.deniedNeverAsk") {
      return Column(children: [
        ButtonTheme(
          minWidth: 120.0,
          height: 45.0,
          child:flexitimein=='2'?getVisitoutButton():getVisitInButton(),
        ),
        SizedBox(height: MediaQuery.of(context).size.height * .04),
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
                      child: new Text(prefix0.globalstreamlocationaddr,
                          textAlign: TextAlign.center,
                          style: new TextStyle(fontSize: 14.0,color: Colors.black54)),
                      onPressed: () {
                        launchMap(prefix0.assign_lat.toString(), prefix0.assign_long.toString());

                      },
                    ),
                    new Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[

                          SizedBox(width: 5.0,),
                          new InkWell(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                Padding(
                                  padding: const EdgeInsets.only(right: 8.0),
                                  child: Icon(const IconData(0xe81a, fontFamily: "CustomIcon"),size: 15.0,color: Colors.teal,),
                                ),
                                new Text(
                              "Refresh location",
                              style: new TextStyle(
                                  color: appcolor,
                                  decoration: TextDecoration.none),
                            ),
                           ]),
                            onTap: () {


                              //  startTimer();
                              //  sl.startStreaming(5);
                              //  cameraChannel.invokeMethod("startAssistant");
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => Flexitime()),
                              );
                            },
                          )
                        ],

                      ),
                    ),
                  ]) ),
            ),
          ),
        ),


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
            PermissionHandler().openAppSettings();          },
        ),
      ]);
    }
    //return Container(width: 0.0, height: 0.0);
  }


  Widget getBulkAttnWid() {
    List <Widget> widList = List<Widget>();
    widList.add(Container(
      padding: EdgeInsets.only(top: 5.0),
      constraints: BoxConstraints(
        maxHeight: 50.0,
        minHeight: 20.0,
      ),
      child: new GestureDetector(
          onTap: () {
            // startTimer();
            //  sl.startStreaming(5);
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => FlexiList()),
            );
          },
          child: Column(
            children: [
              Icon(
                const IconData(0xe81c, fontFamily: "CustomIcon"),
                size: 30.0,
                color: Colors.black45,
              ),
              Text('Log',
                  textAlign: TextAlign.center,
                  style:
                  new TextStyle(fontSize: 12.0, color: Colors.black45)),
            ],
          )),
    ));


    /* widList.add();
    widList.add();*/
    return (Row(children: widList,mainAxisAlignment: MainAxisAlignment.spaceEvenly,));
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
      child: Text('FLEXI TIME IN',
          style: new TextStyle(fontSize: 18.0, color: Colors.white)),
      color: buttoncolor,
      onPressed: () {
        prefix0.globalCameraOpenedStatus=true;
        // if(_clientname.text=='') {
        //   showInSnackBar('Please insert client name first');
        //  return false;
        // }else
        saveVisitImage();
      },
    );
  }


  getVisitoutButton() {
    return  RaisedButton(
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
        color: buttoncolor,
        child: const Text('FLEXI TIME OUT',style: TextStyle(color: Colors.white,fontSize: 18),),

        onPressed: () async {
          prefix0.globalCameraOpenedStatus=true;

          SaveImage saveImage = new SaveImage();
          setState(() {
            act1 = "";
          });
          print('****************************>>');

          // print(visit_id.toString());
          print('00000000000');
          // print(_comments.text);
          print('111111111111111');
          //print(lat+' '+long);
          print('22222222222222');
          print('<<****************************');

          var prefs= await SharedPreferences.getInstance();
          prefix0.showAppInbuiltCamera=prefs.getBool("showAppInbuiltCamera")??false;
          // Navigator.of(context, rootNavigator: true).pop();
          prefix0.showAppInbuiltCamera?
          saveImage.saveFlexiOutAppCamera(empid,prefix0.globalstreamlocationaddr,fid.toString(),prefix0.assign_lat,prefix0.assign_long,orgid,FakeLocationStatus,context)
              .then((res){

            print(res);
            print("444");
            checkTimeinflexi().then((EmpList) {
              setState(() {
                flexiidsts = EmpList;
                fid = flexiidsts[0].fid;
                flexitimein = flexiidsts[0].sts;

                // print("id and sts1");
                //  print(fid);
                //  print(flexitimein);

              });
            });
            if(res) {
              // ignore: deprecated_member_use
              showDialog(context: context, child:
              new AlertDialog(
                content: new Text("Attendance marked successfully!"),
              )
              );
            }
            else
            {
              // ignore: deprecated_member_use
              showDialog(context: context, child:
              new AlertDialog(

                content: new Text("Selfie was not captured. Please try again."),
              )
              );
            }

            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => FlexiList()),
            );
            setState(() {
              act1 = act;
            });
          }).catchError((ett){
            showInSnackBar('Unable to punch attendance');
            setState(() {
              act1 = act;
            });
          })
              :
          saveImage.saveFlexiOut(empid,prefix0.globalstreamlocationaddr,fid.toString(),prefix0.assign_lat,prefix0.assign_long,orgid,FakeLocationStatus,context)
              .then((res){

            print(res);
            print("444");
            checkTimeinflexi().then((EmpList) {
              setState(() {
                flexiidsts = EmpList;
                fid = flexiidsts[0].fid;
                flexitimein = flexiidsts[0].sts;

                // print("id and sts1");
                //  print(fid);
                //  print(flexitimein);

              });
            });
            if(res) {
              // ignore: deprecated_member_use
              showDialog(context: context, child:
              new AlertDialog(
                content: new Text("Attendance marked successfully!"),
              )
              );
            }
            else
            {
              // ignore: deprecated_member_use
              showDialog(context: context, child:
              new AlertDialog(

                content: new Text("Selfie was not captured. Please try again."),
              )
              );
            }

            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => FlexiList()),
            );
            setState(() {
              act1 = act;
            });
          }).catchError((ett){
            showInSnackBar('Unable to punch attendance');
            setState(() {
              act1 = act;
            });
          });
          /*       //  Loc lock = new Loc();
                //   location_addr1 = await lock.initPlatformState();
                if(_isButtonDisabled)
                  return null;

                Navigator.of(context, rootNavigator: true).pop('dialog');
                setState(() {
                  _isButtonDisabled=true;
                });
                //PunchInOut(comments.text,'','empid', location_addr1, 'lid', 'act', 'orgdir', latit, longi).then((res){
                SaveImage saveImage = new SaveImage();
                 saveImage.visitOut(comments.text,visit_id,location_addr1,latit, longi).then((res){
print('visit out called for visit id:'+visit_id);
                /*
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => PunchLocationSummary()),
                  );
*/


                }).catchError((onError){
                  showInSnackBar('Unable to punch visit');
                });
*/
        });
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
    print('------------*11');
    sl.startStreaming(5);
    // client = _clientname.text;
    client ="";
    MarkVisit mk = new MarkVisit(
        empid,client, prefix0.globalstreamlocationaddr, orgdir, prefix0.assign_lat.toString(), prefix0.assign_long.toString(),FakeLocationStatus);
    /* mk1 = mk;*/

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
      prefix0.showAppInbuiltCamera=prefs.getBool("showAppInbuiltCamera")??false;
      issave = prefix0.showAppInbuiltCamera?await saveImage.saveFlexiAppCamera(mk,context): await saveImage.saveFlexi(mk,context);
      ////print(issave);
      if (issave) {
        checkTimeinflexi().then((EmpList) {
          setState(() {
            flexiidsts = EmpList;
            fid = flexiidsts[0].fid;
            flexitimein = flexiidsts[0].sts;

            print("id and sts1");
            print(fid);
            print(flexitimein);

          });
        });
        // ignore: deprecated_member_use
        showDialog(context: context, child:
        new AlertDialog(
          content: new Text("Flexi Attendance marked successfully!"),
        )
        );
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => FlexiList()),
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
    }else {
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
