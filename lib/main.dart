// Copyright 2018-present the Flutter authors. All Rights Reserved.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

import 'dart:convert';

import 'package:Shrine/app.dart';
import 'package:Shrine/globals.dart' as prefix0;
import 'package:Shrine/reports.dart';
import 'package:Shrine/timeoff_list.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:splashscreen/splashscreen.dart';

import 'globals.dart';
import 'newHomePage.dart';
import 'services/services.dart';
import 'package:http/http.dart' as http;

void main(){
  runApp(
      new MaterialApp(
        home: new MyApp(),
        //home: new NewHomePage(),
      ));
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => new _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey(debugLabel: "Main Navigator");


  void initState() {
    //checknetonpage(context);
    // StreamLocation sl = new StreamLocation();
    // sl.startStreaming(10);
    // cameraChannel.invokeMethod("showNotification",{"title":"Welcome to ubiAttendance","description":"Cleck out help videos!"});
    platform.setMethodCallHandler(_handleMethod);
    firebaseHandler();
  }

  FirebaseMessaging _firebaseMessaging = FirebaseMessaging();
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
        String long=call.arguments["longitude"].toString();
        String lat=call.arguments["latitude"].toString();
        assign_lat=double.parse(lat);
        assign_long=double.parse(long);
        address=await getAddressFromLati(lat, long);
        print(call.arguments["mocked"].toString());

        getAreaStatus().then((res) {
          // print('called again');
          print('main dot dart');
          if (mounted) {
            setState(() {
              areaSts = res.toString();
              print('response'+res.toString());
              if (areaId != 0 && geoFence == 1) {
                AbleTomarkAttendance = areaSts;
                print('insideable to markatt --------->>>>');
                print('insideabletoatt'+areaId.toString());
              }
            });
          }
        }).catchError((onError) {
          print('Exception occured in clling function.......');
          print(onError);
        });

        globalstreamlocationaddr=address;

        break;

        return new Future.value("");
    }
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      body:new Builder(
          builder: (BuildContext context) {
            return new SplashScreen(
                seconds: 2,
                navigateAfterSeconds: new ShrineApp(),
                title: new Text('',style: TextStyle(fontSize: 32.0),),
                loaderColor: Colors.blueGrey[100],
                image:   Image.asset('assets/splash.gif'),
                backgroundColor: Colors.white,
                styleTextUnderTheLoader: new TextStyle(color: Colors.grey[500]),
                photoSize: MediaQuery.of(context).size.width*0.60
              /*onClick: ()=>print("Flutter Egypt"),*/
            );
          }),);
  }

  void firebaseHandler() async{
    _firebaseMessaging.configure(
      onMessage: (Map<String, dynamic> message) async {
        print('on message $message'+message['data'].isEmpty.toString());
//{notification: {title: ABC has marked his Time In, body: null}, data: {}}
        cameraChannel.invokeMethod("showNotification",{"title":message['notification']['title']==null?'':message['notification']['title'].toString(),"description":message['notification']['body']==null?'':message['notification']['body'].toString(),"pageToOpenOnClick":message['data'].isEmpty?'':message['data']['pageToNavigate']});

      },
      onResume: (Map<String, dynamic> message) async {
        print('on resume $message');
        var navigate=message['data'].isEmpty?'':message['data']['pageToNavigate'];
        navigateToPageAfterNotificationClicked(navigate, context);
      },
      onLaunch: (Map<String, dynamic> message) async {
        print('on launch $message');
        var navigate=message['data'].isEmpty?'':message['data']['pageToNavigate'];
        navigateToPageAfterNotificationClicked(navigate, context);
      },
    );
  }

}