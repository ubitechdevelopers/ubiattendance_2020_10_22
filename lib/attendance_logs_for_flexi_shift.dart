import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:Shrine/services/services.dart';
import 'package:admob_flutter/admob_flutter.dart';
import 'package:configurable_expansion_tile/configurable_expansion_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'Bottomnavigationbar.dart';
import 'Image_view.dart';
import 'drawer.dart';
import 'globals.dart' as globals;
import 'home.dart';
//import 'package:intl/intl.dart';
import 'customListTile.dart' as custom;

void main() => runApp(new MyAppFlexi());

class MyAppFlexi extends StatefulWidget {
  @override
  _MyAppFlexi createState() => _MyAppFlexi();
}
String org_name="";
AdmobBannerSize bannerSize;
class _MyAppFlexi extends State<MyAppFlexi> {
  String fname="";
  String lname="";
  String desination="";
  String profile="";

  int _currentIndex = 1;
  String admin_sts='0';
  @override
  void initState() {
    super.initState();
    bannerSize = AdmobBannerSize.FULL_BANNER;
    initPlatformState();
  }
  // Platform messages are asynchronous, so we initialize in an async method.
  initPlatformState() async {
    checkNetForOfflineMode(context);
    appResumedPausedLogic(context);
    final prefs = await SharedPreferences.getInstance();
    print('imagestring');
    print( globals.PictureBase64Att);
    setState(() {
      fname = prefs.getString('fname') ?? '';
      lname = prefs.getString('lname') ?? '';
      desination = prefs.getString('desination') ?? '';
      profile = prefs.getString('profile') ?? '';
      org_name = prefs.getString('org_name') ?? '';
      admin_sts = prefs.getString('sstatus') ?? '';
    });
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
  } // This widget is the root of your application.
  Future<bool> sendToHome() async{
    /*Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => HomePage()),
    );*/
    print("-------> back button pressed");
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => HomePage()), (Route<dynamic> route) => false,
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
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => HomePage()),
            );
          },),
          backgroundColor: globals.appcolor,
        ),
      bottomNavigationBar: Bottomnavigationbar(),
        endDrawer: new AppDrawer(),

        body: getWidgets(context),
      )
    );

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

