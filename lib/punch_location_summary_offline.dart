import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:Shrine/database_models/visits_offline.dart';
import 'package:Shrine/genericCameraClass.dart';
import 'package:Shrine/globals.dart' as prefix0;
import 'package:Shrine/services/services.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'Image_view.dart';
import 'globals.dart';
import 'offline_attendance_logs.dart';
import 'offline_home.dart';
import 'punch_location_offline.dart';

void main() => runApp(new PunchLocationSummaryOffline());

class PunchLocationSummaryOffline extends StatefulWidget {
  @override
  _PunchLocationSummaryOffline createState() => _PunchLocationSummaryOffline();
}

class _PunchLocationSummaryOffline extends State<PunchLocationSummaryOffline> {
  static const platform = const MethodChannel('location.spoofing.check');
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  String lat="";
  String long="";
  String desination="";
  String profile="";
  String org_name="";
  String orgid="";
  String empid="";
  String admin_sts='0';
  int _currentIndex = 1;

  //StreamLocation sl = new StreamLocation();
  //bool _isButtonDisabled= false;
  final _comments=TextEditingController();

  Timer timer;

  var FakeLocationStatus=0;
  bool appAlreadyResumed=false;
  int savedVisitId=0;
  VisitsOffline visits;
  String defaultUserImage="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";
  @override
  void initState() {

    super.initState();

    //checkLocationEnabled(context);
    initPlatformState();


  //  setLocationAddress();
    platform.setMethodCallHandler(_handleMethod);

  }
  bool internetAvailable=false;
  String address="";
  Future<dynamic> _handleMethod(MethodCall call) async {
    switch(call.method) {
      case "navigateToPage":
        navigateToPageAfterNotificationClicked(call.arguments["page"].toString(),context);
        break;
      case "locationAndInternet":
    prefix0.locationThreadUpdatedLocation=true;
      // print(call.arguments["internet"].toString()+"akhakahkahkhakha");
      // Map<String,String> responseMap=call.arguments;
        if(call.arguments["TimeSpoofed"].toString()=="Yes"){
          timeSpoofed=true;

        }
        /*if(call.arguments["internet"].toString()=="Internet Available")
        {
          internetAvailable=false;
          print("internet nooooot aaaaaaaaaaaaaaaaaaaaaaaavailable");
          Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => OfflineHomePage()), (Route<dynamic> route) => false,);

        }*/
        long=call.arguments["longitude"].toString();
        lat=call.arguments["latitude"].toString();


        print(call.arguments["mocked"].toString());
        setState(() {
          assign_lat=double.parse(lat);
          assign_long=double.parse(long);
          if(call.arguments["mocked"].toString()=="Yes"){
            fakeLocationDetected=true;
          }
          else{
            fakeLocationDetected=false;
          }

          long=call.arguments["longitude"].toString();
          lat=call.arguments["latitude"].toString();

        });
        break;

        return new Future.value("");
    }
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  initPlatformState() async {
    appResumedPausedLogic(context);
    final prefs = await SharedPreferences.getInstance();
    visits=VisitsOffline.empty();
    setState(() {

      orgid = prefs.getString('orgid') ?? '';
      empid = prefs.getString('empid') ?? '';
      org_name = prefs.getString('org_name') ?? '';
      visits=VisitsOffline.empty();
    });
  }

  /*
  setLocationAddress() async {
    //print('called');
    if (mounted) {
      setState(() {
        streamlocationaddr = globalstreamlocationaddr;
        print('loc: ' + streamlocationaddr);
        if (list != null && list.length > 0) {
          lat = list[list.length - 1].latitude.toString();
          long = list[list.length - 1].longitude.toString();
          if (streamlocationaddr == '') {
            streamlocationaddr = lat + ", " + long;
          }
        }
        if (streamlocationaddr == ''&& varCheckNet==0) {
          print('again');
          timer.cancel();
          //sl.startStreaming(5);
         // startTimer();
        }
        //print("home addr" + streamlocationaddr);
        //print(lat + ", " + long);

        //print(stopstreamingstatus.toString());
      });
    }
  }
  startTimer() {
    const fiveSec = const Duration(seconds: 5);
    int count = 0;
    timer = new Timer.periodic(fiveSec, (Timer t) {
      //print("timmer is running");
      count++;
      //print("timer counter" + count.toString());
     // setLocationAddress();
      if (stopstreamingstatus) {
        t.cancel();
        //print("timer canceled");
      }
    });
  }*/
  // This widget is the root of your application.
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
    //  return false;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => OfflineHomePage()), (Route<dynamic> route) => false,
    );
    return false;
  }
  @override
  Widget build(BuildContext context) {
    return new WillPopScope(
      onWillPop: ()=> sendToHome(),
      child: new Scaffold(
        appBar: new AppBar(
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              new Text(org_name, style: new TextStyle(fontSize: 20.0)),
            ],
          ),
          leading: IconButton(icon:Icon(Icons.arrow_back),onPressed:(){
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => OfflineHomePage()),
            );
          },),
          backgroundColor: appcolor,
        ),
        bottomNavigationBar:
        Hero(
            tag: "bottom",
            child:BottomNavigationBar(
              currentIndex: _currentIndex,
              type: BottomNavigationBarType.fixed,
              backgroundColor: appcolor,
              onTap: (newIndex) {
                if(newIndex==0){
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => OfflineAttendanceLogs()),
                  );
                  return;
                }else
                if(newIndex==1){
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => OfflineHomePage()),
                  );
                  return;
                }
                if(newIndex==2){
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => PunchLocationSummaryOffline()),
                  );
                  return;
                }
                /*else if(newIndex == 3){
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => Notifications()),
                );

              }*/
                setState((){_currentIndex = newIndex;});

              }, // this will be set when a new tab is tapped
              items: [

                BottomNavigationBarItem(
                  icon: new Icon(Icons.art_track,color: Colors.white,),
                  title: new Text('Logs',style: TextStyle(color: Colors.white)),
                ),
                BottomNavigationBarItem(
                  icon: new Icon(Icons.home,color: Colors.white,),
                  title: new Text('Home',style: TextStyle(color: Colors.white)),
                ),
                BottomNavigationBarItem(
                    icon: Icon(Icons.location_on,color: Colors.white,),
                    title: Text('Visits',style: TextStyle(color: Colors.white),)
                ),
                /*  BottomNavigationBarItem(
                  icon: Icon(
                    Icons.notifications
                    ,color: Colors.black54,
                  ),
                  title: Text('Notifications',style: TextStyle(color: Colors.black54))),*/
              ],
            )),

        floatingActionButton: new FloatingActionButton(
          backgroundColor:buttoncolor,
          onPressed: (){
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => PunchLocationOffline()),
            );
          },
          tooltip: 'Punch Location',
          child: new Icon(Icons.add),
        ),

        body: getWidgets(context),
      ),
    );

  }
  /////////////
  _showDialog(visit_id) async {
   // sl.startStreaming(2);
    setState(() {
      if(assign_lat!=null ) {
      //  latit = assign_lat.toString();
       // longi = assign_long.toString();
       // location_addr1 = globalstreamlocationaddr;
      }else{
       // latit = "0.0";
       // longi = "0.0";
       // location_addr1 = "";
      }
    });
    await showDialog<String>(
      context: context,
      // ignore: deprecated_member_use
      child: new AlertDialog(
        contentPadding: const EdgeInsets.all(16.0),
        content: Container(
          height: MediaQuery.of(context).size.height*0.20,
          child: Column(
            children: <Widget>[
              new Expanded(
                child: new TextField(
                  maxLines: 5,
                  autofocus: true,
                  controller: _comments,
                  decoration: new InputDecoration(
                      labelText: 'Visit Feedback ', hintText: 'Visit Feedback (Optional)'),
                ),
              ),
              SizedBox(height: 4.0,),

            ],
          ),
        ),
        actions: <Widget>[
          new FlatButton(
              shape: Border.all(color: Colors.black54),
              child: const Text('CANCEL',style: TextStyle(color: Colors.black),),
              onPressed: () {
                _comments.text='';
                Navigator.of(context, rootNavigator: true).pop();
              }),
          new RaisedButton(
              child: const Text('PUNCH',style: TextStyle(color: Colors.white),),
              color: buttoncolor,
              onPressed: () async{
                Navigator.of(context, rootNavigator: true).pop('dialog');
                var prefs= await SharedPreferences.getInstance();
                prefix0.showAppInbuiltCamera=prefs.getBool("showAppInbuiltCamera")??true;
                prefix0.showAppInbuiltCamera?saveVisitOutOfflineAppCamera(visit_id,_comments.text): saveVisitOutOffline(visit_id,_comments.text);

              })
        ],
      ),
    );
  }



  /************************************************ for app camera ********************************************/





  saveVisitOutOfflineAppCamera(var visitId,String Desc) async {
    // sl.startStreaming(5);
    final prefs = await SharedPreferences.getInstance();
    String Date;
    String PictureBase64;
    String Latitude;
    String Longitude;
    String Time;
    File img = null;
    imageCache.clear();
    var imageRequired = prefs.getInt("VisitImageRequired")??0;
    if (imageRequired == 1) {
      prefix0.globalCameraOpenedStatus=true;
      // cameraChannel.invokeMethod("cameraOpened");
      Navigator.push(context, new MaterialPageRoute(
        builder: (BuildContext context) => new TakePictureScreen(),
        fullscreenDialog: true,)
      )
          .then((img) async {
        prefix0.globalCameraOpenedStatus=false;
        if (img != null) {
          List<int> imageBytes = await img.readAsBytes();
          PictureBase64 = base64.encode(imageBytes);
          //sl.startStreaming(5);
          if (assign_long != null && !assign_long.isNaN ) {
            lat = assign_lat.toString();
            long = assign_long.toString();
            if (globalstreamlocationaddr.isEmpty) {
              globalstreamlocationaddr = lat + "," + long;
            }
          }

          print("--------------------Image---------------------------");
          print(PictureBase64);

          var now = new DateTime.now();
          var formatter = new DateFormat('yyyy-MM-dd');

          Date = formatter.format(now);
          Time = DateFormat("H:mm:ss").format(now);
          Latitude = assign_lat.toString();
          Longitude = assign_long.toString();
          var FakeLocationStatus = 0;
          if (fakeLocationDetected)
            FakeLocationStatus = 1;
          VisitsOffline visit = VisitsOffline.empty();
          visit.saveVisitOut(visitId, Latitude, Longitude, Time, Date, Desc, PictureBase64, FakeLocationStatus,timeSpoofed?1:0);

          print("---------------Visit in saved offline---------------");
          // cameraChannel.invokeMethod("cameraClosed");
          img.deleteSync();
          imageCache.clear();

          // ignore: deprecated_member_use
          showDialog(context: context, child:
          new AlertDialog(
            content: new Text(
                "Visit punched successfully. It will be synced when you are online"),
          )
          );
          Navigator.pushReplacement(context,
              new MaterialPageRoute(
                  builder: (BuildContext context) {
                    return new PunchLocationSummaryOffline();
                  }
              )
          );
        } });
    }
    else{
      //sl.startStreaming(5);
      var now = new DateTime.now();
      var formatter = new DateFormat('yyyy-MM-dd');

      Date = formatter.format(now);
      Time = DateFormat("H:mm:ss").format(now);
      Latitude = assign_lat.toString();
      Longitude = assign_long.toString();
      var FakeLocationStatus = 0;
      if (fakeLocationDetected)
        FakeLocationStatus = 1;
      VisitsOffline visit = VisitsOffline.empty();

      visit.saveVisitOut(visitId, Latitude, Longitude, Time, Date, Desc, defaultUserImage, FakeLocationStatus,timeSpoofed?1:0);

      print("---------------Visit in saved offline---------------");
      Navigator.of(context, rootNavigator: true).pop();
      // ignore: deprecated_member_use
      showDialog(context: context, child:
      new AlertDialog(
        content: new Text(
            "Visit punched successfully. It will be synced when you are online"),
      )
      );
      Navigator.pushReplacement(context,
          new MaterialPageRoute(
              builder: (BuildContext context) {
                return new PunchLocationSummaryOffline();
              }
          )
      );
    }
    _comments.text='';


  }










  //////////////////////////////////////////////////////////////////////////////////////////////////////////////

  saveVisitOutOffline(var visitId,String Desc) async {
   // sl.startStreaming(5);
    final prefs = await SharedPreferences.getInstance();
    String Date;
    String PictureBase64;
    String Latitude;
    String Longitude;
    String Time;
    File img = null;
    imageCache.clear();
    var imageRequired = prefs.getInt("VisitImageRequired")??0;
    if (imageRequired == 1) {
      prefix0.globalCameraOpenedStatus=true;
      cameraChannel.invokeMethod("cameraOpened");

      ImagePicker.pickImage(
          source: ImageSource.camera, maxWidth: 200.0, maxHeight: 200.0)
          .then((img) async {

            prefix0.globalCameraOpenedStatus=false;
        if (img != null) {
          List<int> imageBytes = await img.readAsBytes();
          PictureBase64 = base64.encode(imageBytes);
          //sl.startStreaming(5);
          if (assign_long != null && !assign_long.isNaN ) {
            lat = assign_lat.toString();
            long = assign_long.toString();
            if (globalstreamlocationaddr.isEmpty) {
              globalstreamlocationaddr = lat + "," + long;
            }
          }

          print("--------------------Image---------------------------");
          print(PictureBase64);

          var now = new DateTime.now();
          var formatter = new DateFormat('yyyy-MM-dd');

          Date = formatter.format(now);
          Time = DateFormat("H:mm:ss").format(now);
          Latitude = assign_lat.toString();
          Longitude = assign_long.toString();
          var FakeLocationStatus = 0;
          if (fakeLocationDetected)
            FakeLocationStatus = 1;
          VisitsOffline visit = VisitsOffline.empty();
          visit.saveVisitOut(visitId, Latitude, Longitude, Time, Date, Desc, PictureBase64, FakeLocationStatus,timeSpoofed?1:0);

          print("---------------Visit in saved offline---------------");
          cameraChannel.invokeMethod("cameraClosed");
          img.deleteSync();
          imageCache.clear();

          // ignore: deprecated_member_use
          showDialog(context: context, child:
          new AlertDialog(
            content: new Text(
                "Visit punched successfully. It will be synced when you are online"),
          )
          );
          Navigator.pushReplacement(context,
              new MaterialPageRoute(
                  builder: (BuildContext context) {
                    return new PunchLocationSummaryOffline();
                  }
              )
          );
        } });
    }
        else{
          //sl.startStreaming(5);
          var now = new DateTime.now();
          var formatter = new DateFormat('yyyy-MM-dd');

          Date = formatter.format(now);
          Time = DateFormat("H:mm:ss").format(now);
          Latitude = assign_lat.toString();
          Longitude = assign_long.toString();
          var FakeLocationStatus = 0;
          if (fakeLocationDetected)
            FakeLocationStatus = 1;
          VisitsOffline visit = VisitsOffline.empty();

          visit.saveVisitOut(visitId, Latitude, Longitude, Time, Date, Desc, defaultUserImage, FakeLocationStatus,timeSpoofed?1:0);

          print("---------------Visit in saved offline---------------");
          Navigator.of(context, rootNavigator: true).pop();
          // ignore: deprecated_member_use
          showDialog(context: context, child:
          new AlertDialog(
            content: new Text(
                "Visit punched successfully. It will be synced when you are online"),
          )
          );
          Navigator.pushReplacement(context,
              new MaterialPageRoute(
                  builder: (BuildContext context) {
                    return new PunchLocationSummaryOffline();
                  }
              )
          );
        }
    _comments.text='';


  }


  /////////////
  getWidgets(context){
    return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget> [
          Container(
            padding: EdgeInsets.only(top:12.0,bottom: 2.0),
            child:Center(
              child:Text("Unsynced Visits",
                  style: new TextStyle(fontSize: 22.0, color: appcolor,)),
            ),
          ),
          Divider(color: Colors.black54,height: 1.5,),
          new Row(
            mainAxisAlignment: MainAxisAlignment.start,
//            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              SizedBox(height: 40.0,),
              SizedBox(width: MediaQuery.of(context).size.width*0.02),
              Container(
                width: MediaQuery.of(context).size.width*0.55,
                child:Text(' Client',style: TextStyle(color: buttoncolor,fontWeight:FontWeight.bold,fontSize: 16.0),),
              ),

              SizedBox(height: 40.0,),

              Container(
                width: MediaQuery.of(context).size.width*0.22,
                child:Text(' Visit In',style: TextStyle(color: buttoncolor,fontWeight:FontWeight.bold,fontSize: 16.0),),
              ),
              SizedBox(height: 40.0,),
              Container(
                width: MediaQuery.of(context).size.width*0.2,
                child:Text(' Visit Out',style: TextStyle(color: buttoncolor,fontWeight:FontWeight.bold,fontSize: 16.0),),
              ),
            ],
          ),
          Divider(),

          Container(
            height: MediaQuery.of(context).size.height*0.60,
            child: new FutureBuilder<List<VisitsOffline>>(
              future: VisitsOffline.empty().select(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return new ListView.builder(
                      scrollDirection: Axis.vertical,
                      shrinkWrap: true,
                      itemCount: snapshot.data.length,
                      itemBuilder: (context, index) {
                        //   double h_width = MediaQuery.of(context).size.width*0.5; // screen's 50%
                        //   double f_width = MediaQuery.of(context).size.width*1; // screen's 100%


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
                                        Text(snapshot.data[index].ClientName
                                            .toString(), style: TextStyle(
                                            color: Colors.black87,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16.0),),

                                        InkWell(
                                          child: Text('Visit In: ' +
                                              snapshot.data[index]
                                                  .VisitInLatitude+','+snapshot.data[index].VisitInLongitude,
                                              style: TextStyle(
                                                  color: Colors.black54,
                                                  fontSize: 12.0)),
                                          /*
                                          onTap: () {
                                            goToMap(
                                                snapshot.data[index]
                                                    .pi_latit ,
                                                snapshot.data[index]
                                                    .pi_longi);
                                          },*/
                                        ),
                                        SizedBox(height:2.0),

                                        snapshot.data[index].VisitOutTime=='00:00:00'?

                                        Padding(
                                          padding: EdgeInsets.only(top:8.0,bottom: 8.0),
                                          child: InkWell(

                                            child: new Container(
                                              //width: 100.0,
                                              height: 25.0,
                                              decoration: new BoxDecoration(
                                                color: buttoncolor,
                                                border: new Border.all(color: Colors.white, width: 2.0),
                                                borderRadius: new BorderRadius.circular(10.0),
                                              ),
                                              child: new Center(child: new Text('Visit Out', style: new TextStyle(fontSize: 18.0, color: Colors.white),),),
                                            ),
                                            onTap: (){
                                              _showDialog(snapshot.data[index].Id);
                                            },),
                                        ):Container(
                                          child:InkWell(
                                            child: Text('Visit Out: ' + snapshot.data[index].VisitOutLatitude+','+snapshot.data[index].VisitOutLongitude,
                                              style: TextStyle(
                                                  color: Colors.black54,
                                                  fontSize: 12.0),),

                                          ),
                                        ),

                                        SizedBox(height: 2.0,),


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
                                          Text(formatTime(snapshot.data[index].VisitInTime)
                                              ,style: TextStyle(fontWeight: FontWeight.bold),),

                                          Container(
                                            width: 62.0,
                                            height: 62.0,
                                            child:InkWell(
                                              child: Container(

                                                  child:  ClipOval(


                                                      child:Image.memory(base64Decode(snapshot
                                                          .data[index]
                                                          .VisitInImage),height: 100,
                                                        width: 100,
                                                        fit: BoxFit.cover,))

                                              ),
                                              onTap: (){
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(builder: (context) => ImageView.fromImage((snapshot
                                                      .data[index]
                                                      .VisitInImage),org_name)),
                                                );
                                              },
                                            ),),

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
                                          Text((snapshot.data[index].VisitOutTime==snapshot.data[index].VisitInTime)?'-':formatTime(snapshot.data[index].VisitOutTime)
                                              ,style: TextStyle(fontWeight: FontWeight.bold),),

                                          Container(
                                            width: 62.0,
                                            height: 62.0,
                                            child:InkWell(
                                              child: Container(

                                                  child:  ClipOval(


                                                      child:Image.memory(base64Decode(snapshot
                                                          .data[index]
                                                          .VisitOutImage),height: 100,
                                                        width: 100,
                                                        fit: BoxFit.cover,))

                                              ),
                                              onTap: (){
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(builder: (context) => ImageView.fromImage((snapshot
                                                      .data[index]
                                                      .VisitOutImage),org_name)),
                                                );
                                              },
                                            ),),

                                        ],
                                      )

                                  ),
                                ],


                              ),//
                              snapshot.data[index].VisitOutDescription==''?Container():snapshot.data[index].VisitInDescription!='Visit out not punched'?
                              Row(
                                children: <Widget>[
                                  SizedBox(width: 16.0,),
                                  Text('Remark: ',style: TextStyle(fontWeight: FontWeight.bold,),),
                                  Text(snapshot.data[index].VisitOutDescription)
                                ],

                              ):
                              Row(
                                children: <Widget>[
                                  SizedBox(width: 16.0,),
                                  Text('Remark: ',style: TextStyle(fontWeight: FontWeight.bold,color: Colors.red),),
                                  Text(snapshot.data[index].VisitOutDescription,style: TextStyle(color: Colors.red),)
                                ],

                              ),

                              Row(
                                children: <Widget>[
                                  SizedBox(width: 16.0,),
                                  Text('Date: ',style: TextStyle(fontWeight: FontWeight.bold,color: Colors.black),),
                                  Text(DateFormat("dd-MM-yyyy").format(DateTime.parse(snapshot.data[index].VisitInDate
                                      .toString())).toString(),style: TextStyle(color: Colors.black),)
                                ],

                              ),


                              Divider(color: Colors.black26,),
                            ]);
                      }
                  );
                } else if (snapshot.hasError) {
                  return new Text("You are not connected to internet.");
                }

                // By default, show a loading spinner
                return new Center( child: CircularProgressIndicator());
              },
            ),
          ),
        ]
    );

  }
  formatTime(String time){
    if(time.contains(":")){
      var a=time.split(":");
      return a[0]+":"+a[1];
    }
    else return time;

  }
}
