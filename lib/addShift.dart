// Copyright 2017 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.
import 'package:Shrine/drawer.dart';
import 'package:Shrine/services/gethome.dart';
import 'package:Shrine/services/services.dart';
import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'globals.dart';
import 'shift_list.dart';

class addShift extends StatefulWidget {
  @override
  _addShift createState() => _addShift();
}
class _addShift extends State<addShift> {
  bool isloading = false;
  final _shiftName = TextEditingController();
  final shiftHours = TextEditingController();
  final _from = TextEditingController();
  final minimumworkinghours = TextEditingController();
  final _to = TextEditingController();
  final _from_b = TextEditingController();
  final _to_b = TextEditingController();
  final timeFormat = DateFormat("H:mm");
  var datenew = new DateTime.now();
  final timeFormatnew = DateFormat("H:mm");
  final _formKey = GlobalKey<FormState>();
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  int response=0;
  int _currentIndex = 2;
  String org_name="";
  String admin_sts="0";
  List<Map> shiftlist=[{"id":"1","name":"Single Date"},{"id":"2","name":"Multi Date"},if(bulkAttn==0){"id":"3","name":"Flexi"}];
  String shifttype = "1";
  var visiblity= true;
  var visiblitymin= false;
  var visiblityhours= false;
  var textedit= true;
  var formatter = new DateFormat('HH:mm');
  var formatter1 = new DateFormat('HH');
  var formatter2 = new DateFormat('mm');

  bool _isButtonDisabled=false;

  DateTime _dateTime;

  String date1='';
  String date2='';
  String date3='';
  int date_hours=0;
  int date_min=0;
  @override
  void initState() {
    super.initState();
    initPlatformState();
    //  shiftList= getShifts();
  }
  // Platform messages are asynchronous, so we initialize in an async method.
  initPlatformState() async {
    appResumedPausedLogic(context);
    checkNetForOfflineMode(context);
    //appResumedFromBackground(context);
    final prefs = await SharedPreferences.getInstance();
    response = prefs.getInt('response') ?? 0;
    admin_sts = prefs.getString('sstatus') ?? '0';
    if(response==1) {
      Home ho = new Home();
      setState(() {
        org_name = prefs.getString('org_name') ?? '';
        /*
        response = prefs.getInt('response') ?? 0;
        fname = prefs.getString('fname') ?? '';
        lname = prefs.getString('lname') ?? '';
        empid = prefs.getString('empid') ?? '';
        email = prefs.getString('email') ?? '';
        status = prefs.getString('status') ?? '';
        orgid = prefs.getString('orgid') ?? '';
        orgdir = prefs.getString('orgdir') ?? '';
        sstatus = prefs.getString('sstatus') ?? '';

        desination = prefs.getString('desination') ?? '';
        profile = prefs.getString('profile') ?? '';
        */
      });
    }
    platform.setMethodCallHandler(_handleMethod);
  }
  static const platform = const MethodChannel('location.spoofing.check');

  Future<dynamic> _handleMethod(MethodCall call) async {
/*
    switch(call.method) {

      case "locationAndInternet":
      // print(call.arguments["internet"].toString()+"akhakahkahkhakha");
      // Map<String,String> responseMap=call.arguments;
        if(call.arguments["TimeSpoofed"].toString()=="Yes"){
          timeSpoofed=true;

        }
        if(call.arguments["internet"].toString()=="Internet Not Available")
        {

          print("internet nooooot aaaaaaaaaaaaaaaaaaaaaaaavailable");

          Navigator
              .of(context)
              .pushReplacement(new MaterialPageRoute(builder: (BuildContext context) => OfflineHomePage()));

        }
        break;

        return new Future.value("");
    }
  */}

  @override
  Widget build(BuildContext context) {
    return getmainhomewidget();
  }

  void showInSnackBar(String value) {
    final snackBar = SnackBar(
        content: Text(value,textAlign: TextAlign.center,));
    _scaffoldKey.currentState.showSnackBar(snackBar);
  }