String dateFormatter(String date_) {
  // String date_='2018-09-2';
  var months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun','Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
  var dy = ['st', 'nd', 'rd', 'th', 'th', 'th','th', 'th', 'th', 'th', 'th', 'th', 'th', 'th', 'th', 'th', 'th', 'th', 'th', 'th','st','nd','rd', 'th', 'th', 'th', 'th', 'th', 'th', 'th','st'];
  var date = date_.split("-");
  return(date[2]+""+dy[int.parse(date[2])-1]+" "+months[int.parse(date[1])-1]);
}
getWidgets(context){
  return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget> [
        Container(
          padding: EdgeInsets.only(top:12.0,bottom: 2.0),
          child:Center(
            child:Text('My Attendance Log',
                style: new TextStyle(fontSize: 22.0, color: globals.appcolor,)),
          ),
        ),
        /*
        Container(
          //padding: EdgeInsets.only(left: 5.0),
          child: InkWell(
            child: Text(
              'Rejected Attendance Log',
              style: TextStyle(
                decoration:
                TextDecoration
                    .underline,
                color: Colors
                    .blueAccent,
                fontSize: 16,
                //fontWeight: FontWeight.bold
              ),
            ),
            onTap: () {

            },
          ),
        ),
        */
        Divider(color: Colors.black54,height: 1.5,),
        new Row(
          mainAxisAlignment: MainAxisAlignment.start,
//            crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            SizedBox(height: 50.0,),
            SizedBox(width: MediaQuery.of(context).size.width*0.06),
            Container(
              width: MediaQuery.of(context).size.width*0.30,
              child:Text('Date',style: TextStyle(color: globals.appcolor,fontWeight:FontWeight.bold,fontSize: 16.0),),
            ),

            SizedBox(height: 50.0,),
            Container(
              width: MediaQuery.of(context).size.width*0.44,
              child:Text('Total Logged Hours',textAlign: TextAlign.left,style: TextStyle(color: globals.appcolor,fontWeight:FontWeight.bold,fontSize: 16.0),),
            ),
            SizedBox(height: 50.0,),
            /*
            Container(
              width: MediaQuery.of(context).size.width*0.2,
              child:Text('Time Out',style: TextStyle(color: globals.appcolor,fontWeight:FontWeight.bold,fontSize: 16.0),),
            ),*/
          ],
        ),
        Divider(height: 1.5,),
        SizedBox(height: 5.0,),
        Container(
            height: globals.currentOrgStatus=="TrialOrg"?MediaQuery.of(context).size.height*0.53:MediaQuery.of(context).size.height*0.60,
            child:
            FutureBuilder<List<User>>(
              future: getSummary(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {

                  return new ListView.builder(
                      scrollDirection: Axis.vertical,
                      shrinkWrap: true,
                      itemCount: snapshot.data.length,
                      itemBuilder: (context, index) {
                        var attendanceData=snapshot.data[index];
                     //   double h_width = MediaQuery.of(context).size.width*0.5; // screen's 50%
                     //   double f_width = MediaQuery.of(context).size.width*1; // screen's 100%
                        return new Column(
                            children: <Widget>[
                              ConfigurableExpansionTile(

                                //borderColorStart: Colors.blue,
                                //borderColorEnd: Colors.orange,
                                animatedWidgetFollowingHeader: const Icon(
                                  Icons.expand_more,
                                  color: const Color(0xFF707070),
                                ),

                                children: <Widget>[

                                  FutureBuilder<List<User>>(
                                    future: getInterimAttendanceSummary(attendanceData),
                                    builder: (context, snapshot) {
                                      if (snapshot.hasData) {
                                        return new ListView.builder(
                                            scrollDirection: Axis.vertical,
                                            shrinkWrap: true,
                                            physics: ClampingScrollPhysics(),
                                            itemCount: snapshot.data.length,
                                            itemBuilder: (context, index) {
                                              //   double h_width = MediaQuery.of(context).size.width*0.5; // screen's 50%
                                              //   double f_width = MediaQuery.of(context).size.width*1; // screen's 100%
                                              return new Column(
                                                  children: <Widget>[
                                                    Row(
                                                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                                                      children: <Widget>[
                                                        SizedBox(height: 40.0,),
                                                        Container(
                                                          width: MediaQuery.of(context).size.width * 0.46,
                                                          padding:new EdgeInsets.only(top:10.0),
                                                          child: Column(
                                                            crossAxisAlignment: CrossAxisAlignment
                                                                .start,
                                                            children: <Widget>[
                                                              Text("Logged Hours: "+snapshot.data[index].totalLoggedHours
                                                                  .toString(), style: TextStyle(
                                                                  color: Colors.black87,
                                                                  fontWeight: FontWeight.bold,
                                                                  fontSize: 16.0),),

                                                              InkWell(
                                                                child: Text('Time In: ' +
                                                                    snapshot.data[index]
                                                                        .checkInLoc.toString(),
                                                                    style: TextStyle(
                                                                        color: Colors.black54,
                                                                        fontSize: 12.0)),
                                                                onTap: () {
                                                                  goToMap(
                                                                      snapshot.data[index]
                                                                          .latit_in ,
                                                                      snapshot.data[index]
                                                                          .longi_in);
                                                                },
                                                              ),
                                                              SizedBox(height:2.0),
                                                              InkWell(
                                                                child: Text('Time Out: ' +
                                                                    snapshot.data[index].CheckOutLoc.toString(),
                                                                  style: TextStyle(
                                                                      color: Colors.black54,
                                                                      fontSize: 12.0),),
                                                                onTap: () {
                                                                  goToMap(
                                                                      snapshot.data[index].latit_out,
                                                                      snapshot.data[index].longi_out);
                                                                },
                                                              ),
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

                                                        Container(
                                                            width: MediaQuery.of(context).size.width * 0.22,
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
                                                                        MaterialPageRoute(builder: (context) => ImageView.fromImage((globals.PictureBase64Att),org_name)),
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
                                                                        MaterialPageRoute(builder: (context) => ImageView(myimage: snapshot.data[index].EntryImage,org_name: org_name)),
                                                                      );
                                                                    },
                                                                  ),),

                                                              ],
                                                            )
                                                        ),

                                                        Container(
                                                            width: MediaQuery.of(context).size.width * 0.22,
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
                                                                        MaterialPageRoute(builder: (context) => ImageView.fromImage((globals.PictureBase64Att),org_name)),
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
                                                                        MaterialPageRoute(builder: (context) => ImageView(myimage: snapshot.data[index].ExitImage,org_name: org_name)),
                                                                      );
                                                                    },
                                                                  ),
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
                                        );
                                      } else if (snapshot.hasError) {
                                        return new Text("Unable to connect server");
                                      }

                                      // By default, show a loading spinner
                                      return new Center( child: CircularProgressIndicator());
                                    },
                                  )



                                  ],



                                headerExpanded:Expanded(

                        child: Container(

                          decoration: BoxDecoration(
                              border: Border(bottom: BorderSide(color: Colors.black26,),),
                            color:Colors.white,
                            /*
                              boxShadow: [
                            //background color of box

                            BoxShadow(
                              color: Colors.grey,
                              blurRadius: 1.0, // soften the shadow
                              spreadRadius: 1.0, //extend the shadow
                              offset: Offset(
                                0.0, // Move to right 10  horizontally
                                0.0, // Move to bottom 10 Vertically
                              ),
                            )
                            ],
*/
                          ),
                          padding: new EdgeInsets.only(top:10.0,bottom: 10),
                          child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,

                          children: <Widget>[
                          //SizedBox(height: 20.0,),
                          Container(
                          width: MediaQuery.of(context).size.width * 0.30,

                          child: Column(
                          crossAxisAlignment: CrossAxisAlignment
                              .start,
                          children: <Widget>[
                          SizedBox(width: 30,),
                          Text("   "+snapshot.data[index].AttendanceDate
                              .toString(), style: TextStyle(
                          color: Colors.black87,
                          fontWeight: FontWeight.bold,
                          fontSize: 16.0),),
                          /*
                                              InkWell(
                                                child: Text('Time In: ' +
                                                    snapshot.data[index]
                                                        .checkInLoc.toString(),
                                                    style: TextStyle(
                                                        color: Colors.black54,
                                                        fontSize: 12.0)),
                                                onTap: () {
                                                  goToMap(
                                                      snapshot.data[index]
                                                          .latit_in ,
                                                      snapshot.data[index]
                                                          .longi_in);
                                                },
                                              ),
                                              SizedBox(height:2.0),
                                              InkWell(
                                                child: Text('Time Out: ' +
                                                    snapshot.data[index].CheckOutLoc.toString(),
                                                  style: TextStyle(
                                                      color: Colors.black54,
                                                      fontSize: 12.0),),
                                                onTap: () {
                                                  goToMap(
                                                      snapshot.data[index].latit_out,
                                                      snapshot.data[index].longi_out);
                                                },
                                              ),
                                              snapshot.data[index].bhour.toString()!=''?Container(
                                                //color:globals.buttoncolor,
                                                child:Text(""+snapshot.data[index]
                                                    .bhour.toString()+" Hr(s)",style: TextStyle(),),
                                              ):SizedBox(height: 10.0,),
                                              */

                          ],
                          ),
                          ),

                          Container(
                          width: MediaQuery.of(context).size.width * 0.44,
                          child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                          Text(snapshot.data[index].totalLoggedHours.toString(),style: TextStyle(fontWeight: FontWeight.bold , fontSize: 16.0),),



/*
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
                                                        MaterialPageRoute(builder: (context) => ImageView.fromImage((globals.PictureBase64Att),org_name)),
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
                                                        MaterialPageRoute(builder: (context) => ImageView(myimage: snapshot.data[index].EntryImage,org_name: org_name)),
                                                      );
                                                    },
                                                  ),),
                                                */
                          ],
                          )
                          ),
                          /*
                                        Container(
                                            width: MediaQuery.of(context).size.width * 0.22,
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
                                                        MaterialPageRoute(builder: (context) => ImageView.fromImage((globals.PictureBase64Att),org_name)),
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
                                                        MaterialPageRoute(builder: (context) => ImageView(myimage: snapshot.data[index].ExitImage,org_name: org_name)),
                                                      );
                                                    },
                                                  ),
                                                ),

                                              ],
                                            )

                                        ),*/
                          ],

                          ),
                        ),
                        ),
                                header: Expanded(
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: <Widget>[
                                      //SizedBox(height: 20.0,),
                                      Container(
                                        width: MediaQuery.of(context).size.width * 0.30,
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment
                                              .start,
                                          children: <Widget>[
                                            SizedBox(width: 30,),
                                            Text("   "+snapshot.data[index].AttendanceDate
                                                .toString(), style: TextStyle(
                                                color: Colors.black87,
                                                //fontWeight: FontWeight.bold,
                                                fontSize: 14.0),),
                                            /*
                                            InkWell(
                                              child: Text('Time In: ' +
                                                  snapshot.data[index]
                                                      .checkInLoc.toString(),
                                                  style: TextStyle(
                                                      color: Colors.black54,
                                                      fontSize: 12.0)),
                                              onTap: () {
                                                goToMap(
                                                    snapshot.data[index]
                                                        .latit_in ,
                                                    snapshot.data[index]
                                                        .longi_in);
                                              },
                                            ),
                                            SizedBox(height:2.0),
                                            InkWell(
                                              child: Text('Time Out: ' +
                                                  snapshot.data[index].CheckOutLoc.toString(),
                                                style: TextStyle(
                                                    color: Colors.black54,
                                                    fontSize: 12.0),),
                                              onTap: () {
                                                goToMap(
                                                    snapshot.data[index].latit_out,
                                                    snapshot.data[index].longi_out);
                                              },
                                            ),
                                            snapshot.data[index].bhour.toString()!=''?Container(
                                              //color:globals.buttoncolor,
                                              child:Text(""+snapshot.data[index]
                                                  .bhour.toString()+" Hr(s)",style: TextStyle(),),
                                            ):SizedBox(height: 10.0,),
                                            */

                                          ],
                                        ),
                                      ),

                                      Container(
                                          width: MediaQuery.of(context).size.width * 0.44,
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.center,
                                            children: <Widget>[
                                              Text(snapshot.data[index].totalLoggedHours.toString(),style: TextStyle( fontSize: 14.0),),
/*
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
                                                      MaterialPageRoute(builder: (context) => ImageView.fromImage((globals.PictureBase64Att),org_name)),
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
                                                      MaterialPageRoute(builder: (context) => ImageView(myimage: snapshot.data[index].EntryImage,org_name: org_name)),
                                                    );
                                                  },
                                                ),),
                                              */
                                            ],
                                          )
                                      ),
                                      /*
                                      Container(
                                          width: MediaQuery.of(context).size.width * 0.22,
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
                                                      MaterialPageRoute(builder: (context) => ImageView.fromImage((globals.PictureBase64Att),org_name)),
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
                                                      MaterialPageRoute(builder: (context) => ImageView(myimage: snapshot.data[index].ExitImage,org_name: org_name)),
                                                    );
                                                  },
                                                ),
                                              ),

                                            ],
                                          )

                                      ),*/
                                    ],

                                  ),
                                ),
                              ),
                              Divider(color: Colors.black26,),
                            ]);
                      }
                  );
                } else if (snapshot.hasError) {
                  return new Text("Unable to connect server");
                }

                // By default, show a loading spinner
                return new Center( child: CircularProgressIndicator());
              },
            )
        ),
  if(globals.currentOrgStatus=="TrialOrg" )
  Container(
  margin: EdgeInsets.only(bottom: 0.0),
  child: AdmobBanner(
  adUnitId: getBannerAdUnitId(),
  adSize: bannerSize,
  listener:
  (AdmobAdEvent event, Map<String, dynamic> args) {
  //handleEvent(event, args, 'Banner');
  },
  ),
  )]
  );
}


