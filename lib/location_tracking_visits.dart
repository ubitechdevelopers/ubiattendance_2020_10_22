import 'dart:async';
import 'dart:convert';

import 'package:Shrine/services/services.dart';
import 'package:Shrine/trackAllEmp.dart';
import 'package:Shrine/trackEmp.dart';
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


void main() => runApp(new LocationTrackingVisits());

class LocationTrackingVisits extends StatefulWidget {
  @override
  _LocationTrackingVisits createState() => _LocationTrackingVisits();
}
String org_name="";
class _LocationTrackingVisits extends State<LocationTrackingVisits> {
  String fname="";
  String lname="";
  String desination="";
  String profile="";

  int _currentIndex = 1;
  String admin_sts='0';
  @override
  void initState() {
    super.initState();
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

class VisitsLT {
  String fName;
  String lName;
  String inImage;
  String outImage;
  String client;
  String empId;
  String in_time;
  String out_time;
  VisitsLT({this.fName,this.lName,this.inImage,this.outImage,this.client,this.in_time,this.out_time,this.empId});
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
            child:Text('Punched Visits',
                style: new TextStyle(fontSize: 22.0, color: globals.appcolor,)),
          ),
        ),


        Divider(color: Colors.black54,height: 1.5,),
        RaisedButton(child: Text('Track Employees',style: TextStyle(color: Colors.white),),color: globals.buttoncolor,
        onPressed: (){
          Navigator.push(

            context,
            MaterialPageRoute(builder: (context) => TrackAllEmp(),
          )
          );
        },

        ),

        new Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
//            crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            SizedBox(height: 50.0,),
            SizedBox(width: MediaQuery.of(context).size.width*0.02),
            Container(
              width: MediaQuery.of(context).size.width*0.25,
              child:Text('Name',style: TextStyle(color: globals.appcolor,fontWeight:FontWeight.bold,fontSize: 16.0),),
            ),
            SizedBox(width: MediaQuery.of(context).size.width*0.02),
            Container(
              width: MediaQuery.of(context).size.width*0.25,
              child:Text('Client',style: TextStyle(color: globals.appcolor,fontWeight:FontWeight.bold,fontSize: 16.0),),
            ),

