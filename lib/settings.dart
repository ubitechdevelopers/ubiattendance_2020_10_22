import 'package:Shrine/FaceIdlist.dart';
import 'package:Shrine/globals.dart' as prefix0;
import 'package:Shrine/push_notification_for_employee_settings.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

import 'Bottomnavigationbar.dart';
import 'cameraSettings.dart';
import 'change_password.dart';
import 'department.dart';
import 'designation.dart';
import 'drawer.dart';
import 'employee_list.dart';
import 'globals.dart';
import 'holidays.dart';
import 'home.dart';
import 'notification_settings.dart';
import 'payment.dart';
import 'permission.dart';
import 'profile.dart';
import 'services/services.dart';
import 'shift_list.dart';
import 'super_tooltip.dart';

class Settings extends StatefulWidget {
  @override
  _Settings createState() => _Settings();
}
class _Settings extends State<Settings> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  int _currentIndex = 2;
  String _orgName='';
  String admin_sts='0';
  String buystatus = "";
  String trialstatus = "";
  String orgmail = "";

   var tooltipthree = SuperTooltip(
    popupDirection: TooltipDirection.up,
    arrowTipDistance: 20.0,
    x: -375,
    y: -450,
    //arrowLength: 40.0,
    //top: 50.0,
    //right: 1.0,
    // left: 50.0,
    //bottom: 100.0,
    //showCloseButton: ShowCloseButton.outside,
    hasShadow: false,
    content: new Material(
        child: Container(
          width: 200.0,
          height: 80.0,
          child: Padding(
            padding: const EdgeInsets.all(0.0),
            child: Column(
              children: <Widget>[
                Text("Add Shifts from here",style: TextStyle(fontWeight: FontWeight.bold,fontSize: 20),),
                RaisedButton(
                  onPressed: (){
                    SuperTooltip.a.close();
                    tooltipthreeClicked(SuperTooltip.ctx);
                    istooltipthreeshown=true;
                  },
                  child: Text("Next"),
                ),
              ],
            ),
          ),
        )),
  );
  static var tooltipfour = SuperTooltip(
    popupDirection: TooltipDirection.up,
    arrowTipDistance: 20.0,
    x: -375,
    y: -380,
    //arrowLength: 40.0,
    //top: 50.0,
    //right: 1.0,
    // left: 50.0,
    //bottom: 100.0,
    //showCloseButton: ShowCloseButton.outside,
    hasShadow: false,
    content: new Material(
        child: Container(
          width: 200.0,
          height: 100.0,
          child: Padding(
            padding: const EdgeInsets.all(0.0),
            child: Column(
              children: <Widget>[
                Text("Add Departments from here",style: TextStyle(fontWeight: FontWeight.bold,fontSize: 20),),
                RaisedButton(
                  onPressed: (){
                    SuperTooltip.a.close();
                    tooltipfourClicked(SuperTooltip.ctx);
                    istooltipfourshown=true;
                  } ,
                  child: Text(
                    "Next",
                    softWrap: true,
                  ),
                ),
              ],
            ),
          ),
        )),
  );

  static var tooltipfive = SuperTooltip(
    popupDirection: TooltipDirection.up,
    arrowTipDistance: 20.0,
    x: -375,
    y: -310,
    //arrowLength: 40.0,
    //top: 50.0,
    //right: 1.0,
    // left: 50.0,
    //bottom: 100.0,
    //showCloseButton: ShowCloseButton.outside,
    hasShadow: false,
    content: new Material(
        child: Container(
          width: 200.0,
          height: 100.0,
          child: Padding(
            padding: const EdgeInsets.all(0.0),
            child: Column(
              children: <Widget>[
                Text("Add Designations from here",style: TextStyle(fontWeight: FontWeight.bold,fontSize: 20),),
                RaisedButton(
                  onPressed: (){
                    SuperTooltip.a.close();
                    tooltipfiveClicked(SuperTooltip.ctx);
                    istooltipfiveshown=true;
                  },
                  child: Text(
                    "Next",
                    softWrap: true,
                  ),
                ),
              ],
            ),
          ),
        )),
  );
  static tooltipthreeClicked(var context) async{
    //HomePage h=new HomePage();
    //Navigator.of(context).push(new MaterialPageRoute(builder: (BuildContext context) => ShiftList(),maintainState: false));
    //Future.delayed(Duration(seconds: 2), () => tooltipfour.show(context));
    //tooltipfour.show(context);

  }
  static tooltipfourClicked(var context) async{
    //HomePage h=new HomePage();
    //Navigator.of(context).push(new MaterialPageRoute(builder: (BuildContext context) => Department(),maintainState: false));
    //tooltipfive.show(context);

  }
  static tooltipfiveClicked(var context) async{
    //HomePage h=new HomePage();
    Navigator.of(context).push(new MaterialPageRoute(builder: (BuildContext context) => HomePage(),maintainState: false));

  }

  @override
  void initState() {
    super.initState();
    checkNetForOfflineMode(context);

    checknetonpage(context);
    getOrgName();
    if((istooltiptwoshown==true) && (istooltipthreeshown!=true)){
      //Future.delayed(Duration(seconds: 1), () => tooltipthree.show(context));
      //istooltipthreeshown=true;
    }
//    if((istooltipthreeshown==true) && (istooltipfourshown!=true)){
//      Future.delayed(Duration(seconds: 2), () => tooltipfour.show(context));
//      //istooltipfourshown=true;
//    }
//    if((istooltipfourshown==true) && (istooltipfiveshown!=true)){
//      Future.delayed(Duration(seconds: 2), () => tooltipfive.show(context));
//      //istooltipfiveshown=true;
//    }
  }
  getOrgName() async{
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      admin_sts=prefs.getString('sstatus').toString();
      _orgName= prefs.getString('org_name') ?? '';
      buystatus = prefs.getString('buysts') ?? '';
      trialstatus = prefs.getString('trialstatus') ?? '';
      orgmail = prefs.getString('orgmail') ?? '';
    });
  }

  launchMap(String url) async{
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      print( 'Could not launch $url');
    }
  }

  showDialogWidget(String loginstr){
    if(buystatus=="0") {
      // ignore: deprecated_member_use
      return showDialog(context: context, child:
      new AlertDialog(
        title: new Text("This feature is only available in the premium plan.",
          style: TextStyle(fontSize: 15.0),),
        content: ButtonBar(
          children: <Widget>[
            FlatButton(
              child: Text('Later'),
              shape: Border.all(),
              onPressed: () {
                Navigator.of(context, rootNavigator: true).pop();
              },
            ),
            RaisedButton(
              child: Text('Pay Now', style: TextStyle(color: Colors.white),),
              color: Colors.orangeAccent,
              onPressed: () {
                Navigator.of(context, rootNavigator: true).pop();
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => PaymentPage()),
                );
              },
            ),
          ],
        ),
      )
      );
    }else{
      return showDialog(context: context, builder:(context) {

        return new AlertDialog(
            title: new Text(
              loginstr,
              style: TextStyle(fontSize: 15.0),),
//            actions:[ButtonBar(
//              children: <Widget>[
//                FlatButton(
//                  child: Text('Later',style: TextStyle(fontSize: 13.0,color: Colors.black,),),
//                  shape: Border.all(),
//                  onPressed: () {
//                    Navigator.of(context, rootNavigator: true).pop();
//                  },
//                ),
//                RaisedButton(
//                  child: Text(
//                    'Login Now', style: TextStyle(color: Colors.white,fontSize: 13.0),),
//                  color: Colors.orangeAccent,
//                  onPressed: () {
//                    Navigator.of(context, rootNavigator: true).pop();
//                    launchMap("https://ubiattendance.ubihrm.com/");
//                  },
//                ),
//              ],
//            ),]
        );
      }
      );
    }
  }


  @override
  Widget build(BuildContext context) {
    return getmainhomewidget();
  }
  void showInSnackBar(String value) {
    final snackBar = SnackBar(
        content: Text(value,textAlign: TextAlign.center,));
    _scaffoldKey.currentState.showSnackBar(snackBar);
  }

  Future<bool> sendToHome() async{

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => HomePage()), (Route<dynamic> route) => false,
    );
    return false;
  }

  getmainhomewidget(){
    return new WillPopScope(
        onWillPop: ()=> sendToHome(),
    child: new Scaffold(
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
          sendToHome();}),
        backgroundColor: Colors.teal,
      ),
      bottomNavigationBar: Bottomnavigationbar(),
      endDrawer: new AppDrawer(),
      body:
      Container(
        padding: EdgeInsets.only(left: 2.0,right: 2.0),
        child: Column(
          children: <Widget>[
            SizedBox(height: 8.0),
            Text('Settings',
              style: new TextStyle(fontSize: 22.0, color: Colors.teal,),),
            SizedBox(height: 5.0),
            new Expanded(
              child: getSettingsWidget(),
            )
          ],
        ),
        ),

      ),
    );

  }
  loader(){
    return new Container(
      child: Center(
        child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              Image.asset(
                  'assets/spinner.gif', height: 80.0, width: 80.0),
            ]),
      ),
    );
  }
  List<Widget> raisedButtonWidget()
  {
    List<Widget> list = new List<Widget>();


    if(admin_sts == '1' || admin_sts == '2'){
      list.add(new RaisedButton(
        child: Container(
          padding: EdgeInsets.only(top: 15.0,bottom: 15.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Icon(const IconData(0xe806, fontFamily: 'CustomIcon'), size: 30.0,),
              SizedBox(width: 20.0,),
              Expanded(
//                            widthFactor: MediaQuery.of(context).size.width*0.10,
                child:Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Container(
                        child: Text('Employees',style: TextStyle(fontWeight:FontWeight.bold,fontSize: 18.0,letterSpacing: 1),)
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 5.0),
                      child: Container(
                          child: Text('Manage Employees ',style: TextStyle(fontSize: 12.0,letterSpacing: 1),)
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.keyboard_arrow_right,size: 30.0,),
            ],
          ),
        ),
        color: Colors.white,
        elevation: 0.0,
        splashColor: splashcolor,
        textColor: textcolor,
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => EmployeeList()),
          );
          // Perform some action
        },
      ));
      list.add( SizedBox(height: 0.0));
    }
    if(facerecognition == 1 && admin_sts=='1')
    list.add(new RaisedButton(
      child: Container(
        padding: EdgeInsets.only(top: 15.0,bottom: 15.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Icon(const IconData(58400, fontFamily: 'MaterialIcons'),size: 30.0,color: Colors.black38,),
            SizedBox(width: 20.0,),
            Expanded(
//                            widthFactor: MediaQuery.of(context).size.width*0.10,
              child:Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Container(
                      child: Text('Face ID',style: TextStyle(fontWeight:FontWeight.bold,fontSize: 18.0,letterSpacing: 1),)
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 5.0),
                    child: Container(
                        child: Text('Manage Face ID ',style: TextStyle(fontSize: 12.0,letterSpacing: 1),)
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.keyboard_arrow_right,size: 30.0,),
          ],
        ),
      ),
      color: Colors.white,
      elevation: 0.0,
      splashColor: splashcolor,
      textColor: textcolor,
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => FaceIdList()),
        );
      },
    ));
    ////// shift button
    if(admin_sts == '1'){
      list.add(new RaisedButton(
        child: Container(
          padding: EdgeInsets.only(top: 15.0,bottom: 15.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Icon(const IconData(0xe800, fontFamily: 'CustomIcon'),size: 30.0,),
              SizedBox(width: 20.0,),
              Expanded(
//                            widthFactor: MediaQuery.of(context).size.width*0.10,
                child:Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Container(
                        child: Text('Shifts',style: TextStyle(fontWeight:FontWeight.bold,fontSize: 18.0,letterSpacing: 1),)
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 5.0),
                      child: Container(
                          child: Text('Manage Shifts ',style: TextStyle(fontSize: 12.0,letterSpacing: 1),)
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.keyboard_arrow_right,size: 30.0,),
            ],
          ),
        ),

        color: Colors.white,
        elevation: 0.0,
        splashColor: splashcolor,
        textColor: textcolor,
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => ShiftList()),
          );
          // Perform some action
          istooltipthreeshown=true;
        },
      ) );

      list.add( SizedBox(height: 0.0));

    }

    ///// department button

    if(admin_sts == '1' ){
      list.add(new RaisedButton(
        child: Container(
          padding: EdgeInsets.only(top: 15.0,bottom: 15.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Icon(const IconData(0xe803, fontFamily: 'CustomIcon'),size: 30.0,),
              SizedBox(width: 20.0,),
              Expanded(
//                            widthFactor: MediaQuery.of(context).size.width*0.10,
                child:Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Container(
                        child: Text('Departments',style: TextStyle(fontWeight:FontWeight.bold,fontSize: 18.0,letterSpacing: 1),)
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 5.0),
                      child: Container(
                          child: Text('Manage Departments ',style: TextStyle(fontSize: 12.0,letterSpacing: 1),)
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.keyboard_arrow_right,size: 30.0,),
            ],
          ),
        ),
        color: Colors.white,
        elevation: 0.0,
        splashColor: splashcolor,
        textColor: textcolor,
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => Department()),
          );
          istooltipfourshown=true;
        },
      ));

      list.add( SizedBox(height: 0.0));

    }



    if(admin_sts == '1'){
      list.add(new RaisedButton(
        child: Container(
          padding: EdgeInsets.only(top: 15.0,bottom: 15.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Icon(const IconData(0xe804, fontFamily: "CustomIcon"),size: 30.0,),
              SizedBox(width: 20.0,),
              Expanded(
//                            widthFactor: MediaQuery.of(context).size.width*0.10,
                child:Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Container(
                        child: Text('Designations',style: TextStyle(fontWeight:FontWeight.bold,fontSize: 18.0,letterSpacing: 1),)
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 5.0),
                      child: Container(
                          child: Text('Manage Designations ',style: TextStyle(fontSize: 12.0,letterSpacing: 1),)
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.keyboard_arrow_right,size: 30.0,),
            ],
          ),
        ),
        color: Colors.white,
        elevation: 0.0,
        splashColor:splashcolor,
        textColor: textcolor,
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => Designation()),
          );
          // Perform some action
          istooltipfiveshown=true;
        },
      ));
      list.add( SizedBox(height: 0.0));
    }


    if(admin_sts == '1'){
      list.add(new RaisedButton(
        child: Container(
          padding: EdgeInsets.only(top: 15.0,bottom: 15.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Icon(const IconData(0xe809, fontFamily: "CustomIcon"),size: 30.0,),
              SizedBox(width: 20.0,),
              Expanded(
                //widthFactor: MediaQuery.of(context).size.width*0.10,
                child:Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Container(
                        child: Text('Holidays',style: TextStyle(fontWeight:FontWeight.bold,fontSize: 18.0,letterSpacing: 1),)
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 5.0),
                      child: Container(
                          child: Text('Configure Holidays',style: TextStyle(fontSize: 12.0,letterSpacing: 1),)
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.keyboard_arrow_right,size: 30.0,),
            ],
          ),
        ),
        color: Colors.white,
        elevation: 0.0,
        splashColor: splashcolor,
        textColor: textcolor,
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => HolidayList()),
          );
          //showDialogWidget("To configure the Holidays, login to the web admin panel.");
          // Perform some action
        },
      ));
      list.add( SizedBox(height: 0.0));
    }

    if(admin_sts == '1'){
      list.add(new RaisedButton(
        child: Container(
          padding: EdgeInsets.only(top: 15.0,bottom: 15.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Icon(const IconData(0xe808, fontFamily: 'CustomIcon'),size: 30.0,),
              SizedBox(width: 20.0,),
              Expanded(
//                            widthFactor: MediaQuery.of(context).size.width*0.10,
                child:Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Container(
                        child: Text('Geo Fence',style: TextStyle(fontWeight:FontWeight.bold,fontSize: 18.0,letterSpacing: 1),)
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 5.0),
                      child: Container(
                          child: Text('Configure Geo Fence ',style: TextStyle(fontSize: 12.0,letterSpacing: 1),)
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.keyboard_arrow_right,size: 30.0,),
            ],
          ),
        ),
        color: Colors.white,
        elevation: 0.0,
        splashColor: splashcolor,
        textColor: textcolor,
        onPressed: () {
          showDialogWidget("To configure Geo Fence, login to the web admin panel");
          // Perform some action
        },
      ));
      list.add( SizedBox(height: 0.0));
    }

    if(permission_module_permission == 1){
      list.add(new RaisedButton(
        child: Container(
          padding: EdgeInsets.only(top: 15.0,bottom: 15.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Icon(Icons.group,size: 30.0,),
              SizedBox(width: 20.0,),
              Expanded(
//                            widthFactor: MediaQuery.of(context).size.width*0.10,
                child:Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Container(
                        child: Text('Permissions',style: TextStyle(fontWeight:FontWeight.bold,fontSize: 18.0,letterSpacing: 1),)
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 5.0),
                      child: Container(
                          child: Text('Manage Permissions ',style: TextStyle(fontSize: 12.0,letterSpacing: 1),)
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.keyboard_arrow_right,size: 30.0,),
            ],
          ),
        ),
        color: Colors.white,
        elevation: 0.0,
        splashColor: splashcolor,
        textColor: textcolor,
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => PermissionPage()),
          );
          //showInSnackBar("Under Development");
        },
      ));
      list.add( SizedBox(height: 0.0));
    }


    list.add( new RaisedButton(
      child: Container(
        padding: EdgeInsets.only(top: 15.0,bottom: 15.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            //Icon(const IconData(0xe802, fontFamily: "CustomIcon"),size: 30.0,),
            Image.asset(
                'assets/icons8-camera-50.png', height: 30.0, width: 30.0,color: Colors.black54,),
            SizedBox(width: 20.0,),
            Expanded(
//                            widthFactor: MediaQuery.of(context).size.width*0.10,
              child:Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Container(
                      child: Text('Camera',style: TextStyle(fontWeight:FontWeight.bold,fontSize: 18.0,letterSpacing: 1),)
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 5.0),
                    child: Container(
                        child: Text('Choose phone camera or ubiAttendance camera',style: TextStyle(fontSize: 12.0,letterSpacing: 1),)
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.keyboard_arrow_right,size: 30.0,),
          ],
        ),
      ),
      color: Colors.white,
      elevation: 0.0,
      splashColor: splashcolor,
      textColor: textcolor,
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => CameraSettings()),
        );
      },
    ));

    list.add(SizedBox(height: 0.0));


