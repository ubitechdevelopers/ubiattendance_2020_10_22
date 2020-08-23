// Copyright 2017 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.
import 'dart:convert';

import 'package:Shrine/page/camera.dart';
import 'package:Shrine/page/camera_grpatt.dart';
import 'package:Shrine/services/services.dart';
import 'package:Shrine/shared/widgets/focus_widget.dart';
import 'package:connectivity/connectivity.dart';
import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'Image_view.dart';
import 'drawer.dart';
import 'faceIdScreen.dart';
import 'globals.dart';
import 'home.dart';
import 'outside_label.dart';
import 'FaceIdScreen.dart';

// This app is a stateful, it tracks the user's current choice.
class FaceIdList extends StatefulWidget {
  @override
  _FaceIdList createState() => _FaceIdList();
}
TextEditingController today;String _orgName="";
class _FaceIdList extends State<FaceIdList> with SingleTickerProviderStateMixin {
  TabController _controller;
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

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
      trialstatus = prefs.getString('trialstatus') ?? '';
      admin_sts = prefs.getString('sstatus') ?? '';
      if(admin_sts == '2')
        Hightvar =  MediaQuery.of(context).size.height*0.75;
      else
        Hightvar =  MediaQuery.of(context).size.height*0.75;
    });
  }
  saveImageFaceId(String uid) async {
    print("object");
    var imagei;

    var prefs = await SharedPreferences.getInstance();
    String orgid = prefs.getString("orgid") ?? "";
    String empid = uid;
    timeWhenButtonPressed = DateTime.now();

      /* Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => CameraExampleHome()),
      );*/


        print("caaaallllled");
        imagei = await Navigator.push(context, new MaterialPageRoute(
          builder: (BuildContext context) =>
          new Camera_grpatt(
            mode: Camera_grpattMode.normal,
            imageMask: CameraFocus.circle(
              color: Colors.black.withOpacity(0.5),
            ),
          ),
          fullscreenDialog: true,)
        );
        if (imagei != null) {
          //print("---------------actionb   ----->"+mk.act);


          List<int> imageBytes = await imagei.readAsBytes();

          String PictureBase64 = base64.encode(imageBytes);

          /*
      final tempDir = await getTemporaryDirectory();
      String path = tempDir.path;
      int rand = new Math.Random().nextInt(10000);
      im.Image image1 = im.decodeImage(imagei.readAsBytesSync());
      imagei.deleteSync();
      im.Image smallerImage = im.copyResize(image1, 500); // choose the size here, it will maintain aspect ratio
      File compressedImage = new File('$path/img_$rand.jpg')..writeAsBytesSync(im.encodeJpg(smallerImage, quality: 50));
    */
          //// sending this base64image string +to rest api
          Dio dio = new Dio();

          FormData formData = new FormData.from({
            "uid": empid,
            "refid": orgid,
            "file": new UploadFileInfo(imagei, "image.png"),
          });
          print(formData);
          Response<String> response1 = await dio.post(
              path + "saveImageFaceId", data: formData);
          print("Response from save image:" + response1.toString());
          //Response<String> response1=await dio.post("https://ubiattendance.ubihrm.com/index.php/services/saveImage",data:formData);
          //Response<String> response1=await dio.post("http://192.168.0.200/ubiattendance/index.php/services/saveImage",data:formData);
          //Response<String> response1 = await dio.post("https://ubitech.ubihrm.com/services/saveImage", data: formData);
          imagei.deleteSync();
          imageCache.clear();
          // globals.cameraChannel.invokeMethod("cameraClosed");
          /*getTempImageDirectory();*/
          Map MarkAttMap = json.decode(response1.data);
          print("facerecog");
          print(MarkAttMap["facerecog"].toString());
          if (MarkAttMap["facerecog"].toString() == 'FACE_DETECTED') {
            showDialog(
                context: context,
                // ignore: deprecated_member_use
                child: new AlertDialog(

                  content: new Text(
                      "Our AI engine is generating the Face ID. It may take a few minutes."),
                )
            );
            Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => FaceIdList()), (Route<dynamic> route) => false,);

          }else
          if (MarkAttMap["facerecog"].toString() == 'NO_FACE_DETECTED') {

            showDialog(
                context: context,
                // ignore: deprecated_member_use
                child: new AlertDialog(

                  content: new Text(
                      "Clicked picture is not clear"),
                )
            );
            saveImageFaceId(empid);

          }else
          if (MarkAttMap["facerecog"].toString() == 'NO_IMAGE_RECIEVED') {

            showDialog(
                context: context,
                // ignore: deprecated_member_use
                child: new AlertDialog(

                  content: new Text(
                      "No image recieved"),
                )
            );
            saveImageFaceId(empid);

          }else
          if (MarkAttMap["facerecog"].toString() == 'FACE_ID_ALREADY_EXISTS') {

            showDialog(
                context: context,
                // ignore: deprecated_member_use
                child: new AlertDialog(

                  content: new Text(
                      "Face ID already exists"),
                )
            );
            saveImageFaceId(empid);

          }
          print(MarkAttMap["status"].toString());

        }


  }
  showsuspiciousdialog(id,orgid) async {

    await showDialog<String>(
      context: context,
      // ignore: deprecated_member_use
      child: new AlertDialog(
        contentPadding: const EdgeInsets.all(8.0),
        content: Container(
          height: MediaQuery.of(context).size.height*0.04,
          width: MediaQuery.of(context).size.width*0.06,
          child: Column(
            children: <Widget>[
              /*new Expanded(
                child: new TextField(
                  maxLines: 5,
                  autofocus: true,
                  controller: _comments,
                  decoration: new InputDecoration(
                      labelText: 'Visit Feedback ', hintText: 'Visit Feedback (Optional)'),
                ),
              ),*/
              Text('Disapprove?',style: TextStyle(color: Colors.black,fontSize: 18.0)
              ),
              SizedBox(height: 4.0,),

            ],
          ),
        ),
        actions: <Widget>[
          new FlatButton(

              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(5),
                side: BorderSide( color: Colors.grey.withOpacity(0.5), width: 1,),
              ),
              child: const Text('CANCEL',style: TextStyle(color: Colors.black),),
              onPressed: () {
                Navigator.of(context, rootNavigator: true).pop();
              }),
          Padding(
            padding: const EdgeInsets.only(right:40.0),
            child: new RaisedButton(
                child: const Text('DISAPPROVE',style: TextStyle(color: Colors.white),),
                elevation: 2.0,
                highlightElevation: 5.0,
                highlightColor: Colors.transparent,
                disabledElevation: 0.0,
                focusColor: Colors.transparent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(5),
                ),
                color: buttoncolor,
                onPressed: () async{
                  Navigator.of(context, rootNavigator: true).pop();
                  disapprovefaceid(id,orgid).then((res){
                    print(res.toString());

                    //   if(res)
                    //  {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => FaceIdList()),
                    );
                    showDialog(
                        context: context,
                        // ignore: deprecated_member_use
                        child: new AlertDialog(
                          content: new Text("\"Face ID\" disapproved successfully"),
                        ));
                    //  }
                    //  else
//                  {
//                    showDialog(
//                        context: context,
//                        // ignore: deprecated_member_use
//                        child: new AlertDialog(
//                          content: new Text("Unable to disapprove attendance"),
//                        ));
                  });
//                }).catchError((ett){
//                  showInSnackBar('Unable to disapprove attendance');
//                });
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
                }),
          )
        ],
      ),
    );
  }
  @override
  void initState() {
    super.initState();
    checkNetForOfflineMode(context);
    appResumedPausedLogic(context);
    _controller = new TabController(length: 2, vsync: this);
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
        title: new Text(_orgName, style: new TextStyle(fontSize: 20.0)),
        backgroundColor: appcolor,
      ),
      endDrawer: new AppDrawer(),
      body: new ListView(
        physics: NeverScrollableScrollPhysics(),
        children: <Widget>[
          SizedBox(height:10.0),
          new Container(
            child: Center(child:Text("Face ID",style: TextStyle(fontSize: 22.0,color: appcolor),),),
          ),
          Divider(color: Colors.black54,height: 1.5,),
          /*
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
                labelText: 'Select Date',
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
              title: new SizedBox(height: MediaQuery.of(context).size.height*0.27,

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
          */

          //Divider(),
          SizedBox(height: 8.0,),
          new Container(
            decoration: new BoxDecoration(color: Colors.black54),
            child: new TabBar(
              indicator: BoxDecoration(color: buttoncolor,),
              controller: _controller,
              tabs: [
                new Tab(
                  text: 'Registered',
                ),
                new Tab(
                  text: 'Unregistered',
                ),
                /*
                new Tab(
                  text: 'Late \nComers',
                ),
                new Tab(
                  text: 'Early \nLeavers',
                ),
                */
              ],
            ),
          ),
          /*
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
          */
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
                      child: new FutureBuilder<List<FaceIdLists>>(
                        future: getregisteredFaceIDList('registered'),
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
                                             // SizedBox(height: 40.0,),


                                              Container(
                                                  width: MediaQuery
                                                      .of(context)
                                                      .size
                                                      .width * 0.15,
                                                  child: Column(
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: <Widget>[
                                                      /*
                                                      Text(snapshot.data[index].TimeIn
                                                          .toString(),style: TextStyle(fontWeight: FontWeight.bold),),
                                                      */
                                                      Container(
                                                        width: 42.0,
                                                        height: 42.0,
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
                                                                              .Image)
                                                                  )
                                                              )),
                                                          onTap: (){
                                                            Navigator.push(
                                                              context,
                                                              MaterialPageRoute(builder: (context) => ImageView(myimage: snapshot.data[index].Image,org_name: _orgName)),
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
                                                    .width * 0.4,

                                                child: Column(
                                                  crossAxisAlignment: CrossAxisAlignment
                                                      .start,
                                                  children: <Widget>[
                                                    Text(snapshot.data[index].Name
                                                        .toString(), style: TextStyle(
                                                        color: Colors.black87,
                                                        fontWeight: FontWeight.bold,
                                                        fontSize: 16.0),),
                                                    /*
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

                                                 */
                                                  ],
                                                ),
                                              ),
                                              /*
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
                                              */
                                              Expanded(
                                                child: RaisedButton(
                                                  elevation: 2.0,
                                                  highlightElevation: 5.0,
                                                  highlightColor: Colors.transparent,
                                                  disabledElevation: 0.0,
                                                  focusColor: Colors.transparent,
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius: BorderRadius.circular(5),
                                                  ),
                                                  child: Text(
                                                    'Disapprove',
                                                    style: TextStyle(color: Colors.white),
                                                  ),
                                                  color: buttoncolor,
                                                  onPressed: () {
                                                    print('id-->'+snapshot.data[index].Id+'orgid-->'+snapshot.data[index].orgid);
                                                    showsuspiciousdialog(snapshot.data[index].Id,snapshot.data[index].orgid);


                                                  },
                                                ),
                                              )
                                            ],

                                          ),
                                          Divider(color: Colors.black26,),

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
                                      child:Text("No registered face found ",style: TextStyle(fontSize: 18.0),textAlign: TextAlign.center,),
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
                      child: new FutureBuilder<List<FaceIdLists>>(
                        future: getregisteredFaceIDList('unregistered'),
                        builder: (context, snapshot) {
                          if (snapshot.hasData) {
                            if(snapshot.data.length>0) {
                              return new ListView.builder(
                                  scrollDirection: Axis.vertical,
                                  itemCount: snapshot.data.length,
                                  itemBuilder: (BuildContext context, int index) {
                                    return new Row(
//                                      mainAxisAlignment: MainAxisAlignment
//                                          .spaceAround,
                                      children: <Widget>[
                                        SizedBox(height: 30.0,),
                                        Container(
                                          width: MediaQuery
                                              .of(context)
                                              .size
                                              .width * 0.5,
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
                                        Expanded(
                                          child: RaisedButton(
                                            elevation: 2.0,
                                            highlightElevation: 5.0,
                                            highlightColor: Colors.transparent,
                                            disabledElevation: 0.0,
                                            focusColor: Colors.transparent,
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(5),
                                            ),
                                            child: Text(
                                              'Register',
                                              style: TextStyle(color: Colors.white),
                                            ),
                                            color: buttoncolor,
                                            onPressed: () {
                                              print("saveimage clicked");
                                              print(snapshot.data[index].Id);
                                              saveImageFaceId(snapshot.data[index].Id);
                                            },
                                          ),
                                        )],

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
                                      child:Text("No data found ",style: TextStyle(fontSize: 18.0),textAlign: TextAlign.center,),
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
/*
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
                */
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
}
