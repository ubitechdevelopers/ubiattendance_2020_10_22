import 'package:Shrine/Bottomnavigationbar.dart';
import 'package:Shrine/applyLeave.dart';
import 'package:Shrine/home.dart';
import 'package:Shrine/model/model.dart';
import 'package:Shrine/services/gethome.dart';
import 'package:Shrine/services/newservices.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:rounded_modal/rounded_modal.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'drawer.dart';
import 'employeeleave.dart';
import 'globals.dart';
import 'leave_summary.dart';
import 'login.dart';
import 'myleave.dart';
import 'services/services.dart';


class MyTeamLeave extends StatefulWidget {
  @override
  _MyTeamLeaveState createState() => _MyTeamLeaveState();
}

class _MyTeamLeaveState extends State<MyTeamLeave> {
  int _currentIndex = 0;
  int response;
  var profileimage;
  bool showtabbar ;
  String _orgName="";

  bool _checkLoadedprofile = true;
  bool _checkwithdrawnleave = false;
  var PerLeave;
  var PerApprovalLeave;
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();



  Widget mainWidget= new Container(width: 0.0,height: 0.0,);
  @override
  void initState() {
    super.initState();
    showtabbar=false;
    //  print(profileimage);
    initPlatformState();
    getOrgName();
  }

