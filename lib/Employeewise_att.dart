// Copyright 2017 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.
import 'package:Shrine/generatepdf.dart';
import 'package:Shrine/services/services.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:simple_share/simple_share.dart';

import 'Image_view.dart';
import 'drawer.dart';
import 'globals.dart';
import 'dart:convert';
import 'globals.dart' as globals;
import 'package:http/http.dart' as http;
// This app is a stateful, it tracks the user's current choice.
class EmployeeWise_att extends StatefulWidget {
  @override
  _EmployeeWise_att createState() => _EmployeeWise_att();
}
String _orgName = "";
//TextEditingController today;
class _EmployeeWise_att extends State<EmployeeWise_att> with SingleTickerProviderStateMixin {
  TabController _controller;
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  String countP='0',countA='0',countL='0',countE='0';
  String emp='0';
  bool filests = false;
  String empname= '';
//  var formatter = new DateFormat('dd-MMM-yyyy');
  bool res = true;
  Future<List<Attn>> _listFuture1, _listFuture2,_listFuture3,_listFuture4;
  List presentlist= new List(), absentlist= new List(), latecommerlist= new List(), earlyleaverlist= new List();
  List<Map<String,String>> chartData;

  void showInSnackBar(String value) {
    final snackBar = SnackBar(
        content: Text(value,textAlign: TextAlign.center,));
    _scaffoldKey.currentState.showSnackBar(snackBar);
  }

  getOrgName() async{
    final prefs = await SharedPreferences.getInstance();
    if(mounted) {
      setState(() {
        _orgName=prefs.getString('org_name') ?? '';
      });
      //getCount();
    }
  }

  /*getCount() async {
    getEmpHistoryOf30Count(emp).then((onValue) {
      setState(() {
        if(res == true) {
          countP=onValue[0]['present'];
          countA=onValue[0]['absent'];
          countL=onValue[0]['latecomings'];
          countE=onValue[0]['earlyleavings'];
        }
      });
    });
  }*/

  @override
  void initState() {
    super.initState();
    checkNetForOfflineMode(context);
    appResumedPausedLogic(context);
    _controller = new TabController(length: 4, vsync: this);
    getOrgName();
    setAlldata();
  }

  setAlldata(){
    _listFuture1 = getEmpHistoryOf30('present',emp);
    _listFuture2 = getEmpHistoryOf30('absent',emp);
    _listFuture3 = getEmpHistoryOf30('latecomings',emp);
    _listFuture4 = getEmpHistoryOf30('earlyleavings',emp);

    _listFuture1.then((data) async{
      setState(() {
        presentlist = data;
        countP = data.length.toString();
      });
    });

    _listFuture2.then((data) async{
      setState(() {
        absentlist = data;
        countA = data.length.toString();
      });
    });

    _listFuture3.then((data) async{
      setState(() {
        latecommerlist = data;
        countL = data.length.toString();
      });
    });

    _listFuture4.then((data) async{
      setState(() {
        earlyleaverlist = data;
        countE= data.length.toString();
      });
    });
  }

