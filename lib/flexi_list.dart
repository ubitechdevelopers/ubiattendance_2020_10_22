import 'package:Shrine/globals.dart' as prefix0;
import 'package:Shrine/services/services.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'Bottomnavigationbar.dart';
import 'Image_view.dart';
import 'drawer.dart';
import 'globals.dart';
class FlexiList extends StatefulWidget {
  @override
  _FlexiList createState() => _FlexiList();
}

TextEditingController today;
String _orgName = "";
//FocusNode f_dept ;
class _FlexiList extends State<FlexiList> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  int _currentIndex = 1;
  String admin_sts='0';
  bool res = true;
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
        automaticallyImplyLeading: false,
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
                'Flexi Attendance',
                style: new TextStyle(
                  fontSize: 22.0,
                  color: appcolor,
                ),
              ),
            ),
            Divider(
                color: Colors.black87,
                height: 1.5
            ),
            SizedBox(height: 2.0),
           /* Container(
              child: new GestureDetector(
              onTap: () {
                FocusScope.of(context).requestFocus(new FocusNode());
              },
                child: DateTimeField(
                 // dateOnly: true,
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
                      if (date != null && date.toString() != '')
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
            ),*/
            SizedBox(height: 12.0),
            Container(
              //  padding: EdgeInsets.only(bottom:10.0,top: 10.0),
              //       width: MediaQuery.of(context).size.width * .9,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  SizedBox(width: MediaQuery.of(context).size.width * 0.02),
                  /*
                  Container(
                    width: MediaQuery.of(context).size.width * 0.15,
                    child: Text(
                      'Name',
                      style: TextStyle(color: headingcolor),
                      textAlign: TextAlign.left,
                    ),
                  ),*/
                  Container(
                    width: MediaQuery.of(context).size.width * 0.38,
                    child: Text(
                      'Date',
                      style: TextStyle(color: appcolor,fontSize: 16.0,fontWeight: FontWeight.bold),
                      textAlign: TextAlign.left,
                    ),
                  ),
                  Container(
                    width: MediaQuery.of(context).size.width * 0.30,
                    child: Text('Time In',
                        style: TextStyle(color: appcolor,fontSize: 16.0,fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center),
                  ),
                  Container(
                    width: MediaQuery.of(context).size.width * 0.30,
                    child: Text('Time Out ',
                        style: TextStyle(color: appcolor,fontSize: 16.0,fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center),
                  ),
                ],
              ),
            ),
            SizedBox(height: 5.0),
            Divider(
              height: 5.2,
            ),
            new Expanded(
              child: res == true ? getEmpDataList(today.text) : Center(),
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
    return new FutureBuilder<List<FlexiAtt>>(
        future: getFlexiDataList(date),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            if (snapshot.data.length > 0) {
              return new ListView.builder(
                  itemCount: snapshot.data.length,
                  //    padding: EdgeInsets.only(left: 15.0,right: 15.0),
                  itemBuilder: (BuildContext context, int index) {
                    return new Container(
                      //          width: MediaQuery.of(context).size.width * .9,
                      child:Column(children: <Widget>[
                        new Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[

                            /*
                            new Container(
                                width: MediaQuery.of(context).size.width * 0.18,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    new Text(
                                      snapshot.data[index].Emp.toString(),style: TextStyle(fontWeight: FontWeight.bold),textAlign: TextAlign.left,),
                                  ],
                                )),

                             */
                            SizedBox(width: MediaQuery.of(context).size.width * 0.02),
                            new Container(
                              width: MediaQuery.of(context).size.width * 0.38,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Text(snapshot.data[index].timeindate
                                      .toString(), style: TextStyle(
                                      color: Colors.black87,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16.0),),
                                 /* new Text(
                                    snapshot.data[index].client.toString(),style: TextStyle(fontWeight: FontWeight.bold),textAlign: TextAlign.left,
                                  ),*/
                                  InkWell(
                                    child:Text("Time In: "+
                                        snapshot.data[index].pi_loc.toString(),style: TextStyle(color: Colors.black54,fontSize: 12.0),),
                                    onTap: () {goToMap(snapshot.data[index].pi_latit,snapshot.data[index].pi_longi.toString());},
                                  ),
                                  InkWell(
                                    child:Text("Time Out: "+
                                        snapshot.data[index].po_loc.toString(),style: TextStyle(color: Colors.black54,fontSize: 12.0),),
                                    onTap: () {goToMap(snapshot.data[index].po_latit.toString(),snapshot.data[index].po_longi.toString());},
                                  ),
                                ],
                              ),


                            ),
                            Container(
                                width: MediaQuery
                                    .of(context)
                                    .size
                                    .width * 0.30,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment
                                      .center,
                                  children: <Widget>[
                                    Text(snapshot.data[index].pi_time
                                        .toString(),style: TextStyle(fontWeight: FontWeight.bold),),
                                    Container(
                                      width: 62.0,
                                      height: 62.0,
                                      child:InkWell(
                                        child: Container(
                                            decoration: new BoxDecoration(
                                                shape: BoxShape .circle,
                                                image: new DecorationImage(
                                                    fit: BoxFit.fill,
                                                    image: new NetworkImage(snapshot.data[index].pi_img)
                                                )
                                            )),
                                        onTap: (){
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(builder: (context) => ImageView(myimage: snapshot.data[index].pi_img,org_name: _orgName)),
                                          );
                                        },
                                      ),
                                    ),
                                    Text(snapshot.data[index].timeindate
                                        .toString(),style: TextStyle(color: Colors.grey),),
                                  ],
                                )

                            ),
                            Container(
                                width: MediaQuery
                                    .of(context)
                                    .size
                                    .width * 0.30,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment
                                      .center,
                                  children: <Widget>[
                                    Text(snapshot.data[index].po_time
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
                                                        snapshot.data[index].po_img)
                    )

                                            )),
                                        onTap: (){
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(builder: (context) => ImageView(myimage: snapshot.data[index].po_img,org_name: _orgName)),
                                          );
                                        },
                                      ),
                                    ),
                                    Text(snapshot.data[index].timeoutdate
                                        .toString(),style: TextStyle(color: Colors.grey
                                    ),),
                                  ],
                                )

                            ),
                          ],
                        ),

                        Divider(
                          color: Colors.blueGrey.withOpacity(0.25),
                          height: 0.2,
                        ),
                      ]),
                    );
                  });
            } else {

              return new Container(
                  height: MediaQuery.of(context).size.height*0.50,
                  child:Center(
                    child: Container(
                      width: MediaQuery.of(context).size.width*1,
                      color: appcolor.withOpacity(0.1),
                      padding:EdgeInsets.only(top:5.0,bottom: 5.0),
                      child:Text("No Attendance",style: TextStyle(fontSize: 18.0),textAlign: TextAlign.center,),
                    ),
                  )
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