  getOrgName() async{
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _orgName= prefs.getString('org_name') ?? '';
    });
  }

  initPlatformState() async{
    final prefs = await SharedPreferences.getInstance();

    setState(() {
      mainWidget = loadingWidget();
    });
    String empid = prefs.getString('empid')??"";
    String orgid =prefs.getString('orgid')??"";
    islogin().then((Widget configuredWidget) {
      setState(() {
        mainWidget = configuredWidget;
      });
    });
  }
  void showInSnackBar(String value) {
    FocusScope.of(context).requestFocus(new FocusNode());
    _scaffoldKey.currentState?.removeCurrentSnackBar();
    _scaffoldKey.currentState.showSnackBar(new SnackBar(
      content: new Text(
        value,
        textAlign: TextAlign.center,
        style: TextStyle(
            color: Colors.white,
            fontSize: 16.0,
            fontFamily: "WorkSansSemiBold"),
      ),
      backgroundColor: Colors.redAccent,
      duration: Duration(seconds: 3),
    ));
  }




  Future<Widget> islogin() async{
    final prefs = await SharedPreferences.getInstance();
    int response = prefs.getInt('response')??0;
    if(response==1){
      return mainScafoldWidget();
    }else{
      return new LoginPage();
    }

  }

  @override
  Widget build(BuildContext context) {

    return mainWidget;
  }


  Widget loadingWidget(){
    return Center(child:SizedBox(
      child:
      Text("Loading..", style: TextStyle(fontSize: 10.0,color: Colors.white),),
    ));
  }
  Future<bool> sendToHome() async{
    print("-------> back button pressed");
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => MyLeave()), (Route<dynamic> route) => false,
    );
    return false;
  }

  Widget mainScafoldWidget(){
    return new WillPopScope(
        onWillPop: ()=> sendToHome(),
    child: Scaffold(
        key: _scaffoldKey,
        backgroundColor:Colors.black,
        endDrawer: new AppDrawer(),
        appBar: AppBar(
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              new Text(_orgName, style: new TextStyle(fontSize: 20.0)),
            ],
          ),
          leading: IconButton(icon:Icon(Icons.arrow_back),onPressed:(){
            Navigator.of(context).pop();
          },),
          backgroundColor: appcolor,
        ),
        bottomNavigationBar: Bottomnavigationbar(),
        body:   homewidget()
    )
    );
  }

  Widget homewidget(){
    return Stack(
      children: <Widget>[
        Container(
          //height: MediaQuery.of(context).size.height,
            //margin: EdgeInsets.fromLTRB(10.0, 10.0, 10.0, 10.0),
            //padding: EdgeInsets.fromLTRB(10.0, 10.0, 10.0, 10.0),
            //width: MediaQuery.of(context).size.width*0.9,
            decoration: new ShapeDecoration(
              shape: new RoundedRectangleBorder(borderRadius: new BorderRadius.circular(0.0)),
              color: Colors.white,
            ),

            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget> [
                  Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Expanded(
                          flex:48,
                          child:InkWell(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => MyLeave()),
                              );

                            },
                          child:Column(
                              children: <Widget>[
                                // width: double.infinity,
                                //height: MediaQuery.of(context).size.height * .07,
                                SizedBox(height:MediaQuery.of(context).size.width*.02),
                                Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: <Widget>[
                                      Icon(
                                          Icons.person,
                                          color: Colors.orange[800],
                                          size: 22.0 ),

                                      GestureDetector(
                                        child: Text(
                                            'Self',
                                            style: TextStyle(fontSize: 18.0,color: Colors.orange[800],)
                                        ),
                                        // color: Colors.teal[50],
                                        /* splashColor: Colors.white,
                                shape: new RoundedRectangleBorder(
                                    borderRadius: new BorderRadius.circular(0.0))*/
                                      ),
                                    ]
                                ),
                                SizedBox(height:MediaQuery.of(context).size.width*.03),
                              ]
                          ),
                          ),
                        ),

                        Expanded(
                          flex:48,
                          child: Column(
                            // width: double.infinity,
                              children: <Widget>[
                                SizedBox(height:MediaQuery.of(context).size.width*.02),
                                Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: <Widget>[
                                      Icon(
                                          Icons.group,
                                          color: Colors.orange[800],
                                          size: 22.0 ),
                                      GestureDetector(
                                        onTap: () {
                                          /* Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (context) => MyTeamAtt()),
                                  );*/
                                          false;
                                        },
                                        child: Text(
                                            'Team',
                                            style: TextStyle(fontSize: 18,color: Colors.orange[800],fontWeight:FontWeight.bold)
                                        ),
                                      ),
                                    ]),
                                SizedBox(height:MediaQuery.of(context).size.width*.03),
                                Divider(
                                  color: Colors.orange[800],
                                  height: 0.4,
                                ),
                                Divider(
                                  color: Colors.orange[800],
                                  height: 0.4,
                                ),
                                Divider(
                                  color: Colors.orange[800],
                                  height: 0.4,
                                ),
                              ]
                          ),
                        ),
                      ]
                  ),

                  Container(
                    padding: EdgeInsets.only(top:12.0),
                    child:Center(
                      child:Text("Team's Leave",
                          style: new TextStyle(fontSize: 18.0, color: Colors.black87,),textAlign: TextAlign.center,),
                    ),
                  ),

                  new Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    //crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      SizedBox(height: 10.0,),
                      // SizedBox(width: MediaQuery.of(context).size.width*0.0),
                      new Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(left:8.0),
                          child: Container(
                            width: MediaQuery.of(context).size.width*0.50,
                            child:Text('Name',style: TextStyle(color: appcolor,fontWeight:FontWeight.bold,fontSize: 16.0),),
                          ),
                        ),),
                      //SizedBox(height: 50.0,),
                      new Expanded(
                        child: Container(
                          margin: EdgeInsets.only(left:32.0),
                          padding: EdgeInsets.only(right:12.0),
                          width: MediaQuery.of(context).size.width*0.50,
                          child:Text('Applied on',style: TextStyle(color: appcolor,fontWeight:FontWeight.bold,fontSize: 16.0),textAlign: TextAlign.right,),
                        ),),
                    ],
                  ),

                  new Divider(),

                  new Expanded(
                    child: Container(
                      height: MediaQuery.of(context).size.height*.55,
                      width: MediaQuery.of(context).size.width*.99,
                      //padding: EdgeInsets.only(bottom: 15.0),
                      color: Colors.white,
                      //////////////////////////////////////////////////////////////////////---------------------------------
                      child: new FutureBuilder<List<LeaveListAll>>(
                        future: getLeaveApprovals(),
                        builder: (context, snapshot) {
                          if (snapshot.hasData) {
                            if (snapshot.data.length>0) {
                              return new ListView.builder(
                                  scrollDirection: Axis.vertical,
                                  itemCount: snapshot.data.length,
                                  itemBuilder: (BuildContext context, int index) {
                                    return Padding(
                                      padding: const EdgeInsets.only(left:8.0),
                                      child: GestureDetector(
                                        onTap: () {
                                          /*
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(builder: (context) => EmployeeLeave(leaveid:snapshot.data[index].LeaveId,employeeid:snapshot.data[index].EmployeeId,employeename:snapshot.data[index].name,NoofLeaves:snapshot.data[index].NoofLeaves)),
                                          );
                                          */
                                          // profile navigation
                                          /* Navigator.push(context, MaterialPageRoute(builder: (context) => ProfilePage()));*/
                                        },
                                        child: new Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: <Widget>[
                                            new Row(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              mainAxisAlignment: MainAxisAlignment.start,
                                              children: <Widget>[
                                               //SizedBox(height: 40.0,),
                                                new Expanded(
                                                  child: Container(
                                                    width: MediaQuery.of(context) .size.width * 0.60,
                                                    child: Column(
                                                      crossAxisAlignment: CrossAxisAlignment .start,
                                                      children: <Widget>[
                                                        new Text(snapshot.data[index].name.toString(), style: TextStyle(
                                                          color: Colors.black87,
                                                          fontWeight: FontWeight.bold,
                                                          fontSize: 16.0),),
                                                      ],
                                                    ),
                                                  ),
                                                ),

                                                new Expanded(
                                                  child:Padding(
                                                    padding: const EdgeInsets.only(left:80.0),
                                                    child: Container(
                                                      width: MediaQuery.of(context).size.width * 0.40,
                                                      child: Column(
                                                        crossAxisAlignment: CrossAxisAlignment .center,
                                                        children: <Widget>[
                                                          Text(snapshot.data[index].applydate.toString()),
                                                        ],
                                                      )
                                                    ),
                                                  ),
                                                ),
                                              ],

                                            ),

                                            new Row(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              mainAxisAlignment: MainAxisAlignment.start,
                                              children: <Widget>[
                                                new Expanded(
                                                  child: Container(
                                                    //color:Colors.red,
                                                    //height: MediaQuery .of(context).size.height * 0.06,
                                                    width: MediaQuery .of(context).size.width * 0.70,
                                                    margin: EdgeInsets.only(top: 4.0),
                                                    child: Column(
                                                      crossAxisAlignment: CrossAxisAlignment.start,
                                                      children: <Widget>[
                                                        //     new SizedBox(width: 5.0,),
                                                        new Text("Duration: "+snapshot.data[index].Fdate.toString()+' to '+snapshot.data[index].Tdate.toString(),style: TextStyle(color: Colors.grey[600]),)
                                                      ],
                                                    )
                                                  ),
                                                ),

                                               (snapshot.data[index].ApprovalStatus.toString() == 'Pending')?
                                                new Expanded(
                                                  child: Container (
                                                     //color:Colors.yellow,
                                                    height: MediaQuery .of(context).size.height * 0.04,
                                                    margin: EdgeInsets.only(left:32.0),
                                                    padding: EdgeInsets.only(left:32.0),
                                                    width: MediaQuery.of(context).size.width * 0.30,
                                                    child: new OutlineButton(
                                                      onPressed: () {

                                                        _modalBottomSheet(
                                                              context, snapshot.data[index].LeaveId.toString());


                                                      },
                                                      child:new Icon(
                                                        Icons.thumb_up,
                                                        size: 16.0,
                                                        color:appcolor,
                                                        //      textDirection: TextDirection.rtl,
                                                      ),
                                                      borderSide: BorderSide(color:appcolor),
                                                      shape: new CircleBorder(),
                                                      //         padding:EdgeInsets.all(5.0),
                                                    )
                                                  ),
                                                ):Center(),
                                        ],
                                            ),




                                            snapshot.data[index].Reason.toString()!='-'?Container(
                                              width: MediaQuery.of(context).size.width*.90,
                                              //padding: EdgeInsets.only(top:1.5,bottom: .5),
                                              margin: EdgeInsets.only(top: 4.0),
                                              child: Text('Reason: '+snapshot.data[index].Reason.toString(), style: TextStyle(color: Colors.black54),),
                                            ):Center(),

                                            Container(
                                              width: MediaQuery.of(context).size.width*.90,
                                              //padding: EdgeInsets.only(top:1.5,bottom: .5),
                                              margin: EdgeInsets.only(top: 4.0),
                                              child: Text('No of Leave: '+snapshot.data[index].NoofLeaves.toString(), style: TextStyle(color: Colors.black54),),
                                            ),

                                            (snapshot.data[index].ApprovalStatus.toString()!='Pending' ) ?Container(
                                              width: MediaQuery.of(context).size.width*.90,
                                              //padding: EdgeInsets.only(top:.5,bottom: 1.5),
                                              margin: EdgeInsets.only(top: 4.0),
                                              child: RichText(
                                                text: new TextSpan(
                                                  // Note: Styles for TextSpans must be explicitly defined.
                                                  // Child text spans will inherit styles from parent
                                                  style: new TextStyle(
                                                    fontSize: 14.0,
                                                    color: Colors.black,
                                                  ),
                                                  children: <TextSpan>[
                                                    new TextSpan(text: 'Status: ',style:TextStyle(color: Colors.black54,), ),
                                                    new TextSpan(text: snapshot.data[index].ApprovalStatus.toString(), style: TextStyle(color: snapshot.data[index].ApprovalStatus.toString()=='Approved'?appcolor :snapshot.data[index].ApprovalStatus.toString()=='Rejected' || snapshot.data[index].ApprovalStatus.toString()=='Withdrawn' ?Colors.red:Colors.blue[600], fontSize: 14.0),),
                                                  ],
                                                ),
                                              ),
                                            ):Center(
                                              // child:Text(snapshot.data[index].withdrawlsts.toString()),
                                            ),

                                            (snapshot.data[index].ApprovalStatus.toString()=='Pending') ?Container(
                                              width: MediaQuery.of(context).size.width*.90,
                                              //padding: EdgeInsets.only(top:.5,bottom: 1.5),
                                              margin: EdgeInsets.only(top: 4.0),
                                              child: RichText(
                                                text: new TextSpan(
                                                  // Note: Styles for TextSpans must be explicitly defined.
                                                  // Child text spans will inherit styles from parent
                                                  style: new TextStyle(
                                                    fontSize: 14.0,
                                                    color: Colors.black,
                                                  ),
                                                  children: <TextSpan>[
                                                    new TextSpan(text: 'Status: ',style:TextStyle(color: Colors.black54,), ),
                                                    new TextSpan(text: snapshot.data[index].ApprovalStatus.toString(), style: TextStyle(color: Colors.orange[800], fontSize: 14.0),),
                                                  ],
                                                ),
                                              ),
                                            ):Center(
                                              // child:Text(snapshot.data[index].withdrawlsts.toString()),
                                            ),

                                           Divider(),
                                          ]
                                        ),
                                      ),
                                    );
                                  }
                              );
                            }else
                              return new Center(
                                child: Container(
                                  width: MediaQuery.of(context).size.width*1,
                                  color: appcolor.withOpacity(0.1),
                                  padding:EdgeInsets.only(top:5.0,bottom: 5.0),
                                  child:Text("No Leave History",style: TextStyle(fontSize: 16.0),textAlign: TextAlign.center,),
                                ),
                              );
                              //return new Center( child: Text('No Leave History'), );
                          } else if (snapshot.hasError) {
                            return new Text("Unable to connect server");
                          }
                          // By default, show a loading spinner
                          return new Center( child: CircularProgressIndicator());
                        },
                      ),
                      //////////////////////////////////////////////////////////////////////---------------------------------
                    ),
                  ),


                ]
            )

        ),



      ],
    );
  }





  _modalBottomSheet(context,String leaveid) async{

    final FocusNode myFocusNodeComment = FocusNode();
    TextEditingController CommentController = new TextEditingController();

    showRoundedModalBottomSheet(
        context: context,
        //  radius: 190.0,
        //   radius: 190.0, // This is the default
        // color:Colors.lightGreen.withOpacity(0.9),
        color:Colors.grey[100],
        //   color:Colors.cyan[200].withOpacity(0.7),
        builder: (BuildContext bc){
          return new  Container(
            // padding: MediaQuery.of(context).viewInsets,
            //duration: const Duration(milliseconds: 100),
            // curve: Curves.decelerate,

            // child: new Expanded(
            //height: MediaQuery.of(context).size.height-100.0,
            height: 200.0,
            child: new Container(
              decoration: new BoxDecoration(
                  color: appcolor.withOpacity(0.1),
                  borderRadius: new BorderRadius.only(
                      topLeft: const Radius.circular(0.0),
                      topRight: const Radius.circular(0.0))),


              alignment: Alignment.topCenter,
              child: Wrap(
                children: <Widget>[
                  /*    new Container(
                    width: MediaQuery.of(context).size.width * .20,
                    child:Text(psts,style:TextStyle(
                        fontFamily: "WorkSansSemiBold",
                        fontSize: 18.0,
                        color: Colors.black)),

                  ),
                  Divider(color: Colors.black45,),*/
                  Padding(
                    padding: EdgeInsets.only(
                        top: 20.0, bottom: 20.0, left: 20.0, right: 20.0),
                    child: TextFormField(
                      focusNode: myFocusNodeComment,
                      controller: CommentController,
                      keyboardType: TextInputType.emailAddress,
                      onFieldSubmitted: (String value) {
                        FocusScope.of(context).requestFocus(myFocusNodeComment);
                      },
                      style: TextStyle(
                          fontFamily: "WorkSansSemiBold",
                          fontSize: 16.0,
                          height: 1.0,
                          color: Colors.black),
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        fillColor: Colors.white, filled: true,
                        /* icon: Icon(
                          Icons.edit,
                          color: Colors.black,
                          size: 22.0,
                        ),*/
                        hintText: "Comment",
                        hintStyle: TextStyle(
                            fontFamily: "WorkSansSemiBold", fontSize: 15.0 ),
                        /*suffixIcon: GestureDetector(
                          //onTap: _toggleLogin,
                          child: Icon(
                            Icons.edit,
                            size: 15.0,
                            color: Colors.black,
                          ),
                        ),*/
                      ),

                      /*validator: (value) {
                            if (value.isEmpty) {
                              return 'Please enter Email or Phone no.';
                            }
                          },*/
                      maxLines: 3,
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(
                        top: 10.0, bottom: 0.0, left: 60.0, right: 7.0),
                    child:  ButtonTheme(
                      minWidth: 50.0,
                  //    height: 40.0,
/*                      child: RaisedGradientButton(
                        onPressed: () async  {
                          //getApprovals(choice.title);
                          final sts= await ApproveLeave(leaveid,CommentController.text,2);
                          //  print("kk");
                          // print("kk"+sts);
                          if(sts=="true") {
                            showDialog(
                                context: context,
                                builder: (_) =>
                                new AlertDialog(
                                  //title: new Text("Dialog Title"),
                                  content: new Text("Approved succesfully"),
                                )
                            );
                          }
                          else{
                            showDialog(
                                context: context,
                                builder: (_) =>
                                new AlertDialog(
                                  //title: new Text("Dialog Title"),
                                  content: new Text("Could not be approved. Try again. "),
                                )
                            );
                          }

                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => TabbedApp()),
                          ); },
                        // color: Colors.green[400],
                        //shape: new RoundedRectangleBorder(
                        //  borderRadius: new BorderRadius.circular(30.0)),
                        gradient: LinearGradient(
                          colors: <Color>[Colors.green[700], Colors.green[700]],
                        ),
                        child: new Text('Approve',
                            style: new TextStyle(
                              color: Colors.white,
                              fontSize: 16.0,
                              fontWeight: FontWeight.bold,
                            )),
                      ),*/
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
                            'Approve',
                            style: TextStyle(color: Colors.white),
                          ),
                          color: buttoncolor,
                          onPressed: () async{
                            //getApprovals(choice.title);
                            final sts= await ApproveLeave(leaveid,CommentController.text,2);
                            //  print("kk");
                            // print("kk"+sts);
                            if(sts=="true") {
                              Navigator.pop(context);
                              showDialog(
                                  context: context,
                                  builder: (_) =>
                                  new AlertDialog(
                                    //title: new Text("Dialog Title"),
                                    content: new Text("Approved succesfully"),
                                  )
                              );
                              await new Future.delayed(const Duration(seconds: 1));
                              Navigator.pop(context);
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => MyTeamLeave()),
                              );
                            }
                            else{
                              showDialog(
                                  context: context,
                                  builder: (_) =>
                                  new AlertDialog(
                                    //title: new Text("Dialog Title"),
                                    content: new Text("Could not be approved. Try again. "),
                                  )
                              );
                            }
                          },
                        ),
/*
                        child: new OutlineButton(
                            child: new Text('Approve',
                                style: new TextStyle(
                                  color: Colors.green[700],
                                  fontSize: 16.0,
                                  fontWeight: FontWeight.bold,

                                )),
                             borderSide: BorderSide(color: Colors.green[700],),
                            onPressed: () async  {

                              //getApprovals(choice.title);
                              final sts= await ApproveLeave(leaveid,CommentController.text,2);
                              //  print("kk");
                              // print("kk"+sts);
                              if(sts=="true") {
                                Navigator.pop(context);
                                showDialog(
                                    context: context,
                                    builder: (_) =>
                                    new AlertDialog(
                                      //title: new Text("Dialog Title"),
                                      content: new Text("Approved succesfully"),
                                    )
                                );
                                await new Future.delayed(const Duration(seconds: 1));
                                Navigator.pop(context);
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => MyTeamLeave()),
                                );
                              }
                              else{
                                showDialog(
                                    context: context,
                                    builder: (_) =>
                                    new AlertDialog(
                                      //title: new Text("Dialog Title"),
                                      content: new Text("Could not be approved. Try again. "),
                                    )
                                );
                              }


                            },
                            shape: new RoundedRectangleBorder(borderRadius: new BorderRadius.circular(0.0),),

                        )
                        */


                    ),),


                  Padding(
                    padding: EdgeInsets.only(
                        top: 10.0, bottom: 0.0, left: 7.0, right: 60.0),
                    child:  ButtonTheme(
                      minWidth: 50.0,
                //      height: 40.0,
/*                      child: RaisedGradientButton(
                        onPressed: () async {
                          //getApprovals(choice.title);
                          var sts = await ApproveLeave(leaveid,CommentController.text,1);
                          print("ff"+sts);
                          if(sts=="true") {
                            showDialog(
                                context: context,
                                builder: (_) =>
                                new AlertDialog(
                                  //title: new Text("Dialog Title"),
                                  content: new Text("Leave rejected"),
                                )
                            );
                          }
                          else{
                            showDialog(
                                context: context,
                                builder: (_) =>
                                new AlertDialog(
                                  //title: new Text("Dialog Title"),
                                  content: new Text("Could not be rejected. Try again."),
                                )
                            );
                          }



                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => TabbedApp()),
                          ); },
                        // color: Colors.red[400],
                        gradient: LinearGradient(
                          colors: <Color>[Colors.red[700], Colors.red[700]],
                        ),
                        child: new Text('Reject',
                            style: new TextStyle(
                                color: Colors.white,
                                fontSize: 16.0,
                                fontWeight: FontWeight.bold)),
                      ),*/
                    child:FlatButton(
                      highlightColor: Colors.transparent,
                      focusColor: Colors.transparent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5),
                        side: BorderSide( color: Colors.grey.withOpacity(0.5), width: 1,),
                      )
                      ,child: Text('Reject',style: TextStyle(color: Colors.blue),),
                      onPressed: () async{
                        //getApprovals(choice.title);
                        var sts = await ApproveLeave(leaveid,CommentController.text,3);
                        print("ff"+sts);
                        if(sts=="true") {
                          Navigator.pop(context);
                          showDialog(
                              context: context,
                              builder: (_) =>
                              new AlertDialog(
                                //title: new Text("Dialog Title"),
                                content: new Text("Leave rejected"),
                              )
                          );
                          await new Future.delayed(const Duration(seconds: 2));
                          Navigator.pop(context);
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => MyTeamLeave()),
                          );
                        }
                        else{
                          showDialog(
                              context: context,
                              builder: (_) =>
                              new AlertDialog(
                                //title: new Text("Dialog Title"),
                                content: new Text("Could not be rejected. Try again."),
                              )
                          );
                        }

                      },

                     )
/*
                      child: new OutlineButton(
                          child: new Text('Reject',
                              style: new TextStyle(
                                  color: Colors.red[700],
                                  fontSize: 16.0,
                                  fontWeight: FontWeight.bold)),borderSide: BorderSide(color: Colors.red[700]),
                          onPressed: () async {

                            //getApprovals(choice.title);
                            var sts = await ApproveLeave(leaveid,CommentController.text,3);
                            print("ff"+sts);
                            if(sts=="true") {
                              Navigator.pop(context);
                              showDialog(
                                  context: context,
                                  builder: (_) =>
                                  new AlertDialog(
                                    //title: new Text("Dialog Title"),
                                    content: new Text("Leave rejected"),
                                  )
                              );
                              await new Future.delayed(const Duration(seconds: 2));
                              Navigator.pop(context);
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => MyTeamLeave()),
                              );
                            }
                            else{
                              showDialog(
                                  context: context,
                                  builder: (_) =>
                                  new AlertDialog(
                                    //title: new Text("Dialog Title"),
                                    content: new Text("Could not be rejected. Try again."),
                                  )
                              );
                            }


                            },
                          shape: new RoundedRectangleBorder(borderRadius: new BorderRadius.circular(0.0))
                      ),
                      */


                    ),
                  ),
                ],
              ),
            ),
          );

        }
    );

  }



}