  /*void _updateText() {
    setState(() {
      // update the text
      countP = countP;
    });
  }*/

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
          SizedBox(height:10.0),
          new Container(
            child: Center(child:Text("Employee Wise Attendance",style: TextStyle(fontSize: 22.0,color:appcolor,),),),
          ),
          Divider(color: Colors.black54,height: 1.5,),
          Row(
            children: <Widget>[
              Expanded(child: getEmployee_DD()),
         /*     Padding(
                padding: const EdgeInsets.only(left: 4.0),
                child:(emp != '0')?Container(
                    color: Colors.white,
                    height: 65,
                    width: MediaQuery.of(context).size.width * 0.25,
                    child: new Column(
                        //mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: <Widget>[
                          (presentlist.length > 0 || absentlist.length > 0 || latecommerlist.length > 0 || earlyleaverlist.length > 0)?
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              SizedBox(
                                height:  65,
                              ),
                              Container(
                                //padding: EdgeInsets.only(left: 5.0),
                                child: InkWell(
                                  child: Text('CSV',
                                    style: TextStyle(
                                      decoration: TextDecoration.underline,
                                      color: Colors.blueAccent,
                                      fontSize: 16,
                                      //fontWeight: FontWeight.bold
                                    ),
                                  ),
                                  onTap: () {
                                    //openFile(filepath);
                                    if (mounted) {
                                      setState(() {
                                        filests = true;
                                      });
                                    }
                                    getCsvAlldata(presentlist, absentlist, latecommerlist, earlyleaverlist,
                                          'Employee_Wise_Report', 'emp')
                                          .then((res) {
                                        print('snapshot.data');

                                        if (mounted) {
                                          setState(() {
                                            filests=false;
                                          });
                                        }
                                        // showInSnackBar('CSV has been saved in file storage in ubiattendance_files/Department_Report_'+today.text+'.csv');
                                        dialogwidget(
                                            "CSV has been saved in internal storage in ubiattendance_files/Employee_Wise_Report" +
                                                ".csv", res);
                                      }
                                      );
                                  },
                                ),
                              ),
                              SizedBox(
                                width:6,
                              ),
                              Container(
                                padding: EdgeInsets.only(
                                    left: 5.0),
                                child: InkWell(
                                  child: Text('PDF',
                                    style: TextStyle(
                                      decoration:
                                      TextDecoration
                                          .underline,
                                      color: Colors
                                          .blueAccent,
                                      fontSize: 16,),
                                  ),
                                  onTap: () {
                                    /*final uri = Uri.file('/storage/emulated/0/ubiattendance_files/Employee_Wise_Report_14-Jun-2019.pdf');
                                    SimpleShare.share(
                                        uri: uri.toString(),
                                        title: "Share my file",
                                        msg: "My message");*/
                                    if (mounted) {
                                      setState(() {
                                        filests = true;
                                      });
                                    }
                                    CreateEmployeeWisepdf(
                                        presentlist, absentlist, latecommerlist, earlyleaverlist, 'Employee Report ' + empname,
                                        'Employee_Wise_Report', 'employeewise')
                                        .then((res) {
                                      if(mounted) {
                                        setState(() {
                                          filests =
                                          false;
                                          // OpenFile.open("/sdcard/example.txt");
                                        });
                                      }
                                      dialogwidget(
                                          'PDF has been saved in internal storage in ubiattendance_files/Employee_Wise_Report'+
                                              '.pdf',
                                          res);
                                      // showInSnackBar('PDF has been saved in file storage in ubiattendance_files/'+'Department_Report_'+today.text+'.pdf');
                                    });
                                  },
                                ),
                              ),
                            ],
                          ):Center(
//                              child: Padding(
//                                padding: const EdgeInsets.only(top:12.0),
//                                child: Text("No CSV/Pdf generated", textAlign: TextAlign.center,),
//                              )
                          )
                        ]
                    )
                ):Center()
              )
              */
            ],
          ),
          //Divider(height: 10,color: Colors.black,),
          //SizedBox(height: 5,),
