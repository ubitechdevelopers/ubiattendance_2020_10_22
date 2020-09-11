import 'package:Shrine/Bottomnavigationbar.dart';
import 'package:Shrine/applyLeave.dart';
import 'package:Shrine/home.dart';
import 'package:Shrine/model/model.dart';
import 'package:Shrine/services/gethome.dart';
import 'package:Shrine/services/newservices.dart';
import 'package:Shrine/teamleave.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'drawer.dart';
import 'globals.dart';
import 'leave_summary.dart';
import 'login.dart';
import 'services/services.dart';


class MyLeave extends StatefulWidget {
  @override
  _MyLeaveState createState() => _MyLeaveState();
}

class _MyLeaveState extends State<MyLeave> {
  int _currentIndex = 0;
  int response;
  var profileimage;
  bool showtabbar ;
  String _orgName="";
  String admin_sts='';


  bool _checkwithdrawnleave = false;
  bool _checkLoadedprofile = true;
  bool _isButtonDisabled=false;
  int checkProcessing = 0;
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
      admin_sts = prefs.getString('sstatus') ?? '';
    });
  }

  initPlatformState() async{
    final prefs = await SharedPreferences.getInstance();

    setState(() {
      mainWidget = loadingWidget();
    });
    String empid = prefs.getString('uid')??"";
    String orgid =prefs.getString('orgid')??"";
    islogin().then((Widget configuredWidget) {
      setState(() {
        mainWidget = configuredWidget;
      });
    });
  }

  withdrawlLeave(String leaveid) async{
    setState(() {
      _checkwithdrawnleave = true;
    });
    print("----> withdrawn service calling "+_checkwithdrawnleave.toString());
    final prefs = await SharedPreferences.getInstance();
    String empid = prefs.getString('empid')??"";
    String orgid =prefs.getString('orgid')??"";
    //var leave = Leave(leaveid: leaveid, orgid: orgid, uid: empid);
    var islogin = await withdrawLeave(leaveid,orgid,empid);
    print(islogin);
    if(islogin=="success"){
      setState(() {
        _isButtonDisabled=false;
      });
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => MyLeave()),
      );
      showDialog(context: context, child:
      new AlertDialog(
        //backgroundColor: appEndColor(),
      //  title: new Text("Congrats!"),
        content: new Text("Leave application withdrawn successfully."),
      )
      );
    }else if(islogin=="failure"){
      setState(() {
        _isButtonDisabled=false;
      });
      showDialog(context: context, child:
      new AlertDialog(
        //title: new Text("Sorry!"),
        content: new Text("Leave could not be withdrawn."),
      )
      );
    }else{
      setState(() {
        _isButtonDisabled=false;
      });
      showDialog(context: context, child:
      new AlertDialog(
       // title: new Text("Sorry!"),
        content: new Text("Poor network connection."),
      )
      );
    }
  }


  confirmWithdrawl(String leaveid) async{
    showDialog(context: context, child:
    new AlertDialog(
      title: new Text("Withdraw leave?",textAlign: TextAlign.center,),
      content:  Padding(
        padding: const EdgeInsets.only(right:28.0),
        child: ButtonBar(
          children: <Widget>[
            RaisedButton(
              child: _checkwithdrawnleave?Text('Processing..',style: TextStyle(color: Colors.white),):Text('Withdraw',style: TextStyle(color: Colors.white),),
              elevation: 2.0,
              highlightElevation: 5.0,
              highlightColor: Colors.transparent,
              disabledElevation: 0.0,
              focusColor: Colors.transparent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(5),
              ),
              color: buttoncolor,
              onPressed: () {
                Navigator.of(context, rootNavigator: true).pop();
                withdrawlLeave(leaveid);
              },
            ),
            FlatButton(
            highlightColor: Colors.transparent,
            focusColor: Colors.transparent,
            shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(5),
            side: BorderSide( color: Colors.grey.withOpacity(0.5), width: 1,),
            ),
              child: Text('CANCEL'),
              onPressed: () {
                setState(() {
                  _isButtonDisabled=false;
                });
                Navigator.of(context, rootNavigator: true).pop();
              },
            ),
          ],
        ),
      ),
    )
    );
    /*return new Center(child: SizedBox(
      child: CircularProgressIndicator(strokeWidth: 2.2,),
      height: 20.0,
      width: 20.0,
    ),
    );*/
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
    return mainScafoldWidget();
  }

  Widget loadingWidget(){
    return Center(child:SizedBox(
      child:
      Text("Loading..", style: TextStyle(fontSize: 10.0,color: Colors.white),),
    ));
  }

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

  Widget mainScafoldWidget(){
    return  WillPopScope(
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
          body: homewidget(),
          //body: homewidget(),
           floatingActionButton: new FloatingActionButton(
            backgroundColor: buttoncolor,
            onPressed: (){
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ApplyLeave()),
              );
            },
            tooltip: 'Request Leave',
            child: new Icon(Icons.add),
          ),

      ),
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
                admin_sts=='1' ? Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Expanded(
                        flex:48,
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
                                      onTap: () {
                                        false;
                                      },

                                      child: Text(
                                          'Self',
                                          style: TextStyle(fontSize: 18,color: Colors.orange[800],fontWeight:FontWeight.bold)
                                      ),
                                    ),
                                  ]),

                              SizedBox(height:MediaQuery.of(context).size.width*.036),
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

                       Expanded(
                        flex:48,
                        child:InkWell(
                          onTap: () {

                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => MyTeamLeave()),
                            );




                          },
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

                                      child: Text(
                                          'Team',
                                          style: TextStyle(fontSize: 18,color: Colors.orange[800])
                                      ),
                                    ),
                                  ]),
                              SizedBox(height:MediaQuery.of(context).size.width*.04),
                            ]
                        ),
                        ),
                      )
                    ]
                ):Center(),

                Container(
                  padding: EdgeInsets.only(top:12.0),
                  child:Center(
                    child:Text('My Leave',
                        style: admin_sts=='1'?new TextStyle(fontSize: 18.0, color: Colors.black87,):new TextStyle(fontSize: 22.0, color: appcolor,),textAlign: TextAlign.center,),
                  ),
                ),


                new Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  //            crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    SizedBox(height: 20.0,),
                    // SizedBox(width: MediaQuery.of(context).size.width*0.0),

                    new Expanded(
                      child: Container(
                   //     color: Colors.red,
                        width: MediaQuery.of(context).size.width*0.60,
                        child:Text('Applied on',style: TextStyle(color: appcolor,fontWeight:FontWeight.bold,fontSize: 16.0),),
                      ),),

                    //SizedBox(height: 50.0,),

                    new Expanded(
                      child: Container(
                    //   color: Colors.yellow,
                        width: MediaQuery.of(context).size.width*0.40,
                        margin: EdgeInsets.only(left:32.0),
                        padding: EdgeInsets.only(right:12.0),
                        child:Text('Action',style: TextStyle(color: appcolor,fontWeight:FontWeight.bold,fontSize: 16.0,),textAlign: TextAlign.right,),
                      ),
                    ),


                  ],
                ),

                new Divider(),

                new Expanded(
                  child: Container(
                    height: MediaQuery.of(context).size.height*.55,
                    width: MediaQuery.of(context).size.width*.99,
             //       margin: EdgeInsets.only(top: 4.0),
                    //padding: EdgeInsets.only(bottom: 15.0),
                    color: Colors.white,
                    //////////////////////////////////////////////////////////////////////---------------------------------
                    child: new FutureBuilder<List<LeaveList>>(
                      future: getLeaveSummary(),
                      builder: (context, snapshot) {
                        if (snapshot.hasData) {
                          if (snapshot.data.length>0) {
                            return new ListView.builder(
                                scrollDirection: Axis.vertical,
                                itemCount: snapshot.data.length,

                                itemBuilder: (BuildContext context, int index) {
                                  return new Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: <Widget>[

                                        new Row(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          mainAxisAlignment: MainAxisAlignment.start,
                                          children: <Widget>[

                                            new Expanded(
                                              child: Padding(
                                                padding: const EdgeInsets.fromLTRB(0.0,5.0,0.0,0.0),
                                                child: Container(
                                            //     color:Colors.red,
                                                    height: MediaQuery .of(context).size.height * 0.04,
                                                    width: MediaQuery .of(context).size.width * 0.60,
                                                    child: Column(
                                                      crossAxisAlignment: CrossAxisAlignment.start,
                                                      children: <Widget>[

                                                        new Text(snapshot.data[index].AppliedDate.toString(), style: TextStyle(fontSize:14.0,fontWeight: FontWeight.bold),),
                                                       // new Text('To:     '+snapshot.data[index].ToDate.toString(), style: TextStyle(fontSize:12.0,fontWeight: FontWeight.bold),),
                                                       // new Text('Reason:'+snapshot.data[index].Reason.toString(), style: TextStyle(fontSize:14.0,fontWeight: FontWeight.bold),)
                                                      ],
                                                    )
                                                ),
                                              ),
                                            ),



                                            (snapshot.data[index].ApprovalStatus.toString() !='Withdraw' && snapshot.data[index].ApprovalStatus.toString() !="Rejected" && snapshot.data[index].ApprovalStatus.toString()!="Approved")?
                                              new Expanded(
                                                child: Padding(
                                                  padding: const EdgeInsets.fromLTRB(115.0,3.0,0.0,0.0),
                                                  child: Container (
                            //                   color:Colors.yellow,
                                                   height: MediaQuery .of(context).size.height * 0.04,
                                                   //margin: EdgeInsets.only(left:40.0),
                                                   //padding: EdgeInsets.only(left:40.0),
                                                   width: MediaQuery .of(context).size.width * 0.50,

                                                   child: new OutlineButton(
                                                      onPressed: () {
                                                        if(_isButtonDisabled)
                                                          return null;
                                                        setState(() {
                                                          _isButtonDisabled=true;
                                                          checkProcessing = index;
                                                        });
                                                        confirmWithdrawl(snapshot.data[index].LeaveId.toString());
                                                      },
                                                       child:new Icon(
                                                         Icons.replay,
                                                         size: 18.0,
                                                         color:appcolor,
                                                   //      textDirection: TextDirection.rtl,
                                                       ),
                                                       borderSide: BorderSide(color:appcolor),
                                                       shape: new CircleBorder(),
                                            //         padding:EdgeInsets.all(5.0),
                                                    )
                                                      /*
                                                   child: RaisedButton(
                                                     elevation: 2.0,
                                                     highlightElevation: 5.0,
                                                     highlightColor: Colors.transparent,
                                                     disabledElevation: 0.0,
                                                     focusColor: Colors.transparent,
                                                     shape: RoundedRectangleBorder(
                                                       borderRadius: BorderRadius.circular(5),
                                                     ),
                                                     child: _isButtonDisabled?Text(
                                                       'Processing..',
                                                       style: TextStyle(
                                                           color: Colors.white),
                                                     )
                                                         :Text(
                                                       'Withdraw',
                                                       style: TextStyle(
                                                           color: Colors.white),),
                                                     color: buttoncolor,
                                                     onPressed: (){
                                                       if(_isButtonDisabled)
                                                         return null;
                                                       setState(() {
                                                         _isButtonDisabled=true;
                                                         checkProcessing = index;
                                                       });
                                                       confirmWithdrawl(snapshot.data[index].LeaveId.toString());

                                                     },
                                                   ),
                                  */
                                                  ),
                                                ),
                                              ):Center(),
                                          ],
                                        ),
                                        new SizedBox(width: 5.0,),
                                        Container(
                                          width: MediaQuery.of(context).size.width*.90,
                                          //padding: EdgeInsets.only(top:1.5,bottom: .5),
                                          //margin: EdgeInsets.only(top: 4.0),
                                          child: Text('Duration: '+snapshot.data[index].FromDate.toString()+' To '+snapshot.data[index].ToDate.toString() +"  ",style: TextStyle(color: Colors.grey[600])),
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
                                          child: Text('No of Leaves: '+snapshot.data[index].NoofLeaves.toString(), style: TextStyle(color: Colors.black54),),
                                        ),



                                        snapshot.data[index].ApprovalStatus.toString()!='-'?Container(
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
                                                new TextSpan(text: snapshot.data[index].ApprovalStatus.toString(), style: TextStyle(color: snapshot.data[index].ApprovalStatus.toString()=='Approved'?appcolor :snapshot.data[index].ApprovalStatus.toString()=='Rejected' || snapshot.data[index].ApprovalStatus.toString()=='Cancel' ?Colors.red:snapshot.data[index].ApprovalStatus.toString().startsWith('Pending')?Colors.orange[800]:Colors.blue[600], fontSize: 14.0),),
                                              ],
                                            ),
                                          ),
                                        ):Center(
                                          // child:Text(snapshot.data[index].withdrawlsts.toString()),
                                        ),
                                        snapshot.data[index].Remarks.toString() != '' ? Container(
                                          width: MediaQuery .of(context).size .width * .90,
                                          //padding: EdgeInsets.only( top: 0.0, bottom: 0.5),
                                          margin: EdgeInsets.only(top: 4.0),
                                          child: Text('Remarks: ' +  snapshot.data[index].Remarks.toString(),style: TextStyle(color: Colors.black54),),
                                        ): Center(),


                                        Divider(),


                                      ]);
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


////////////////////////OLD DESIGN////////////////////
/*                new Row(
                mainAxisAlignment: MainAxisAlignment.start,
            //            crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                SizedBox(height: 50.0,),
                // SizedBox(width: MediaQuery.of(context).size.width*0.0),

                new Expanded(
                child: Container(
                width: MediaQuery.of(context).size.width*0.45,
                child:Text('Applied on',style: TextStyle(color: appStartColor(),fontWeight:FontWeight.bold,fontSize: 16.0),),
                ),),

                //SizedBox(height: 50.0,),

                new Expanded(
                child: Container(
                width: MediaQuery.of(context).size.width*0.20,
                margin: EdgeInsets.only(left:22.0),
                child:Text('Duration',style: TextStyle(color: appStartColor(),fontWeight:FontWeight.bold,fontSize: 16.0),),
                ),
                ),

                new Expanded(
                child: Container(
                margin: EdgeInsets.only(left:42.0),
                width: MediaQuery.of(context).size.width*0.30,
                child:Text('Action',style: TextStyle(color: appStartColor(),fontWeight:FontWeight.bold,fontSize: 16.0),),
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
                    child: new FutureBuilder<List<Leave>>(
                       future: getLeaveSummary(),
                       builder: (context, snapshot) {
                        if (snapshot.hasData) {
                          if (snapshot.data.length>0) {
                            return new ListView.builder(
                              scrollDirection: Axis.vertical,
                              itemCount: snapshot.data.length,
                              itemBuilder: (BuildContext context, int index) {
                              return new Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                new Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: <Widget>[
                                    new Expanded(
                                      child: Container(
                                        width: MediaQuery .of(context).size .width * 0.35,
                                        child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                          children: <Widget>[
                                            new SizedBox(width: 5.0,),
                                            new Text(snapshot.data[index].attendancedate.toString(), style: TextStyle(fontWeight: FontWeight.bold),)
                                          ],
                                        )
                                      ),
                                    ),

                                    new Container(
                                      child: RichText(
                                        text: new TextSpan(
                                          style: new TextStyle(
                                          fontSize: 14.0,
                                          color: Colors.black,
                                          ),
                                          children: <TextSpan>[
                                          new TextSpan(text: ''
                                          ,style: new TextStyle(fontWeight: FontWeight.bold)),
                                          new TextSpan(text: snapshot.data[index].leavefrom.toString()+snapshot.data[index].leaveto.toString() +"  ",style: TextStyle(color: Colors.grey[600]), ),

                                          ],
                                        ),
                                      )
                                    ),

                                    new Expanded(
                                      child: Container(
                                        width: MediaQuery .of(context).size.width * 0.30,
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: <Widget>[
                                            new SizedBox(width: 5.0,),
                                            new Text(
                                            "",
                                            style: TextStyle(
                                            fontWeight: FontWeight.bold),),
                                            (snapshot.data[index].withdrawlsts &&
                                            snapshot.data[index].approverstatus.toString() !='Withdrawn' && snapshot.data[index].approverstatus.toString() !=
                                            "Rejected") ? new Container(
                                            height: 30.5,
                                            margin: EdgeInsets.only(
                                            left:25.0),
                                            child: new OutlineButton(
                                            child:new Icon(Icons.replay, size: 18.0,color:appStartColor(), ),
                                            borderSide: BorderSide(color:appStartColor()),

                                            //  color: Colors.orangeAccent,
                                            onPressed: () {
                                            confirmWithdrawl(
                                            snapshot.data[index].leaveid.toString());},
                                            shape: new CircleBorder(),
                                            )
                                            ) : Center()
                                          ],
                                        )
                                      ),
                                    ),
                                  ],
                                ),

                                snapshot.data[index].reason.toString()!='-'?Container(
                                width: MediaQuery.of(context).size.width*.90,
                                padding: EdgeInsets.only(top:1.5,bottom: .5),
                                margin: EdgeInsets.only(top: 4.0),
                                child: Text('Reason: '+snapshot.data[index].reason.toString(), style: TextStyle(color: Colors.black54),),
                                ):Center(),

                                snapshot.data[index].comment.toString() != '-' ? Container(
                                width: MediaQuery .of(context).size .width * .90,
                                padding: EdgeInsets.only( top: 0.0, bottom: 0.5),
                                margin: EdgeInsets.only(top: 0.0),
                                child: Text('Approver Comment: ' +  snapshot.data[index].comment.toString(),style: TextStyle(color: Colors.black54),),
                                ): Center(),

                                snapshot.data[index].approverstatus.toString()!='-'?Container(
                                width: MediaQuery.of(context).size.width*.90,
                                padding: EdgeInsets.only(top:.5,bottom: 1.5),
                                margin: EdgeInsets.only(top: 1.0),
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
                                new TextSpan(text: snapshot.data[index].approverstatus.toString(), style: TextStyle(color: snapshot.data[index].approverstatus.toString()=='Approved'?appStartColor() :snapshot.data[index].approverstatus.toString()=='Rejected' || snapshot.data[index].approverstatus.toString()=='Cancel' ?Colors.red:snapshot.data[index].approverstatus.toString().startsWith('Pending')?Colors.orange[800]:Colors.blue[600], fontSize: 14.0),),
                                ],
                                ),
                                ),
                                ):Center(
                                // child:Text(snapshot.data[index].withdrawlsts.toString()),
                                ),

                                Divider(color: Colors.grey,),
                              ]);
                            }
                          );
                        }else
                          return new Center( child: Text('No Leave History'), );
                        } else if (snapshot.hasError) {
                          return new Text("Unable to connect server");
                        }

                // By default, show a loading spinner
                        return new Center( child: CircularProgressIndicator());
                    },
                ),
                //////////////////////////////////////////////////////////////////////---------------------------------
                ),
                ),*/
//////////////OLD DESIGN///////////

              ]
            )



    ///////////////////TESTING//////////////////////////



/*
            child:Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  Text('My Leave',
                   style: new TextStyle(fontSize: 22.0, color: appStartColor())),
                  //SizedBox(height: 10.0),

                  new Divider(color: Colors.black54,height: 1.5,),
                  new Row(
                    mainAxisAlignment: MainAxisAlignment.start,
//            crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      SizedBox(height: 50.0,),
                     // SizedBox(width: MediaQuery.of(context).size.width*0.0),

                      new Expanded(
                        child: Container(
                        width: MediaQuery.of(context).size.width*0.45,
                        child:Text('Applied on',style: TextStyle(color: appStartColor(),fontWeight:FontWeight.bold,fontSize: 16.0),),
                      ),),

                      //SizedBox(height: 50.0,),

                      new Expanded(
                        child: Container(
                        width: MediaQuery.of(context).size.width*0.20,
                          margin: EdgeInsets.only(left:22.0),
                        child:Text('Duration',style: TextStyle(color: appStartColor(),fontWeight:FontWeight.bold,fontSize: 16.0),),
                      ),
        ),

                      new Expanded(
                        child: Container(
                          margin: EdgeInsets.only(left:42.0),
                        width: MediaQuery.of(context).size.width*0.30,
                        child:Text('Action',style: TextStyle(color: appStartColor(),fontWeight:FontWeight.bold,fontSize: 16.0),),
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
                      child: new FutureBuilder<List<Leave>>(
                        future: getLeaveSummary(),
                        builder: (context, snapshot) {
                          if (snapshot.hasData) {
                            if (snapshot.data.length>0) {
                              return new ListView.builder(
                                  scrollDirection: Axis.vertical,
                                  itemCount: snapshot.data.length,
                                  itemBuilder: (BuildContext context, int index) {
                                    return new Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: <Widget>[
                                          new Row(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            mainAxisAlignment: MainAxisAlignment.start,
                                 children: <Widget>[
                                   new Expanded(
                                     child: Container(
                                      width: MediaQuery .of(context).size .width * 0.35,
                                      child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: <Widget>[
                                          new SizedBox(width: 5.0,),
                                          new Text(
                                          snapshot.data[index].attendancedate.toString(),
                                          style: TextStyle(
                                          fontWeight: FontWeight.bold),)

                                        ],
                                        )),),




                                   new Container(
                                       child: RichText(
                                         text: new TextSpan(
                                           style: new TextStyle(
                                             fontSize: 14.0,
                                             color: Colors.black,
                                           ),
                                           children: <TextSpan>[
                                             new TextSpan(text: ''
                                                 ,style: new TextStyle(fontWeight: FontWeight.bold)),
                                             new TextSpan(text: snapshot.data[index].leavefrom.toString()+snapshot.data[index].leaveto.toString() +"  ",style: TextStyle(color: Colors.grey[600]), ),

                                           ],
                                         ),
                                       )
                                   ),

                                   new Expanded(
                                     child: Container(
                                      width: MediaQuery .of(context).size.width * 0.30,
                                         child: Column(
                                           crossAxisAlignment: CrossAxisAlignment.start,
                                           children: <Widget>[
                                             new SizedBox(width: 5.0,),
                                             new Text(
                                               "",
                                             style: TextStyle(
                                                 fontWeight: FontWeight.bold),),
                                             (snapshot.data[index].withdrawlsts &&
                                              snapshot.data[index].approverstatus.toString() !='Withdrawn' && snapshot.data[index].approverstatus.toString() !=
                                                 "Rejected") ? new Container(
                                                 height: 30.5,
                                                 margin: EdgeInsets.only(
                                                 left:25.0),
                                                 child: new OutlineButton(
                                                 child:new Icon(Icons.replay, size: 18.0,color:appStartColor(), ),
                                                borderSide: BorderSide(color:appStartColor()),

                                                   //  color: Colors.orangeAccent,
                                                 onPressed: () {
                                                 confirmWithdrawl(
                                                 snapshot.data[index].leaveid.toString());},
                                                 shape: new CircleBorder(),
                                                 )
                                             ) : Center()
                                           ],
                                         )




                                     ),),




                                            ],
                                          ),
                                          //SizedBox(width: 30.0,),


                                          snapshot.data[index].reason.toString()!='-'?Container(
                                            width: MediaQuery.of(context).size.width*.90,
                                            padding: EdgeInsets.only(top:1.5,bottom: .5),
                                            margin: EdgeInsets.only(top: 4.0),
                                            child: Text('Reason: '+snapshot.data[index].reason.toString(), style: TextStyle(color: Colors.black54),),
                                          ):Center(),





                                          snapshot.data[index].comment.toString() != '-' ? Container(
                                            width: MediaQuery .of(context).size .width * .90,
                                            padding: EdgeInsets.only( top: 0.0, bottom: 0.5),
                                            margin: EdgeInsets.only(top: 0.0),
                                            child: Text('Approver Comment: ' +  snapshot.data[index].comment.toString(),style: TextStyle(color: Colors.black54),),
                                          ): Center(),



                                          snapshot.data[index].approverstatus.toString()!='-'?Container(
                                            width: MediaQuery.of(context).size.width*.90,
                                            padding: EdgeInsets.only(top:.5,bottom: 1.5),
                                            margin: EdgeInsets.only(top: 1.0),
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
                                                  new TextSpan(text: snapshot.data[index].approverstatus.toString(), style: TextStyle(color: snapshot.data[index].approverstatus.toString()=='Approved'?appStartColor() :snapshot.data[index].approverstatus.toString()=='Rejected' || snapshot.data[index].approverstatus.toString()=='Cancel' ?Colors.red:snapshot.data[index].approverstatus.toString().startsWith('Pending')?Colors.orange[800]:Colors.blue[600], fontSize: 14.0),),
                                                ],
                                              ),
                                            ),
                                          ):Center(
                                            // child:Text(snapshot.data[index].withdrawlsts.toString()),
                                          ),

                                          Divider(color: Colors.grey,),
                             ]);
                              }
                          );
                          }else
                           return new Center(
                             child: Text('No Leave History'),
                           );
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
                ])*/

    ///////////////////TESTING//////////////////////////


        ),



      ],
    );
  }

}
/*
class LeaveAppHeader extends StatelessWidget implements PreferredSizeWidget {
  bool _checkLoadedprofile = true;
  var profileimage;
  bool showtabbar;
  var orgname;
  LeaveAppHeader(profileimage1,showtabbar1,orgname1){
    profileimage = profileimage1;
    orgname = orgname1;
    // print("--------->");
    // print(profileimage);
    //  print("--------->");
    //   print(_checkLoadedprofile);
    if (profileimage!=null) {
      _checkLoadedprofile = false;
      //    print(_checkLoadedprofile);
    };
    showtabbar= showtabbar1;
  }
  /*void initState() {
    super.initState();
 //   initPlatformState();
  }
*/
  @override
  Widget build(BuildContext context) {
    return new GradientAppBar(
        backgroundColorStart: appStartColor(),
        backgroundColorEnd: appEndColor(),
        automaticallyImplyLeading: false,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            IconButton(icon:Icon(Icons.arrow_back),
              onPressed:(){
                print("ICON PRESSED");
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => HomePageMain()), (Route<dynamic> route) => false,
                );
              },),
            GestureDetector(
              // When the child is tapped, show a snackbar
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => CollapsingTab()),
                );
              },
              child:Container(
                  width: 40.0,
                  height: 40.0,
                  decoration: new BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                      image: new DecorationImage(
                        fit: BoxFit.fill,
                        // image: AssetImage('assets/avatar.png'),
                        image: _checkLoadedprofile ? AssetImage('assets/avatar.png') : profileimage,
                      )
                  )
              ),
            ),
            Flexible(
              child: Container(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(orgname, overflow: TextOverflow.ellipsis,)
              ),
            )
          ],
        ),
        bottom:
        showtabbar==true ? TabBar(
          unselectedLabelColor: Colors.white70,
          indicatorColor: Colors.white,
          isScrollable: true,
          tabs: choices.map((Choice choice) {
            return Tab(
              text: choice.title,
              //   unselectedLabelColor: Colors.white70,
              //   indicatorColor: Colors.white,
              //   icon: Icon(choice.icon),
            );
          }).toList(),
        ):null
    );
  }
  @override
  Size get preferredSize => new Size.fromHeight(showtabbar==true ? 100.0 : 60.0);


}

 */
