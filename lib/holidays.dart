import 'package:Shrine/addHoliday.dart';
import 'package:Shrine/services/services.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'Bottomnavigationbar.dart';
import 'drawer.dart';
import 'globals.dart';
import 'settings.dart';

class HolidayList extends StatefulWidget {
  @override
  _HolidayList createState() => _HolidayList();
}
TextEditingController dept;
//FocusNode f_dept ;
class _HolidayList extends State<HolidayList> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  /*int _currentIndex = 2;
  String _sts = 'Active';
  String _sts1 = 'Active';*/
  String _orgName="";
  //bool _isButtonDisabled = false;
  String admin_sts='0';
  @override
  void initState() {
    super.initState();
    checkNetForOfflineMode(context);

    dept = new TextEditingController();
    // f_dept = FocusNode();
    getOrgName();
  }
  getOrgName() async{
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _orgName= prefs.getString('org_name') ?? '';
      admin_sts= prefs.getString('sstatus') ?? '0';
    });
  }
  @override
  Widget build(BuildContext context) {
    return getmainhomewidget();
  }

  void showInSnackBar(String value) {
    final snackBar = SnackBar(
        content: Text(value, textAlign: TextAlign.center,));
    _scaffoldKey.currentState.showSnackBar(snackBar);
  }
  Future<bool> sendToHome() async{

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => Settings()), (Route<dynamic> route) => false,
    );
    return false;
  }

  getmainhomewidget() {
    return new WillPopScope(
      onWillPop: ()=> sendToHome(),
      child: Scaffold(
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
          leading: IconButton(icon:Icon(Icons.arrow_back),onPressed:(){
            //Navigator.pop(context);
            sendToHome();
          }),
          backgroundColor: appcolor,
        ),
        bottomNavigationBar: Bottomnavigationbar(),

        endDrawer: new AppDrawer(),
        body:
        Container(
          //   padding: EdgeInsets.only(left: 2.0, right: 2.0),
          child: Column(
            children: <Widget>[
              SizedBox(height: 10.0),
              Center(
                child: Text('Holidays',
                  style: new TextStyle(fontSize: 22.0, color: appcolor,),),
              ),
              Divider(color: Colors.black54,height: 1.5,),
              //Divider(height: 10.0,),
              SizedBox(height: 8.0),
              Container(
                padding: EdgeInsets.only(bottom:10.0,top: 10.0),
                width: MediaQuery.of(context).size.width*.9,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Container(
                      width: MediaQuery.of(context).size.width*0.35,
                      child: Text('Holidays', style: TextStyle(color: appcolor,fontSize: 16.0, fontWeight: FontWeight.bold ),textAlign: TextAlign.left,),
                    ),
                    Container(
                      width: MediaQuery.of(context).size.width*0.22,
                      child: Text('From', style: TextStyle(color: appcolor,fontSize: 16.0, fontWeight: FontWeight.bold ),textAlign: TextAlign.left,),
                    ),
                    Container(
                      width: MediaQuery.of(context).size.width*0.16,
                      child: Text('To', style: TextStyle( color: appcolor,fontSize: 16.0, fontWeight: FontWeight.bold ),textAlign: TextAlign.center),
                    ),
                    Container(
                      width: MediaQuery.of(context).size.width*0.10,
                      child: Text('Days', style: TextStyle(color: appcolor,fontSize: 16.0, fontWeight: FontWeight.bold ),textAlign: TextAlign.right),
                    ),

                  ],
                ),
              ),
              Divider(height: 0.2,),
              new Expanded(
                child: getDeptWidget(),
              ),

            ],
          ),

        ),
        floatingActionButton: new FloatingActionButton(
          mini: false,
          backgroundColor: buttoncolor,
          onPressed: (){
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => addHoliday()),
            );
          },
          tooltip: 'Add Holiday',
          child: new Icon(Icons.add),
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
              Image.asset(
                  'assets/spinner.gif', height: 50.0, width: 50.0),
            ]),
      ),
    );
  }

  getDeptWidget() {

    return new FutureBuilder<List<Holiday>>(
        future: getHolidays(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return new ListView.builder(
                itemCount: snapshot.data.length,
                //    padding: EdgeInsets.only(left: 15.0,right: 15.0),
                itemBuilder: (BuildContext context, int index) {
                  return  new Column(
                      children: <Widget>[
                        new FlatButton(
                          child : new Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              new Container(
                                  width: MediaQuery.of(context).size.width*0.3,
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: <Widget>[
                                      new Text(snapshot.data[index].Name.toString())
                                    ],
                                  )
                              ),
                              new Container(
                                width: MediaQuery.of(context).size.width*0.22,
                                child: new Text(snapshot.data[index].From.toString(),),
                              ),
                              new Container(
                                width: MediaQuery.of(context).size.width*0.22,
                                child: new Text(snapshot.data[index].To.toString(),),
                              ),
                              new Container(
                                width: MediaQuery.of(context).size.width*0.05,
                                child: new Text(snapshot.data[index].Days.toString()),
                              ),
                            ],
                          ),
                          onPressed: (){

                          },),
                        Divider(color: Colors.blueGrey.withOpacity(0.25),height: 0.2,),
                      ]
                  );
                }
            );
          }
          return loader();
        }
    );
  }


}/////////mail class close
