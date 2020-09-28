import 'package:Shrine/services/services.dart';
import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'Bottomnavigationbar.dart';
import 'drawer.dart';
import 'globals.dart';

class TimeOffList extends StatefulWidget {
  @override
  _TimeOffList createState() => _TimeOffList();
}
TextEditingController today;

//FocusNode f_dept ;
class _TimeOffList extends State<TimeOffList> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  int _currentIndex = 1;
  String _orgName='';
  bool res = true;
  String admin_sts='0';
  var formatter = new DateFormat('dd-MMM-yyyy');
  @override
  void initState() {
    super.initState();
    checkNetForOfflineMode(context);
    appResumedPausedLogic(context);
    today = new TextEditingController();
    today.text = formatter.format(DateTime.now());
    // f_dept = FocusNode();
    getOrgName();
  }

  getOrgName() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _orgName = prefs.getString('org_name') ?? '';
      admin_sts = prefs.getString('sstatus') ?? '0';
    });
  }

  void showInSnackBar(String value) {
    final snackBar = SnackBar(
        content: Text(
          value,
          textAlign: TextAlign.center,
        ));
    _scaffoldKey.currentState.showSnackBar(snackBar);
  }

  @override
  Widget build(BuildContext context) {
    return getmainhomewidget();
  }

  getmainhomewidget() {
    return new Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            new Text(_orgName, style: new TextStyle(fontSize: 20.0)),

            /*  Image.asset(
                    'assets/logo.png', height: 40.0, width: 40.0),*/
          ],
        ),
        leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.pop(context);
            }),
        backgroundColor: appcolor,
      ),
      bottomNavigationBar: Bottomnavigationbar(),
      endDrawer: new AppDrawer(),
      body: Container(
        //   padding: EdgeInsets.only(left: 2.0, right: 2.0),
        child: Column(
          children: <Widget>[
            SizedBox(height: 8.0),
            Center(
              child: Text(
                'Time Off',
                style: new TextStyle(
                  fontSize: 22.0,
                  color: appcolor,
                ),
              ),
            ),
            Divider(
              height: 1.5,color: Colors.black87,
            ),
//            Divider(
//              height: 10.0,
//            ),
            SizedBox(height: 2.0),
            Container(
              child: DateTimeField(
                //dateOnly: true,
                format: formatter,
                controller: today,
                onShowPicker: (context, currentValue) {
                  return showDatePicker(
                      context: context,
                      firstDate: DateTime(1900),
                      initialDate: currentValue ?? DateTime.now(),
                      lastDate: DateTime(2100));
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
            SizedBox(height: 12.0),
            Container(
              //  padding: EdgeInsets.only(bottom:10.0,top: 10.0),
              //width: MediaQuery.of(context).size.width * .9,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Container(
                    width: MediaQuery.of(context).size.width * 0.37,
                    child: Text(
                      ' Name',
                      style: TextStyle(color: appcolor, fontSize: 16.0, fontWeight: FontWeight.bold),
                      //textAlign: TextAlign.left,
                    ),
                  ),
                  Container(
                    width: MediaQuery.of(context).size.width * 0.16,
                    child: Text(
                      'From',
                      style: TextStyle(color: appcolor,fontSize: 16.0, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  Container(
                    width: MediaQuery.of(context).size.width * 0.2,
                    child: Text('To',
                        style: TextStyle(color: appcolor,fontSize: 16.0, fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center),
                  ),
                  Container(
                    width: MediaQuery.of(context).size.width * 0.22,
                    child: Text('Duration',
                        style: TextStyle(color: appcolor,fontSize: 16.0, fontWeight: FontWeight.bold),
                        textAlign: TextAlign.left),
                  ),
                ],
              ),
            ),
            SizedBox(height: 5.0),
            Divider(
              height: 5.2,
            ),
            new Expanded(
              child: res == true ? getEmpDataList(today.text) : Center(child: Container(
                  height: MediaQuery.of(context).size.height*0.30,
                  child:Center(
                    child: Container(
                      width: MediaQuery.of(context).size.width*1,
                      color: appcolor.withOpacity(0.1),
                      padding:EdgeInsets.only(top:5.0,bottom: 5.0),
                      child:Text("Please select the date",style: TextStyle(fontSize: 18.0),textAlign: TextAlign.center,),
                    ),
                  )
              ),),
            ),
          ],
        ),
      ),
    );
  }

  loader() {
    return new Container(
      child: Center(
        child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              Image.asset('assets/spinner.gif', height: 50.0, width: 50.0),
            ]),
      ),
    );
  }

  getEmpDataList(date) {
    return new FutureBuilder<List<EmpListTimeOff>>(
        future: getTimeOFfDataList(date),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            if (snapshot.data.length > 0) {
              return new ListView.builder(
                  itemCount: snapshot.data.length,
                  //    padding: EdgeInsets.only(left: 15.0,right: 15.0),
                  itemBuilder: (BuildContext context, int index) {
                    return new Column(children: <Widget>[
                      SizedBox(height: MediaQuery.of(context).size.height*.01,),
                      new Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          new Padding(
                              padding: EdgeInsets.only(left: 5.0),
                              child:Container(
                                  width: MediaQuery.of(context).size.width * 0.37,
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: <Widget>[
                                      new Text(
                                          snapshot.data[index].name.toString(),style: TextStyle(fontWeight: FontWeight.bold)),
                                    ],
                                  )
                              )),
                          new Container(
                            width: MediaQuery.of(context).size.width * 0.18,
                            child: new Text(
                                snapshot.data[index].from.toString(),style: TextStyle(fontWeight: FontWeight.bold)
                            ),
                          ),
                          new Container(
                            width: MediaQuery.of(context).size.width * 0.20,
                            child: new Text(
                                snapshot.data[index].to.toString(),style: TextStyle(fontWeight: FontWeight.bold)
                            ),
                          ),
                          new Container(
                            width: MediaQuery.of(context).size.width * 0.16,
                            child: new Text(snapshot.data[index].to.toString()=='00:00'?'Running':snapshot.data[index].diff.toString(), style: TextStyle(fontWeight: FontWeight.bold, color:snapshot.data[index].to.toString()=='00:00'?Colors.orange:Colors.teal),),
                          ),
                        ],
                      ),
                      //SizedBox(height: MediaQuery.of(context).size.height*.005,),
                      snapshot.data[index].Reason.toString()!=""?new Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Container(margin: EdgeInsets.only(top: 4.0),child: new Text("  Reason: ", style: TextStyle(fontSize: 12.0,color: Colors.black, fontWeight: FontWeight.bold),)),
                            Expanded(
                              child: Container(
                                margin: EdgeInsets.only(top: 4.0),
                                child: new Text(snapshot.data[index].Reason.toString(), style: TextStyle(
                                    color: Colors.black54,
                                    fontSize: 12.0),overflow: TextOverflow.ellipsis,),
                              ),
                            ),
                            //new Text(snapshot.data[index].ApprovalSts.toString(), style: TextStyle(color: snapshot.data[index].ApprovalSts.toString()=='Approved'?Colors.green.withOpacity(0.75):snapshot.data[index].ApprovalSts.toString()=='Rejected' || snapshot.data[index].ApprovalSts.toString()=='Cancel' ?Colors.red.withOpacity(0.65):snapshot.data[index].ApprovalSts.toString().startsWith('Pending')?buttoncolor:Colors.black54, fontSize: 14.0,),textAlign: TextAlign.center,),
                          ]):Center(),
                      snapshot.data[index].StartLoc.toString()!="..."?new Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Container(margin: EdgeInsets.only(top: 4.0),child: new Text("  Start Location: ", style: TextStyle(fontSize: 12.0,color: Colors.black, fontWeight: FontWeight.bold),)),
                            InkWell(
                              child: Container(
                                margin: EdgeInsets.only(top: 4.0),
                                child: new Text(snapshot.data[index].StartLoc.toString(), style: TextStyle(
                                    color: Colors.black54,
                                    fontSize: 12.0)),
                              ),
                              onTap: () {
                                goToMap(
                                    snapshot.data[index]
                                        .LatIn ,
                                    snapshot.data[index]
                                        .LongIn);
                              },
                            ),
                            //new Text(snapshot.data[index].ApprovalSts.toString(), style: TextStyle(color: snapshot.data[index].ApprovalSts.toString()=='Approved'?Colors.green.withOpacity(0.75):snapshot.data[index].ApprovalSts.toString()=='Rejected' || snapshot.data[index].ApprovalSts.toString()=='Cancel' ?Colors.red.withOpacity(0.65):snapshot.data[index].ApprovalSts.toString().startsWith('Pending')?buttoncolor:Colors.black54, fontSize: 14.0,),textAlign: TextAlign.center,),
                          ]):Center(),
                      snapshot.data[index].EndLoc.toString()!="..."?new Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Container(margin: EdgeInsets.only(top: 4.0),child: new Text("  End Location: ", style: TextStyle(fontSize: 12.0,color: Colors.black, fontWeight: FontWeight.bold),)),
                            InkWell(
                              child: Container(
                                margin: EdgeInsets.only(top: 4.0),
                                child: new Text(snapshot.data[index].EndLoc.toString(), style: TextStyle(
                                    color: Colors.black54,
                                    fontSize: 12.0)),
                              ),
                              onTap: () {
                                goToMap(
                                    snapshot.data[index]
                                        .LatOut ,
                                    snapshot.data[index]
                                        .LongOut);
                              },
                            ),
                            //new Text(snapshot.data[index].ApprovalSts.toString(), style: TextStyle(color: snapshot.data[index].ApprovalSts.toString()=='Approved'?Colors.green.withOpacity(0.75):snapshot.data[index].ApprovalSts.toString()=='Rejected' || snapshot.data[index].ApprovalSts.toString()=='Cancel' ?Colors.red.withOpacity(0.65):snapshot.data[index].ApprovalSts.toString().startsWith('Pending')?buttoncolor:Colors.black54, fontSize: 14.0,),textAlign: TextAlign.center,),
                          ]):Center(),
                      SizedBox(height: MediaQuery.of(context).size.height*.005,),
                      Divider(
                        color: Colors.blueGrey.withOpacity(0.25),
                        height: 0.5,
                      ),
                    ]);
                  });
            } else {
              return new Center(
                child: Container(
                  width: MediaQuery.of(context).size.width*1,
                  color: appcolor.withOpacity(0.1),
                  padding:EdgeInsets.only(top:5.0,bottom: 5.0),
                  child:Text("No records found ",style: TextStyle(fontSize: 18.0),textAlign: TextAlign.center,),
                ),
              );
            }
          } else if (snapshot.hasError) {
            return new Text("Unable to connect server");
          }
          // return loader();
          return new Center(child: CircularProgressIndicator());
        });
  }
} /////////mail class close
