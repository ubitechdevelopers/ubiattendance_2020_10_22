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
// this is testing
import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:Shrine/database_models/qr_offline.dart';
import 'package:Shrine/globals.dart' as prefix0;
import 'package:Shrine/model/user.dart';
import 'package:Shrine/offline_home.dart';
import 'package:Shrine/services/checklogin.dart';
import 'package:Shrine/services/services.dart';
import 'package:barcode_scan/barcode_scan.dart';
import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:rounded_modal/rounded_modal.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'askregister.dart';
import 'forgot_password.dart';
import 'globals.dart';
import 'home.dart';
import 'otpvarify.dart';


class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  static const platform = const MethodChannel('location.spoofing.check');
  String barcode = "";
  final _formKey = GlobalKey<FormState>();
  final _formKeyM = GlobalKey<FormState>();
  String loginuser="";


  bool loader = false;
  FocusNode textSecondFocusNode = new FocusNode();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool isloading = false;
  String username="";
  final _username = TextEditingController();
  FocusNode __username = new FocusNode();
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  int response=0;
  bool err=false;
  bool succ=false;
  bool _isButtonDisabled=false;
  bool loginu=false;
  int _currentIndex = 2;

  @override
  void initState() {
    super.initState();
    initPlatformState();
    platform.setMethodCallHandler(_handleMethod);
  }
  String address="";
  Future<dynamic> _handleMethod(MethodCall call) async {
    switch(call.method) {

      case "locationAndInternet":
        prefix0.locationThreadUpdatedLocation=true;
        // print(call.arguments["internet"].toString()+"akhakahkahkhakha");
        // Map<String,String> responseMap=call.arguments;
        if(call.arguments["TimeSpoofed"].toString()=="Yes"){
          timeSpoofed=true;

        }

        String long=call.arguments["longitude"].toString();
        String lat=call.arguments["latitude"].toString();
        assign_lat=double.parse(lat);
        assign_long=double.parse(long);
        address=await getAddressFromLati(lat, long);
        print(call.arguments["mocked"].toString());



        if(call.arguments["mocked"].toString()=="Yes"){
          fakeLocationDetected=true;
        }
        else{
          fakeLocationDetected=false;
        }

        long=call.arguments["longitude"].toString();
        lat=call.arguments["latitude"].toString();
        globalstreamlocationaddr=address;




        break;

        return new Future.value("");
    }
  }





  initPlatformState() async {
    final prefs=await SharedPreferences.getInstance();
    // syncOfflineQRData();
    var isAlreadyLoggedIn=prefs.getInt("response");
    var isConnected=await checkConnectionToServer();

    if (isAlreadyLoggedIn == 1) {
      /*if(isConnected==1){
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => HomePage()),
        );
      }

      else */
      if (prefs.getInt("OfflineModePermission") == 1 && isConnected != 1) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => OfflineHomePage()),
        );
      }
    }
    if (mounted) {
      setState(() {
        loginuser=prefs.getString('username') ?? "";
        _usernameController.text=loginuser;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      key: _scaffoldKey,
      body:new Builder(
        builder: (BuildContext context) {
          return new Center(
            child: Form(
              key: _formKey,
              child: SafeArea(
                child: ListView(
                  padding: EdgeInsets.symmetric(horizontal: 24.0),
                  children: <Widget>[
                    SizedBox(height: 50.0),
                    Column(
                      children: <Widget>[
                        Image.asset(
                          'assets/logo.png', height: 150.0, width: 150.0,),
                        (loader) ? Center(child : new CircularProgressIndicator()) : SizedBox(height: 2.0),
                        /*Text('Log In', style: new TextStyle(fontSize: 20.0)),*/
                      ],
                    ),
                    /*SizedBox(height: 10.0),*/
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: <Widget>[
                        GestureDetector(
                          onTap: () {

                            if(globalstreamlocationaddr == "Location not fetched."){
                              showDialog(
                                  context: context,
                                  barrierDismissible: false,
                                  // ignore: deprecated_member_use
                                  child: new AlertDialog(
                                    content: new Text('Kindly enable location excess from settings',style:TextStyle(fontSize: 16.0,)),
                                    actions: <Widget>[
                                      RaisedButton(
                                        child: Text('Open Settings'),
                                        onPressed: () {
                                          PermissionHandler().openAppSettings();
                                        },
                                      ),
                                    ],
                                  ));
                              return null;




                            }
                            if(loader)
                              return null;

                            setState(() {
                              loader = true;
                            });
                            /*var internetAvailable= checkConnectionToServer().then((connected){

                            if(connected==0){
                                 markAttByQROffline(context);
                               }
                               else{
                              */   scan().then((onValue){
                              print("******************** QR value **************************");
                              print(onValue);
                              print("******************** QR value **************************");
                              //return false;
                              if(onValue!='error') {

                                markAttByQR(onValue, context);
                              }else {
                                setState(() {
                                  loader = false;
                                });
                              }
                            });
                            /*    }
                          });*/

                          },
                          child:  Image.asset(
                            'assets/qr.png', height: 45.0, width: 45.0,
                          ),
                        ),
                      ],
                    ),

                    TextFormField(
                      decoration: InputDecoration(
                        labelText: 'Email or Phone',
                      ),
                      onFieldSubmitted: (String value) {
                        FocusScope.of(context).requestFocus(textSecondFocusNode);
                      },
                      controller: _usernameController,
                      validator: (value) {
                        if (value.isEmpty) {
                          return 'Please enter the Username';
                        }
                      },
                    ),
                    // spacer
                    SizedBox(height: 12.0),
                    // [Password]
                    TextFormField(
                      decoration: InputDecoration(
                        labelText: 'Password',
                      ),
                      obscureText: true,
                      focusNode: textSecondFocusNode,
                      controller: _passwordController,
                      validator: (value) {
                        if (value.isEmpty) {
                          return 'Please enter password';
                        }
                      },
                      onFieldSubmitted: (String value) {
                        if (_formKey.currentState.validate())  {

                          login(_usernameController.text,_passwordController.text,context);
                        }
                      },
                    ),

                    SizedBox(height: 5.0),
                    Row(

                      mainAxisAlignment: MainAxisAlignment.end,
                      children: <Widget>[
                        ButtonBar(
                          children: <Widget>[
                            FlatButton(
                              shape: Border.all(color: Colors.black54),
                              child: Text('CANCEL'),
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => AskRegisterationPage()),
                                );
                              },
                            ),
                            ButtonTheme(
                              minWidth: MediaQuery.of(context).size.width*0.25,
                              child:RaisedButton(
                                child: Text('LOGIN',style: TextStyle(color: Colors.white),),
                                color: buttoncolor,
                                onPressed: () {
                                  if (_formKey.currentState.validate()) {
                                    login(_usernameController.text,_passwordController.text,context);
                                  }
                                },
                              ),
                            ),
                          ],
                        ),

                      ],
                    ),

                    /* Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      ButtonTheme(
                        minWidth: MediaQuery.of(context).size.width*0.3,
                        child:RaisedButton(
                        child: Text('Scan QR code'),
                        color: Colors.orangeAccent,
                        onPressed: () {
                         scan().then((onValue){
                            print(onValue);
                            markAttByQR(onValue,context);
                         });
                        },
                      ),
                      ),
                    ],
                  ),*/
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: <Widget>[
                        InkWell(
                          child: new Text("Forgot Password?", style: new TextStyle(
                              color: appcolor,
                              fontWeight: FontWeight.bold,
                              fontSize: 13.0,
                              decoration: TextDecoration.underline),),
                          onTap: () {
                            _showModalSheet(context);

//                            Navigator.push(
//                                context, new MaterialPageRoute(builder: (BuildContext context) => ForgotPassword()));
                          },
                        ),
                        SizedBox(width: 19.0,)
                      ],
                    )
                  ],
                ),
              ),
            )
            ,
          );
        },
      ),
    );

  }

  void showInSnackBar(String value) {
    final snackBar = SnackBar(
        content: Text(value,textAlign: TextAlign.center,));
    _scaffoldKey.currentState.showSnackBar(snackBar);
  }

  markAttByQROffline(BuildContext context){
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(

            content: Container(
                height: MediaQuery.of(context).size.height * 0.18,
                child: Column(children: <Widget>[
                  Container(
                      width: MediaQuery.of(context).size.width * 0.6,
                      child: Text(
                          "")),
                  new Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        ButtonBar(
                          children: <Widget>[
                            FlatButton(
                              child: Text('Time In' ,style: TextStyle(color: Colors.green),),
                              shape: Border.all(color: Colors.green),
                              onPressed: () {
                                timeInPressedTime=DateTime.now();
                                Navigator.of(context, rootNavigator: true)
                                    .pop();
                                saveOfflineQr(0);

                              },
                            ),
                            new RaisedButton(
                              child: new Text(
                                "Time Out",
                                style: new TextStyle(
                                  color: Colors.white,
                                ),
                              ),
                              color: Colors.redAccent,
                              onPressed: () {
                                timeOutPressedTime=DateTime.now();
                                Navigator.of(context, rootNavigator: true)
                                    .pop();
                                saveOfflineQr(1);
                              },
                            ),
                          ],
                        ),
                      ])
                ]))));
  }

  saveOfflineQr(int action) async{
    final prefs = await SharedPreferences.getInstance();
    int UserId = int.parse(prefs.getString("empid")??"0") ?? 0;
    int Action = action; // 0 for time in and 1 for time out
    String Date;
    int OrganizationId = int.parse(prefs.getString("orgid")??"0") ?? 0;
    String PictureBase64;
    int IsSynced;
    String Latitude;
    String Longitude;
    String Time;
    String actionString=(action==0)?"Time In":"Time Out";
    File img = null;
    imageCache.clear();
    scan().then((onValue){
      print("******************** QR value **************************");
      print(onValue);
      print("******************** QR value **************************");
      //return false;
      if(onValue!='error') {
        List splitstring = onValue.split("ykks==");
        var UserName=splitstring[0];
        var Password=splitstring[1];

        var imageRequired = prefs.getInt("ImageRequired");
        if (imageRequired == 1) {

          cameraChannel.invokeMethod("cameraOpened");
          ImagePicker.pickImage(
              source: ImageSource.camera, maxWidth: 200.0, maxHeight: 200.0)
              .then((img) async {

            if (img != null) {
              List<int> imageBytes = await img.readAsBytes();
              PictureBase64 = base64.encode(imageBytes);

              print("--------------------Image---------------------------");
              print(PictureBase64);

              print("--------------------Image---------------------------");

              var now;
              if(action==0){
                now=timeInPressedTime;
              }
              else{
                now=timeOutPressedTime;
              }
              var formatter = new DateFormat('yyyy-MM-dd');

              Date = formatter.format(now);
              Time = DateFormat("H:mm:ss").format(now);


              print("--------------------Date Time---------------------------");
              print(Date + " " + Time);

              print("--------------------Date Time---------------------------");

              Latitude = await assign_lat.toString();
              Longitude = await assign_long.toString();
              var FakeLocationStatus=0;
              if(fakeLocationDetected)
                FakeLocationStatus=1;

              // print(lat+"lalalal"+long+location_addr);

              IsSynced = 0;


              QROffline qrOffline = new QROffline(
                  null,
                  UserId,
                  Action,
                  Date,
                  OrganizationId,
                  PictureBase64,
                  IsSynced,
                  Latitude,
                  Longitude,
                  Time,
                  UserName,
                  Password,
                  FakeLocationStatus,
                  timeSpoofed?1:0
              );
              qrOffline.save();
              timeInPressedTime=null;
              timeOutPressedTime=null;
              cameraChannel.invokeMethod("cameraClosed");
              img.deleteSync();
              imageCache.clear();

              // ignore: deprecated_member_use
              showDialog(context: context, child:
              new AlertDialog(
                content: new Text(
                    actionString+" is marked. It will be synced when you are online"),
              )
              );
              print("-----------------------Context-----------------------");
              print(context);
              Navigator
                  .of(context)
                  .push(
                MaterialPageRoute(builder: (context) => LoginPage()),
              );
              Navigator.of(context, rootNavigator: true)
                  .pop();
            }
            else {
              setState(() {
                // timeInClicked = false;
                // timeOutClicked = false;
              });
            }
          });
        }
        else {
          var now;
          if(action==0){
            now=timeInPressedTime;
          }
          else{
            now=timeOutPressedTime;
          }
          var formatter = new DateFormat('yyyy-MM-dd');

          Date = formatter.format(now);
          Time = DateFormat("H:mm:ss").format(now);


          print("--------------------Date Time---------------------------");
          print(Date + " " + Time);

          print("--------------------Date Time---------------------------");

          Latitude = assign_lat.toString();
          Longitude = assign_long.toString();

          // print(lat+"lalalal"+long+location_addr);

          IsSynced = 0;
          var FakeLocationStatus=0;
          if(fakeLocationDetected)
            FakeLocationStatus=1;


          QROffline qrOffline = new QROffline(
              null,
              UserId,
              Action,
              Date,
              OrganizationId,
              '',
              IsSynced,
              Latitude,
              Longitude,
              Time,
              UserName,
              Password,
              FakeLocationStatus,
              timeSpoofed?1:0
          );
          qrOffline.save();

          timeInPressedTime=null;
          timeOutPressedTime=null;

          // ignore: deprecated_member_use
          showDialog(context: context, child:
          new AlertDialog(
            content: new Text(
                "Attendance marked successfully and will be synced when you get connected!"),
          )
          );
          print("-----------------------Context-----------------------");
          print(context);
          Navigator
              .of(context)
              .push(
            MaterialPageRoute(builder: (context) => LoginPage()),
          );
        }

      }else {
        setState(() {
          loader = false;
        });
      }
    });

  }
  /*
  markAttByQR(var qr, BuildContext context) async{
    Login dologin = Login();
    setState(() {
      loader = true;
    });
    print('ab');

    var islogin = await dologin.markAttByQR(qr,fakeLocationDetected?1:0,context);
    print(islogin);
    if(islogin=="success" || islogin=="success1" ){
      setState(() {
        loader = false;
      });
      if(islogin=="success" )
        showDialog(
            context: context,
            // ignore: deprecated_member_use
            child: new AlertDialog(
              content: new Text("Time In marked successfully"),
            ));
      /*Scaffold.of(context)
          .showSnackBar(
          SnackBar(content: Text("TimeIn marked successfully.")));*/
      else
        showDialog(
            context: context,
            // ignore: deprecated_member_use
            child: new AlertDialog(
              content: new Text("Time Out marked successfully"),
            ));

    }else if(islogin=="failure"){
      setState(() {
        loader = false;
      });
      Scaffold.of(context)
          .showSnackBar(
          SnackBar(content: Text("Invalid login credentials")));
    }else if(islogin=="imposed"){
      setState(() {
        loader = false;
      });
      Scaffold.of(context)
          .showSnackBar(
          SnackBar(content: Text("Attendance is already marked")));
    }else if(islogin=="nolocation"){
      setState(() {
        loader = false;
      });
      /* Scaffold.of(context)
          .showSnackBar(
          SnackBar(content: Text("Problem Getting Location! Please turn on GPS and try again")));*/
      showDialog(
          context: context,
          // ignore: deprecated_member_use
          child: new AlertDialog(
            content: new Text("Problem Getting Location! Please turn on GPS and try again"),
          ));
    }else{
      setState(() {
        loader = false;
      });
      Scaffold.of(context)
          .showSnackBar(
          SnackBar(content: Text("Problem while marking attendance")));
    }
  }
  */

  markAttByQR(var qr, BuildContext context) async{
    final prefs = await SharedPreferences.getInstance();
    int FakeLocationStatus=0;
    Login dologin = Login();
    setState(() {
      loader = true;
    });
    print('ab');

    var islogin = await dologin.markAttByQR(qr,FakeLocationStatus,context);
    print(islogin);
    if(islogin=="success"){
      prefs.setString('username', username);
      /*Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => HomePage()),
      );*/
      Navigator.pushAndRemoveUntil(context,MaterialPageRoute(builder: (context) => HomePage()), (Route<dynamic> route) => false,);
    }else if(islogin == 'MailNotVerified') {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => Otp(_usernameController.text,_passwordController.text,context)),
      );
    } else if(islogin == 'inactive user') {
      setState(() {
        loader = false;
      });
      Scaffold.of(context)
          .showSnackBar(
          SnackBar(content: Text("Your account has been deactivated or archived. You can not login.")));
      return;
    }else if(islogin=="failure"){
      setState(() {
        loader = false;
      });
      Scaffold.of(context)
          .showSnackBar(
          SnackBar(content: Text("Invalid login credentials")));
    }else{
      setState(() {
        loader = false;
      });
      Scaffold.of(context)
          .showSnackBar(
          SnackBar(content: Text("Poor network connection.")));
    }
  }

  login(var username,var userpassword, BuildContext context) async{
    final prefs = await SharedPreferences.getInstance();


    var user = User(username,userpassword);
    var connectivityResult = await (new Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.mobile || connectivityResult == ConnectivityResult.wifi) {
      Login dologin = Login();
      setState(() {
        loader = true;
      });

      var islogin = await dologin.checkLogin(user);
      print(islogin);
      print(mailstatus);   //when new organization registered
      print(mailverifiedstatus);  //when existing organiztion's employee login
      print("mailll");

      if(islogin=="success"  ) {
        prefs.setString('username', username);
        /*Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => HomePage()),
      );*/
        Navigator.pushAndRemoveUntil(context,MaterialPageRoute(builder: (context) => HomePage()), (Route<dynamic> route) => false,);
      }
      else if(islogin == 'MailNotVerified') {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => Otp(_usernameController.text,_passwordController.text,context)),
        );
      }
      else if(islogin == 'inactive user') {

        setState(() {
          loader = false;
        });
        Scaffold.of(context)
            .showSnackBar(
            SnackBar(content: Text("Your account has been deactivated or archived. You can not login.")));
        return;
      }
      else if(islogin=="failure"){
        setState(() {
          loader = false;
        });
        Scaffold.of(context)
            .showSnackBar(
            SnackBar(content: Text("Invalid login credentials")));
      }else{
        setState(() {
          loader = false;
        });
        Scaffold.of(context)
            .showSnackBar(
            SnackBar(content: Text("Poor network connection.")));
      }
    }else{
      // ignore: deprecated_member_use
      showDialog(context: context, child:
      new AlertDialog(

        content: new Text("Internet connection not found!."),
      )
      );
    }

  }

  Future scan() async {
    try {
      String barcode = await BarcodeScanner.scan();
      setState(() => this.barcode = barcode);
      return barcode;
    } on PlatformException catch (e) {
      if (e.code == BarcodeScanner.CameraAccessDenied) {
        setState(() {
          this.barcode = 'The user did not grant the camera permission!';
        });
        return "pemission denied";
      } else {
        setState(() => this.barcode = 'Unknown error: $e');
        return "error";
      }
    } on FormatException{
      setState(() => this.barcode = 'null (User returned using the "back"-button before scanning anything. Result)');
      return "error";
    } catch (e) {
      setState(() => this.barcode = 'Unknown error: $e');
      return "error";
    }
  }


  _showModalSheet(context) async{
    showRoundedModalBottomSheet(context: context, builder: (builder) {
      return Container(
        height: MediaQuery.of(context).size.height*0.33,
        child: Form(
          key: _formKeyM,
          child: SafeArea(
            child: ListView(
              padding: EdgeInsets.symmetric(horizontal: 24.0),
              children: <Widget>[
//              SizedBox(height: 50.0),
//              Column(
//                children: <Widget>[
//                  Image.asset(
//                    'assets/logo.png', height: 150.0, width: 150.0,),
//                  //(loader) ? Center(child : new CircularProgressIndicator()) : SizedBox(height: 2.0),
//                  /*Text('Log In', style: new TextStyle(fontSize: 20.0)),*/
//                ],
//              ),
                Center(
                  child:Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      SizedBox(height: MediaQuery.of(context).size.height*0.05),
                      Center(child:
                      Text("Reset Password",style: new TextStyle(fontSize: 22.0,color: Colors.black54)),
                      ),
                      SizedBox(height: 10.0),
                      succ==false?Container(
                          child: Row(
                            children: <Widget>[
                              Container(
                                width: MediaQuery.of(context).size.width*.8,
                                child: TextFormField(
                                  controller: _username,
                                  focusNode: __username,
                                  keyboardType: TextInputType.text,
                                  decoration: InputDecoration(
                                      hintText: 'Email',
                                      //labelText: 'Email',
                                      prefixIcon: Padding(
                                        padding: EdgeInsets.all(0.0),
                                        child: Icon(
                                          Icons.mail,
                                          color: Colors.grey,
                                        ), // icon is 48px widget.
                                      )
                                  ),
                                  validator: (value) {
                                    if (value.isEmpty || value==null) {
//                                  FocusScope.of(context).requestFocus(__oldPass);
                                      return 'Please enter valid Email';
                                    }
                                  },

                                ),
                              ),
                            ],
                          )
                      ):Center(), //Enter date
                      SizedBox(height: 12.0),

                      succ==false?ButtonBar(
                        children: <Widget>[
                          FlatButton(
                            shape: Border.all(color: Colors.black54),
                            child: Text('CANCEL'),
                            onPressed: () {
                              Navigator.pop(context);
                            },
                          ),
                          RaisedButton(
                            child: _isButtonDisabled==false?Text('SUBMIT',style: TextStyle(color: Colors.white),):Text('WAIT...',style: TextStyle(color: Colors.white),),
                            color: buttoncolor,
                            onPressed: () {
                              if (_formKeyM.currentState.validate()) {
                                if (_username.text == ''||_username.text == null) {
                                  showInSnackBar("Please Enter Email");
                                  FocusScope.of(context).requestFocus(__username);
                                } else {
                                  if(_isButtonDisabled)
                                    return null;
                                  setState(() {
                                    _isButtonDisabled=true;
                                  });
                                  resetMyPassword(_username.text).then((res) async{
                                    final prefs = await SharedPreferences.getInstance();
                                    prefs.setString('username', _username.text);

                                    if(res==1) {

                                      username = _username.text;
                                      _username.text='';
                                      print("hello user");
                                      showInSnackBar(
                                          "Request submitted successfully");
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(builder: (context) => LoginPage()),
                                      );
                                      setState(() {
                                        loginu=true;
                                        succ=true;
                                        err=false;
                                        _isButtonDisabled=false;
                                      });
                                      // ignore: deprecated_member_use
                                      showDialog(context: context,
                                          child: new AlertDialog(
                                            title: new Text("Alert"),
                                            content: new Text("Please check your mail for the reset Password link."),
                                          ));
                                    }
                                    else {
                                      showInSnackBar("Email Not Found.");
                                      setState(() {
                                        loginu=false;
                                        succ=false;
                                        err=true;
                                        _isButtonDisabled=false;
                                      });
                                    }
                                  }).catchError((onError){
                                    showInSnackBar("Unable to call reset password service");
                                    setState(() {
                                      loginu=false;
                                      succ=false;
                                      err=false;
                                      _isButtonDisabled=false;
                                    });
                                    // showInSnackBar("Unable to call reset password service::"+onError.toString());
                                    print(onError);
                                  });
                                }
                              }
                            },
                          ),
                        ],
                      ):Center(),
                      //err==true?Text('Invalid Email.',style: TextStyle(color: Colors.red,fontSize: 16.0),):Center(),
                      succ==true?Text('Please check your mail for the Password reset link. After you have reset the password, please click below link to login.',style: TextStyle(fontSize: 16.0),):Center(),
                      loginu==true?InkWell(
                        child: Text('\nClick here to Login',style: TextStyle(fontWeight: FontWeight.bold,fontSize: 16.0,color: appcolor),),
                        onTap:() async{
                          final prefs = await SharedPreferences.getInstance();
                          prefs.setString('username', username);
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => LoginPage()),
                          );
                        } ,
                      ):Center(),
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      );
    });
  }



}