            SizedBox(height: 50.0,),
            Container(
              width: MediaQuery.of(context).size.width*0.22,
              child:Text('Visit In',textAlign: TextAlign.left,style: TextStyle(color: globals.appcolor,fontWeight:FontWeight.bold,fontSize: 16.0),),
            ),
            SizedBox(height: 50.0,),
            Container(
              width: MediaQuery.of(context).size.width*0.2,
              child:Text('Visit Out',style: TextStyle(color: globals.appcolor,fontWeight:FontWeight.bold,fontSize: 16.0),),
            ),
          ],
        ),
        Divider(height: 1.5,),
        SizedBox(height: 5.0,),
        Container(
            height: MediaQuery.of(context).size.height*0.55,
            child:
            FutureBuilder<List<VisitsLT>>(
              future: getSummary(),
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
                                mainAxisAlignment: MainAxisAlignment.spaceAround,
                                children: <Widget>[
                                  SizedBox(height: 40.0,),
                                  Container(
                                    width: MediaQuery.of(context).size.width * 0.23,
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment
                                          .start,
                                      children: <Widget>[
                                        InkWell(
                                          child: Text(snapshot.data[index].fName
                                              .toString()+" "+snapshot.data[index].lName.toString(), style: TextStyle(
                                              color: globals.appcolor,
                                              fontWeight: FontWeight.normal,
                                              fontSize: 16.0,
                                             // decoration: TextDecoration.underline
                                          ),),
                                          onTap: (){
                                            Navigator.push(

                                              context,
                                              MaterialPageRoute(builder: (context) => TrackEmp(snapshot.data[index].empId)),
                                            );
                                          },
                                        ),
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
                                          color:globals.buttoncolor,
                                          child:Text(""+snapshot.data[index]
                                              .bhour.toString()+" Hr(s)",style: TextStyle(),),
                                        ):SizedBox(height: 10.0,),
*/

                                      ],
                                    ),
                                  ),
                                  SizedBox(height: 40.0,),
                                  Container(
                                    width: MediaQuery.of(context).size.width * 0.23,
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment
                                          .start,
                                      children: <Widget>[
                                        InkWell(
                                          child: Text(snapshot.data[index].client
                                              .toString(), style: TextStyle(
                                              color: Colors.black87,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16.0,

                                          ),),
                                          onTap: (){
                                            Navigator.push(

                                              context,
                                              MaterialPageRoute(builder: (context) => TrackEmp(snapshot.data[index].empId)),
                                            );
                                          },
                                        ),
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
                                          color:globals.buttoncolor,
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
                                        //  Text(snapshot.data[index].TimeIn.toString(),style: TextStyle(fontWeight: FontWeight.bold , fontSize: 16.0),),

                                           Container(
                                            width: 62.0,
                                            height: 62.0,
                                            child:InkWell(
                                              child: Container(
                                                  decoration: new BoxDecoration(
                                                      shape: BoxShape.circle,
                                                      image: new DecorationImage(
                                                          fit: BoxFit.fill,
                                                          image: new NetworkImage(snapshot.data[index].inImage)
                                                      )
                                                  )),
                                              onTap: (){
                                               /*
                                                Navigator.push(

                                                  context,
                                                  MaterialPageRoute(builder: (context) => ImageView(myimage: snapshot.data[index].EntryImage,org_name: org_name)),
                                                );
                                              */},
                                            ),),

                                        ],
                                      )
                                  ),

                                  Container(
                                      width: MediaQuery.of(context).size.width * 0.22,
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        children: <Widget>[
                                        /*  Row(
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
                                          ):*/Container(
                                            width: 62.0,
                                            height: 62.0,
                                            child:InkWell(
                                              child: Container(
                                                  decoration: new BoxDecoration(
                                                      shape: BoxShape.circle,
                                                      image: new DecorationImage(
                                                          fit: BoxFit.fill,
                                                          image: new NetworkImage(snapshot.data[index].outImage)
                                                      )
                                                  )),
                                              onTap: (){
                                                /*
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(builder: (context) => ImageView(myimage: snapshot.data[index].ExitImage,org_name: org_name)),
                                                );*/
                                              },
                                            ),
                                          ),

                                        ],
                                      )

                                  ),
                                ],

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
      ]
  );
}
Future<List<VisitsLT>> getSummary() async {
  final prefs = await SharedPreferences.getInstance();
  String empid = prefs.getString('empid') ?? '';
  String orgid = prefs.getString('orgid') ?? '';
  print(globals.path+'getEmployeeListForLT?orgId=$orgid');
  final response = await http.get(globals.path+'getEmployeeListForLT?orgId=$orgid');
  print(response.body);
  List responseJson = json.decode(response.body.toString());

  List<VisitsLT> visitList = createVisitList(responseJson);
  return visitList;
}


List<VisitsLT> createVisitList(List data){
  List<VisitsLT> list = new List();
  print("kjhkjdhkdh"+data.length.toString());
  for (int i = 0; i < data.length; i++) {
   String empId = data[i]["empId"]==null?"-":data[i]["empId"];
    String inImage=data[i]["inImage"]!=''&&data[i]["inImage"]!=null&&data[i]["inImage"].isNotEmpty?data[i]["inImage"]:'http://ubiattendance.ubihrm.com/assets/img/avatar.png';
    String outImage=data[i]["outImage"]!=''&&data[i]["outImage"]!=null&&data[i]["outImage"].isNotEmpty?data[i]["outImage"]:'http://ubiattendance.ubihrm.com/assets/img/avatar.png';
    String fName=data[i]["fName"];
    String lName=data[i]["lName"];
    String in_time=data[i]["in_time"];
    String out_time=data[i]["out_time"];
    String client=data[i]["client"]==null?"-":data[i]["client"];
print((data[i]["outImage"]!=null).toString()+"\n");
   VisitsLT visit=new VisitsLT(client: client,empId: empId,inImage: inImage,outImage: outImage,fName: fName,lName: lName,in_time: in_time,out_time: out_time);
   list.add(visit);
  }
  print("Listtttttt");
  print(list.toString());


  return list;
}