/*
    list.add(new RaisedButton(
      child: Container(
        padding: EdgeInsets.only(top: 15.0,bottom: 15.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Icon(const IconData(0xe80b, fontFamily: "CustomIcon"),size: 30.0,),
            SizedBox(width: 20.0,),
            Expanded(
//                            widthFactor: MediaQuery.of(context).size.width*0.10,
              child:Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Container(
                      child: Text('Notifications',style: TextStyle(fontWeight:FontWeight.bold,fontSize: 18.0,letterSpacing: 1),)
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 5.0),
                    child: Container(
                        child: Text('Manage Notifications ',style: TextStyle(fontSize: 12.0,letterSpacing: 1),)
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.keyboard_arrow_right,size: 30.0,),
          ],
        ),
      ),
      color: Colors.white,
      elevation: 0.0,
      splashColor: splashcolor,
      textColor: textcolor,
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => NotificationSettings()),
        );
      },
    ));*/
    if(admin_sts == '1')
    list.add(new RaisedButton(
      child: Container(
        padding: EdgeInsets.only(top: 15.0,bottom: 15.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Icon(const IconData(0xe80b, fontFamily: "CustomIcon"),size: 30.0,),
            SizedBox(width: 20.0,),
            Expanded(
//                            widthFactor: MediaQuery.of(context).size.width*0.10,
              child:Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Container(
                      child: Text('Notifications',style: TextStyle(fontWeight:FontWeight.bold,fontSize: 18.0,letterSpacing: 1),)
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 5.0),
                    child: Container(
                        child: Text('Manage Notifications ',style: TextStyle(fontSize: 12.0,letterSpacing: 1),)
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.keyboard_arrow_right,size: 30.0,),
          ],
        ),
      ),
      color: Colors.white,
      elevation: 0.0,
      splashColor: splashcolor,
      textColor: textcolor,
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => PushNotificationForEmployee()),
        );
      },
    ));

    list.add(new RaisedButton(
      child: Container(
        padding: EdgeInsets.only(top: 15.0,bottom: 15.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Icon(const IconData(0xe80c, fontFamily: "CustomIcon"),size: 30.0,),
            SizedBox(width: 20.0,),
            Expanded(
//                            widthFactor: MediaQuery.of(context).size.width*0.10,
              child:Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Container(
                      child: Text('Profile',style: TextStyle(fontWeight:FontWeight.bold,fontSize: 18.0,letterSpacing: 1),)
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 5.0),
                    child: Container(
                        child: Text('Manage your profile ',style: TextStyle(fontSize: 12.0,letterSpacing: 1),)
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.keyboard_arrow_right,size: 30.0,),
          ],
        ),
      ),
      color: Colors.white,

      elevation: 0.0,
      splashColor: splashcolor,
      textColor: textcolor,
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => ProfilePage()),
        );
      },
    ));
    list.add(SizedBox(height: 0.0));

    list.add( new RaisedButton(
      child: Container(
        padding: EdgeInsets.only(top: 15.0,bottom: 15.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Icon(const IconData(0xe802, fontFamily: "CustomIcon"),size: 30.0,),
            SizedBox(width: 20.0,),
            Expanded(
//                            widthFactor: MediaQuery.of(context).size.width*0.10,
              child:Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Container(
                      child: Text('Password',style: TextStyle(fontWeight:FontWeight.bold,fontSize: 18.0,letterSpacing: 1),)
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 5.0),
                    child: Container(
                        child: Text('Change your password',style: TextStyle(fontSize: 12.0,letterSpacing: 1),)
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.keyboard_arrow_right,size: 30.0,),
          ],
        ),
      ),
      color: Colors.white,
      elevation: 0.0,
      splashColor: splashcolor,
      textColor: textcolor,
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => changePassword()),
        );
      },
    ));

    return list;
  }

  getSettingsWidget(){
    return Container(
      child:
      ListView(
          padding: EdgeInsets.only(left: 5.0,right: 5.0),
          children: raisedButtonWidget()
      ),
    );
  }
}



