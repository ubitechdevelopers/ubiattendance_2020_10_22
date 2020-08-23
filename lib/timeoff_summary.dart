// Copyright 2017 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.
import 'dart:async';

import 'package:Shrine/model/model.dart';
import 'package:Shrine/services/newservices.dart';
import 'package:Shrine/services/saveimage.dart';
import 'package:Shrine/services/services.dart';
import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'Bottomnavigationbar.dart';
import 'addtimeoff.dart';
import 'drawer.dart';
import 'globals.dart';
import 'home.dart';
import 'login.dart';
import 'timeoff.dart';
// This app is a stateful, it tracks the user's current choice.
class TimeoffSummary extends StatefulWidget {
  @override
  _TimeoffSummary createState() => _TimeoffSummary();
}

class _TimeoffSummary extends State<TimeoffSummary> {
  StreamLocation sl = new StreamLocation();
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  List<Flexi> flexiidsts = null;
  var profileimage;
  bool _checkLoaded = true;
  int checkProcessing = 0;
  int _currentIndex = 1;
  bool _visible = true;
  bool _isButtonDisabled=false;
  String location_addr = "";
  String location_addr1 = "";
  String admin_sts='0';
  String act = "";
  String act1 = "";
  int response;
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
      profile = "",
      latit = "",
      longi = "";
  String time;
  bool isWithdrawPopupOpen=false;
  String lid = "";
  String shiftId = "";
  var timeofflist;
  TextEditingController client_name,comments;
  var FakeLocationStatus=0;
  String timeoffstatus = "0";
  String timeoffid = "0";

  @override
  void initState() {
    client_name = new TextEditingController();
    comments = new TextEditingController();
    super.initState();
    checkNetForOfflineMode(context);
    appResumedPausedLogic(context);
    initPlatformState();

  }
  @override

  // Platform messages are asynchronous, so we initialize in an async method.
  initPlatformState() async {
    appResumedPausedLogic(context);
    timeofflist=await getTimeOffSummary();
    setState(() {
      timeoffRunning=timeofflist[0].TimeTo.toString()=='00:00'?true:false;
    });

    checkTimeOff().then((EmpList) {
      setState(() {
        flexiidsts = EmpList;
        timeoffid = flexiidsts[0].fid;
        timeoffstatus = flexiidsts[0].sts;
        print("id and sts");
        print(timeoffid);
        print(timeoffstatus);

      });
    });

    final prefs = await SharedPreferences.getInstance();
    empid = prefs.getString('empid') ?? '';
    orgdir = prefs.getString('orgdir') ?? '';
    response = prefs.getInt('response') ?? 0;
    admin_sts = prefs.getString('sstatus') ?? 0;
    if (response == 1) {
      // Loc lock = new Loc();
      // location_addr = await lock.initPlatformState();
      //act =await checkPunch(empid, orgdir);

      //act= 'PunchOut';

      setState(() {
        location_addr1 = location_addr;
        response = prefs.getInt('response') ?? 0;
        fname = prefs.getString('fname') ?? '';
        lname = prefs.getString('lname') ?? '';
        empid = prefs.getString('empid') ?? '';
        email = prefs.getString('email') ?? '';
        status = prefs.getString('status') ?? '';
        orgid = prefs.getString('orgid') ?? '';
        orgdir = prefs.getString('orgdir') ?? '';
        sstatus = prefs.getString('sstatus') ?? '';
        org_name = prefs.getString('org_name') ?? '';
        desination = prefs.getString('desination') ?? '';
        profile = prefs.getString('profile') ?? '';
        lid = prefs.getString('lid') ?? "0";
        act= lid!='0'?'PunchOut':'PunchIn';

        profileimage = new NetworkImage(profile);
        _checkLoaded = false;
        /* profileimage.resolve(new ImageConfiguration()).addListener((_, __) {
          if (mounted) {
            setState(() {
              _checkLoaded = false;
            });
          }
        });*/
        latit = prefs.getString('latit') ?? '';
        longi = prefs.getString('longi') ?? '';
        shiftId = prefs.getString('shiftId') ?? "";
        print("this is set state " + lid);
        act1 = act;
      });
    }
  }

