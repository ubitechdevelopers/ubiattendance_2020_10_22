import 'package:Shrine/services/services.dart';
import 'package:flutter/material.dart';
import 'AdminShiftCalendar.dart';
import 'Bottomnavigationbar.dart';
import 'UserShiftCalendar.dart';
import 'drawer.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/services.dart';
import 'edit_employee.dart';
import 'home.dart';
import 'settings.dart';
import 'reports.dart';
import 'profile.dart';
import 'attendance_summary.dart';
import 'globals.dart';
import 'dart:math' as math;
import 'package:url_launcher/url_launcher.dart';


class shiftPlannerList extends StatefulWidget {
  @override
  _EmployeeList createState() => _EmployeeList();
}
TextEditingController dept;
//FocusNode f_dept ;
class _EmployeeList extends State<shiftPlannerList> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  int _currentIndex = 2;
  String _sts = 'Active';
  String _sts1 = 'Active';
  String admin_sts='0';
  String _orgName="";
  String empname = "";
  bool res = true;
  var name;
  var First;
  var Last;

  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    //checkConnectionToServer(context);
    dept = new TextEditingController();
    // f_dept = FocusNode();
    getOrgName();
  }

  _launchURL(url) async {
    //  const url = 'https://flutter.io';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  getOrgName() async{
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _orgName= prefs.getString('org_name') ?? '';
      admin_sts= prefs.getString('sstatus') ?? '';
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
    /*Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => HomePage()),
    );*/
    print("-------> back button pressed");
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => Settings()), (Route<dynamic> route) => false,
    );
    return false;
  }

  getmainhomewidget() {
    return new WillPopScope(
      onWillPop: sendToHome,
      child: new Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[

              new Text('Monthly Shift planner', style: new TextStyle(fontSize: 20.0)),

              /*  Image.asset(
                      'assets/logo.png', height: 40.0, width: 40.0),*/
            ],
          ),
          leading: IconButton(icon:Icon(Icons.arrow_back),onPressed:(){
            Navigator.pop(context);}),
          backgroundColor: appcolor,
        ),
        bottomNavigationBar: Bottomnavigationbar(),
        endDrawer: new AppDrawer(),
        body: Container(
          //   padding: EdgeInsets.only(left: 2.0, right: 2.0),
          child: Column(
            children: <Widget>[
              SizedBox(height: 8.0),
              /* Center(
              child: Text('Employee Directory',
                style: new TextStyle(fontSize: 22.0, color: buttoncolor,),),
                ),*/
              SizedBox(height: 5.0),
              Container(
//              height: 40,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Card(
                    elevation: 2.0,
                    child: TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        prefixIcon: Icon(Icons.search),
                        hintText: 'Search',
                        focusColor: Colors.white,
                        /*suffixIcon: IconButton(
                            icon: Icon(Icons.close),
                            : (){},
                          )*/
                      ),
                      /*onChanged: _searchController,*/
                      onChanged: (value) {
                        setState(() {
                          empname = value;
                          res = true;
                        });
                      },
                    ),
                  ),
                ),
              ),
              new Expanded(
                child: getDeptWidget(),
              ),

            ],
          ),

        ),
        /* floatingActionButton: new FloatingActionButton(
          mini: false,
          backgroundColor: Colors.blue,
          onPressed: (){
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => AddEmployee()),
            );
          },
          tooltip: 'Add Employee',
          child: new Icon(Icons.add),
        ),*/
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
    return new FutureBuilder<List<Emp>>(
        future: getEmployee(empname),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return new ListView.builder(
                itemCount: snapshot.data.length,
                itemBuilder: (BuildContext context, int index) {
                  getAcronym(var val) {
                    if ((snapshot.data[index].Name.trim()).contains(" ")) {
                      name = snapshot.data[index].Name.split(" ");
                      First = name[0][0].trim();
                      Last = name[1][0].trim();
                      return First + Last;
                    } else {
                      First = snapshot.data[index].Name[0];
                      return First;
                    }
                  }
                  return new Column(
                      children: <Widget>[
                        SizedBox(height: 10.0,),
                        Wrap(
                          children: <Widget>[
                            Container(
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment
                                    .center,
                                children: <Widget>[
                                  InkWell(
                                    child:
                                    new Container(
                                      margin: EdgeInsets.only(left: 10.0),
                                      width: 40.0,
                                      height: 40.0,
                                      child: CircleAvatar(
                                        child: Text(getAcronym(snapshot.data[index].Name),
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 20,
                                                fontWeight: FontWeight
                                                    .w400)),
                                        backgroundColor: Color(
                                            (math.Random().nextDouble() *
                                                0xFFFFFF).toInt() << 0)
                                            .withOpacity(1.0),
                                      ),
                                    ),

                                  ),
                                  SizedBox(width: 5.0,),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment
                                        .start,
                                    children: <Widget>[
                                      Row(
                                        children: <Widget>[
                                          Container(
                                            width: MediaQuery
                                                .of(context)
                                                .size
                                                .width * 0.56,
                                            child: new Text(
                                              snapshot.data[index].Name
                                                  .toString(),
                                              style: TextStyle(
                                                color: Colors.black87,
                                                fontSize: 18.0,
//                                                   fontWeight: FontWeight.w500
                                              ),
                                            ),
                                          ),
                                          SizedBox(width: 50.0,),
                                          new InkWell(
                                            onTap:() {

                                              Navigator.push(
                                                context, MaterialPageRoute(builder: (context) => MyHomePage1(snapshot.data[index].Id
                                                  .toString(),snapshot.data[index].Name
                                                  .toString(),snapshot.data[index].ShiftId)),
                                              );
                                              //
                                            },

                                            child: Icon(
                                              Icons.remove_red_eye,
                                              color: Colors.black54,
                                              size: 30.0,

                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),


                                ],
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 15.0,)
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