  getmainhomewidget(){
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            new Text(org_name, style: new TextStyle(fontSize: 20.0)),
          ],
        ),
        leading: IconButton(icon:Icon(Icons.arrow_back),onPressed:(){
          Navigator.pop(context);
          /*  Navigator.push(
            context,
           MaterialPageRoute(builder: (context) => TimeoffSummary()),
          );*/
        },),
        backgroundColor: appcolor,
      ),
      bottomNavigationBar: Container(

        height: 70.0,
        decoration: new BoxDecoration(
            color: Colors.white,
            boxShadow: [new BoxShadow(
              color: Colors.grey,
              blurRadius: 3.0,
            ),]
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Container(
              //margin: const EdgeInsets.only(left: 50.0),
              child: ButtonBar(

                children: <Widget>[
                  FlatButton(
                    padding: const EdgeInsets.all(8.0),

                    highlightColor: Colors.transparent,
                    focusColor: Colors.transparent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5),
                      side: BorderSide( color: Colors.grey.withOpacity(0.5), width: 1,),
                    ),
                    child: Text('CANCEL'),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                  SizedBox(width: 10.0),
                  RaisedButton(
                    elevation: 2.0,
                    highlightElevation: 5.0,
                    highlightColor: Colors.transparent,
                    disabledElevation: 0.0,
                    focusColor: Colors.transparent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: _isButtonDisabled?Text(
                      'Processing..',
                      style: TextStyle(
                          color: Colors.white),
                    )
                        :Text(
                      'ADD',
                      style: TextStyle(
                          color: Colors.white),),
                    color: buttoncolor,
                    onPressed: () async {
                      print('thisisshifttype------->>>>>'+shifttype);

                      if (_formKey.currentState.validate()) {
                        if(_isButtonDisabled)
                          return null;
                            print('Name:'+_shiftName.text);
                            print('Starts:'+_from.text);
                            print('Ends:'+_to.text);
                        var diff = "";
                        var diff1 ;
                        var diff_b = "";
                        var diff_b1  ;
                        DateTime from ;
                        DateTime to ;
                        DateTime from_b ;
                        DateTime to_b ;

                        if (shifttype.toString() == '1' || shifttype.toString() == '3')
                        {
                        //var arr2='00:00';
                        var arr;
                        var arr1;
                        if(shifttype=='3'){
                        arr= '00:00';
                        arr1='00:00';
                        print('minimumworkinghours---->'+date2.toString());
                        if(date1==''){
                            showInSnackBar(
                                "Please enter minimum working hours");
                            return null;
                          }

                        if(date_hours>=18){
                          if(date_min>0) {
                            showInSnackBar(
                                "Minimum working hours cannot be greater than 18 hrs");
                            return null;
                          }


                        }
                        if(date_hours==0){
                          if(date_min<15){
                            showInSnackBar(
                                "Minimum working hours cannot be less than 00:15 hours");
                            return null;
                          }
                        }

                        }else{
                        arr=_from.text.split(':');
                        arr1=_to.text.split(':');

                        from=new DateTime(2001,01,01,int.parse(arr[0]),int.parse(arr[1]),00,00);
                        to=new DateTime(2001,01,01,int.parse(arr1[0]),int.parse(arr1[1]),00,00);

                        var arr_b=_from_b.text.split(':');
                        var arr1_b=_to_b.text.split(':');
                        from_b=new DateTime(2001,01,01,int.parse(arr_b[0]),int.parse(arr_b[1]),00,00);
                        to_b=new DateTime(2001,01,01,int.parse(arr1_b[0]),int.parse(arr1_b[1]),00,00);


                        diff = to.difference(from).toString();
                        diff_b = to_b.difference(from_b).toString();
                        diff_b1 = to_b.difference(from_b);

                        if(to.isAtSameMomentAs(from)){
                        showInSnackBar("Shift's start and end time can't be same");
                        return null;
                        }
                        else if(!from.isBefore(to)){
                        showInSnackBar('Invalid Shift time');
                        return null;
                        }
                        else if(!from_b.isBefore(to_b))
                        {
                        showInSnackBar('Invalid Break time');
                        return null;
                        }
                        else if((!from.isBefore(from_b)) || (!to_b.isBefore(to)))
                        {
                        showInSnackBar('Invalid Break time');
                        return null;
                        }
                        }

                        }
                        else
                        {
                          var arr=_from.text.split(':');
                          var arr1=_to.text.split(':');
                          from=new DateTime(2001,01,01,int.parse(arr[0]),int.parse(arr[1]),00,00);
                          to=new DateTime(2001,01,02,int.parse(arr1[0]),int.parse(arr1[1]),00,00);

                          print(from);
                          print(to);

                          var arr_b=_from_b.text.split(':');
                          var arr1_b=_to_b.text.split(':');
                          from_b=new DateTime(2001,01,01,int.parse(arr_b[0]),int.parse(arr_b[1]),00,00);
                          to_b=new DateTime(2001,01,01,int.parse(arr1_b[0]),int.parse(arr1_b[1]),00,00);

                          if(!from_b.isBefore(to_b))
                          {
                            from_b=new DateTime(2001,01,01,int.parse(arr_b[0]),int.parse(arr_b[1]),00,00);
                            to_b=new DateTime(2001,01,02,int.parse(arr1_b[0]),int.parse(arr1_b[1]),00,00);
                          }
                          if(from_b.isBefore(from) && to_b.isBefore(to) )
                          {
                            from_b=new DateTime(2001,01,02,int.parse(arr_b[0]),int.parse(arr_b[1]),00,00);
                            to_b=new DateTime(2001,01,02,int.parse(arr1_b[0]),int.parse(arr1_b[1]),00,00);
                          }


                          diff = to.difference(from).toString();
                          diff1 = to.difference(from);
                          diff_b = to_b.difference(from_b).toString();
                          diff_b1 = to_b.difference(from_b);
                          print(diff1);
                          if(to.isAtSameMomentAs(from)){
                            showInSnackBar("Shift's start and end time can't be same");
                            return null;
                          }
                          else if(diff1.inHours > 20)
                          {
                            showInSnackBar("Shift hour's should be less then 20");
                            return null;
                          }
                          else if(!from.isBefore(to)){
                            showInSnackBar('Invalid Shift time');
                            return null;
                          }
                          else if(!from_b.isBefore(to_b))
                          {
                            showInSnackBar('Invalid Break time');
                            return null;
                          }
                          else if((!from.isBefore(from_b)) ||  (!to_b.isBefore(to)))
                          {
                            showInSnackBar('Invalid Break time');
                            return null;
                          }

                        }


                        /*
                            print(diff_b1.inHours.toString());
                            if(to.isAtSameMomentAs(from)){
                              showInSnackBar("Shift's start and end time can't be same");
                              return null;
                            }else if(diff_b.startsWith('-') && shifttype.toString() == '1'){
                              showInSnackBar('Invalid break time');
                              return null;
                            }else if(diff_b.startsWith('-') && shifttype.toString() == '2' && diff_b1.inHours>-12){
                              print(diff_b);
                              print(from_b);
                              print(to_b);
                              showInSnackBar('Invalid break time');
                              return null;
                            }
                            else if((!from.isBefore(from_b))&& (from.isAtSameMomentAs(from_b))&& shifttype.toString() == '1'){
                              showInSnackBar('Break time should be between shift hours1');
                              return null;
                            }else if((!to.isAfter(to_b))&& (to.isAtSameMomentAs(to_b))&& shifttype.toString() == '1'){
                              showInSnackBar('Break time should be between shift hours2');
                              return null;
                            }
                            else if((!from.isBefore(from_b))&& (from.isAtSameMomentAs(from_b))&& shifttype.toString() == '2'){
                              showInSnackBar('Break time should be between shift hours3');
                              return null;
                            }else if((!to_b.isAfter(to))&& (to.isAtSameMomentAs(to_b)) && shifttype.toString() == '2' && diff_b1.inHours>-12){
                              showInSnackBar('Break time should be between shift hours4');
                              return null;
                            }

                           else {
                              if (shifttype.toString() == '1') {
                                if (diff.startsWith('-')) {
                                  showInSnackBar('Invalid Shift timimgs');
                                  return null;
                                } else {
                                  print('Valid shift for single date');
                                  print("Diff: " + diff);
                                }
                              } else {
                                if (!diff.startsWith('-')) {
                                  showInSnackBar('Invalid Shift timimgs');
                                  return null;
                                } else {
                                  print('Valid shift for multi date');
                                  print("Diff: " + diff);
                                }
                              }
                            }
                            return false;*/

                        setState(() {
                          _isButtonDisabled=true;
                        });

                        createShift(_shiftName.text,shifttype,_from.text,_to.text,_from_b.text,_to_b.text,date1).then((res)async{
                          if(res.toString()=='1') {

                            var prefs=await SharedPreferences.getInstance();
                            var shiftAdded=prefs.getBool("ShiftAdded")??false;

                            if(!shiftAdded)
                              prefs.setBool("ShiftAdded", true);

                            // showInSnackBar('Shift added successfully');


                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => ShiftList()),
                            );
                            showDialog(context: context, child:
                            new AlertDialog(
                              content: new Text("Shift added successfully"),
                            )
                            );
                          }
                          else if(res.toString()=='-1')
                            showInSnackBar('Shift already exists');
                          else
                            showInSnackBar('Unable to add shift');
                          setState(() {
                            _isButtonDisabled=false;
                          });
                        }).catchError((exp){
                          showInSnackBar('Unable to call server service');
                          setState(() {
                            _isButtonDisabled=false;
                          });
                        });



                        //   print(new DateTime(2001,01,01,int.parse(arr[0]),int.parse(arr[1]),00,00));
                        /*    if(from > to)
                              print(_from.text+' is greater');
                            else
                              print(_to.text+' is greater');*/
                        // requesttimeoff(_dateController.text ,_starttimeController.text,_endtimeController.text,_reasonController.text, context);
                      }
                    },
                  ),
                ],
              ),
            ),

          ],
        ),
      ),
      endDrawer: new AppDrawer(),
      body:  checkalreadylogin(),
    );

  }
  checkalreadylogin(){
    if(response==1) {
      return new IndexedStack(
        index: _currentIndex,
        children: <Widget>[
          underdevelopment(),
          underdevelopment(),
          mainbodyWidget(),
        ],
      );
    }else{
      /* Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => LoginPage()),
      );*/
    }
  }
  loader(){
    return new Container(
      child: Center(
        child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              Image.asset(
                  'assets/spinner.gif', height: 80.0, width: 80.0),
            ]),
      ),
    );
  }
  underdevelopment(){
    return new Container(
      child: Center(
        child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              Icon(Icons.android,color: appcolor),Text("Under development",style: new TextStyle(fontSize: 30.0,color: appcolor),)
            ]),
      ),
    );
  }

  mainbodyWidget(){
    return Center(
      child: Form(
        key: _formKey,
        child: SafeArea(
          child: ListView(
            padding: EdgeInsets.symmetric(horizontal: 24.0),
            children: <Widget>[
              Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  SizedBox(height: 20.0),
                  Center(
                    child:Text("Add Shift",style: new TextStyle(fontSize: 24.0,color:appcolor)),
                  ),
                  //Divider(color: Colors.black87,height: 5.0),
                  SizedBox(height: 20.0),
                  //Text('Shift Details',style: TextStyle(fontWeight: FontWeight.bold,fontSize: 20.0),),
                  SizedBox(height: 15.0),
                  //  Text("Shift Starts and Ends within",style: new TextStyle(fontSize: 16.0,color: Colors.black54,fontWeight:FontWeight.bold),textAlign: TextAlign.left),
                  Container(
                    decoration: ShapeDecoration(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                        side: BorderSide( color: Colors.grey.withOpacity(1.0), width: 1,),
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Row(children: <Widget>[
                        Container(
                          width: 280.0,
                          child: DropdownButtonHideUnderline(
                            child: ButtonTheme(
                              child: DropdownButton<String>(
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 16,
                                ),
                                iconSize: 30.0,
                                icon: Icon(
                                  Icons.arrow_drop_down,
                                  color: Colors.grey,
                                ),
                                isDense: true,
                                value: shifttype,
                                onChanged: (String newValue) {
                                  setState(() {
                                    shifttype =newValue;
                                    // var arr=newValue.split('#');
                                    //_countryCode.text=arr[1];
                                    // _countryId.text=arr[0];
                                  });
                                },
                                items: shiftlist.map((Map map) {
                                  print('shiftypenew----->>>'+shifttype);
                                   setState(() {
                                      if(shifttype=='3'){
                                        visiblity=false;
                                        visiblitymin=true;
                                      }else{
                                        visiblity=true;
                                        visiblitymin=false;
                                        visiblityhours=false;

                                      }

                                    });

                                  return new DropdownMenuItem<String>(
                                    value: map["id"].toString(),
                                    child:  new SizedBox(
//                                width: 200.0,
                                        child: new Text(
                                          map["name"],
                                        )
                                    ),
                                  );
                                }).toList(),

                              ),
                            ),
                          ),
                        ),
                      ],),
                    ),
                  ),
                  SizedBox(height: 20.0),
                  Container(
                    child: TextFormField(
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide( color: Colors.grey.withOpacity(0.0), width: 1,),
                        ),
                        labelText: 'Shift Name',
                      ),
                      //format: dateFormat,
                      controller: _shiftName,
                      validator: (date) {
                        if (_shiftName.text==null||_shiftName.text.trim()==''){
                          return 'Please enter shift name';
                        }
                      },
                    ),
                  ), //Enter date
                  SizedBox(height: 20.0),
                  Visibility(
                      visible:visiblitymin,child: Text('Minimum Working Hours',style: TextStyle(fontSize: 17.0),)),

                  Visibility(
                      visible:visiblity,child: Text('Shift Timings',style: TextStyle(fontSize: 17.0),)),
                  SizedBox(height: 15.0),
                  Visibility(
                    visible: visiblitymin,
                    child: Row(
                      children: <Widget>[
                        Expanded(
                          child: InkWell(
                            onTap: (){
                              DatePicker.showTimePicker(context, showTitleActions: true, showSecondsColumn:false, onChanged: (date) {
                                print('change $date in time zone ' + date.timeZoneOffset.inHours.toString());
                              }, onConfirm: (date) {
                                print('confirm $date');

                                setState(() {
                                  datenew=date;
                                  date1 = formatter.format(date);
                                  date2 = formatter1.format(date);
                                  date3 = formatter2.format(date);
                                  print(int.parse(date2));
                                  print(int.parse(date3));
                                  date_hours = int.parse(date2);
                                  date_min = int.parse(date3);

                                  visiblityhours=true;
                                });

                              }, currentTime: DateTime.now());

                            },
                            child: TextFormField(
                              enabled: false,
                              decoration: InputDecoration(
                                //hintText: 'Maximum 18 hours',
                                //hintStyle: TextStyle(color:Colors.black87),
                                suffixIcon: Padding(
                                    padding: EdgeInsets.only(top: 15), // add padding to adjust icon
                                    child: Icon(Icons.access_time)),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: BorderSide( color: Colors.grey.withOpacity(0.0), width: 1,),
                                ),
                                labelText: visiblityhours==false ? "Maximum 18 hours": date1.toString(),labelStyle: TextStyle(color: Colors.black45)
                              ),
                              //format: dateFormat,
                              controller: shiftHours,
                              validator: (date) {
                               /* if (_shiftName.text==null||_shiftName.text.trim()==''){
                                  return 'Please enter shift name';
                                }

                                */
                              },
                              onTap: (){


                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                    ),
            /*
                        ,Visibility(
                    visible: visiblityhours,
                          child: Text(
                            date1.toString(),textAlign: TextAlign.center,
                    style: TextStyle(color:Colors.black87,fontSize: 18.0),
                  ),
                        ),
                  */
                  Visibility(
                    visible:visiblity, child: Row(
                      children: <Widget>[
                        Expanded(
                          child:DateTimeField(
                            format: timeFormat,
                            controller: _from,
                            //editable: false,
                            onShowPicker: (context, currentValue) async {
                              final time = await showTimePicker(
                                context: context,
                                initialTime: TimeOfDay.fromDateTime(currentValue ?? DateTime.now()),
                              );
                              return DateTimeField.convert(time);
                            },
                            readOnly: true,
                            decoration: InputDecoration(
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide( color: Colors.grey.withOpacity(0.0), width: 1,),
                              ),

                              labelText: 'From',
                              labelStyle: TextStyle(
                                fontSize: 15,


                              ),
                            ),
                            validator: (time) {
                              if (time==null && shifttype!='3') {
                                return 'Please enter shift start time';
                              }
                            },
                          ),
                        ),
                        SizedBox(width: 10.0),
                        Expanded(
                          child:DateTimeField(
                            format: timeFormat,
                            controller: _to,
                            // editable: false,
                            onShowPicker: (context, currentValue) async {
                              final time = await showTimePicker(
                                context: context,
                                initialTime: TimeOfDay.fromDateTime(currentValue ?? DateTime.now()),
                              );
                              return DateTimeField.convert(time);
                            },
                            readOnly: true,
                            decoration: InputDecoration(
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: BorderSide( color: Colors.grey.withOpacity(0.0), width: 1,),
                                ),

                                labelText: 'To',
                                labelStyle: TextStyle(
                                  fontSize: 15,

                                )
                            ),

                            validator: (time) {
                              if (time==null && shifttype!='3') {
                                return 'Please enter shift end time';
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 20.0),
                  Visibility(visible:visiblity,child: Text('Break Timings',style: TextStyle(fontSize: 17.0),)),
                  SizedBox(height: 15.0),
                  Visibility(
                    visible:visiblity,child: Row(
                      children: <Widget>[
                        Expanded(
                          child:DateTimeField(
                            format: timeFormat,
                            controller: _from_b,
                            //editable: false,
                            onShowPicker: (context, currentValue) async {
                              final time = await showTimePicker(
                                context: context,
                                initialTime: TimeOfDay.fromDateTime(currentValue ?? DateTime.now()),
                              );
                              return DateTimeField.convert(time);
                            },
                            readOnly: true,

                            decoration: InputDecoration(
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: BorderSide( color: Colors.grey.withOpacity(0.0), width: 1,),
                                ),
                                labelText: 'From',
                                labelStyle: TextStyle(
                                  fontSize: 15,

                                )
                            ),
                            validator: (time) {
                              if (time==null && shifttype!='3') {
                                return 'Please enter break start time';
                              }
                            },
                          ),
                        ),
                        SizedBox(width: 10.0),
                        Expanded(
                          child:DateTimeField(
                            format: timeFormat,
                            controller: _to_b,
                            // editable: false,
                            onShowPicker: (context, currentValue) async {
                              final time = await showTimePicker(
                                context: context,
                                initialTime: TimeOfDay.fromDateTime(currentValue ?? DateTime.now()),
                              );
                              return DateTimeField.convert(time);
                            },
                            readOnly: true,
                            decoration: InputDecoration(
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: BorderSide( color: Colors.grey.withOpacity(0.0), width: 1,),
                                ),

                                labelText: 'To',
                                labelStyle: TextStyle(
                                  fontSize: 15,

                                )
                            ),
                            validator: (time) {
                              if (time==null && shifttype!='3') {
                                return 'Please enter break end time';
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

            ],
          ),
        ),
      ),
    );
  }
}