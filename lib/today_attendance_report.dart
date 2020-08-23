// Copyright 2017 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.
import 'package:Shrine/services/services.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:simple_share/simple_share.dart';

import 'Image_view.dart';
import 'drawer.dart';
import 'generatepdf.dart';
import 'globals.dart';
import 'outside_label.dart';
import 'payment.dart';

// This app is a stateful, it tracks the user's current choice.
class TodayAttendance extends StatefulWidget {
  @override
  _TodayAttendance createState() => _TodayAttendance();
}

String _orgName = "";

class _TodayAttendance extends State<TodayAttendance>
    with SingleTickerProviderStateMixin {
  TabController _controller;
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  String countP = '-', countA = '-', countL = '-', countE = '-';
  bool filests = false;
  String todaydate = "";
  String buystatus = "";
  String trialstatus = "";
  List<Map<String, String>> chartData;
  void showInSnackBar(String value) {
    final snackBar = SnackBar(
        content: Text(
      value,
      textAlign: TextAlign.center,
    ));
    _scaffoldKey.currentState.showSnackBar(snackBar);
  }

  getOrgName() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _orgName = prefs.getString('org_name') ?? '';
      buystatus = prefs.getString('buysts') ?? '';
      trialstatus = prefs.getString('trialstatus') ?? '';
      print(trialstatus);
      print("Sohan Patel");
    });

    getChartDataToday().then((onValue) {
      print('get chart data summary called successfully......');
      setState(() {
        countP = onValue[0]['present'];
        countA = onValue[0]['absent'];
        countL = onValue[0]['late'];
        countE = onValue[0]['early'];
      });
    });
  }

  @override
  void initState() {
    super.initState();
    checkNetForOfflineMode(context);
    appResumedPausedLogic(context);
    _controller = new TabController(length: 4, vsync: this);
    getOrgName();
    print("Date");
    var now = new DateTime.now();
    todaydate = new DateFormat("dd-MM-yyyy").format(now);
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      key: _scaffoldKey,
      appBar: new AppBar(
        title: new Text(_orgName, style: new TextStyle(fontSize: 20.0)),
        backgroundColor: appcolor,
      ),
      endDrawer: new AppDrawer(),
      body: new ListView(
        physics: NeverScrollableScrollPhysics(),
        children: <Widget>[
          SizedBox(height: 10.0),
          new Container(
            child: Center(
              child: Text(
                "Today's Attendance",
                style: TextStyle(
                  fontSize: 22.0,
                  color: appcolor,
                ),
              ),
            ),
          ),
          Divider(color: Colors.black54,height: 1.5,),
          new Container(
            padding: EdgeInsets.all(0.1),
            margin: EdgeInsets.all(0.1),
            child: new ListTile(
              title: new SizedBox(
                height: MediaQuery.of(context).size.height * 0.20,

                child: new FutureBuilder<List<Map<String, String>>>(
                    future: getChartDataToday(),
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        if (snapshot.data.length > 0) {
                          return new PieOutsideLabelChart.withRandomData(
                              snapshot.data);
                        }
                      }
                      return new Center(child: CircularProgressIndicator());
                    }),

                //  child: new PieOutsideLabelChart.withRandomData(),

                width: MediaQuery.of(context).size.width * 1.0,
              ),
            ),
          ),
          new Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              Text(
                'Present(P)',
                style: TextStyle(color: appcolor, fontSize: 12.0),
              ),
              Text(
                'Absent(A)',
                style: TextStyle(color: appcolor, fontSize: 12.0),
              ),
              Text(
                'Late Comers(LC)',
                style: TextStyle(color: appcolor, fontSize: 12.0),
              ),
              Text(
                'Early Leavers(EL)',
                style: TextStyle(color: appcolor, fontSize: 12.0),
              ),
            ],
          ),
          Divider(),
          new Container(
            decoration: new BoxDecoration(color: Colors.black54),
            child: new TabBar(
              indicator: BoxDecoration(
                color: buttoncolor,
              ),
              controller: _controller,
              tabs: [
                new Tab(
                  text: 'Present ', //('+countP+')',
                ),
                new Tab(
                  text: 'Absent', // ('+countA+')',
                ),
                new Tab(
                  text: 'Late \nComers', // ('+countL+')',
                ),
                new Tab(
                  text: 'Early \nLeavers', // ('+countE+')',
                ),
              ],
            ),
          ),
          new Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              SizedBox(
                height: 50.0,
              ),
              Container(
                width: MediaQuery.of(context).size.width * 0.46,
                child: Text(
                  '  Name',
                  style: TextStyle(
                      color: appcolor,
                      fontWeight: FontWeight.bold,
                      fontSize: 16.0),
                ),
              ),
              SizedBox(
                height: 50.0,
              ),
              Container(
                width: MediaQuery.of(context).size.width * 0.22,
                child: Text(
                  'Time In', textAlign: TextAlign.center,
                  style: TextStyle(
                      color: appcolor,
                      fontWeight: FontWeight.bold,
                      fontSize: 16.0),
                ),
              ),
              SizedBox(
                height: 50.0,
              ),
              Container(
                width: MediaQuery.of(context).size.width * 0.22,
                child: Text(
                  'Time Out',
                  style: TextStyle(
                      color: appcolor,
                      fontWeight: FontWeight.bold,
                      fontSize: 16.0),
                ),
              ),
            ],
          ),
          new Divider(
            height: 1.0,
            color: Colors.black45,
          ),
          new Container(
            height: MediaQuery.of(context).size.height * 0.50,
            child: new TabBarView(
              controller: _controller,
              children: <Widget>[
                new Container(
                  height: MediaQuery.of(context).size.height * 0.3,
                  //   shape: Border.all(color: Colors.deepOrange),
                  child: new ListTile(
                    title: Container(
                      height: MediaQuery.of(context).size.height * .45,
                      //width: MediaQuery.of(context).size.width*.99,
                      color: Colors.white,
                      //////////////////////////////////////////////////////////////////////---------------------------------
                      child: new FutureBuilder<List<Attn>>(
                        future: getTodaysAttn('present'),
                        builder: (context, snapshot) {
                          if (snapshot.hasData) {
                            if (snapshot.data.length > 0) {
                              return new ListView.builder(
                                  scrollDirection: Axis.vertical,
                                  itemCount: snapshot.data.length,
                                  itemBuilder:
                                      (BuildContext context, int index) {
                                    return new Column(children: <Widget>[
                                      (index == 0)
                                          ? Row(children: <Widget>[
                                              SizedBox(
                                                height: 25.0,
                                              ),
                                              Container(
                                                padding:
                                                    EdgeInsets.only(left: 5.0),
                                                child: Text(
                                                  "Total Present: " +
                                                      snapshot.data.length
                                                          .toString(),
                                                  style: TextStyle(
                                                    color: Colors.orange,
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 16.0,
                                                  ),
                                                ),
                                              ),
                                              Container(
                                                padding:
                                                    EdgeInsets.only(left: 15.0),
                                                child: InkWell(
                                                  child: Text(
                                                    'CSV',
                                                    style: TextStyle(
                                                        decoration:
                                                            TextDecoration
                                                                .underline,
                                                        color:
                                                            Colors.blueAccent),
                                                  ),
                                                  onTap: () {
                                                    if (trialstatus != '2') {
                                                      setState(() {
                                                        filests = true;
                                                      });

                                                      getCsv(
                                                              snapshot.data,
                                                              'Today_present_$todaydate',
                                                              'present')
                                                          .then((res) {
                                                        setState(() {
                                                          filests = false;
                                                        });
                                                        dialogwidget(
                                                            'CSV has been saved in internal storage in ubiattendance_files/Today_present_$todaydate',
                                                            res);
                                                      });
                                                    } else {
                                                      showInSnackBar(
                                                          "For CSV please Buy Now");
                                                    }
                                                  },
                                                ),
                                              ),
                                              Container(
                                                padding:
                                                    EdgeInsets.only(left: 5.0),
                                                child: InkWell(
                                                  child: Text(
                                                    'PDF',
                                                    style: TextStyle(
                                                        decoration:
                                                            TextDecoration
                                                                .underline,
                                                        color:
                                                            Colors.blueAccent),
                                                  ),
                                                  onTap: () {
                                                    if (trialstatus != '2') {
                                                      setState(() {
                                                        filests = true;
                                                      });
                                                      CreateDeptpdf(
                                                              snapshot.data,
                                                              'Present Employees($todaydate)',
                                                              snapshot
                                                                  .data.length
                                                                  .toString(),
                                                              'Today_present_$todaydate',
                                                              'present')
                                                          .then((res) {
                                                        setState(() {
                                                          filests = false;
                                                        });
                                                        dialogwidget(
                                                            'PDF has been saved in internal storage in ubiattendance_files/Today_present_$todaydate.pdf',
                                                            res);
                                                      });
                                                    } else {
                                                      showInSnackBar(
                                                          "For PDF please Buy Now");
                                                    }
                                                  },
                                                ),
                                              ),
                                            ])
                                          : new Center(),
                                      (index == 0)
                                          ? Divider(
                                              color: Colors.black26,
                                            )
                                          : new Center(),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceAround,
                                        children: <Widget>[
                                          SizedBox(
                                            height: 40.0,
                                          ),
                                          Container(
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0.46,
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: <Widget>[
                                                Text(
                                                  snapshot.data[index].Name
                                                      .toString(),
                                                  style: TextStyle(
                                                      color: Colors.black87,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 16.0),
                                                ),
                                                InkWell(
                                                  child: Text(
                                                      'Time In: ' +
                                                          snapshot.data[index]
                                                              .CheckInLoc
                                                              .toString(),
                                                      style: TextStyle(
                                                          color: Colors.black54,
                                                          fontSize: 12.0)),
                                                  onTap: () {
                                                    goToMap(
                                                        snapshot.data[index]
                                                            .LatitIn,
                                                        snapshot.data[index]
                                                            .LongiIn);
                                                  },
                                                ),
                                                SizedBox(height: 2.0),
                                                InkWell(
                                                  child: Text(
                                                    'Time Out: ' +
                                                        snapshot.data[index]
                                                            .CheckOutLoc
                                                            .toString(),
                                                    style: TextStyle(
                                                        color: Colors.black54,
                                                        fontSize: 12.0),
                                                  ),
                                                  onTap: () {
                                                    goToMap(
                                                        snapshot.data[index]
                                                            .LatitOut,
                                                        snapshot.data[index]
                                                            .LongiOut);
                                                  },
                                                ),
                                                SizedBox(
                                                  height: 15.0,
                                                ),
                                              ],
                                            ),
                                          ),
                                          Container(
                                              width: MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  0.22,
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.center,
                                                children: <Widget>[
                                                  Text(
                                                    snapshot.data[index].TimeIn
                                                        .toString(),
                                                    style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold),
                                                  ),
                                                  Container(
                                                    width: 62.0,
                                                    height: 62.0,
                                                    child: InkWell(
                                                      child: Container(
                                                        decoration: new BoxDecoration(
                                                            shape: BoxShape
                                                                .circle,
                                                            image: new DecorationImage(
                                                                fit: BoxFit
                                                                    .fill,
                                                                image: new NetworkImage(
                                                                    snapshot
                                                                        .data[
                                                                            index]
                                                                        .EntryImage))),
                                                        /*child: new Stack(
                                                      children: <Widget>[
                                                        new Positioned(
                                                          right: MediaQuery.of(context).size.width*.00,
                                                          bottom: MediaQuery.of(context).size.height*.00,
                                                          child: new Icon(Icons.add,size: 25.0,color: Colors.teal,),
                                                        )
                                                      ],
                                                    ),*/
                                                      ),
                                                      onTap: () {
                                                        Navigator.push(
                                                          context,
                                                          MaterialPageRoute(
                                                              builder: (context) => ImageView(
                                                                  myimage: snapshot
                                                                      .data[
                                                                          index]
                                                                      .EntryImage,
                                                                  org_name:
                                                                      _orgName)),
                                                        );
                                                      },
                                                    ),
                                                  ),
                                                ],
                                              )),
                                          Container(
                                              width: MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  0.22,
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.center,
                                                children: <Widget>[
                                                  Text(
                                                    snapshot.data[index].TimeOut
                                                        .toString(),
                                                    style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold),
                                                  ),
                                                  Container(
                                                    width: 62.0,
                                                    height: 62.0,
                                                    child: InkWell(
                                                      child: Container(
                                                        decoration: new BoxDecoration(
                                                            shape: BoxShape
                                                                .circle,
                                                            image: new DecorationImage(
                                                                fit: BoxFit
                                                                    .fill,
                                                                image: new NetworkImage(
                                                                    snapshot
                                                                        .data[
                                                                            index]
                                                                        .ExitImage))),
                                                      ),
                                                      onTap: () {
                                                        Navigator.push(
                                                          context,
                                                          MaterialPageRoute(
                                                              builder: (context) => ImageView(
                                                                  myimage: snapshot
                                                                      .data[
                                                                          index]
                                                                      .ExitImage,
                                                                  org_name:
                                                                      _orgName)),
                                                        );
                                                      },
                                                    ),
                                                  ),
                                                ],
                                              )),
                                        ],
                                      ),
                                      Divider(
                                        color: Colors.black26,
                                      ),
                                      (index == snapshot.data.length - 1 && trialstatus == '2')
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
                                    ]);
                                  });
                            } else {
                              return new Container(
                                  height: MediaQuery.of(context).size.height*0.30,
                                  child:Center(
                                    child: Container(
                                      width: MediaQuery.of(context).size.width*1,
                                      color: appcolor.withOpacity(0.1),
                                      padding:EdgeInsets.only(top:5.0,bottom: 5.0),
                                      child:Text("No one is present today ",style: TextStyle(fontSize: 18.0),textAlign: TextAlign.center,),
                                    ),
                                  )
                              );
                            }
                          } else if (snapshot.hasError) {
                            return new Center(
                                child: Text("Unable to connect server"));
                          }

                          // By default, show a loading spinner
                          return new Center(child: CircularProgressIndicator());
                        },
                      ),
                      //////////////////////////////////////////////////////////////////////---------------------------------
                    ),
                  ),
                ),
                //////////////TABB 2 Start
                new Container(
                  height: MediaQuery.of(context).size.height * 0.5,
                  //   shape: Border.all(color: Colors.deepOrange),
                  child: new ListTile(
                    title: Container(
                      height: MediaQuery.of(context).size.height * .45,
                      //width: MediaQuery.of(context).size.width*.99,
                      color: Colors.white,
                      //////////////////////////////////////////////////////////////////////---------------------------------
                      child: new FutureBuilder<List<Attn>>(
                        future: getTodaysAttn('absent'),
                        builder: (context, snapshot) {
                          if (snapshot.hasData) {
                            if (snapshot.data.length > 0) {
                              return new ListView.builder(
                                  scrollDirection: Axis.vertical,
                                  itemCount: snapshot.data.length,
                                  itemBuilder:
                                      (BuildContext context, int index) {
                                    return new Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceAround,
                                        children: <Widget>[
                                          (index == 0)
                                              ? Row(children: <Widget>[
                                                  SizedBox(
                                                    height: 25.0,
                                                  ),
                                                  Container(
                                                    padding: EdgeInsets.only(
                                                        left: 5.0),
                                                    child: Text(
                                                      "Total Absent: " +
                                                          snapshot.data.length
                                                              .toString(),
                                                      style: TextStyle(
                                                        color: Colors.orange,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontSize: 16.0,
                                                      ),
                                                    ),
                                                  ),
                                                  Container(
                                                    padding: EdgeInsets.only(
                                                        left: 5.0),
                                                    child: InkWell(
                                                      child: Text(
                                                        'CSV',
                                                        style: TextStyle(
                                                            decoration:
                                                                TextDecoration
                                                                    .underline,
                                                            color: Colors
                                                                .blueAccent),
                                                      ),
                                                      onTap: () {
                                                      if (trialstatus != '2') {
                                                        setState(() {
                                                          filests = true;
                                                        });

                                                        getCsv(
                                                                snapshot.data,
                                                                'Today_absent_$todaydate',
                                                                'absent')
                                                            .then((res) {
                                                          setState(() {
                                                            filests = false;
                                                          });
                                                          dialogwidget(
                                                              'CSV has been saved in internal storage in ubiattendance_files/Today_absent_$todaydate',
                                                              res);
                                                        });
                                                      } else {
                                                        showInSnackBar(
                                                            "For CSV please Buy Now");
                                                      }
                                                      },
                                                    ),
                                                  ),
                                                  Container(
                                                    padding: EdgeInsets.only(
                                                        left: 5.0),
                                                    child: InkWell(
                                                      child: Text(
                                                        'PDF',
                                                        style: TextStyle(
                                                            decoration:
                                                                TextDecoration
                                                                    .underline,
                                                            color: Colors
                                                                .blueAccent),
                                                      ),
                                                      onTap: () {
                                                     if (trialstatus != '2') {
                                                        setState(() {
                                                          filests = true;
                                                        });
                                                        CreateDeptpdf(
                                                                snapshot.data,
                                                                'Absent Employees($todaydate)',
                                                                snapshot
                                                                    .data.length
                                                                    .toString(),
                                                                'Today_absent_$todaydate',
                                                                'absent')
                                                            .then((res) {
                                                          setState(() {
                                                            filests = false;
                                                          });
                                                          dialogwidget(
                                                              'PDF has been saved in internal storage in ubiattendance_files/Today_absent_$todaydate.pdf',
                                                              res);
                                                        });
                                                     } else {
                                                       showInSnackBar(
                                                           "For CSV please Buy Now");
                                                     }
                                                      },
                                                    ),
                                                  ),
                                                ])
                                              : new Center(),
                                          (index == 0)
                                              ? Divider(
                                                  color: Colors.black26,
                                                )
                                              : new Center(),
                                          new Row(
//                                              mainAxisAlignment:
//                                                  MainAxisAlignment.spaceAround,
                                              children: <Widget>[
                                                SizedBox(
                                                  height: 40.0,
                                                ),
                                                Container(
                                                  width: MediaQuery.of(context)
                                                          .size
                                                          .width *
                                                      0.46,
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: <Widget>[
                                                      Padding(
                                                        padding: const EdgeInsets.all(8.0),
                                                        child: Text(
                                                          snapshot
                                                              .data[index].Name
                                                              .toString(),
                                                          style: TextStyle(
                                                              color:
                                                                  Colors.black87,
                                                              fontWeight:
                                                                  FontWeight.bold,
                                                              fontSize: 16.0),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
//                                                Container(
//                                                    width:
//                                                        MediaQuery.of(context)
//                                                                .size
//                                                                .width *
//                                                            0.22,
//                                                    child: Column(
//                                                      crossAxisAlignment:
//                                                          CrossAxisAlignment
//                                                              .center,
//                                                      children: <Widget>[
//                                                        Text(snapshot
//                                                            .data[index].TimeIn
//                                                            .toString()),
//                                                      ],
//                                                    )),
//                                                Container(
//                                                    width:
//                                                        MediaQuery.of(context)
//                                                                .size
//                                                                .width *
//                                                            0.22,
//                                                    child: Column(
//                                                      crossAxisAlignment:
//                                                          CrossAxisAlignment
//                                                              .center,
//                                                      children: <Widget>[
//                                                        Text(snapshot
//                                                            .data[index].TimeOut
//                                                            .toString()),
//                                                      ],
//                                                    )),
                                                Divider(
                                                  color: Colors.black26,
                                                ),
                                              ]),
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
                                        ]);
                                  });
                            } else {
                              return new Container(
                                  height: MediaQuery.of(context).size.height*0.30,
                                  child:Center(
                                    child: Container(
                                      width: MediaQuery.of(context).size.width*1,
                                      color: appcolor.withOpacity(0.1),
                                      padding:EdgeInsets.only(top:5.0,bottom: 5.0),
                                      child:Text("No one is absent today",style: TextStyle(fontSize: 18.0),textAlign: TextAlign.center,),
                                    ),
                                  )
                              );
                            }
                          } else if (snapshot.hasError) {
                            return new Text("Unable to connect server");
                          }

                          // By default, show a loading spinner
                          return new Center(child: CircularProgressIndicator());
                        },
                      ),
                      //////////////////////////////////////////////////////////////////////---------------------------------
                    ),
                  ),
                ),

                /////////////TAB 2 Ends

                /////////////TAB 3 STARTS

                new Container(
                  height: MediaQuery.of(context).size.height * 0.5,
                  //   shape: Border.all(color: Colors.deepOrange),
                  child: new ListTile(
                    title: Container(
                      height: MediaQuery.of(context).size.height * .45,
                      //width: MediaQuery.of(context).size.width*.99,
                      color: Colors.white,
                      //////////////////////////////////////////////////////////////////////---------------------------------
                      child: new FutureBuilder<List<Attn>>(
                        future: getTodaysAttn('latecomings'),
                        builder: (context, snapshot) {
                          if (snapshot.hasData) {
                            if (snapshot.data.length > 0) {
                              return new ListView.builder(
                                  scrollDirection: Axis.vertical,
                                  itemCount: snapshot.data.length,
                                  itemBuilder:
                                      (BuildContext context, int index) {
                                    return new Column(children: <Widget>[
                                      (index == 0)
                                          ? Row(children: <Widget>[
                                              SizedBox(
                                                height: 25.0,
                                              ),
                                              Container(
                                                padding:
                                                    EdgeInsets.only(left: 5.0),
                                                child: Text(
                                                  "Total Latecomings: " +
                                                      snapshot.data.length
                                                          .toString(),
                                                  style: TextStyle(
                                                    color: Colors.orange,
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 16.0,
                                                  ),
                                                ),
                                              ),
                                              Container(
                                                padding:
                                                    EdgeInsets.only(left: 5.0),
                                                child: InkWell(
                                                  child: Text(
                                                    'CSV',
                                                    style: TextStyle(
                                                        decoration:
                                                            TextDecoration
                                                                .underline,
                                                        color:
                                                            Colors.blueAccent),
                                                  ),
                                                  onTap: () {
                                                  if (trialstatus != '2') {
                                                    setState(() {
                                                      filests = true;
                                                    });

                                                    getCsv(
                                                            snapshot.data,
                                                            'Today_latecomings_$todaydate',
                                                            'late')
                                                        .then((res) {
                                                      setState(() {
                                                        filests = false;
                                                      });
                                                      dialogwidget(
                                                          'CSV has been saved in internal storage in ubiattendance_files/Today_latecomings_$todaydate',
                                                          res);
                                                    });
                                                  } else {
                                                  showInSnackBar(
                                                  "For CSV please Buy Now");
                                                  }
                                                  },
                                                ),
                                              ),
                                              Container(
                                                padding:
                                                    EdgeInsets.only(left: 5.0),
                                                child: InkWell(
                                                  child: Text(
                                                    'PDF',
                                                    style: TextStyle(
                                                        decoration:
                                                            TextDecoration
                                                                .underline,
                                                        color:
                                                            Colors.blueAccent),
                                                  ),
                                                  onTap: () {
                                                   if (trialstatus != '2') {
                                                    setState(() {
                                                      filests = true;
                                                    });
                                                    CreateDeptpdf(
                                                            snapshot.data,
                                                            'Latecomings Employees($todaydate)',
                                                            snapshot.data.length
                                                                .toString(),
                                                            'Today_latecomings_$todaydate',
                                                            'late')
                                                        .then((res) {
                                                      setState(() {
                                                        filests = false;
                                                      });
                                                      dialogwidget(
                                                          'PDF has been saved in internal storage in ubiattendance_files/Today_latecomings_$todaydate.pdf',
                                                          res);
                                                    });
                                                  } else {
                                                  showInSnackBar(
                                                  "For CSV please Buy Now");
                                                  }
                                                  },
                                                ),
                                              ),
                                            ])
                                          : new Center(),
                                      (index == 0)
                                          ? Divider(
                                              color: Colors.black26,
                                            )
                                          : new Center(),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceAround,
                                        children: <Widget>[
                                          SizedBox(
                                            height: 40.0,
                                          ),
                                          Container(
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0.46,
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: <Widget>[
                                                Text(
                                                  snapshot.data[index].Name
                                                      .toString(),
                                                  style: TextStyle(
                                                      color: Colors.black87,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 16.0),
                                                ),
                                                InkWell(
                                                  child: Text(
                                                      'Time In: ' +
                                                          snapshot.data[index]
                                                              .CheckInLoc
                                                              .toString(),
                                                      style: TextStyle(
                                                          color: Colors.black54,
                                                          fontSize: 12.0)),
                                                  onTap: () {
                                                    goToMap(
                                                        snapshot.data[index]
                                                            .LatitIn,
                                                        snapshot.data[index]
                                                            .LongiIn);
                                                  },
                                                ),
                                                SizedBox(height: 2.0),
                                                InkWell(
                                                  child: Text(
                                                    'Time Out: ' +
                                                        snapshot.data[index]
                                                            .CheckOutLoc
                                                            .toString(),
                                                    style: TextStyle(
                                                        color: Colors.black54,
                                                        fontSize: 12.0),
                                                  ),
                                                  onTap: () {
                                                    goToMap(
                                                        snapshot.data[index]
                                                            .LatitOut,
                                                        snapshot.data[index]
                                                            .LongiOut);
                                                  },
                                                ),
                                                SizedBox(
                                                  height: 15.0,
                                                ),
                                              ],
                                            ),
                                          ),
                                          Container(
                                              width: MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  0.22,
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.center,
                                                children: <Widget>[
                                                  Text(
                                                    snapshot.data[index].TimeIn
                                                        .toString(),
                                                    style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold),
                                                  ),
                                                  Container(
                                                    width: 62.0,
                                                    height: 62.0,
                                                    child: InkWell(
                                                      child: Container(
                                                          decoration: new BoxDecoration(
                                                              shape: BoxShape
                                                                  .circle,
                                                              image: new DecorationImage(
                                                                  fit: BoxFit
                                                                      .fill,
                                                                  image: new NetworkImage(snapshot
                                                                      .data[
                                                                          index]
                                                                      .EntryImage)))),
                                                      onTap: () {
                                                        Navigator.push(
                                                          context,
                                                          MaterialPageRoute(
                                                              builder: (context) => ImageView(
                                                                  myimage: snapshot
                                                                      .data[
                                                                          index]
                                                                      .EntryImage,
                                                                  org_name:
                                                                      _orgName)),
                                                        );
                                                      },
                                                    ),
                                                  ),
                                                ],
                                              )),
                                          Container(
                                              width: MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  0.22,
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.center,
                                                children: <Widget>[
                                                  Text(
                                                    snapshot.data[index].TimeOut
                                                        .toString(),
                                                    style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold),
                                                  ),
                                                  Container(
                                                    width: 62.0,
                                                    height: 62.0,
                                                    child: InkWell(
                                                      child: Container(
                                                          decoration: new BoxDecoration(
                                                              shape: BoxShape
                                                                  .circle,
                                                              image: new DecorationImage(
                                                                  fit: BoxFit
                                                                      .fill,
                                                                  image: new NetworkImage(snapshot
                                                                      .data[
                                                                          index]
                                                                      .ExitImage)))),
                                                      onTap: () {
                                                        Navigator.push(
                                                          context,
                                                          MaterialPageRoute(
                                                              builder: (context) => ImageView(
                                                                  myimage: snapshot
                                                                      .data[
                                                                          index]
                                                                      .ExitImage,
                                                                  org_name:
                                                                      _orgName)),
                                                        );
                                                      },
                                                    ),
                                                  ),
                                                ],
                                              )),
                                        ],
                                      ),
                                      Divider(
                                        color: Colors.black26,
                                      ),
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
                                    ]);
                                  });
                            } else {
                              return new Container(
                                  height: MediaQuery.of(context).size.height*0.30,
                                  child:Center(
                                    child: Container(
                                      width: MediaQuery.of(context).size.width*1,
                                      color: appcolor.withOpacity(0.1),
                                      padding:EdgeInsets.only(top:5.0,bottom: 5.0),
                                      child:Text("No one is late today",style: TextStyle(fontSize: 18.0),textAlign: TextAlign.center,),
                                    ),
                                  )
                              );
                            }
                          } else if (snapshot.hasError) {
                            return new Text("Unable to connect server");
                          }

                          // By default, show a loading spinner
                          return new Center(child: CircularProgressIndicator());
                        },
                      ),
                      //////////////////////////////////////////////////////////////////////---------------------------------
                    ),
                  ),
                ),
                /////////TAB 3 ENDS

                /////////TAB 4 STARTS
                new Container(
                  height: MediaQuery.of(context).size.height * 0.5,
                  //   shape: Border.all(color: Colors.deepOrange),
                  child: new ListTile(
                    title: Container(
                      height: MediaQuery.of(context).size.height * .45,
                      //width: MediaQuery.of(context).size.width*.99,
                      color: Colors.white,
                      //////////////////////////////////////////////////////////////////////---------------------------------
                      child: new FutureBuilder<List<Attn>>(
                        future: getTodaysAttn('earlyleavings'),
                        builder: (context, snapshot) {
                          if (snapshot.hasData) {
                            if (snapshot.data.length > 0) {
                              return new ListView.builder(
                                  scrollDirection: Axis.vertical,
                                  itemCount: snapshot.data.length,
                                  itemBuilder:
                                      (BuildContext context, int index) {
                                    return new Column(children: <Widget>[
                                      (index == 0)
                                          ? Row(children: <Widget>[
                                              SizedBox(
                                                height: 25.0,
                                              ),
                                              Container(
                                                padding:
                                                    EdgeInsets.only(left: 5.0),
                                                child: Text(
                                                  "Total Early leavings: " +
                                                      snapshot.data.length
                                                          .toString(),
                                                  style: TextStyle(
                                                    color: Colors.orange,
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 16.0,
                                                  ),
                                                ),
                                              ),
                                              Container(
                                                padding:
                                                    EdgeInsets.only(left: 5.0),
                                                child: InkWell(
                                                  child: Text(
                                                    'CSV',
                                                    style: TextStyle(
                                                        decoration:
                                                            TextDecoration
                                                                .underline,
                                                        color:
                                                            Colors.blueAccent),
                                                  ),
                                                  onTap: () {
                                                  if (trialstatus != '2') {
                                                    setState(() {
                                                      filests = true;
                                                    });

                                                    getCsv(
                                                            snapshot.data,
                                                            'Today_earlyleavings_$todaydate',
                                                            'early')
                                                        .then((res) {
                                                      setState(() {
                                                        filests = false;
                                                      });
                                                      dialogwidget(
                                                          'CSV has been saved in internal storage in ubiattendance_files/Today_earlyleavings_$todaydate',
                                                          res);
                                                    });
                                                  } else {
                                                    showInSnackBar(
                                                        "For CSV please Buy Now");
                                                  }
                                                  },
                                                ),
                                              ),
                                              Container(
                                                padding:
                                                    EdgeInsets.only(left: 5.0),
                                                child: InkWell(
                                                  child: Text(
                                                    'PDF',
                                                    style: TextStyle(
                                                        decoration:
                                                            TextDecoration
                                                                .underline,
                                                        color:
                                                            Colors.blueAccent),
                                                  ),
                                                  onTap: () {
                                                   if (trialstatus != '2') {

                                                    setState(() {
                                                      filests = true;
                                                    });
                                                    CreateDeptpdf(
                                                            snapshot.data,
                                                            'Earlyleavings Employees($todaydate)',
                                                            snapshot.data.length
                                                                .toString(),
                                                            'Today_earlyleavings_$todaydate',
                                                            'early')
                                                        .then((res) {
                                                      setState(() {
                                                        filests = false;
                                                      });
                                                      dialogwidget(
                                                          'PDF has been saved in internal storage in ubiattendance_files/Today_earlyleavings_$todaydate.pdf',
                                                          res);
                                                    });
                                                    } else {
                                                    showInSnackBar(
                                                    "For CSV please Buy Now");
                                                    }
                                                  },
                                                ),
                                              ),
                                            ])
                                          : new Center(),
                                      (index == 0)
                                          ? Divider(
                                              color: Colors.black26,
                                            )
                                          : new Center(),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceAround,
                                        children: <Widget>[
                                          SizedBox(
                                            height: 40.0,
                                          ),
                                          Container(
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0.46,
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: <Widget>[
                                                Text(
                                                  snapshot.data[index].Name
                                                      .toString(),
                                                  style: TextStyle(
                                                      color: Colors.black87,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 16.0),
                                                ),
                                                InkWell(
                                                  child: Text(
                                                      'Time In: ' +
                                                          snapshot.data[index]
                                                              .CheckInLoc
                                                              .toString(),
                                                      style: TextStyle(
                                                          color: Colors.black54,
                                                          fontSize: 12.0)),
                                                  onTap: () {
                                                    goToMap(
                                                        snapshot.data[index]
                                                            .LatitIn,
                                                        snapshot.data[index]
                                                            .LongiIn);
                                                  },
                                                ),
                                                SizedBox(height: 2.0),
                                                InkWell(
                                                  child: Text(
                                                    'Time Out: ' +
                                                        snapshot.data[index]
                                                            .CheckOutLoc
                                                            .toString(),
                                                    style: TextStyle(
                                                        color: Colors.black54,
                                                        fontSize: 12.0),
                                                  ),
                                                  onTap: () {
                                                    goToMap(
                                                        snapshot.data[index]
                                                            .LatitOut,
                                                        snapshot.data[index]
                                                            .LongiOut);
                                                  },
                                                ),
                                                SizedBox(
                                                  height: 15.0,
                                                ),
                                              ],
                                            ),
                                          ),
                                          Container(
                                              width: MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  0.22,
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.center,
                                                children: <Widget>[
                                                  Text(
                                                    snapshot.data[index].TimeIn
                                                        .toString(),
                                                    style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold),
                                                  ),
                                                  Container(
                                                    width: 62.0,
                                                    height: 62.0,
                                                    child: InkWell(
                                                      child: Container(
                                                          decoration: new BoxDecoration(
                                                              shape: BoxShape
                                                                  .circle,
                                                              image: new DecorationImage(
                                                                  fit: BoxFit
                                                                      .fill,
                                                                  image: new NetworkImage(snapshot
                                                                      .data[
                                                                          index]
                                                                      .EntryImage)))),
                                                      onTap: () {
                                                        Navigator.push(
                                                          context,
                                                          MaterialPageRoute(
                                                              builder: (context) => ImageView(
                                                                  myimage: snapshot
                                                                      .data[
                                                                          index]
                                                                      .EntryImage,
                                                                  org_name:
                                                                      _orgName)),
                                                        );
                                                      },
                                                    ),
                                                  ),
                                                ],
                                              )),
                                          Container(
                                              width: MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  0.22,
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.center,
                                                children: <Widget>[
                                                  Text(
                                                    snapshot.data[index].TimeOut
                                                        .toString(),
                                                    style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold),
                                                  ),
                                                  Container(
                                                    width: 62.0,
                                                    height: 62.0,
                                                    child: InkWell(
                                                      child: Container(
                                                          decoration: new BoxDecoration(
                                                              shape: BoxShape
                                                                  .circle,
                                                              image: new DecorationImage(
                                                                  fit: BoxFit
                                                                      .fill,
                                                                  image: new NetworkImage(snapshot
                                                                      .data[
                                                                          index]
                                                                      .ExitImage)))),
                                                      onTap: () {
                                                        Navigator.push(
                                                          context,
                                                          MaterialPageRoute(
                                                              builder: (context) => ImageView(
                                                                  myimage: snapshot
                                                                      .data[
                                                                          index]
                                                                      .ExitImage,
                                                                  org_name:
                                                                      _orgName)),
                                                        );
                                                      },
                                                    ),
                                                  ),
                                                ],
                                              )),
                                        ],
                                      ),
                                      Divider(
                                        color: Colors.black26,
                                      ),
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
                                                            "For More Information Pay Now ",
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
                                    ]);
                                  });
                            } else {
                              return new Container(
                                  height: MediaQuery.of(context).size.height*0.30,
                                  child:Center(
                                    child: Container(
                                      width: MediaQuery.of(context).size.width*1,
                                      color: appcolor.withOpacity(0.1),
                                      padding:EdgeInsets.only(top:5.0,bottom: 5.0),
                                      child:Text("No early leavers today",style: TextStyle(fontSize: 18.0),textAlign: TextAlign.center,),
                                    ),
                                  )
                              );
                            }
                          } else if (snapshot.hasError) {
                            return new Text("Unable to connect server");
                          }

                          // By default, show a loading spinner
                          return new Center(child: CircularProgressIndicator());
                        },
                      ),
                      //////////////////////////////////////////////////////////////////////---------------------------------
                    ),
                  ),
                ),
                ///////////////////TAB 4 Ends
              ],
            ),
          ),
        ],
      ),
    );
  }

  dialogwidget(msg, filename) {
    showDialog(
        context: context,
        // ignore: deprecated_member_use
        child: new AlertDialog(
          content: new Text(msg),
          actions: <Widget>[
            FlatButton(
              child: Text('Later'),
              shape: Border.all(),
              onPressed: () {
                Navigator.of(context, rootNavigator: true).pop();
              },
            ),
            RaisedButton(
              child: Text(
                'Share File',
                style: TextStyle(color: Colors.white),
              ),
              color: buttoncolor,
              onPressed: () {
                Navigator.of(context, rootNavigator: true).pop();
                final uri = Uri.file(filename);
                SimpleShare.share(
                    uri: uri.toString(),
                    title: "Ubiattendance Report",
                    msg: "Ubiattendance Report");
              },
            ),
          ],
        ));
  }
}