//          new Row(
//            crossAxisAlignment: CrossAxisAlignment.center,
//            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//            children: <Widget>[
//              Text(
//                'Present($countP)',
//                style: TextStyle(color: appcolor, fontSize: 12.0),
//              ),
//              Text(
//                'Absent($countA)',
//                style: TextStyle(color: appcolor, fontSize: 12.0),
//              ),
//              Text(
//                'Late Comers($countL)',
//                style: TextStyle(color: appcolor, fontSize: 12.0),
//              ),
//              Text(
//                'Early Leavers($countE)',
//                style: TextStyle(color: appcolor, fontSize: 12.0),
//              ),
//            ],
//          ),
          //Divider(),
          //SizedBox(height: 5,),
          new Container(
            decoration: new BoxDecoration(color: Colors.black54),
            child: new TabBar(
              indicator: BoxDecoration(color: buttoncolor,),
              controller: _controller,
              tabs: [
                new Tab(
                  text: 'Present',//('+countP+')
                ),
                new Tab(
                  text: 'Absent ', //('+countA+')
                ),
                new Tab(
                  text: 'Late\nComers', //('+countL+')
                ),
                new Tab(
                  text: 'Early\nLeavers', //('+countE+')
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
                width: MediaQuery.of(context).size.width*0.50,
                child:Text('   Date',style: TextStyle(color: appcolor,fontWeight:FontWeight.bold,fontSize: 16.0),),
              ),

              SizedBox(height: 50.0,),
              Container(
                width: MediaQuery.of(context).size.width*0.18,
                child:Text('Time In', textAlign: TextAlign.center,style: TextStyle(color: appcolor,fontWeight:FontWeight.bold,fontSize: 16.0),),
              ),
              SizedBox(height: 50.0,),
              Container(
                width: MediaQuery.of(context).size.width*0.24,
                child:Text('Time Out',textAlign: TextAlign.center,style: TextStyle(color: appcolor,fontWeight:FontWeight.bold,fontSize: 16.0),),
              ),
            ],
          ),
          new Divider(height: 1.0,),

          res==true?new Container(
            height: MediaQuery.of(context).size.height*1,
            child: new TabBarView(
              controller: _controller,
              children: <Widget>[
                new Container(
                  height: MediaQuery.of(context).size.height*0.30,
                  //   shape: Border.all(color: Colors.deepOrange),
                  child: new ListTile(
                    title:
                    Container( height: MediaQuery.of(context).size.height*.55,
                      //width: MediaQuery.of(context).size.width*.99,
                      color: Colors.white,
                      //////////////////////////////////////////////////////////////////////---------------------------------
                      child: new FutureBuilder<List<Attn>>(
                          future: _listFuture1,

                        builder: (context, snapshot) {
                          if (snapshot.hasData) {
                            /*SchedulerBinding.instance.addPostFrameCallback((_) => setState(() {
                              countP=snapshot.data.length.toString();
                              print("--------This is present employee ${countP}");
                            }));*/
                           countP=snapshot.data.length.toString();
                         //  print("hello to app ->${countP}");
                            if(snapshot.data.length>0) {
                              return  ListView.builder(
                                  scrollDirection: Axis.vertical,
                                  itemCount: snapshot.data.length,
                                  itemBuilder: (BuildContext context, int index) {
                                    return new Column(
                                        children: <Widget>[
                                          (index == 0)?
                                            Row(
                                                  children: <Widget>[
                                                    //SizedBox(height: 25.0,),
                                                    Container(
                                                      //padding: EdgeInsets.only(left: 11.0),
                                                      child: Text("Total Present: ${countP}",style: TextStyle(color: headingcolor,fontWeight: FontWeight.bold,fontSize: 16.0,),),
                                                    ),SizedBox(
                                                      height:  10.0,
                                                    ),Row(
                                                      mainAxisAlignment: MainAxisAlignment.center,
                                                      children: <Widget>[
                                                        SizedBox(
                                                          height:  10.0,
                                                        ),
                                                        Container(
                                                          padding: EdgeInsets.only(left: 10.0),
                                                          child: InkWell(
                                                            child: Text('CSV',
                                                              style: TextStyle(
                                                                decoration: TextDecoration.underline,
                                                                color: Colors.blueAccent,
                                                                fontSize: 16,
                                                                //fontWeight: FontWeight.bold
                                                              ),
                                                            ),
                                                            onTap: () {
                                                              //openFile(filepath);
                                                              if (mounted) {
                                                                setState(() {
                                                                  filests = true;
                                                                });
                                                              }
                                                              getCsvAlldata(presentlist, absentlist, latecommerlist, earlyleaverlist,
                                                                  'Employee_Wise_Report', 'emp')
                                                                  .then((res) {
                                                                print('snapshot.data');

                                                                if (mounted) {
                                                                  setState(() {
                                                                    filests=false;
                                                                  });
                                                                }
                                                                // showInSnackBar('CSV has been saved in file storage in ubiattendance_files/Department_Report_'+today.text+'.csv');
                                                                dialogwidget(
                                                                    "CSV has been saved in internal storage in ubiattendance_files/Employee_Wise_Report" +
                                                                        ".csv", res);
                                                              }
                                                              );
                                                            },
                                                          ),
                                                        ),
                                                        SizedBox(
                                                          width:6,
                                                        ),
                                                        Container(
                                                          padding: EdgeInsets.only(
                                                              left: 5.0),
                                                          child: InkWell(
                                                            child: Text('PDF',
                                                              style: TextStyle(
                                                                decoration:
                                                                TextDecoration
                                                                    .underline,
                                                                color: Colors
                                                                    .blueAccent,
                                                                fontSize: 16,),
                                                            ),
                                                            onTap: () {
                                                              /*final uri = Uri.file('/storage/emulated/0/ubiattendance_files/Employee_Wise_Report_14-Jun-2019.pdf');
                                    SimpleShare.share(
                                        uri: uri.toString(),
                                        title: "Share my file",
                                        msg: "My message");*/
                                                              if (mounted) {
                                                                setState(() {
                                                                  filests = true;
                                                                });
                                                              }
                                                              CreateEmployeeWisepdf(
                                                                  presentlist, absentlist, latecommerlist, earlyleaverlist, 'Employee Report ' + empname,
                                                                  'Employee_Wise_Report', 'employeewise')
                                                                  .then((res) {
                                                                if(mounted) {
                                                                  setState(() {
                                                                    filests =
                                                                    false;
                                                                    // OpenFile.open("/sdcard/example.txt");
                                                                  });
                                                                }
                                                                dialogwidget(
                                                                    'PDF has been saved in internal storage in ubiattendance_files/Employee_Wise_Report'+
                                                                        '.pdf',
                                                                    res);
                                                                // showInSnackBar('PDF has been saved in file storage in ubiattendance_files/'+'Department_Report_'+today.text+'.pdf');
                                                              });
                                                            },
                                                          ),
                                                        ),
                                                      ],
                                                    )
                                                   ]
                                               ):new Center(),
                                          (index == 0)?
                                            Divider(color: Colors.black26,):new Center(),
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment
                                                .spaceAround,
                                            children: <Widget>[
                                              SizedBox(height: 40.0,),

                                              Container(
                                                width: MediaQuery
                                                    .of(context)
                                                    .size
                                                    .width * 0.47,
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
                                                      .width * 0.24,
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

                                              Stack(
                                                children: <Widget>[
                                                  Container(
                                                      width: MediaQuery
                                                          .of(context)
                                                          .size
                                                          .width * 0.20,
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
                                              ),
                                            ],

                                          ),
                                          Divider(color: Colors.black26,),
                                        ]);}

                              );

                            }

                            else{
                              return new Container(
                                  height: MediaQuery.of(context).size.height*0.30,
                                  child:Center(
                                    child: Container(
                                      width: MediaQuery.of(context).size.width*1,
                                      color: emp=='0'?appcolor.withOpacity(0.0):appcolor.withOpacity(0.1),
                                      padding:EdgeInsets.only(top:5.0,bottom: 5.0),
                                      child:Text(emp=='0'?"":"No present in last 30 days ",style: TextStyle(fontSize: 18.0),textAlign: TextAlign.center,),
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
                  height: MediaQuery.of(context).size.height*0.30,
                  //   shape: Border.all(color: Colors.deepOrange),
                  child: new ListTile(
                    title:
                    Container( height: MediaQuery.of(context).size.height*.55,
                      //width: MediaQuery.of(context).size.width*.99,
                      color: Colors.white,
                      //////////////////////////////////////////////////////////////////////---------------------------------
                      child: new FutureBuilder<List<Attn>>(
                        future: _listFuture2,
                        builder: (context, snapshot) {
                          if (snapshot.hasData) {
                           /* SchedulerBinding.instance.addPostFrameCallback((_) => setState(() {
                              countA=snapshot.data.length.toString();
                            }));*/
                            countA=snapshot.data.length.toString();
                            if(snapshot.data.length>0) {
                              return new ListView.builder(
                                  scrollDirection: Axis.vertical,
                                  itemCount: snapshot.data.length,
                                  itemBuilder: (BuildContext context, int index) {
                                    return new Column(
                                       children: <Widget>[
                                         (index == 0)?
                                           Row(
                                               children: <Widget>[
                                                 SizedBox(height: 25.0,),
                                                 Container(
                                                   padding: EdgeInsets.only(left: 5.0),
                                                   child: Text("Total Absent: ${countA}",style: TextStyle(color: headingcolor,fontWeight: FontWeight.bold,fontSize: 16.0,),),
                                                 ),
                                               ]
                                           ):new Center(),
                                         (index == 0)?
                                           Divider(color: Colors.black26,):new Center(),
                                       Row(
//                                           mainAxisAlignment: MainAxisAlignment
//                                               .spaceAround,
                                       children: <Widget>[
                                        SizedBox(height: 40.0,),
                                        Container(
                                          width: MediaQuery
                                              .of(context)
                                              .size
                                              .width * 0.30,
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
//                                            ),
                                           ]
                                         )
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
                                      color: emp=='0'?appcolor.withOpacity(0.0):appcolor.withOpacity(0.1),
                                      padding:EdgeInsets.only(top:5.0,bottom: 5.0),
                                      child: emp=='0'?"":Text("No absent in last 30 days ",style: TextStyle(fontSize: 18.0),textAlign: TextAlign.center,),
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
                  height: MediaQuery.of(context).size.height*0.30,
                  //   shape: Border.all(color: Colors.deepOrange),
                  child: new ListTile(
                    title:
                    Container( height: MediaQuery.of(context).size.height*.55,
                      //width: MediaQuery.of(context).size.width*.99,
                      color: Colors.white,
                      //////////////////////////////////////////////////////////////////////---------------------------------
                      child: new FutureBuilder<List<Attn>>(
                        future: _listFuture3,
                        builder: (context, snapshot) {
                          if (snapshot.hasData) {
                            /*SchedulerBinding.instance.addPostFrameCallback((_) => setState(() {
                              countL=snapshot.data.length.toString();
                            }));*/
                            countL=snapshot.data.length.toString();
                            if(snapshot.data.length>0) {
                              return new ListView.builder(
                                  scrollDirection: Axis.vertical,
                                  itemCount: snapshot.data.length,
                                  itemBuilder: (BuildContext context, int index) {
                                    return new Column(
                                        children: <Widget>[
                                          (index == 0)?
                                            Row(
                                                children: <Widget>[
                                                  SizedBox(height: 25.0,),
                                                  Container(
                                                    padding: EdgeInsets.only(left: 5.0),
                                                    child: Text("Total Late Coming: ${countL}",style: TextStyle(color: headingcolor,fontWeight: FontWeight.bold,fontSize: 16.0,),),
                                                  ),
                                                ]
                                            ):new Center(),
                                          (index == 0)?
                                            Divider(color: Colors.black26,):new Center(),
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
                                        ]);}
                              );
                            }

                            else{
                              return new Container(
                                  height: MediaQuery.of(context).size.height*0.30,
                                  child:Center(
                                    child: Container(
                                      width: MediaQuery.of(context).size.width*1,
                                      color: emp=='0'?appcolor.withOpacity(0.0):appcolor.withOpacity(0.1),
                                      padding:EdgeInsets.only(top:5.0,bottom: 5.0),
                                      child: emp=='0'?"":Text("No late comers in last 30 days ",style: TextStyle(fontSize: 18.0),textAlign: TextAlign.center,),
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
                  height: MediaQuery.of(context).size.height*0.30,
                  //   shape: Border.all(color: Colors.deepOrange),
                  child: new ListTile(
                    title:
                    Container( height: MediaQuery.of(context).size.height*.55,
                      //width: MediaQuery.of(context).size.width*.99,
                      color: Colors.white,
                      //////////////////////////////////////////////////////////////////////---------------------------------
                      child: new FutureBuilder<List<Attn>>(
                        future: _listFuture4,
                        builder: (context, snapshot) {
                          if (snapshot.hasData) {
                           /* SchedulerBinding.instance.addPostFrameCallback((_) => setState(() {
                              countE=snapshot.data.length.toString();
                            }));*/
                            countE=snapshot.data.length.toString();
                            if(snapshot.data.length>0) {
                              return new ListView.builder(
                                  scrollDirection: Axis.vertical,
                                  itemCount: snapshot.data.length,
                                  itemBuilder: (BuildContext context, int index) {
                                    return new Column(
                                        children: <Widget>[
                                          (index == 0)?
                                            Row(
                                                children: <Widget>[
                                                  SizedBox(height: 25.0,),
                                                  Container(
                                                    padding: EdgeInsets.only(left: 11.0),
                                                    child: Text("Total Early Leaving: ${countE}",style: TextStyle(color: headingcolor,fontWeight: FontWeight.bold,fontSize: 16.0,),),
                                                  ),
                                                ]
                                            ):new Center(),
                                          (index == 0)?
                                            Divider(color: Colors.black26,):new Center(),
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
                                        ]);}
                              );
                            }else{
                              return new Container(
                                  height: MediaQuery.of(context).size.height*0.25,
                                  child:Center(
                                    child: Container(
                                      width: MediaQuery.of(context).size.width*1,
                                      color: emp=='0'?appcolor.withOpacity(0.0):appcolor.withOpacity(0.1),
                                      padding:EdgeInsets.only(top:5.0,bottom: 5.0),
                                      child: emp=='0'?"":Text("No early leavers in last 30 days",style: TextStyle(fontSize: 18.0),textAlign: TextAlign.center,),
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
              child: Text('No Data Available'),
            ),
          ),
        ],
      ),

    );

  }

  Widget getEmployee_DD() {
    String dc = "0";
    return new FutureBuilder<List<Map>>(
        future: getEmployeesList(0),// with -select- label
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            try {
              return new Container(
                color: Colors.white,
                //width: MediaQuery.of(context).size.width*.45,
                child: InputDecorator(

                  decoration: InputDecoration(
                    border: InputBorder.none,
                    labelText: 'Select an employee',
                    prefixIcon: Padding(
                      padding: EdgeInsets.all(0.0),
                      child: Icon(
                        Icons.person,
                        color: Colors.grey,
                      ), // icon is 48px widget.
                    ),
                  ),

                  child: Padding(
                    padding: const EdgeInsets.only(right: 4.0),
                    child: new DropdownButton<String>(
                      isExpanded: true,
                      isDense: true,
                      style: new TextStyle(
                          fontSize: 15.0,
                          color: Colors.black
                      ),
                      value: emp,
                      onChanged: (String newValue) {
                        for(int i=0;i<snapshot.data.length;i++)
                        {
                          if(snapshot.data[i]['Id'].toString()==newValue)
                          {
                            setState(() {
                              empname = snapshot.data[i]['Name'].toString();
                            });
                            break;
                          }
                          print(i);
                        }
                          setState(() {
                            emp = newValue;
                            if(res = true) {
                              //getCount();
                              setAlldata();
                            }else{
                              print('state set----');
                              countP='0';
                              countA='0';
                              countE='0';
                              countL='0';
                            }
                          });
                      },
                      items: snapshot.data.map((Map map) {
                        return new DropdownMenuItem<String>(
                          value: map["Id"].toString(),
                          child: new SizedBox(
                              width: MediaQuery.of(context).size.width * 0.80,
                              child: map["Code"]!=''?new Text('('+map["Code"]+') '+map["Name"]):
                                new Text(map["Name"],)),
                        );

                      }).toList(),
                    ),
                  ),
                ),
              );
            }
            catch(e){
              return Text("EX: Unable to fetch employees");

            }
          } else if (snapshot.hasError) {
            print(snapshot.error);
            return new Text("ER: Unable to fetch employees");
          }
          // return loader();
          return new Center(child: SizedBox(
            child: CircularProgressIndicator(strokeWidth: 2.2,),
            height: 20.0,
            width: 20.0,
          ),);
        });
  }

  dialogwidget(msg, filename) {
    showDialog(
        context: context,
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
