// Copyright 2017 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.


import 'package:Shrine/payment.dart';
import 'package:Shrine/services/services.dart';
import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'Image_view.dart';
import 'drawer.dart';
import 'globals.dart';
import 'outside_label.dart';
import 'dart:convert';
import 'globals.dart' as globals;
import 'package:http/http.dart' as http;
// This app is a stateful, it tracks the user's current choice.
class CustomDateAttendance extends StatefulWidget {
  @override
  _CustomDateAttendance createState() => _CustomDateAttendance();
}
TextEditingController today;String _orgName;
class _CustomDateAttendance extends State<CustomDateAttendance> with SingleTickerProviderStateMixin {
  TabController _controller;
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  String trialstatus = "";

  var formatter = new DateFormat('dd-MMM-yyyy');
  bool res = true;
  String admin_sts = "0";
  var Hightvar = 0.0;
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
      trialstatus = prefs.getString('trialstatus') ?? '';
      if(admin_sts == '2')
        Hightvar =  MediaQuery.of(context).size.height*0.35;
      else
        Hightvar =  MediaQuery.of(context).size.height*0.35;
    });
  }
  @override
  void initState() {
    super.initState();
    checkNetForOfflineMode(context);
    appResumedPausedLogic(context);
    _controller = new TabController(length: 4, vsync: this);
    getOrgName();
    today = new TextEditingController();
    today.text = formatter.format(DateTime.now());
    platform.setMethodCallHandler(_handleMethod);
  }
  static const platform = const MethodChannel('location.spoofing.check');

  Future<dynamic> _handleMethod(MethodCall call) async {
    switch(call.method) {
/*
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

 */
    }
  } @override
  Widget build(BuildContext context) {
    return new Scaffold(
      key: _scaffoldKey,
      appBar: new AppBar(
        title: new Text(_orgName??"", style: new TextStyle(fontSize: 20.0)),
        backgroundColor: appcolor,
      ),
      endDrawer: new AppDrawer(),
      body: new ListView(
        physics: NeverScrollableScrollPhysics(),
        children: <Widget>[
          SizedBox(height:10.0),
          new Container(
            child: Center(child:Text("Daily Attendance",style: TextStyle(fontSize: 22.0,color: appcolor),),),
          ),
          Divider(color: Colors.black54,height: 1.5,),
          Container(
            child: DateTimeField(
              //dateOnly: true,
              format: formatter,
              controller: today,
              //editable: false,
              onShowPicker: (context, currentValue) {
                if(trialstatus=='2')
                  return showDatePicker(
                      context: context,
                      firstDate: DateTime.now().subtract(Duration(days: 2)),
                      initialDate: currentValue ?? DateTime.now(),
                      lastDate: DateTime.now());
                else
                  return showDatePicker(
                      context: context,
                      firstDate: DateTime(1900),
                      initialDate: currentValue ?? DateTime.now(),
                      lastDate: DateTime.now());
              },
              readOnly: true,
              decoration: InputDecoration(
                prefixIcon: Padding(
                  padding: EdgeInsets.all(0.0),
                  child: Icon(
                    Icons.date_range,
                    color: Colors.grey,
                  ), // icon is 48px widget.
                ), // icon is 48px widget.
                labelText: "Select Date",
                //hintText: 'Select Date()',
              ),
              onChanged: (date) {
                setState(() {
                  if (date != null && date.toString()!='')
                    res = true; //showInSnackBar(date.toString());
                  else
                    res = false;
                });
              },
              validator: (date) {
                if (date == null) {
                  return 'Please select date';
                }
              },
            ),
          ),

          (res==true && admin_sts=='1') ?new Container(
            padding: EdgeInsets.all(0.1),
            margin: EdgeInsets.all(0.1),
            child: new ListTile(
              title: new SizedBox(height: MediaQuery.of(context).size.height*0.20,

                child: new FutureBuilder<List<Map<String,String>>>(
                    future: getChartDataCDate(today.text),
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        if (snapshot.data.length > 0) {
                          return new PieOutsideLabelChart.withRandomData(snapshot.data);
                        }
                      }
                      return new Center( child: CircularProgressIndicator());
                    }
                ),

                //  child: new PieOutsideLabelChart.withRandomData(),

                width: MediaQuery.of(context).size.width*1.0,),
            ),
          ): admin_sts=='1'?Container(
            height: MediaQuery.of(context).size.height*0.25,
            child: Center(
              child: Container(
                width: MediaQuery.of(context).size.width*1,
                color: appcolor.withOpacity(0.1),
                padding:EdgeInsets.only(top:5.0,bottom: 5.0),
                child:Text("No Chart Available",style: TextStyle(fontSize: 18.0),textAlign: TextAlign.center,),
              ),
            ),

          ):Center(),
          (res==true && admin_sts=='1')?new Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              Text('Present(P)',style: TextStyle(color:appcolor,fontSize: 12.0),),
              Text('Absent(A)',style: TextStyle(color:appcolor,fontSize: 12.0),),
              Text('Late Comers(LC)',style: TextStyle(color:appcolor,fontSize: 12.0),),
              Text('Early Leavers(EL)',style: TextStyle(color:appcolor,fontSize: 12.0),)
            ],
          ):Center(),

          Divider(),
          new Container(
            decoration: new BoxDecoration(color: Colors.black54),
            child: new TabBar(
              indicator: BoxDecoration(color: buttoncolor,),
              controller: _controller,
              tabs: [
                new Tab(
                  text: 'Present',
                ),
                new Tab(
                  text: 'Absent',
                ),
                new Tab(
                  text: 'Late \nComers',
                ),
                new Tab(
                  text: 'Early \nLeavers',
                ),
              ],
            ),
          ),
          new Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              SizedBox(height: 50.0,),
              Container(
                width: MediaQuery.of(context).size.width*0.46,
                child:Text('  Name',style: TextStyle(color: appcolor,fontWeight:FontWeight.bold,fontSize: 16.0),),
              ),
              SizedBox(height: 50.0,),
              Container(
                width: MediaQuery.of(context).size.width*0.22,
                child:Text('Time In',textAlign: TextAlign.center,style: TextStyle(color: appcolor,fontWeight:FontWeight.bold,fontSize: 16.0),),
              ),
              SizedBox(height: 50.0,),
              Container(
                width: MediaQuery.of(context).size.width*0.22,
                child:Text('Time Out',style: TextStyle(color: appcolor,fontWeight:FontWeight.bold,fontSize: 16.0),),
              ),
            ],
          ),
          new Divider(height: 1.0,),
          res==true?new Container(
            height: Hightvar,
            child: new TabBarView(
              controller: _controller,
              children: <Widget>[
                new Container(
                  height: Hightvar,
                  //   shape: Border.all(color: Colors.deepOrange),
                  child: new ListTile(
                    title:
                    Container( height: Hightvar,
                      //width: MediaQuery.of(context).size.width*.99,
                      color: Colors.white,
                      //////////////////////////////////////////////////////////////////////---------------------------------
                      child: new FutureBuilder<List<Attn>>(
                        future: getCDateAttn('present',today.text),
                        builder: (context, snapshot) {
                          if (snapshot.hasData) {
                            if(snapshot.data.length>0) {
                              return new ListView.builder(
                                  scrollDirection: Axis.vertical,
                                  itemCount: snapshot.data.length,
                                  itemBuilder: (BuildContext context, int index) {
                                    return Stack(
                                      children: <Widget>[

                                        new Column(
                                            children: <Widget>[
                                              Row(
                                                mainAxisAlignment: MainAxisAlignment
                                                    .spaceAround,
                                                children: <Widget>[
                                                  SizedBox(height: 40.0,),
                                                  Container(
                                                    width: MediaQuery
                                                        .of(context)
                                                        .size
                                                        .width * 0.46,
                                                    child: Column(
                                                      crossAxisAlignment: CrossAxisAlignment
                                                          .start,
                                                      children: <Widget>[
                                                        Text(snapshot.data[index].Name
                                                            .toString(), style: TextStyle(
                                                            color: Colors.black87,
                                                            fontWeight: FontWeight.bold,
                                                            fontSize: 16.0),),

                                                        InkWell(
                                                          child: Text('Time In: ' +
                                                              snapshot.data[index]
                                                                  .CheckInLoc.toString(),
                                                              style: TextStyle(
                                                                  color: Colors.black54,
                                                                  fontSize: 12.0)),
                                                          onTap: () {
                                                            goToMap(
                                                                snapshot.data[index]
                                                                    .LatitIn ,
                                                                snapshot.data[index]
                                                                    .LongiIn);
                                                          },
                                                        ),
                                                        SizedBox(height:2.0),
                                                        InkWell(
                                                          child: Text('Time Out: ' +
                                                              snapshot.data[index]
                                                                  .CheckOutLoc.toString(),
                                                            style: TextStyle(
                                                                color: Colors.black54,
                                                                fontSize: 12.0),),
                                                          onTap: () {
                                                            goToMap(
                                                                snapshot.data[index]
                                                                    .LatitOut,
                                                                snapshot.data[index]
                                                                    .LongiOut);
                                                          },
                                                        ),
                                                        SizedBox(height: 5.0,),
                                                        if(snapshot.data[index].ShiftType.toString()=='3')
                                                          Text("Logged Hours: "+snapshot.data[index].DayLoggedHours
                                                              .toString(), style: TextStyle(
                                                              color: Colors.black87,
                                                              fontWeight: FontWeight.bold,
                                                              fontSize: 14.0),),

                                                      ],
                                                    ),
                                                  ),

                                                  Container(
                                                      width: MediaQuery
                                                          .of(context)
                                                          .size
                                                          .width * 0.22,
                                                      child: Column(
                                                        crossAxisAlignment: CrossAxisAlignment
                                                            .center,
                                                        children: <Widget>[
                                                          Text(snapshot.data[index].TimeIn
                                                              .toString(),style: TextStyle(fontWeight: FontWeight.bold),),
                                                          Container(
                                                            width: 62.0,
                                                            height: 62.0,
                                                            child:InkWell(
                                                              child: Container(
                                                                  decoration: new BoxDecoration(
                                                                      shape: BoxShape
                                                                          .circle,
                                                                      image: new DecorationImage(
                                                                          fit: BoxFit.fill,
                                                                          image: new NetworkImage(
                                                                              snapshot
                                                                                  .data[index]
                                                                                  .EntryImage)
                                                                      )
                                                                  )),
                                                              onTap: (){
                                                                Navigator.push(
                                                                  context,
                                                                  MaterialPageRoute(builder: (context) => ImageView(myimage: snapshot.data[index].EntryImage,org_name: _orgName)),
                                                                );
                                                              },
                                                            ),
                                                          ),

                                                        ],
                                                      )

                                                  ),
                                                  Container(
                                                      width: MediaQuery
                                                          .of(context)
                                                          .size
                                                          .width * 0.22,
                                                      child: Column(
                                                        crossAxisAlignment: CrossAxisAlignment
                                                            .center,
                                                        children: <Widget>[
                                                          Text(snapshot.data[index].TimeOut
                                                              .toString(),style: TextStyle(fontWeight: FontWeight.bold),),
                                                          Container(
                                                            width: 62.0,
                                                            height: 62.0,
                                                            child:InkWell(
                                                              child: Container(
                                                                  decoration: new BoxDecoration(
                                                                      shape: BoxShape
                                                                          .circle,
                                                                      image: new DecorationImage(
                                                                          fit: BoxFit.fill,
                                                                          image: new NetworkImage(
                                                                              snapshot
                                                                                  .data[index]
                                                                                  .ExitImage)
                                                                      )
                                                                  )),
                                                              onTap: (){
                                                                Navigator.push(
                                                                  context,
                                                                  MaterialPageRoute(builder: (context) => ImageView(myimage: snapshot.data[index].ExitImage,org_name: _orgName)),
                                                                );
                                                              },
                                                            ),
                                                          ),

                                                        ],
                                                      )

                                                  ),
                                                ],

                                              ),
                                              Divider(color: Colors.black26,),
                                              (index == snapshot.data.length - 1 &&
                                                  trialstatus == '2')
                                                  ? Row(children: <Widget>[
                                                //  SizedBox(height: 25.0,),
                                                Padding(
                                                  padding: const EdgeInsets.only(
                                                      bottom: 4.0),
                                                  child: Container(
                                                    //  padding: EdgeInsets.only(bottom: 10.0),
                                                    child: InkWell(
                                                      child: Center(
                                                        child: Container(
                                                          width: MediaQuery.of(
                                                              context)
                                                              .size
                                                              .width *
                                                              0.88,
                                                          color: Colors.red[400],
                                                          padding:
                                                          EdgeInsets.only(
                                                              top: 3.0,
                                                              bottom: 3.0),
                                                          child: Text(
                                                              "To view complete data, upgrade to Premium Plan ",
                                                              style: TextStyle(
                                                                  fontSize: 18.0,
                                                                  color: Colors
                                                                      .white),
                                                              textAlign: TextAlign
                                                                  .center),
                                                        ),
                                                      ),
                                                      onTap: () {
                                                        Navigator.push(
                                                          context,
                                                          MaterialPageRoute(
                                                              builder: (context) =>
                                                                  PaymentPage()),
                                                        );
                                                      },
                                                    ),
                                                  ),
                                                ),
                                                SizedBox(
                                                  height: 50.0,
                                                ),
                                              ])
                                                  : new Center(),
                                            ]),
                                        if(snapshot.data[index].ShiftType.toString()=='3')
                                          new Positioned(
                                            right:0.0,
                                            top: 40,
                                            child: Container(
                                                padding: EdgeInsets.only(top:1,right: 3,bottom: 1,left: 3),
                                                color: buttoncolor,
                                                child: InkWell(
                                                  child: Icon(Icons.more_horiz,color: Colors.white,),
                                                  onTap: (){
                                                    showInterimAttendanceDialog(snapshot.data[index].AttendanceMasterId);
                                                  },
                                                )
                                            ),
                                          ),
                                      ],
                                    );}
                              );
                            }else{
                              return new Container(
                                  height: MediaQuery.of(context).size.height*0.30,
                                  child:Center(
                                    child: Container(
                                      width: MediaQuery.of(context).size.width*1,
                                      color: appcolor.withOpacity(0.1),
                                      padding:EdgeInsets.only(top:5.0,bottom: 5.0),
                                      child:Text("No one is present on this date ",style: TextStyle(fontSize: 18.0),textAlign: TextAlign.center,),
                                    ),
                                  )
                              );
                            }
                          }
                          else if (snapshot.hasError) {
                            return new Text("Unable to connect server");
                            //  return new Text("${snapshot.error}");
                          }

                          // By default, show a loading spinner
                          return new Center( child: CircularProgressIndicator());
                        },
                      ),
                      //////////////////////////////////////////////////////////////////////---------------------------------
                    ),
                  ),
                ),
                //////////////TABB 2 Start
                new Container(

                  height: Hightvar,
                  //   shape: Border.all(color: Colors.deepOrange),
                  child: new ListTile(
                    title:
                    Container( height: Hightvar,
                      //width: MediaQuery.of(context).size.width*.99,
                      color: Colors.white,
                      //////////////////////////////////////////////////////////////////////---------------------------------
                      child: new FutureBuilder<List<Attn>>(
                        future: getCDateAttn('absent',today.text),
                        builder: (context, snapshot) {
                          if (snapshot.hasData) {
                            if(snapshot.data.length>0) {
                              return new ListView.builder(
                                  scrollDirection: Axis.vertical,
                                  itemCount: snapshot.data.length,
                                  itemBuilder: (BuildContext context, int index) {
                                    return Column(
                                        children: <Widget>[
                                          new Row(
//                                      mainAxisAlignment: MainAxisAlignment
//                                          .spaceAround,
                                            children: <Widget>[
                                              SizedBox(height: 30.0,),
                                              Container(
                                                width: MediaQuery
                                                    .of(context)
                                                    .size
                                                    .width * 0.46,
                                                child: Column(
                                                  crossAxisAlignment: CrossAxisAlignment
                                                      .start,
                                                  children: <Widget>[
                                                    Padding(
                                                      padding: const EdgeInsets.all(8.0),
                                                      child: Text(snapshot.data[index].Name
                                                          .toString(), style: TextStyle(
                                                          color: Colors.black87,
                                                          fontWeight: FontWeight.bold,
                                                          fontSize: 16.0),),
                                                    ),
                                                  ],
                                                ),
                                              ),

//                                        Container(
//                                            width: MediaQuery
//                                                .of(context)
//                                                .size
//                                                .width * 0.22,
//                                            child: Column(
//                                              crossAxisAlignment: CrossAxisAlignment
//                                                  .center,
//                                              children: <Widget>[
//                                                Text(snapshot.data[index].TimeIn
//                                                    .toString()),
//                                              ],
//                                            )
//
//                                        ),
//                                        Container(
//                                            width: MediaQuery
//                                                .of(context)
//                                                .size
//                                                .width * 0.22,
//                                            child: Column(
//                                              crossAxisAlignment: CrossAxisAlignment
//                                                  .center,
//                                              children: <Widget>[
//                                                Text(snapshot.data[index].TimeOut
//                                                    .toString()),
//                                              ],
//                                            )
//
//                                        ),
                                            ],
                                          ),
                                          (index == snapshot.data.length - 1 &&
                                              trialstatus == '2')
                                              ? Row(children: <Widget>[
                                            //  SizedBox(height: 25.0,),
                                            Padding(
                                              padding:
                                              const EdgeInsets.only(
                                                  bottom: 4.0),
                                              child: Container(
                                                //  padding: EdgeInsets.only(bottom: 10.0),
                                                child: InkWell(
                                                  child: Center(
                                                    child: Container(
                                                      width: MediaQuery.of(
                                                          context)
                                                          .size
                                                          .width *
                                                          0.88,
                                                      color:
                                                      Colors.red[400],
                                                      padding:
                                                      EdgeInsets.only(
                                                          top: 3.0,
                                                          bottom:
                                                          3.0),
                                                      child: Text(
                                                          "To view complete data, upgrade to Premium Plan ",
                                                          style: TextStyle(
                                                              fontSize:
                                                              18.0,
                                                              color: Colors
                                                                  .white),
                                                          textAlign:
                                                          TextAlign
                                                              .center),
                                                    ),
                                                  ),
                                                  onTap: () {
                                                    Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                          builder:
                                                              (context) =>
                                                              PaymentPage()),
                                                    );
                                                  },
                                                ),
                                              ),
                                            ),
                                            SizedBox(
                                              height: 50.0,
                                            ),
                                          ])
                                              : new Center(),
                                        ]
                                    );

                                  }
                              );
                            }else{
                              return new Container(
                                  height: MediaQuery.of(context).size.height*0.30,
                                  child:Center(
                                    child: Container(
                                      width: MediaQuery.of(context).size.width*1,
                                      color:appcolor.withOpacity(0.1),
                                      padding:EdgeInsets.only(top:5.0,bottom: 5.0),
                                      child:Text("No one is absent on this date ",style: TextStyle(fontSize: 18.0),textAlign: TextAlign.center,),
                                    ),
                                  )
                              );
                            }
                          }
                          else if (snapshot.hasError) {
                            return new Text("Unable to connect server");
                            // return new Text("${snapshot.error}");
                          }

                          // By default, show a loading spinner
                          return new Center( child: CircularProgressIndicator());
                        },
                      ),
                      //////////////////////////////////////////////////////////////////////---------------------------------
                    ),
                  ),

                ),

                /////////////TAB 2 Ends



                /////////////TAB 3 STARTS

                new Container(

                  height: Hightvar,
                  //   shape: Border.all(color: Colors.deepOrange),
                  child: new ListTile(
                    title:
                    Container( height: Hightvar,
                      //width: MediaQuery.of(context).size.width*.99,
                      color: Colors.white,
                      //////////////////////////////////////////////////////////////////////---------------------------------
                      child: new FutureBuilder<List<Attn>>(
                        future: getCDateAttn('latecomings',today.text),
                        builder: (context, snapshot) {
                          if (snapshot.hasData) {
                            if(snapshot.data.length>0) {
                              return new ListView.builder(
                                  scrollDirection: Axis.vertical,
                                  itemCount: snapshot.data.length,
                                  itemBuilder: (BuildContext context, int index) {
                                    return new Column(
                                        children: <Widget>[
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment
                                                .spaceAround,
                                            children: <Widget>[
                                              SizedBox(height: 40.0,),
                                              Container(
                                                width: MediaQuery
                                                    .of(context)
                                                    .size
                                                    .width * 0.46,
                                                child: Column(
                                                  crossAxisAlignment: CrossAxisAlignment
                                                      .start,
                                                  children: <Widget>[
                                                    Text(snapshot.data[index].Name
                                                        .toString(), style: TextStyle(
                                                        color: Colors.black87,
                                                        fontWeight: FontWeight.bold,
                                                        fontSize: 16.0),),

                                                    InkWell(
                                                      child: Text('Time In: ' +
                                                          snapshot.data[index]
                                                              .CheckInLoc.toString(),
                                                          style: TextStyle(
                                                              color: Colors.black54,
                                                              fontSize: 12.0)),
                                                      onTap: () {
                                                        goToMap(
                                                            snapshot.data[index]
                                                                .LatitIn ,
                                                            snapshot.data[index]
                                                                .LongiIn);
                                                      },
                                                    ),
                                                    SizedBox(height:2.0),
                                                    InkWell(
                                                      child: Text('Time Out: ' +
                                                          snapshot.data[index]
                                                              .CheckOutLoc.toString(),
                                                        style: TextStyle(
                                                            color: Colors.black54,
                                                            fontSize: 12.0),),
                                                      onTap: () {
                                                        goToMap(
                                                            snapshot.data[index]
                                                                .LatitOut,
                                                            snapshot.data[index]
                                                                .LongiOut);
                                                      },
                                                    ),
                                                    SizedBox(height: 15.0,),


                                                  ],
                                                ),
                                              ),

                                              Container(
                                                  width: MediaQuery
                                                      .of(context)
                                                      .size
                                                      .width * 0.22,
                                                  child: Column(
                                                    crossAxisAlignment: CrossAxisAlignment
                                                        .center,
                                                    children: <Widget>[
                                                      Text(snapshot.data[index].TimeIn
                                                          .toString(),style: TextStyle(fontWeight: FontWeight.bold),),
                                                      Container(
                                                        width: 62.0,
                                                        height: 62.0,
                                                        child:InkWell(
                                                          child: Container(
                                                              decoration: new BoxDecoration(
                                                                  shape: BoxShape
                                                                      .circle,
                                                                  image: new DecorationImage(
                                                                      fit: BoxFit.fill,
                                                                      image: new NetworkImage(
                                                                          snapshot
                                                                              .data[index]
                                                                              .EntryImage)
                                                                  )
                                                              )),
                                                          onTap: (){
                                                            Navigator.push(
                                                              context,
                                                              MaterialPageRoute(builder: (context) => ImageView(myimage: snapshot.data[index].EntryImage,org_name: _orgName)),
                                                            );
                                                          },
                                                        ),
                                                      ),

                                                    ],
                                                  )

                                              ),
                                              Container(
                                                  width: MediaQuery
                                                      .of(context)
                                                      .size
                                                      .width * 0.22,
                                                  child: Column(
                                                    crossAxisAlignment: CrossAxisAlignment
                                                        .center,
                                                    children: <Widget>[
                                                      Text(snapshot.data[index].TimeOut
                                                          .toString(),style: TextStyle(fontWeight: FontWeight.bold),),
                                                      Container(
                                                        width: 62.0,
                                                        height: 62.0,
                                                        child:InkWell(
                                                          child: Container(
                                                              decoration: new BoxDecoration(
                                                                  shape: BoxShape
                                                                      .circle,
                                                                  image: new DecorationImage(
                                                                      fit: BoxFit.fill,
                                                                      image: new NetworkImage(
                                                                          snapshot
                                                                              .data[index]
                                                                              .ExitImage)
                                                                  )
                                                              )),
                                                          onTap: (){
                                                            Navigator.push(
                                                              context,
                                                              MaterialPageRoute(builder: (context) => ImageView(myimage: snapshot.data[index].ExitImage,org_name: _orgName)),
                                                            );
                                                          },
                                                        ),
                                                      ),

                                                    ],
                                                  )

                                              ),
                                            ],

                                          ),
                                          Divider(color: Colors.black26,),
                                          (index == snapshot.data.length - 1 &&
                                              trialstatus == '2')
                                              ? Row(children: <Widget>[
                                            //  SizedBox(height: 25.0,),
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                  bottom: 4.0),
                                              child: Container(
                                                //  padding: EdgeInsets.only(bottom: 10.0),
                                                child: InkWell(
                                                  child: Center(
                                                    child: Container(
                                                      width: MediaQuery.of(
                                                          context)
                                                          .size
                                                          .width *
                                                          0.88,
                                                      color: Colors.red[400],
                                                      padding:
                                                      EdgeInsets.only(
                                                          top: 3.0,
                                                          bottom: 3.0),
                                                      child: Text(
                                                          "To view complete data, upgrade to Premium Plan ",
                                                          style: TextStyle(
                                                              fontSize: 18.0,
                                                              color: Colors
                                                                  .white),
                                                          textAlign: TextAlign
                                                              .center),
                                                    ),
                                                  ),
                                                  onTap: () {
                                                    Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                          builder: (context) =>
                                                              PaymentPage()),
                                                    );
                                                  },
                                                ),
                                              ),
                                            ),
                                            SizedBox(
                                              height: 50.0,
                                            ),
                                          ])
                                              : new Center(),
                                        ]);}
                              );
                            }else{
                              return new Container(
                                  height: MediaQuery.of(context).size.height*0.30,
                                  child:Center(
                                    child: Container(
                                      width: MediaQuery.of(context).size.width*1,
                                      color: appcolor.withOpacity(0.1),
                                      padding:EdgeInsets.only(top:5.0,bottom: 5.0),
                                      child:Text("No late comers on this date ",style: TextStyle(fontSize: 18.0),textAlign: TextAlign.center,),
                                    ),
                                  )
                              );
                            }
                          }
                          else if (snapshot.hasError) {
                            return new Text("Unable to connect server");
                          }

                          // By default, show a loading spinner
                          return new Center( child: CircularProgressIndicator());
                        },
                      ),
                      //////////////////////////////////////////////////////////////////////---------------------------------
                    ),
                  ),

                ),
                /////////TAB 3 ENDS


                /////////TAB 4 STARTS
                new Container(


                  height: Hightvar,
                  //   shape: Border.all(color: Colors.deepOrange),
                  child: new ListTile(
                    title:
                    Container( height: Hightvar,
                      //width: MediaQuery.of(context).size.width*.99,
                      color: Colors.white,
                      //////////////////////////////////////////////////////////////////////---------------------------------
                      child: new FutureBuilder<List<Attn>>(
                        future: getCDateAttn('earlyleavings',today.text),
                        builder: (context, snapshot) {
                          if (snapshot.hasData) {
                            if(snapshot.data.length>0) {
                              return new ListView.builder(
                                  scrollDirection: Axis.vertical,
                                  itemCount: snapshot.data.length,
                                  itemBuilder: (BuildContext context, int index) {
                                    return new Column(
                                        children: <Widget>[
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment
                                                .spaceAround,
                                            children: <Widget>[
                                              SizedBox(height: 40.0,),
                                              Container(
                                                width: MediaQuery
                                                    .of(context)
                                                    .size
                                                    .width * 0.46,
                                                child: Column(
                                                  crossAxisAlignment: CrossAxisAlignment
                                                      .start,
                                                  children: <Widget>[
                                                    Text(snapshot.data[index].Name
                                                        .toString(), style: TextStyle(
                                                        color: Colors.black87,
                                                        fontWeight: FontWeight.bold,
                                                        fontSize: 16.0),),

                                                    InkWell(
                                                      child: Text('Time In: ' +
                                                          snapshot.data[index]
                                                              .CheckInLoc.toString(),
                                                          style: TextStyle(
                                                              color: Colors.black54,
                                                              fontSize: 12.0)),
                                                      onTap: () {
                                                        goToMap(
                                                            snapshot.data[index]
                                                                .LatitIn ,
                                                            snapshot.data[index]
                                                                .LongiIn);
                                                      },
                                                    ),
                                                    SizedBox(height:2.0),
                                                    InkWell(
                                                      child: Text('Time Out: ' +
                                                          snapshot.data[index]
                                                              .CheckOutLoc.toString(),
                                                        style: TextStyle(
                                                            color: Colors.black54,
                                                            fontSize: 12.0),),
                                                      onTap: () {
                                                        goToMap(
                                                            snapshot.data[index]
                                                                .LatitOut,
                                                            snapshot.data[index]
                                                                .LongiOut);
                                                      },
                                                    ),
                                                    SizedBox(height: 15.0,),


                                                  ],
                                                ),
                                              ),

                                              Container(
                                                  width: MediaQuery
                                                      .of(context)
                                                      .size
                                                      .width * 0.22,
                                                  child: Column(
                                                    crossAxisAlignment: CrossAxisAlignment
                                                        .center,
                                                    children: <Widget>[
                                                      Text(snapshot.data[index].TimeIn
                                                          .toString(),style: TextStyle(fontWeight: FontWeight.bold),),
                                                      Container(
                                                        width: 62.0,
                                                        height: 62.0,
                                                        child:InkWell(
                                                          child: Container(
                                                              decoration: new BoxDecoration(
                                                                  shape: BoxShape
                                                                      .circle,
                                                                  image: new DecorationImage(
                                                                      fit: BoxFit.fill,
                                                                      image: new NetworkImage(
                                                                          snapshot
                                                                              .data[index]
                                                                              .EntryImage)
                                                                  )
                                                              )),
                                                          onTap: (){
                                                            Navigator.push(
                                                              context,
                                                              MaterialPageRoute(builder: (context) => ImageView(myimage: snapshot.data[index].EntryImage,org_name: _orgName)),
                                                            );
                                                          },
                                                        ),
                                                      ),

                                                    ],
                                                  )

                                              ),
                                              Container(
                                                  width: MediaQuery
                                                      .of(context)
                                                      .size
                                                      .width * 0.22,
                                                  child: Column(
                                                    crossAxisAlignment: CrossAxisAlignment
                                                        .center,
                                                    children: <Widget>[
                                                      Text(snapshot.data[index].TimeOut
                                                          .toString(),style: TextStyle(fontWeight: FontWeight.bold),),
                                                      Container(
                                                        width: 62.0,
                                                        height: 62.0,
                                                        child:InkWell(
                                                          child: Container(
                                                              decoration: new BoxDecoration(
                                                                  shape: BoxShape
                                                                      .circle,
                                                                  image: new DecorationImage(
                                                                      fit: BoxFit.fill,
                                                                      image: new NetworkImage(
                                                                          snapshot
                                                                              .data[index]
                                                                              .ExitImage)
                                                                  )
                                                              )),
                                                          onTap: (){
                                                            Navigator.push(
                                                              context,
                                                              MaterialPageRoute(builder: (context) => ImageView(myimage: snapshot.data[index].ExitImage,org_name: _orgName)),
                                                            );
                                                          },
                                                        ),
                                                      ),

                                                    ],
                                                  )

                                              ),
                                            ],

                                          ),
                                          Divider(color: Colors.black26,),
                                          (index == snapshot.data.length - 1 &&
                                              trialstatus == '2')
                                              ? Row(children: <Widget>[
                                            //  SizedBox(height: 25.0,),
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                  bottom: 4.0),
                                              child: Container(
                                                //  padding: EdgeInsets.only(bottom: 10.0),
                                                child: InkWell(
                                                  child: Center(
                                                    child: Container(
                                                      width: MediaQuery.of(
                                                          context)
                                                          .size
                                                          .width *
                                                          0.88,
                                                      color: Colors.red[400],
                                                      padding:
                                                      EdgeInsets.only(
                                                          top: 3.0,
                                                          bottom: 3.0),
                                                      child: Text(
                                                          "To view complete data, upgrade to Premium Plan ",
                                                          style: TextStyle(
                                                              fontSize: 18.0,
                                                              color: Colors
                                                                  .white),
                                                          textAlign: TextAlign
                                                              .center),
                                                    ),
                                                  ),
                                                  onTap: () {
                                                    Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                          builder: (context) =>
                                                              PaymentPage()),
                                                    );
                                                  },
                                                ),
                                              ),
                                            ),
                                            SizedBox(
                                              height: 50.0,
                                            ),
                                          ])
                                              : new Center(),
                                        ]);}
                              );
                            }else{
                              return new Container(
                                  height: MediaQuery.of(context).size.height*0.25,
                                  child:Center(
                                    child: Container(
                                      width: MediaQuery.of(context).size.width*1,
                                      color: appcolor.withOpacity(0.1),
                                      padding:EdgeInsets.only(top:5.0,bottom: 5.0),
                                      child:Text("No early leavers on this date",style: TextStyle(fontSize: 18.0),textAlign: TextAlign.center,),
                                    ),
                                  )
                              );
                            }
                          }
                          else if (snapshot.hasError) {
                            return new Text("Unable to connect server");
                          }

                          // By default, show a loading spinner
                          return new Center( child: CircularProgressIndicator());
                        },
                      ),
                      //////////////////////////////////////////////////////////////////////---------------------------------
                    ),
                  ),
                ),
                ///////////////////TAB 4 Ends
              ],
            ),
          ):Container(
            height: MediaQuery.of(context).size.height*0.25,
            child:Center(
              child: Container(
                width: MediaQuery.of(context).size.width*1,
                color: appcolor.withOpacity(0.1),
                padding:EdgeInsets.only(top:5.0,bottom: 5.0),
                child:Text("No Data Available",style: TextStyle(fontSize: 18.0),textAlign: TextAlign.center,),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void showInterimAttendanceDialog(String attendanceMasterId) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Interim Attendance",textAlign: TextAlign.center,),
          content:FutureBuilder<List<User>>(
            future: getInterimAttendanceSummary(attendanceMasterId),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return Container(
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height*.7,
                  child: new ListView.builder(
                      scrollDirection: Axis.vertical,
                      shrinkWrap: true,
                      physics: ClampingScrollPhysics(),
                      itemCount: snapshot.data.length,
                      itemBuilder: (context, index) {
                        //   double h_width = MediaQuery.of(context).size.width*0.5; // screen's 50%
                        //   double f_width = MediaQuery.of(context).size.width*1; // screen's 100%
                        return new Column(
                            children: <Widget>[
                              Text("Logged Hours: "+snapshot.data[index].totalLoggedHours
                                  .toString(), style: TextStyle(
                                  color: Colors.black87,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13.0),),
                              SizedBox(height:2.0),
                              Divider(color: Colors.black45,height: 2,),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceAround,
                                children: <Widget>[
                                  SizedBox(height: 10.0,),
                                  /*
                                  Container(
                                    width: MediaQuery.of(context).size.width * 0.16,
                                    padding:new EdgeInsets.only(top:10.0),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment
                                          .start,
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      children: <Widget>[
                                        Text("Logged Hours: "+snapshot.data[index].totalLoggedHours
                                            .toString(), style: TextStyle(
                                            color: Colors.black87,
                                            //fontWeight: FontWeight.bold,
                                            fontSize: 13.0),),


                                        SizedBox(height:2.0),

                                        /*
                                                                snapshot.data[index].bhour.toString()!=''?Container(
                                                                  //color:globals.buttoncolor,
                                                                  child:Text(""+snapshot.data[index]
                                                                      .bhour.toString()+" Hr(s)",style: TextStyle(),),
                                                                ):SizedBox(height: 10.0,),
*/

                                      ],
                                    ),
                                  ),
                                  */
                                  Container(
                                      width: MediaQuery.of(context).size.width * 0.3,
                                      padding:EdgeInsets.only(top: 5),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        children: <Widget>[
                                          Text(snapshot.data[index].TimeIn.toString(),style: TextStyle(fontWeight: FontWeight.bold , fontSize: 16.0),),

                                          (index == 0 && snapshot.data[index].TimeIn.toString().trim() != '-' && snapshot.data[index].TimeOut.toString().trim() == '-'  &&  globals.PictureBase64Att != "")?
                                          Container(
                                            width: 62.0,
                                            height: 62.0,
                                            child:InkWell(
                                              child: Container(
                                                  child:  ClipOval(child:Image.memory(base64Decode(globals.PictureBase64Att),height: 100, width: 100, fit: BoxFit.cover,))
                                              ),
                                              onTap: (){
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(builder: (context) => ImageView.fromImage((globals.PictureBase64Att),'')),
                                                );
                                              },
                                            ),
                                          ): Container(
                                            width: 62.0,
                                            height: 62.0,
                                            child:InkWell(
                                              child: Container(
                                                  decoration: new BoxDecoration(
                                                      shape: BoxShape.circle,
                                                      image: new DecorationImage(
                                                          fit: BoxFit.fill,
                                                          image: new NetworkImage(snapshot.data[index].EntryImage)
                                                      )
                                                  )),
                                              onTap: (){
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(builder: (context) => ImageView(myimage: snapshot.data[index].EntryImage,org_name: '')),
                                                );
                                              },
                                            ),),
                                          InkWell(
                                            child: Text('Time In: ' +
                                                snapshot.data[index]
                                                    .checkInLoc.toString(),
                                                textAlign: TextAlign.center,
                                                style: TextStyle(
                                                    color: Colors.blue,
                                                    decoration: TextDecoration.underline,

                                                    fontSize: 10.0)),
                                            onTap: () {
                                              goToMap(
                                                  snapshot.data[index]
                                                      .latit_in ,
                                                  snapshot.data[index]
                                                      .longi_in);
                                            },
                                          ),
                                        ],
                                      )
                                  ),

                                  Container(
                                      padding:EdgeInsets.only(top: 5),
                                      width: MediaQuery.of(context).size.width * 0.3,
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        children: <Widget>[
                                          Row(
                                              crossAxisAlignment: CrossAxisAlignment.center,
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              children: <Widget>[
                                                Text(snapshot.data[index].TimeOut.toString(),style: TextStyle(fontWeight: FontWeight.bold , fontSize: 16.0),),
                                                if(snapshot.data[index].timeindate.toString() != snapshot.data[index].timeoutdate.toString())
                                                  Text(" +1 \n Day",style: TextStyle(fontSize: 9.0,color: Colors.teal,fontWeight: FontWeight.bold),),
                                              ]),
                                          (index == 0 && snapshot.data[index].TimeOut.toString().trim() != '-'  &&  globals.PictureBase64Att != "")?
                                          Container(
                                            width: 62.0,
                                            height: 62.0,
                                            child:InkWell(
                                              child: Container(
                                                  child:  ClipOval(child:Image.memory(base64Decode(globals.PictureBase64Att),height: 100, width: 100, fit: BoxFit.cover,))
                                              ),
                                              onTap: (){
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(builder: (context) => ImageView.fromImage((globals.PictureBase64Att),'')),
                                                );
                                              },
                                            ),
                                          ):Container(
                                            width: 62.0,
                                            height: 62.0,
                                            child:InkWell(
                                              child: Container(
                                                  decoration: new BoxDecoration(
                                                      shape: BoxShape.circle,
                                                      image: new DecorationImage(
                                                          fit: BoxFit.fill,
                                                          image: new NetworkImage(snapshot.data[index].ExitImage)
                                                      )
                                                  )),
                                              onTap: (){
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(builder: (context) => ImageView(myimage: snapshot.data[index].ExitImage,org_name: '')),
                                                );
                                              },
                                            ),
                                          ),
                                          InkWell(
                                            child: Text('Time Out: ' +
                                                snapshot.data[index].CheckOutLoc.toString(),
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                  color: Colors.blue,
                                                  decoration: TextDecoration.underline,

                                                  fontSize: 10.0),),
                                            onTap: () {
                                              goToMap(
                                                  snapshot.data[index].latit_out,
                                                  snapshot.data[index].longi_out);
                                            },
                                          ),
                                        ],
                                      )

                                  ),
                                ],

                              ),
                              if(index!=snapshot.data.length-1)
                                Divider(color: Colors.black26,),
                            ]);
                      }
                  ),
                );
              } else if (snapshot.hasError) {
                return new Text("Unable to connect server");
              }

              // By default, show a loading spinner
              return new Center( child: CircularProgressIndicator());
            },
          ),
          actions: <Widget>[
            FlatButton(
              child: Text('OK'),
              onPressed: () {

                Navigator.of(context).pop();
              },
            ),

          ],
        );
      },
    );

  }
  Future<List<User>> getInterimAttendanceSummary(attendanceMasterId) async {

    final response = await http.get(globals.path+'getInterimAttendances?attendanceMasterId=$attendanceMasterId');
    print(response.body);
    List responseJson = json.decode(response.body.toString());
    List<User> userList = createInterimAttendanceList(responseJson);
    return userList;
  }

  List<User> createInterimAttendanceList(List data){
    List<User> list = new List();
    for (int i = 0; i < data.length; i++) {
      //String title = Formatdate(data[i]["AttendanceDate"]);
      String TimeOut=data[i]["TimeOut"]=="00:00:00"||data[i]["TimeOut"]==data[i]["TimeIn"]?'-':data[i]["TimeOut"].toString().substring(0,5);
      String TimeIn=data[i]["TimeIn"]=="00:00:00"?'-':data[i]["TimeIn"].toString().substring(0,5);
      //String thours=data[i]["thours"]=="00:00:00"?'-':data[i]["thours"].toString().substring(0,5);
      //String bhour=data[i]["bhour"]==null?'':'Time Off: '+data[i]["bhour"].substring(0,5);
      String EntryImage=data[i]["TimeInImage"]!=''?data[i]["TimeInImage"]:'http://ubiattendance.ubihrm.com/assets/img/avatar.png';
      String ExitImage=data[i]["TimeOutImage"]!=''?data[i]["TimeOutImage"]:'http://ubiattendance.ubihrm.com/assets/img/avatar.png';
      String checkInLoc=data[i]["TimeInLocation"];
      checkInLoc=(checkInLoc.length <= 50)
          ? checkInLoc
          :'${checkInLoc.substring(0, 50)}...';
      String CheckOutLoc=data[i]["TimeOutLocation"];
      CheckOutLoc=(CheckOutLoc.length <= 50)
          ? CheckOutLoc
          :'${CheckOutLoc.substring(0, 50)}...';
      String Latit_in=data[i]["LatitudeIn"];
      String Longi_in=data[i]["LongitudeIn"];
      String Latit_out=data[i]["LatitudeOut"];
      String Longi_out=data[i]["LongitudeOut"];
      String totalLoggedHours=data[i]["LoggedHours"]=="00:00:00"?'-':data[i]["LoggedHours"].toString().substring(0,5);

      //String timeindate=data[i]["timeindate"];
      //String attendanceMasterId=data[i]["Id"];
      //if(timeindate =='0000-00-00')
      //  timeindate = data[i]["AttendanceDate"];

      //String timeoutdate=data[i]["timeoutdate"];
      // if(timeoutdate =='0000-00-00')
      //  timeoutdate=data[i]["AttendanceDate"];
      //int id = 0;
      User user = new User(
          TimeOut:TimeOut,TimeIn:TimeIn,EntryImage:EntryImage,checkInLoc:checkInLoc,ExitImage:ExitImage,CheckOutLoc:CheckOutLoc,latit_in: Latit_in,longi_in: Longi_in,latit_out: Latit_out,longi_out: Longi_out,totalLoggedHours: totalLoggedHours);
      list.add(user);
    }
    return list;
  }

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
  String totalLoggedHours;
  String attendanceMasterId;
  int id=0;
  User({this.AttendanceDate,this.thours,this.id,this.TimeOut,this.TimeIn,this.bhour,this.EntryImage,this.checkInLoc,this.ExitImage,this.CheckOutLoc,this.latit_in,this.longi_in,this.latit_out,this.longi_out,this.timeindate,this.timeoutdate,this.totalLoggedHours,this.attendanceMasterId});
}