  withdrawlTimeOff(String timeoffid) async{
    NewServices ns = new NewServices();

    var timeoff = TimeOff(TimeOffId: timeoffid, OrgId: orgid, EmpId: empid, ApprovalSts: '5');
    var islogin = await ns.withdrawTimeOff(timeoff);
    print(islogin);
    if(islogin=="success"){
      setState(() {
        _isButtonDisabled=false;
      });
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => TimeoffSummary()),
      );
      /*showDialog(context: context, child:
      new AlertDialog(
        title: new Text("Congrats!"),
        content: new Text("Your leave is withdrawl successfully!"),
      )
      );*/
    }else if(islogin=="failure"){
      setState(() {
        _isButtonDisabled=false;
      });
      // ignore: deprecated_member_use
      showDialog(context: context, child:
      new AlertDialog(
        title: new Text("Sorry!"),
        content: new Text("Timeoff withdrawl failed."),
      )
      );
    }else{
      setState(() {
        _isButtonDisabled=false;
      });
      // ignore: deprecated_member_use
      showDialog(context: context, child:
      new AlertDialog(
        title: new Text("Sorry!"),
        content: new Text("Poor network connection."),
      )
      );
    }
  }

  confirmWithdrawl(String timeoffid) async{
    setState(() {
      isWithdrawPopupOpen=true;
    });

    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return WillPopScope(
              onWillPop: () {},
              child: new AlertDialog(
                title: new Text("Are you sure?",style: TextStyle(fontWeight: FontWeight.normal,fontSize: 18.0),),
                content:  ButtonBar(
                  children: <Widget>[
                    FlatButton(
                      child: Text('CANCEL'),
                      shape: Border.all(color: Colors.grey),
                      onPressed: () {
                        setState(() {
                          _isButtonDisabled=false;
                        });
                        Navigator.pop(context);
                      },
                    ),
                    RaisedButton(
                      child: Text('Withdraw',style: TextStyle(color: Colors.white),),
                      color: buttoncolor,
                      onPressed: () {
                        Navigator.pop(context);
                        withdrawlTimeOff(timeoffid);
                      },
                    ),
                  ],
                ),
              )
          );
        }
    );
    return Center(
        child: CircularProgressIndicator()
    );

    /*

    showDialog(context: context, barrierDismissible: false, child:
    new AlertDialog(
      title: new Text("Are you sure?",style: TextStyle(fontWeight: FontWeight.normal,fontSize: 18.0),),
      content:  ButtonBar(
        children: <Widget>[
          FlatButton(
            child: Text('CANCEL'),
            shape: Border.all(color: Colors.black54),
            onPressed: () {
              setState(() {
                _isButtonDisabled=false;
              });
              Navigator.of(context, rootNavigator: true).pop();
            },
          ),
          RaisedButton(
            child: Text('Withdraw',style: TextStyle(color: Colors.white),),
            color: buttoncolor,
            onPressed: () {
              Navigator.of(context, rootNavigator: true).pop();
              withdrawlTimeOff(timeoffid);
            },
          ),
        ],
      ),
    )
    );*/
  }

  @override
  Widget build(BuildContext context) {
    return (response == 0) ? new LoginPage() : getmainhomewidget();
  }

  void showInSnackBar(String value) {
    final snackBar = SnackBar(
        content: Text(value, textAlign: TextAlign.center,));
    _scaffoldKey.currentState.showSnackBar(snackBar);
  }
  Future<bool> sendToHome() async{
    /*Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => HomePage()),
    );*/
    print("-------> back button pressed");
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => HomePage()), (Route<dynamic> route) => false,
    );
    return false;
  }

  getmainhomewidget() {
    return new WillPopScope(
      onWillPop: ()=> sendToHome(),
      child: Scaffold(
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
              MaterialPageRoute(builder: (context) => HomePage()),
            );
          },),
          backgroundColor: appcolor,
        ),
        bottomNavigationBar: Bottomnavigationbar(),
        endDrawer: new AppDrawer(),
        body: Container(
          child: Column(
              children: <Widget>[
                SizedBox(height: 8.0),
          Text('My Time Off History',
              style: new TextStyle(fontSize: 22.0, color: appcolor)),
          SizedBox(height: 5.0),

          new Divider(color: Colors.black54,height: 1.5,),
          new Row(
            mainAxisAlignment: MainAxisAlignment.start,
//            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              SizedBox(height: 50.0,),
              SizedBox(width: MediaQuery.of(context).size.width*0.02),
              Container(
                width: MediaQuery.of(context).size.width*0.30,
                child:Text(' Date',style: TextStyle(color: appcolor,fontWeight:FontWeight.bold,fontSize: 16.0),),
              ),

              SizedBox(height: 50.0,),
              Container(
                width: MediaQuery.of(context).size.width*0.22,
                child:Text('Start \nTime',style: TextStyle(color: appcolor,fontWeight:FontWeight.bold,fontSize: 16.0),),
              ),
              SizedBox(height: 50.0,),
              Container(
                width: MediaQuery.of(context).size.width*0.24,
                child:Text(' End \nTime',style: TextStyle(color: appcolor,fontWeight:FontWeight.bold,fontSize: 16.0),),
              ),
              Container(
                width: MediaQuery.of(context).size.width*0.22,
                child:Text('Duration',style: TextStyle(color: appcolor,fontWeight:FontWeight.bold,fontSize: 16.0),),
              ),
            ],
          ),
          new Divider(height: 1.5,),
                new Expanded(child: getMarkAttendanceWidgit(act1))

        ])),
        floatingActionButton: timeoffRunning==false?new RaisedButton(
          color: buttoncolor,
          onPressed: (){
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => AddTimeoff()),
            );
          },
          child: Text(timeoffRunning?"End":"Start" ,style: TextStyle(color: Colors.white),),
        ):Center()
      ),
    );
  }

  checkalreadylogin() {
    if (response == 1) {
      return new IndexedStack(
        index: _currentIndex,
        children: <Widget>[
          underdevelopment(),
          mainbodyWidget(),
          underdevelopment()
        ],
      );
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => LoginPage()),
      );
    }
  }

  loader() {
    return new Container(
      child: Center(
        child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              Image.asset(
                  'assets/spinner.gif', height: 150.0, width: 150.0),
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
              Icon(Icons.android, color: appcolor,),
              Text("Under development",
                style: new TextStyle(fontSize: 30.0, color: appcolor),)
            ]),
      ),
    );
  }

  var timeoffRunning=false;

  mainbodyWidget() {
    return SafeArea(
      child: ListView(
        children: <Widget>[
          Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              SizedBox(height: 5.0),
              (act1 == '') ? loader() : getMarkAttendanceWidgit(act1),
              //getMarkAttendanceWidgit(),
            ],
          ),


        ],
      ),

    );
  }

  getMarkAttendanceWidgit(act1) {
    //double h_width = MediaQuery.of(context).size.width*0.5; // screen's 50%
    //double f_width = MediaQuery.of(context).size.width*1;

//print('==========================='+act1);
    return Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[


          new Container(
            height: MediaQuery.of(context).size.height*.68,
            width: MediaQuery.of(context).size.width*.99,
            padding: EdgeInsets.only(top: 8.0,left: 8.0),
            color: Colors.white,
            //////////////////////////////////////////////////////////////////////---------------------------------
            child: new FutureBuilder<List<TimeOff>>(
              future: getTimeOffSummary(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  if(snapshot.data.length>0){
                    return new ListView.builder(
                        scrollDirection: Axis.vertical,
                        itemCount: snapshot.data.length,
                        itemBuilder: (BuildContext context, int index) {

                          return new Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                new Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: <Widget>[
                                    new Container(
                                        width: MediaQuery.of(context).size.width * 0.30,
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: <Widget>[
                                            new Text(
                                              snapshot.data[index].TimeofDate.toString(),style: TextStyle(fontWeight: FontWeight.bold),),
                                            /*  (snapshot.data[index].withdrawlsts && snapshot.data[index].ApprovalSts.toString()!='Withdrawn' && snapshot.data[index].ApprovalSts.toString()!="Rejected")?new Container(
                                              height:18.5,
                                              child:new  FlatButton(
                                                shape: Border.all(color: Colors.blue),
                                                padding: EdgeInsets.all(1.0),
                                                onPressed: () {
                                                  confirmWithdrawl(snapshot.data[index].TimeOffId.toString());
                                                },
                                                child: Text("Withdraw",style: TextStyle(color: Colors.blue),),
                                              )
                                      ):Center(),*/
                                          ],
                                        )),

                                    new Container(
                                      width: MediaQuery.of(context).size.width * 0.22,
                                      child:  Text(
                                          snapshot.data[index].TimeFrom.toString(),style:TextStyle(fontWeight: FontWeight.bold)),
                                    ),
                                    new Container(
                                      width: MediaQuery.of(context).size.width * 0.22,
                                      child:  Text(
                                          snapshot.data[index].TimeTo.toString(),style:TextStyle(fontWeight: FontWeight.bold)),
                                    ),
                                    Container(
                                      width: MediaQuery.of(context).size.width * 0.22,
                                      /*decoration: new ShapeDecoration(
                                  shape: new RoundedRectangleBorder(borderRadius: new BorderRadius.circular(2.0)),
                                  color: snapshot.data[index].ApprovalSts.toString()=='Approved'?Colors.green.withOpacity(0.75):snapshot.data[index].ApprovalSts.toString()=='Rejected' || snapshot.data[index].ApprovalSts.toString()=='Cancel' ?Colors.red.withOpacity(0.65):snapshot.data[index].ApprovalSts.toString().startsWith('Pending')?Colors.orangeAccent:Colors.black12,
                                ),

                                //color: Colors.black12, // withdrawn
                                //color: Colors.orangeAccent, // pending
                                //color: Colors.red.withOpacity(0.65), // rejected,cancel
                                // color: Colors.green.withOpacity(0.75), // approved
                                padding: EdgeInsets.only(top:1.5,bottom: 1.5,left:8.0,right:8.0),
                                margin: EdgeInsets.only(top: 4.0),
                                child: Text(snapshot.data[index].ApprovalSts.toString(), style: TextStyle(color: Colors.white, fontSize: 14.0,),textAlign: TextAlign.center, ),*/
                                      child:Column(
                                        children: <Widget>[
                                          // new Text(snapshot.data[index].ApprovalSts.toString(), style: TextStyle(color: snapshot.data[index].ApprovalSts.toString()=='Approved'?Colors.green.withOpacity(0.75):snapshot.data[index].ApprovalSts.toString()=='Rejected' || snapshot.data[index].ApprovalSts.toString()=='Cancel' ?Colors.red.withOpacity(0.65):snapshot.data[index].ApprovalSts.toString().startsWith('Pending')?buttoncolor:Colors.black54, fontSize: 14.0,),textAlign: TextAlign.center,),
                                          snapshot.data[index].TimeTo.toString()=='00:00' && timeoffRunning?
                                          InkWell(
                                            child: Container(
                                              height: 25,
                                              width:60,
                                              decoration: BoxDecoration(
                                                  color: Colors.orangeAccent,
//borderRadius: BorderRadius.circular(10),
                                                  border: Border.all(color: Colors.orangeAccent,width: 1)
                                              ),
                                              child: Center(child: Text("End",style: TextStyle(color: Colors.white),)),
                                            ),
                                            onTap: (){
                                              saveVisitImage();
                                            },
                                          )
                          /*
                                          RaisedButton(
                                            color: buttoncolor,
                                            onPressed: (){
                                              saveVisitImage();
                                              /*Navigator.push(
                                                context,
                                                MaterialPageRoute(builder: (context) => AddTimeoff()),
                                              );*/
                                            },
                                            child: Text("End",style: TextStyle(color: Colors.white),),
                                          )
                                          */
                                          :new Text(snapshot.data[index].hrs.toString(), style: TextStyle(fontWeight: FontWeight.bold, color:snapshot.data[index].TimeTo.toString()=='00:00'?Colors.orange:Colors.teal),),
                                          // new Text(snapshot.data[index].ApprovalSts.toString(), style: TextStyle(color: snapshot.data[index].ApprovalSts.toString()=='Approved'?Colors.green.withOpacity(0.75):snapshot.data[index].ApprovalSts.toString()=='Rejected' || snapshot.data[index].ApprovalSts.toString()=='Cancel' ?Colors.red.withOpacity(0.65):snapshot.data[index].ApprovalSts.toString().startsWith('Pending')?buttoncolor:Colors.black54, fontSize: 14.0,),textAlign: TextAlign.center,),


                                          //SizedBox(height: 7.0,),
                                          /*(snapshot.data[index].withdrawlsts && snapshot.data[index].ApprovalSts.toString()!='Withdrawn' && snapshot.data[index].ApprovalSts.toString()!="Rejected")?InkWell(
                                      child: Container(
                                       /* height:18.5,
                                        child:new  FlatButton(
                        shape: new RoundedRectangleBorder(borderRadius: new BorderRadius.circular(25.0),side: BorderSide(color: Colors.blue),),
                                        padding: EdgeInsets.only(left:1.0,right:1.0),
                                        onPressed: () {
                                          if(_isButtonDisabled)
                                            return null;
                                          setState(() {
                                            _isButtonDisabled=true;
                                            checkProcessing = index;
                                          });
                                          confirmWithdrawl(snapshot.data[index].TimeOffId.toString());
                                        },
                                        child: (_isButtonDisabled && checkProcessing==index)?Text("Processing..",style: TextStyle(color: Colors.blue),):Text("Withdraw",style: TextStyle(color: Colors.blue),),
                                      ),*/
                                      ),
                                    ):Center(),*/

                                        ],
                                      ),
                                      // child: Text(snapshot.data[index].ApprovalSts.toString(), style: TextStyle(color: snapshot.data[index].ApprovalSts.toString()=='Approved'?Colors.green.withOpacity(0.75):snapshot.data[index].ApprovalSts.toString()=='Rejected' || snapshot.data[index].ApprovalSts.toString()=='Cancel' ?Colors.red.withOpacity(0.65):snapshot.data[index].ApprovalSts.toString().startsWith('Pending')?Colors.orangeAccent:Colors.black54, fontSize: 14.0,),textAlign: TextAlign.center, )
                                    ),
                                    /*  (snapshot.data[index].withdrawlsts && snapshot.data[index].ApprovalSts.toString()!='Withdraw' && snapshot.data[index].ApprovalSts.toString()!="Rejected")?Container(
                                  height: 25.0,
                                  width: 25.0,
                                  child: FittedBox(
                                      child:new  FloatingActionButton(
                                        backgroundColor: Colors.redAccent,
                                        onPressed: () {
                                          confirmWithdrawl(snapshot.data[index].TimeOffId.toString());
                                        },
                                        tooltip: 'Withdraw Timeoff',
                                        child: new Icon(Icons.refresh, size: 40.0,),
                                      )
                                  )
                              ): Container(),*/
                                    //Divider(),
                                  ],
                                ),
                                //SizedBox(width: 30.0,),

                                snapshot.data[index].Reason.toString()!='-'?Row(
                                  children: <Widget>[
                                    Container(
                                      margin: EdgeInsets.only(top: 4.0),
                                      child: Text('Reason: ', style: TextStyle(
                                          color: Colors.black,
                                          fontSize: 12.0, fontWeight: FontWeight.bold)),
                                    ),
                                    Expanded(
                                      child: Container(
                                        //width: MediaQuery.of(context).size.width*.80,
                                        //padding: EdgeInsets.only(top:1.5,bottom: 1.5),
                                        margin: EdgeInsets.only(top: 4.0),
                                        child: Text(snapshot.data[index].Reason.toString(), style: TextStyle(
                                            color: Colors.black54,
                                            fontSize: 12.0),overflow: TextOverflow.ellipsis,),
                                      ),
                                    ),
                                  ],
                                ):Center(),
                                snapshot.data[index].StartLoc.toString()!='-'?Row(
                                  children: <Widget>[
                                    Container(
                                      margin: EdgeInsets.only(top: 4.0),
                                      child: Text('Start Location: ', style: TextStyle(
                                          color: Colors.black,
                                          fontSize: 12.0, fontWeight: FontWeight.bold)),
                                    ),
                                    Expanded(
                                      child: InkWell(
                                        child: Container(
                                          //width: MediaQuery.of(context).size.width*.90,
                                          //padding: EdgeInsets.only(top:1.5,bottom: 1.5),
                                          margin: EdgeInsets.only(top: 4.0),
                                          child: Text(snapshot.data[index].StartLoc.toString()+'...', style: TextStyle(
                                              color: Colors.black54,
                                              fontSize: 12.0),overflow: TextOverflow.ellipsis,maxLines: 1,),
                                        ),
                                        onTap: () {
                                          goToMap(
                                              snapshot.data[index]
                                                  .LatIn ,
                                              snapshot.data[index]
                                                  .LongIn);
                                        },
                                      ),
                                    ),
                                  ],
                                ):Center(),
                                snapshot.data[index].EndLoc.toString()!='-'?Row(
                                  children: <Widget>[
                                    Container(
                                      margin: EdgeInsets.only(top: 4.0),
                                      child: Text('End Location: ', style: TextStyle(
                                          color: Colors.black,
                                          fontSize: 12.0, fontWeight: FontWeight.bold)),
                                    ),
                                    Expanded(
                                      child: InkWell(
                                        child: Container(
                                          //width: MediaQuery.of(context).size.width*.90,
                                          //padding: EdgeInsets.only(top:1.5,bottom: 1.5),
                                          margin: EdgeInsets.only(top: 4.0),
                                          child: Text(snapshot.data[index].EndLoc.toString(), style: TextStyle(
                                              color: Colors.black54,
                                              fontSize: 12.0),overflow: TextOverflow.ellipsis,maxLines: 1,),
                                        ),
                                        onTap: () {
                                          goToMap(
                                              snapshot.data[index]
                                                  .LatOut ,
                                              snapshot.data[index]
                                                  .LongOut);
                                        },
                                      ),
                                    ),
                                  ],
                                ):Center(),
                                /*snapshot.data[index].ApproverComment.toString()!='-'?Container(
                                  width: MediaQuery.of(context).size.width*.90,
                                  padding: EdgeInsets.only(top:1.5,bottom: 1.5),
                                  margin: EdgeInsets.only(top: 4.0),
                                  child: Text('Comment: '+snapshot.data[index].ApproverComment.toString(), style: TextStyle(color: Colors.black54), ),
                                ):Center(
                                  // child:Text(snapshot.data[index].withdrawlsts.toString()),
                                ),*/

                                Divider(color: Colors.black45,),
                              ]);
                        }
                    );
                  }else
                    return new Center(
                      child: Container(
                        width: MediaQuery.of(context).size.width*1,
                        color: appcolor.withOpacity(0.1),
                        padding:EdgeInsets.only(top:5.0,bottom: 5.0),
                        child:Text("You have not taken any time off  ",style: TextStyle(fontSize: 18.0),textAlign: TextAlign.center,),
                      ),
                    );
                } else if (snapshot.hasError) {
                  return new Text("Unable to connect server");
                }

                // By default, show a loading spinner
                return new Center( child: CircularProgressIndicator());
              },
            ),
            //////////////////////////////////////////////////////////////////////---------------------------------
          ),

        ]);
  }

  saveVisitImage() async {
    sl.startStreaming(5);
    var prefs = await SharedPreferences.getInstance();
    var orgTopic = prefs.getString("OrgTopic") ?? '';
    var eName = prefs.getString('fname') ?? 'User';
    String topic = orgTopic+'PushNotifications';
    var formatter = new DateFormat('HH:mm');
    var date= formatter.format(DateTime.now());
    var connectivityResult = await (new Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.mobile || connectivityResult == ConnectivityResult.wifi) {
      SaveImage saveImage = new SaveImage();
      String issave = 'false';
      setState(() {
        act1 = "";
      });
      issave =  await saveImage.marktimeoff(empid, globalstreamlocationaddr, orgdir,'', assign_lat.toString(), assign_long.toString(),FakeLocationStatus,timeoffid,timeoffstatus,context);
      print("issave");
      print(issave);
      //String tempstatus = timeoffstatus;
      if (issave=='true') {
        if(TimeOffEndStatus==13||TimeOffEndStatus==9||TimeOffEndStatus==11||TimeOffEndStatus==15){
          sendPushNotification(eName + ' ' +TimeOffEndStatusMessage+' '+ date, '',
              '(\'' + orgTopic + '\' in topics) && (\'admin\' in topics)');
          print('(\'' + orgTopic + '\' in topics) && (\'admin\' in topics)');


        }
        if(TimeOffEndStatus==5||TimeOffEndStatus==7||TimeOffEndStatus==13||TimeOffEndStatus==15){
          String subject = 'Time Off';
          String content =eName + ' ' +TimeOffEndStatusMessage+' '+ date;
          sendMailByAppToAdmin(subject,content);

        }
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => TimeoffSummary()),
        );
          showDialog(context: context, child:
          new AlertDialog(
            content: new Text("Time Off has ended"),
          )
          );
      } else if(issave=='false1') {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => HomePage()),
        );
        showDialog(context: context, child:
        new AlertDialog(
          content: new Text("Please punch your 'Time In' first!"),
        )
        );
      } else if(issave=='false2') {
        /*Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => HomePage()),
        );*/
        showDialog(context: context, child:
        new AlertDialog(
          content: new Text("Time Off can not be taken after Time Out"),
        )
        );
      } else {
        // ignore: deprecated_member_use
        showDialog(context: context, child:
        new AlertDialog(
          content: new Text("Unable to connect to server. Please try again."),
        )
        );
      }
      setState(() {
        act1 = act;
      });
    }else {
      // ignore: deprecated_member_use
      showDialog(context: context, child:
      new AlertDialog(
        content: new Text("Internet connection not found!."),
      )
      );
    }
  }

  getPunchPrefs() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    print('getPunchPrefs called: new lid- '+ prefs.getString('lid').toString());
    return prefs.getString('lid');
  }


/////////////////////futere method dor getting today's punched liist-start

/////////////////////futere method dor getting today's punched liist-close

}