String getBannerAdUnitId() {
  if (Platform.isIOS) {
    return 'ca-app-pub-3940256099942544/2934735716';
  } else if (Platform.isAndroid) {
    return 'ca-app-pub-3940256099942544/6300978111';
  }
  return null;
}
Future<List<User>> getSummary() async {
  final prefs = await SharedPreferences.getInstance();
  String empid = prefs.getString('empid') ?? '';
  String orgdir = prefs.getString('orgdir') ?? '';
 final response = await http.get(globals.path+'getHistory?uid=$empid&refno=$orgdir');
  print(response.body);
  List responseJson = json.decode(response.body.toString());
  List<User> userList = createUserList(responseJson);
  return userList;
}

Future<List<User>> getInterimAttendanceSummary(User attendanceData) async {

  var attendanceMasterId=attendanceData.attendanceMasterId;
  final response = await http.get(globals.path+'getInterimAttendances?attendanceMasterId=$attendanceMasterId');
  print(response.body);
  List responseJson = json.decode(response.body.toString());
  List<User> userList = createInterimAttendanceList(responseJson);
  if(userList.length==0){
    userList.add(attendanceData);
  }
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


List<User> createUserList(List data){
  List<User> list = new List();
  for (int i = 0; i < data.length; i++) {
    String title = Formatdate(data[i]["AttendanceDate"]);
    String TimeOut=data[i]["TimeOut"]=="00:00:00"?'-':data[i]["TimeOut"].toString().substring(0,5);
    String TimeIn=data[i]["TimeIn"]=="00:00:00"?'-':data[i]["TimeIn"].toString().substring(0,5);
    String thours=data[i]["thours"]=="00:00:00"?'-':data[i]["thours"].toString().substring(0,5);
    String bhour=data[i]["bhour"]==null?'':'Time Off: '+data[i]["bhour"].substring(0,5);
    String EntryImage=data[i]["EntryImage"]!=''?data[i]["EntryImage"]:'http://ubiattendance.ubihrm.com/assets/img/avatar.png';
    String ExitImage=data[i]["ExitImage"]!=''?data[i]["ExitImage"]:'http://ubiattendance.ubihrm.com/assets/img/avatar.png';
    String checkInLoc=data[i]["checkInLoc"];
    String CheckOutLoc=data[i]["CheckOutLoc"];
    String Latit_in=data[i]["latit_in"];
    String Longi_in=data[i]["longi_in"];
    String Latit_out=data[i]["latit_out"];
    String Longi_out=data[i]["longi_out"];
    String totalLoggedHours=data[i]["TotalLoggedHours"]=="00:00:00"?'-':data[i]["TotalLoggedHours"].toString().substring(0,5);

    String timeindate=data[i]["timeindate"];
    String attendanceMasterId=data[i]["Id"];
    if(timeindate =='0000-00-00')
       timeindate = data[i]["AttendanceDate"];

    String timeoutdate=data[i]["timeoutdate"];
    if(timeoutdate =='0000-00-00')
       timeoutdate=data[i]["AttendanceDate"];
    int id = 0;
    User user = new User(
        AttendanceDate: title,thours: thours,id: id,TimeOut:TimeOut,TimeIn:TimeIn,bhour:bhour,EntryImage:EntryImage,checkInLoc:checkInLoc,ExitImage:ExitImage,CheckOutLoc:CheckOutLoc,latit_in: Latit_in,longi_in: Longi_in,latit_out: Latit_out,longi_out: Longi_out,timeindate: timeindate,timeoutdate: timeoutdate,totalLoggedHours: totalLoggedHours,attendanceMasterId: attendanceMasterId);
    list.add(user);
  }
  return list;
}