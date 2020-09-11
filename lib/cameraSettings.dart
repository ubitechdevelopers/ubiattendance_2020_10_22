// Copyright 2017 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.
import 'package:Shrine/Bottomnavigationbar.dart';
import 'package:Shrine/drawer.dart';
import 'package:Shrine/globals.dart' as prefix0;
import 'package:Shrine/services/gethome.dart';
import 'package:Shrine/services/services.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'globals.dart';

class CameraSettings extends StatefulWidget {
  @override
  _CameraSettings createState() => _CameraSettings();
}
class _CameraSettings extends State<CameraSettings> {
  bool isloading = false;
  final _oldPass = TextEditingController();
  final _newPass = TextEditingController();
  FocusNode __oldPass = new FocusNode();
  FocusNode __newPass = new FocusNode();
  final _formKey = GlobalKey<FormState>();
  bool _obscureText_old = true;
  bool _obscureText_new = true;
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  int response=0;
  int _currentIndex = 2;
  String org_name="";
  String admin_sts="0";
  @override
  void initState() {
    super.initState();
    initPlatformState();
  }
  // Platform messages are asynchronous, so we initialize in an async method.
  initPlatformState() async {
    appResumedPausedLogic(context);
    final prefs = await SharedPreferences.getInstance();
    response = prefs.getInt('response') ?? 0;

    prefix0.showAppInbuiltCamera=prefs.getBool("showAppInbuiltCamera")??true;
    prefix0.showPhoneCamera=prefs.getBool("showPhoneCamera")??false;

    admin_sts = prefs.getString('sstatus') ?? '0';
    if(response==1) {
      Home ho = new Home();
      setState(() {
        org_name = prefs.getString('org_name') ?? '';
      });
    }
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

        return new Future.value("");*/
    }
  }

  void _toggle_old() {
    setState(() {
      _obscureText_old = !_obscureText_old;
    });
  }
  void _toggle_new() {
    setState(() {
      _obscureText_new = !_obscureText_new;
    });
  }

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
      bottomNavigationBar: Bottomnavigationbar(),
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
              Icon(Icons.android,color: appcolor,),Text("Under development",style: new TextStyle(fontSize: 30.0,color: appcolor),)
            ]),
      ),
    );
  }
  bool isSwitched=true;
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
                    child:Text("Choose Camera",style: new TextStyle(fontSize: 22.0,color: appcolor)),
                  ),
                  SizedBox(height: 30.0),
                  Container(
                      child: Row(
                        children: <Widget>[
                          Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[    Container(
                                width: MediaQuery.of(context).size.width*.65,
                                child: Text("App\'s Camera",style: TextStyle(fontSize: 22.0),

                                ),
                              ),
                              ]
                          ),
                          Column(
                              mainAxisAlignment: MainAxisAlignment.end,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: <Widget>[    Container(
                                  width: MediaQuery.of(context).size.width*.15,
                                  child:Switch(
                                      value: showAppInbuiltCamera,
                                      onChanged: (value) async{
                                        //prefix0.cameraChannel.invokeMethod("askAudioPermission");
                                        var prefs= await SharedPreferences.getInstance();
                                        prefs.setBool("showAppInbuiltCamera", await value);
                                        setState((){
                                          showAppInbuiltCamera = value;
                                          if(prefix0.showAppInbuiltCamera==true){
                                            showPhoneCamera=false;
                                            prefs.setBool("showPhoneCamera", false);
                                          }else{
                                            showPhoneCamera=true;
                                            prefs.setBool("showPhoneCamera", true);
                                          }


                                        });
                                      })
                              ),

                              ]
                          )

                        ],
                      )
                  ),
                  Container(
                      child: Row(
                        children: <Widget>[
                          Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[    Container(
                                width: MediaQuery.of(context).size.width*.65,
                                child: Text("Phone Camera",style: TextStyle(fontSize: 22.0),

                                ),
                              ),
                              ]
                          ),
                          Column(
                              mainAxisAlignment: MainAxisAlignment.end,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: <Widget>[    Container(
                                  width: MediaQuery.of(context).size.width*.15,
                                  child:Switch(
                                      value: showPhoneCamera,
                                      onChanged: (value) async{
                                        //prefix0.cameraChannel.invokeMethod("askAudioPermission");
                                        var prefs= await SharedPreferences.getInstance();
                                        prefs.setBool("showPhoneCamera", await value);
                                        setState((){
                                          showPhoneCamera = value;
                                          if(prefix0.showPhoneCamera==true){
                                            showAppInbuiltCamera=false;
                                            prefs.setBool("showAppInbuiltCamera", false);

                                          }else{
                                            showAppInbuiltCamera=true;
                                            prefs.setBool("showAppInbuiltCamera", true);
                                          }


                                        });
                                      })
                              ),

                              ]
                          )

                        ],
                      )
                  ),//Enter date
                  SizedBox(height: 12.0),

                  /*
                  Container(
                      child: Row(
                        children: <Widget>[
                          Container(
                            width: MediaQuery.of(context).size.width*.75,
                            child: TextFormField(
                              controller: _newPass,
                              focusNode: __newPass,
                              keyboardType: TextInputType.text,
                              obscureText: _obscureText_new,

                              decoration: InputDecoration(
                                  labelText: 'New Password',
                                  prefixIcon: Padding(
                                    padding: EdgeInsets.all(0.0),
                                    child: Icon(
                                      Icons.lock,
                                      color: Colors.grey,
                                    ), // icon is 48px widget.
                                  )
                              ),
                              validator: (value) {
                                if (value.isEmpty || value==null || value.length<6 ) {
                                  __oldPass.notifyListeners();
                                  //                                 FocusScope.of(context).requestFocus(__newPass);
                                  return 'Password must be at least 8 characters';
                                }
                              },
                            ),
                          ),

                          Container(
                            width: MediaQuery.of(context).size.width*.1,
                            child: FlatButton(
                              padding: EdgeInsets.only(right:10.0),
                              child: Icon(
                                _obscureText_new ?Icons.visibility_off:Icons.visibility,
                                color: Colors.grey,
                              ),
                              onPressed: _toggle_new,
                            ),
                          ),
                        ],
                      )
                  ),

                  ButtonBar(
                    children: <Widget>[
                      FlatButton(
                        shape: Border.all(color: Colors.black54),
                        child: Text('CANCEL'),
                        onPressed: () {
                          Navigator.pop(context);
                        },
                      ),
                      RaisedButton(
                        child: Text('SUBMIT',style: TextStyle(color: Colors.white),),
                        color: Colors.orangeAccent,
                        onPressed: () {
                          if (_formKey.currentState.validate()) {
                            if (_oldPass.text == _newPass.text) {
                              showInSnackBar("New password can't same as old");
                              FocusScope.of(context).requestFocus(__newPass);
                            } else {
                              changeMyPassword(_oldPass.text, _newPass.text).then((res){
                                if(res==1) {
                                  _newPass.text='';
                                  _oldPass.text='';

                                  showInSnackBar(
                                      "Password changed successfully");
                                }
                                else if(res==2)
                                  showInSnackBar("Old Password did not match");
                                else if(res==3)
                                  showInSnackBar("New password can't be the same as old password");
                                else
                                  showInSnackBar("Unable to set password "+res.toString());
                              }).catchError((onError){
                                showInSnackBar("Unable to connect server");
                                print(onError);
                              });
                            }
                          }
                        },
                      ),
                    ],
                  ),*/
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}