// Copyright 2017 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.
import 'package:Shrine/myleave.dart';
import 'package:Shrine/services/saveimage.dart';
import 'package:Shrine/services/services.dart';
import 'package:connectivity/connectivity.dart';
import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'Bottomnavigationbar.dart';
import 'Image_view.dart';
import 'attendance_summary.dart';
import 'drawer.dart';
import 'globals.dart';
import 'outside_label.dart';
// This app is a stateful, it tracks the user's current choice.
class ApplyLeave extends StatefulWidget {
  @override
  _ApplyLeave createState() => _ApplyLeave();
}
TextEditingController today;
class _ApplyLeave extends State<ApplyLeave> with SingleTickerProviderStateMixin {
  TabController _controller;
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  var formatter = new DateFormat('dd-MMM-yyyy');
  bool res = true;
  String admin_sts = "0";
  String _orgName='';
  var Hightvar = 0.0;
  List<Map> leavetimeList = [{"id":"2","name":"Half Day"},{"id":"1","name":"Full Day"}];
  List<Map> leavetypeList = [];
  bool isServiceCalling = false;
  String leavetimevalue = "1";
  String leavetimevalue1 = "1";
  String leavetypevalue = "1";
  bool isloading = false;
  String leavetype='0';
  String CompoffSts='0';
  String substituteemp='0';
  String empid;
  String orgid;
  DateTime Date1 = new DateTime.now();
  DateTime Date2 = new DateTime.now();
  final _dateController = TextEditingController();
  final _dateController1 = TextEditingController();
  final _leavetimevalueController = TextEditingController();
  final _leavetimevalueController1 = TextEditingController();
  final _reasonController = TextEditingController();
  FocusNode textSecondFocusNode = new FocusNode();
  FocusNode textthirdFocusNode = new FocusNode();
  FocusNode textfourthFocusNode = new FocusNode();
  final dateFormat = DateFormat("yyyy-MM-dd");
  final timeFormat = DateFormat("h:mm a");
  final _formKey = GlobalKey<FormState>();
  String _radioValue = "1"; // half day from type
  String _radioValue1 = "1"; // half day to type
  bool visibilityFromHalf = false;
  bool visibilityToHalf = false;
  int _currentIndex = 0;
  int response;
  var profileimage;
  bool showtabbar;
  String orgName="";
  bool _checkLoadedprofile=true;
  Widget mainWidget= new Container(width: 0.0,height: 0.0,);
  List<Map<String,String>> chartData;
  void showInSnackBar(String value) {
    final snackBar = SnackBar(
        content: Text(value,textAlign: TextAlign.center,));
    _scaffoldKey.currentState.showSnackBar(snackBar);
  }
  getOrgName() async{
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _orgName= prefs.getString('org_name') ?? '';
      admin_sts = prefs.getString('sstatus') ?? '';
      if(admin_sts == '2')
        Hightvar =  MediaQuery.of(context).size.height*0.7;
      else
        Hightvar =  MediaQuery.of(context).size.height*0.7;
    });
  }


  @override
  void initState() {
    super.initState();
    checkNetForOfflineMode(context);
    appResumedPausedLogic(context);
    _controller = new TabController(length: 1, vsync: this);
    getOrgName();
    today = new TextEditingController();
    today.text = formatter.format(DateTime.now());
    initPlatformState();
    platform.setMethodCallHandler(_handleMethod);
  }
  static const platform = const MethodChannel('location.spoofing.check');

  Future<dynamic> _handleMethod(MethodCall call) async {
    switch(call.method) {

    }
  }

  Future<bool> sendToLeaveList() async{
    /*Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => HomePage()),
    );*/
    print("-------> back button pressed");
    /*
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => MyLeave()), (Route<dynamic> route) => false,
    );

     */
    return false;
  }
  initPlatformState() async {

    /*await availableCameras();*/
    final prefs = await SharedPreferences.getInstance();
    empid = prefs.getString('empid') ?? '';
    orgid = prefs.getString('orgdir') ?? '';
    response = prefs.getInt('response') ?? 0;



      setState(() {
        admin_sts = prefs.getString('sstatus').toString() ?? '0';
        response = prefs.getInt('response') ?? 0;
        empid = prefs.getString('empid') ?? '';
        orgid = prefs.getString('orgid') ?? '';
        org_name = prefs.getString('org_name') ?? '';
        // //print("2-"+_checkLoaded.toString());

      });



  }
  @override
  Widget build(BuildContext context) {
    return  WillPopScope(
      onWillPop: ()=> sendToLeaveList(),
      child: Scaffold(
          key: _scaffoldKey,
          backgroundColor:Colors.black,
          endDrawer: new AppDrawer(),
          appBar: AppBar(
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                new Text(_orgName, style: new TextStyle(fontSize: 20.0)),
              ],
            ),
            leading: IconButton(icon:Icon(Icons.arrow_back),onPressed:(){
              Navigator.of(context).pop();
            },),
            backgroundColor: appcolor,
          ),
          bottomNavigationBar: Bottomnavigationbar(),
          body: homewidget()
          /*
          ModalProgressHUD(
              inAsyncCall: isServiceCalling,
              opacity: 0.15,
              progressIndicator: SizedBox(
                child:new CircularProgressIndicator(
                    valueColor: new AlwaysStoppedAnimation(Colors.green),
                    strokeWidth: 5.0),
                height: 40.0,
                width: 40.0,
              ),
              child: homewidget()
          )
        */

      ),
    );
  }
  Widget homewidget(){
    return Stack(
      children: <Widget>[
        Container(
          //height: MediaQuery.of(context).size.height,
          //margin: EdgeInsets.fromLTRB(10.0, 10.0, 10.0, 10.0),
          //padding: EdgeInsets.fromLTRB(10.0, 10.0, 10.0, 10.0),
          //width: MediaQuery.of(context).size.width*0.9,

          decoration: new ShapeDecoration(
            shape: new RoundedRectangleBorder(borderRadius: new BorderRadius.circular(0.0)),
            color: Colors.white,
          ),

          child:Form(
            key: _formKey,
            child: SafeArea(
                child: Column( children: <Widget>[
                  SizedBox(height: 8.0),
                  Text('Request Leave',
                      style: new TextStyle(fontSize: 22.0, color: appcolor)),
                  new Divider(color: Colors.black54,height: 8.0,),
                  new Expanded(
                    child: ListView(
                      //padding: EdgeInsets.symmetric(horizontal: 15.0),
                      children: <Widget>[
                        Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: <Widget>[
                            //SizedBox(height: 5.0),
                            //getLeaveType_DD(),
                            SizedBox(height: 5.0),
                            //Enter date
                            Row(
                              children: <Widget>[
                                new Expanded(
                                  child: Container(
                                    //margin: EdgeInsets.fromLTRB(0.0, 1.0, 0.0, 0.0),
                                    height: MediaQuery.of(context).size.height*0.1,
                                    child:DateTimeField(
                                      //firstDate: new DateTime.now(),
                                      //initialDate: new DateTime.now(),
                                      //dateOnly: true,
                                      format: dateFormat,
                                      controller: _dateController,
                                      readOnly: true,
                                      onShowPicker: (context, currentValue) {
                                        print("current value1");
                                        print(currentValue);
                                        print(DateTime.now());
                                        return showDatePicker(
                                            context: context,
                                            firstDate: DateTime.now().subtract(Duration(days: 1)),
                                            initialDate: currentValue ?? DateTime.now(),
                                            lastDate: DateTime(2100)
                                        );
                                      },

                                      decoration: InputDecoration(
                                        prefixIcon: Padding(
                                          padding: EdgeInsets.all(0.0),
                                          child: Icon(
                                            Icons.date_range,
                                            color: Colors.grey,
                                          ), // icon is 48px widget.
                                        ), // icon is 48px widget.
                                        labelText: 'From Date',
                                      ),
                                      onChanged: (date) {
                                        setState(() {
                                          Date1 = date;
                                        });
                                        print("----->Changed date------> "+Date1.toString());
                                      },
                                      validator: (date) {
                                        if (date==null){
                                          return 'Please enter Leave From date';
                                        }
                                      },

                                    ),
                                  ),
                                ),
                                new Expanded(
                                  child: Container(
                                    //margin: EdgeInsets.fromLTRB(0.0, 5.0, 0.0, 0.0),
                                    // height: 80.0,
                                    height: MediaQuery.of(context).size.height*0.1,
                                    child:DateTimeField(
                                      //firstDate: new DateTime.now(),
                                      //initialDate: new DateTime.now(),
                                      //dateOnly: true,
                                      format: dateFormat,
                                      controller: _dateController1,
                                      readOnly: true,
                                      onShowPicker: (context, currentValue) {
                                        print("current value");
                                        print(currentValue);
                                        return showDatePicker(
                                            context: context,
                                            initialDate: currentValue ?? DateTime.now(),
                                            firstDate: DateTime.now().subtract(Duration(days: 1)),
                                            lastDate: DateTime(2100));

                                      },
                                      decoration: InputDecoration(
                                        prefixIcon: Padding(
                                          padding: EdgeInsets.all(0.0),
                                          child: Icon(
                                            Icons.date_range,
                                            color: Colors.grey,
                                          ), // icon is 48px widget.
                                        ), // icon is 48px widget.

                                        labelText: 'To Date',
                                      ),
                                      onChanged: (dt) {
                                        setState(() {
                                          Date2 = dt;
                                        });
                                        print("----->Changed date------> "+Date2.toString());
                                      },
                                      validator: (dt) {
                                        if (dt==null){
                                          return 'Please enter Leave to date';
                                        }
                                        if(Date2.isBefore(Date1)){
                                          print("Date1 ---->"+Date1.toString());
                                          print("Date2---->"+Date2.toString());
                                          return '\"To Date\" can\'t be smaller.';
                                        }

                                      },
                                    ),
                                  ),
                                ),
                                /*
                                (CompoffSts=='0')?SizedBox(width: 10.0):Center(),
                                (CompoffSts=='0')?Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.only(top:10.0),
                                    child: Container(
                                      //height: MediaQuery.of(context).size.height*0.1,
                                      //height: 60.0,
                                      child: new InputDecorator(
                                        decoration: InputDecoration(
                                          // labelText: 'Leave Type',
                                          prefixIcon: Padding(
                                            padding: EdgeInsets.all(0.0),
                                            child: Icon(
                                              Icons.tonality,
                                              color: Colors.grey,
                                            ), // icon is 48px widget.
                                          ),
                                          border: new UnderlineInputBorder(
                                            borderSide: BorderSide(color: Colors.white,
                                                width: 0.0, style: BorderStyle.none ),),
                                        ),
                                        //   isEmpty: _color == '',
                                        child:  DropdownButtonHideUnderline(
                                          child: new DropdownButton<String>(
                                            isDense: true,
                                            style: new TextStyle(
                                                fontSize: 15.0,
                                                color: Colors.black
                                            ),
                                            value: leavetimevalue,
                                            onChanged: (String newValue) {
                                              setState(() {
                                                leavetimevalue = newValue;
                                                if(leavetimevalue=="2"){
                                                  visibilityFromHalf = true;
                                                }else{
                                                  visibilityFromHalf = false;
                                                }
                                              });
                                            },
                                            items: leavetimeList.map((Map map) {
                                              return new DropdownMenuItem<String>(
                                                value: map["id"].toString(),
                                                child: new Text(
                                                  map["name"],
                                                ),
                                              );
                                            }).toList(),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ):Center(),
                                */
                              ],
                            ),
                            /*
                            (visibilityFromHalf)?Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: <Widget>[
                                new Radio(
                                  value: "1",
                                  groupValue: _radioValue,
                                  //onChanged: _handleRadioValueChange,
                                ),
                                Text("First Half",style: TextStyle(fontSize: 16.0),),
                                SizedBox(width: 50.0,),
                                new Radio(
                                  value: "2",
                                  groupValue: _radioValue,
                                  //onChanged: _handleRadioValueChange,
                                ),
                                Text("Second Half",style: TextStyle(fontSize: 16.0),)
                              ],
                            ):Container(),
                            SizedBox(height: 5.0,),
                            */
                            Row(
                              children: <Widget>[

                                /*
                                (CompoffSts=='0')?SizedBox(width: 10.0):Center(),
                                (CompoffSts=='0')?Expanded(
                                    child:Padding(
                                      padding: const EdgeInsets.only(top:10.0),
                                      child: Container(
                                        //height: 60.0,
                                        child: new InputDecorator(
                                            decoration: InputDecoration(
                                              // labelText: 'Leave Type',
                                              prefixIcon: Padding(
                                                padding: EdgeInsets.all(0.0),
                                                child: Icon(
                                                  Icons.tonality,
                                                  color: Colors.grey,
                                                ), // icon is 48px widget.
                                              ),
                                            ),
                                            //   isEmpty: _color == '',
                                            child:  DropdownButtonHideUnderline(
                                              child:  new DropdownButton<String>(
                                                isDense: true,
                                                style: new TextStyle(
                                                    fontSize: 15.0,
                                                    color: Colors.black
                                                ),
                                                value: leavetimevalue1,
                                                onChanged: (String newValue) {
                                                  setState(() {
                                                    leavetimevalue1 = newValue;
                                                    if(leavetimevalue1=="2"){
                                                      visibilityToHalf = true;
                                                    }else{
                                                      visibilityToHalf = false;
                                                    }
                                                  });
                                                },
                                                items: leavetimeList.map((Map map) {
                                                  return new DropdownMenuItem<String>(
                                                    value: map["id"].toString(),
                                                    child: new Text(
                                                      map["name"],
                                                    ),
                                                  );
                                                }).toList(),
                                              ),
                                            )
                                        ),
                                      ),
                                    )
                                ):Center(),
                                */
                              ],
                            ),
/*
                            (visibilityToHalf)?Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: <Widget>[
                                new Radio(
                                  value: "1",
                                  groupValue: _radioValue1,
                                 // onChanged: _handleRadioValueChange1,
                                ),
                                Text("First Half",style: TextStyle(fontSize: 16.0),),
                                SizedBox(width: 50.0,),
                                new Radio(
                                  value: "2",
                                  groupValue: _radioValue1,
                                 // onChanged: _handleRadioValueChange1,
                                ),
                                Text("Second Half",style: TextStyle(fontSize: 16.0),)
                              ],
                            ):Container(),
                            */

                            SizedBox(height: 5.0,),

                            TextFormField(
                              controller: _reasonController,
                              decoration: InputDecoration(
                                  labelText: 'Reason',
                                  prefixIcon: Padding(
                                    padding: EdgeInsets.only(bottom:0.0),
                                    child: Icon(
                                      Icons.event_note,
                                      color: Colors.grey,
                                    ), // icon is 48px widget.
                                  )
                              ),
                              validator: (value) {
                                if (value.isEmpty) {
                                  return 'Please enter reason';
                                }
                              },
                              onFieldSubmitted: (String value) {
                                /*if (_formKey.currentState.validate()) {
                              //requesttimeoff(_dateController.text ,_starttimeController.text,_endtimeController.text,_reasonController.text, context);
                              }*/
                              },
                              maxLines: 1,
                            ),

                           // (CompoffSts=='0')?getSubstituteEmp_DD():Center(),

                            ButtonBar(
                              children: <Widget>[

                                RaisedButton(
                                  elevation: 2.0,
                                  highlightElevation: 5.0,
                                  highlightColor: Colors.transparent,
                                  disabledElevation: 0.0,
                                  focusColor: Colors.transparent,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(5),
                                  ),
                                  child: isServiceCalling?Text('Processing..',style: TextStyle(color: Colors.white),):Text('APPLY',style: TextStyle(color: Colors.white),),
                                  color: buttoncolor,
                                  onPressed: () {
                                    if (_formKey.currentState.validate()) {
                                        requestLeave();
                                      /*
                                        if(CompoffSts=='0')
                                          requestleave(_dateController.text, _dateController1.text ,leavetimevalue, leavetimevalue1, _radioValue, _radioValue1, _reasonController.text.trim(), substituteemp, CompoffSts);
                                        else
                                          requestleave(_dateController.text, _dateController1.text , '0', '0', '0', '0', _reasonController.text.trim(), '0', CompoffSts);
                                     */
                                    }
                                  },
                                ),
                                FlatButton(
                                  highlightColor: Colors.transparent,
                                  focusColor: Colors.transparent,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(5),
                                    side: BorderSide( color: Colors.grey.withOpacity(0.5), width: 1,),
                                  ),
                                  //shape: Border.all(color: Colors.orange[800]),
                                  child: Text('CANCEL',style: TextStyle(color: Colors.black87),),
                                  onPressed: () {

                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(builder: (context) => ApplyLeave()),
                                    );

                                  },
                                ),

                              ],
                            ),
                          ],
                        ),

                      ],
                    ),
                  )
                ]
                )
            ),
          ),

        ),

      ],
    );
  }
  requestLeave() async {

    print('------------*11');


    var prefs = await SharedPreferences.getInstance();
    var formatter = new DateFormat('HH:mm');
    var date= formatter.format(DateTime.now());


    var connectivityResult = await (new Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.mobile || connectivityResult == ConnectivityResult.wifi) {
      /* Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => CameraExampleHome()),
      );*/
      SaveImage saveImage = new SaveImage();
      String issave = 'false';
      setState(() {
      });
      issave =  await saveImage.applyLeave( empid , _reasonController.text.trim(),  _dateController.text, _dateController1.text,_radioValue, _radioValue1, orgid);
      print("issave");
      print(issave);
      //String tempstatus = timeoffstatus;
      if (issave=='true') {


        /*checkTimeOff().then((EmpList) {
          setState(() {
            flexiidsts = EmpList;
            timeoffid = flexiidsts[0].fid;
            timeoffstatus = flexiidsts[0].sts;
            print("id and sts1");
            print(timeoffid);
            print(timeoffstatus);

          });
        });*/
        // ignore: deprecated_member_use
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => MyLeave()),
        );
        /* if(tempstatus=='2') {
          showDialog(context: context, child:
          new AlertDialog(
            content: new Text("Time Off has ended"),
          )
          );
        } else {*/
        showDialog(context: context, child:
        new AlertDialog(
          content: new Text("Leave has been applied successfully."),
        )
        );
        //}
      } else if(issave=='false1') {

        /*
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => HomePage()),
        );
        */
        showDialog(context: context, child:
        new AlertDialog(
          content: new Text("You have Already Applied for Leave for this day"),
        )
        );
      } else if(issave=='false2') {
        /*Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => HomePage()),
        );*/
        showDialog(context: context, child:
        new AlertDialog(
          content: new Text("You have insufficient Leave Balance"),
        )
        );
      } else if(issave=='false3') {
        /*Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => HomePage()),
        );*/
        showDialog(context: context, child:
        new AlertDialog(
          content: new Text("Leave can not be applied on Weekoffs/Holidays"),
        )
        );
      }else if(issave=='false4') {
        /*Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => HomePage()),
        );*/
        showDialog(context: context, child:
        new AlertDialog(
          content: new Text("Leave can not be applied after marking Time In"),
        )
        );
      }else if(issave=='false5') {
        /*Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => HomePage()),
        );*/
        showDialog(context: context, child:
        new AlertDialog(
          content: new Text("Leave can not be applied before joining date"),
        )
        );
      }
      else if(issave=='false6') {
        /*Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => HomePage()),
        );*/
        showDialog(context: context, child:
        new AlertDialog(
          content: new Text("Contact admin and get date of joining assigned to you"),
        )
        );
      }else {
        // ignore: deprecated_member_use
        showDialog(context: context, child:
        new AlertDialog(
          content: new Text("Unable to connect to server. Please try again."),
        )
        );
      }
      setState(() {

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
  /*
  requestleave(var leavefrom, var leaveto, var leavetypefrom, var leavetypeto, var halfdayfromtype, var halfdaytotype, var reason, var substituteemp, var compoffsts) async{
    setState(() {
      isServiceCalling = true;
    });
    print("----> service calling "+isServiceCalling.toString());
    final prefs = await SharedPreferences.getInstance();
    String uid = prefs.getString("empid")??"";
    String orgid = prefs.getString("orgid")??"";
    Leave leave =new Leave(uid: uid, leavefrom: leavefrom, leaveto: leaveto, orgid: orgid, reason: reason, leavetypeid: leavetype, leavetypefrom: leavetypefrom, leavetypeto: leavetypeto, halfdayfromtype: halfdayfromtype, halfdaytotype: halfdaytotype, substituteemp: substituteemp, compoffsts:compoffsts);
    var islogin1 = await requestLeave(leave);
    //print("---ss>"+islogin1);
    if(islogin1=="true"){
      //showInSnackBar("Leave has been applied successfully.");
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => MyLeave()), (Route<dynamic> route) => false,
      );
      // ignore: deprecated_member_use
      showDialog(context: context, child:
      new AlertDialog(

        content: new Text('Leave application applied successfully.'),
      )
      );
    }else if(islogin1=="false"){
      // ignore: deprecated_member_use
      showDialog(context: context, child:
      new AlertDialog(
        content: new Text('There is some problem while applying for Leave.'),
      )
      );
      setState(() {
        isServiceCalling = false;
      });
      //showInSnackBar("There is some problem while applying for Leave.");
    }else if(islogin1=="wrong"){
      // ignore: deprecated_member_use
      showDialog(context: context, child:
      new AlertDialog(
        content: new Text('Leave format is wrong'),
      )
      );
      setState(() {
        isServiceCalling = false;
      });
      //showInSnackBar("Leave format is wrong");
    }else if(islogin1=="You cannot apply for comp off"){
      // ignore: deprecated_member_use
      showDialog(context: context, child:
      new AlertDialog(
        content: new Text('You cannot apply for comp off'),
      )
      );
      setState(() {
        isServiceCalling = false;
      });
      //showInSnackBar("Leave format is wrong");
    }else if(islogin1=="You cannot apply more than credited leaves"){
      showDialog(context: context, child:
      new AlertDialog(
        content: new Text('You cannot apply more than credited leaves'),
      )
      );
      setState(() {
        isServiceCalling = false;
      });
      //showInSnackBar("Leave format is wrong");
    }else if(islogin1=="alreadyApply"){
      // ignore: deprecated_member_use
      showDialog(context: context, child:
      new AlertDialog(
        content: new Text('You have already applied for same date'),
      )
      );
      setState(() {
        isServiceCalling = false;
      });
      //showInSnackBar("You already applied for same date");
    }else{
      // ignore: deprecated_member_use
      showDialog(context: context, child:
      new AlertDialog(
        content: new Text('Poor Network Connection'),
      )
      );
      setState(() {
        isServiceCalling = false;
      });
      //showInSnackBar("Poor Network Connection");
    }
  }
  */
}



