import 'dart:ui';

import 'package:Shrine/globals.dart' as prefix0;
import 'package:Shrine/services/services.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:launch_review/launch_review.dart';
import 'package:share/share.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

import 'about_app.dart';
import 'contactUs.dart';
import 'flexi_time.dart';
import 'globals.dart';
import 'home.dart';
import 'login.dart';
import 'notifications.dart';
import 'payment.dart';
import 'profile.dart';
import 'services/services.dart';
import 'userGuide.dart';

class AppDrawer extends StatefulWidget {
  @override
  AppDrawerState createState() => new AppDrawerState();
}

class AppDrawerState extends State<AppDrawer> {
  /*var _defaultimage = new NetworkImage(
      "http://ubiattendance.ubihrm.com/assets/img/avatar.png");*/
  var profileimage;
  bool _checkLoaded = true;
  String fname="";
  String lname="";
  String store="";
  String sstatus="";
  String desination="";
  String profile="";
  int reportper = 0;
  String buystatus = "";
  String trialstatus = "";
  String orgmail = "";
  String empId="";
  Services services=new Services();
  @override
  void initState() {
    super.initState();
    checknetonpage(context);
    initPlatformState();
  }
  String admin_sts='0';
  // Platform messages are asynchronous, so we initialize in an async method.
  initPlatformState() async {
    final prefs = await SharedPreferences.getInstance();
    //String admin= await getUserPerm();
    setState(() {
      admin_sts = prefs.getString('sstatus').toString();
      fname = prefs.getString('fname') ?? '';
      lname = prefs.getString('lname') ?? '';
      store = prefs.getString('store') ?? '';
      empId = prefs.getString("empid")??"0";
      sstatus = (int.parse(prefs.getString('sstatus')))==1 ? 'You have logged in as Admin':'';
      desination = prefs.getString('desination') ?? '';
      profile = prefs.getString('profile') ?? '';
      // reportper = report_permission;
      reportper =int.parse(prefs.getString('sstatus')) ?? 0;
      buystatus = prefs.getString('buysts') ?? '';

      print("Buy Status");
      print(buystatus);


      trialstatus = prefs.getString('trialstatus') ?? '';
      orgmail = prefs.getString('orgmail') ?? '';
      profileimage = new NetworkImage(profile);
      profileimage.resolve(new ImageConfiguration()).addListener(new ImageStreamListener((_, __) {
        if (mounted) {
          setState(() {
            _checkLoaded = false;
          });
        }
      }));
    });
  }

  launchMap(String url) async{
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      print( 'Could not launch $url');
    }
  }

  showDialogWidget(String loginstr, String buystr){
    if(buystatus=="0") {
      // ignore: deprecated_member_use
      return showDialog(context: context, child:
      new AlertDialog(
        title: new Text(buystr,
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
              color: buttoncolor,
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
          content: ButtonBar(
            children: <Widget>[
              FlatButton(
                child: Text('Later',style: TextStyle(fontSize: 13.0)),
                shape: Border.all(),
                onPressed: () {
                  Navigator.of(context, rootNavigator: true).pop();
                },
              ),
              RaisedButton(
                child: Text(
                  'Login Now', style: TextStyle(color: Colors.white,fontSize: 13.0),),
                color: buttoncolor,
                onPressed: () {
                  Navigator.of(context, rootNavigator: true).pop();
                  launchMap("https://ubiattendance.ubihrm.com/");
                },
              ),
            ],
          ),
        );
      }
      );
    }
  }


  @override
  Widget build(BuildContext context){

    return new Drawer(
      child:new ListView(
        children: <Widget>[
          new Container(
            color: appcolor,
            height: sstatus==''?160.0:172.0,
            child: new DrawerHeader(
              child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children:<Widget>[
                    Center(),
                    Column(
                      children: <Widget>[
                        new Stack(
                            children: <Widget>[
                              new Container(
                                  width: 90.0,
                                  height: 90.0,
                                  decoration: new BoxDecoration(
                                      shape: BoxShape.circle,
                                      image: new DecorationImage(
                                        fit: BoxFit.fill,
                                        image: _checkLoaded ? AssetImage('assets/avatar.png') : profileimage,
                                      )
                                  )),
                              new Positioned(
                                right: MediaQuery.of(context).size.width*-.06,
                                top: MediaQuery.of(context).size.height*.07,
                                child: new RawMaterialButton(
                                  onPressed: () {
                                    Navigator.push(context, MaterialPageRoute(builder: (context) => ProfilePage()));
                                  },
                                  child: new Icon(
                                    Icons.edit,
                                    size: 18.0,
                                  ),
                                  shape: new CircleBorder(),
                                  elevation: 0.5,
                                  fillColor: buttoncolor,
                                  padding: const EdgeInsets.all(1.0),
                                ),
                              ),
                            ]),
                        //SizedBox(height: 2.0),
                        //Image.asset('assets/logo.png',height: 150.0,width: 150.0),
                        // SizedBox(height: 5.0),
                        Text("Hi "+fname,style: new TextStyle(fontSize: 20.0,color: Colors.white)),
                        // SizedBox(height: 3.0),
                        Text(desination,style: new TextStyle(fontSize: 12.0,color: Colors.white)),
                        sstatus!=''?Text(sstatus,style: new TextStyle(fontSize: 10.0,color: Colors.white)):Center(),
                      ],
                    ),
                    (buystatus=="0" && reportper==1)?new Column(
                        children:<Widget>[
                          ButtonTheme(
                            minWidth: 60.0,
                            height: 30.0,
                            child:RaisedButton(
                              child: Row(children:<Widget>[Text("Buy Now")]),
                              color: buttoncolor,
                              onPressed: (){
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => PaymentPage()),
                                );
                              },
                              textColor: Colors.white,
                            ),

                          )]):Center(),
                  ]
              ),

            ),
          ),

          new ListTile(
            title: Row(
              children: <Widget>[
                Icon(Icons.home,size: 20.0),SizedBox(width: 5.0),
                new Text('Home', style: new TextStyle(fontSize: 15.0)),
              ],
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => HomePage()),
              );
            },
          ),
          /*  (reportper ==1 || reportper ==2)?new ListTile(
            title: Row(
              children: <Widget>[
                Icon(Icons.library_books,size: 20.0),SizedBox(width: 5.0),
                new Text("Reports", style: new TextStyle(fontSize: 15.0)),
              ],
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => Reports()),
              );
            },
          ):new Center(),
*//*
          flexi_permission ==1 ?
          new ListTile(
            title: Row(
              children: <Widget>[
                Icon(Icons.av_timer,size: 20.0),SizedBox(width: 5.0),
                new Text("Flexi Time ", style: new TextStyle(fontSize: 15.0)),
              ],
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => Flexitime()),
              );
            },
          ):new Center(),
          offline_permission ==1 ?
          new ListTile(
            title: Row(
              children: <Widget>[
                Icon(Icons.shuffle,size: 20.0),SizedBox(width: 5.0),
                new Text("Rejected Attendance Log", style: new TextStyle(fontSize: 15.0)),
              ],
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => Notifications()),
              );
            },
          ):new Center(),*/
          /*(reportper ==1 || reportper ==2)&&geoFence==1?new ListTile(
            title: Row(
              children: <Widget>[
                Icon(Icons.location_on,size: 20.0),SizedBox(width: 5.0),
                new Text("Set Geo Fence", style: new TextStyle(fontSize: 15.0)),
              ],
            ),
            onTap: () {
              showDialogWidget("To set Geo Fence, login to the web admin panel.", "To set Geo Fence upgrade to Premium Plan.");
            },
          ):new Center(),*/
          /*      reportper ==1?new ListTile(
           title: Row(
              children: <Widget>[
                Icon(Icons.attach_money,size: 20.0),SizedBox(width: 5.0),
                new Text("Generate Payroll", style: new TextStyle(fontSize: 15.0)),
              ],
            ),
            onTap: () {
              showDialogWidget("To Generate Payroll, Login to the web panel.", "To Generate Payroll upgrade to Premium Plan.");
            },
          ):new Center(),*/
          /*  (reportper ==1 || reportper ==2)?new ListTile(
            title: Row(
              children: <Widget>[
                Icon(Icons.camera,size: 20.0),SizedBox(width: 5.0),
                new Text("Generate QR Code", style: new TextStyle(fontSize: 15.0)),
              ],
            ),
            onTap: () {
              showDialogWidget("To Generate QR Code of Employee, Login to the web panel.", "To Generate QR Code of Employee upgrade to Premium Plan.");
            },
          ):new Center(),*/
          /* new ListTile(
            title: Row(
              children: <Widget>[
                Icon(Icons.account_box,size: 20.0),SizedBox(width: 5.0),
                new Text("Profile", style: new TextStyle(fontSize: 15.0)),
              ],
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => MyApp()),
              );
            },
          ),*/
          /*     new ListTile(
            title: Row(
              children: <Widget>[
                Icon(Icons.perm_contact_calendar,size: 20.0),SizedBox(width: 5.0),
                new Text("Employee History", style: new TextStyle(fontSize: 15.0)),
              ],
            ),
            onTap: () {
              /*
              getUserPerm().then((res){
                print('func called with response: '+res);
              });*/


              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => MyApp()),
              );

            },
          ),*/
          /*   new ListTile(
            title: Row(
              children: <Widget>[
                Icon(Icons.location_city,size: 20.0),SizedBox(width: 5.0),
                new Text("Organization", style: new TextStyle(fontSize: 15.0)),
              ],
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => MyApp()),
              );
            },
          ),*/
          /*  new ListTile(
            title: Row(
              children: <Widget>[
                Icon(Icons.settings,size: 20.0),SizedBox(width: 5.0),
                new Text("Settings", style: new TextStyle(fontSize: 15.0)),
              ],
            ),
            onTap: () {
             // Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => Settings()),
              );
            },
          ),*/
          (admin_sts==0)?
          new ListTile(
            title: Row(
              children: <Widget>[
                Icon(Icons.share,size: 20.0),SizedBox(width: 5.0),
                new Text("Share App", style: new TextStyle(fontSize: 15.0)),
              ],
            ),
            onTap: () {
              final RenderBox box = context.findRenderObject();
              Share.share("Check out ubiAttendance App. I use it to track attendance and visits of my employees. Get it for free at \n"+store,
                  sharePositionOrigin:
                  box.localToGlobal(Offset.zero) &
                  box.size);
            },
          ):new ListTile(
            title: Row(
              children: <Widget>[
                Icon(Icons.share,size: 20.0),SizedBox(width: 5.0),
                new Text("Share and Earn", style: new TextStyle(fontSize: 15.0)),
              ],
            ),
            onTap: () async {
              generateAndShareReferralLink();

            },
          ),
          new ListTile(
            title: Row(
              children: <Widget>[
                Icon(Icons.star,size: 20.0),SizedBox(width: 5.0),
                new Text("Rate Us", style: new TextStyle(fontSize: 15.0)),
              ],
            ),
            onTap: () {
              prefix0.facebookChannel.invokeMethod("logRateEvent");
              LaunchReview.launch(
                  androidAppId: "org.ubitech.attendance"
              );
            },
          ),

          /*  new ListTile(
            title: Row(
              children: <Widget>[
                Icon(Icons.security,size: 20.0),SizedBox(width: 5.0),
                new Text("Privacy Policy", style: new TextStyle(fontSize: 14.0)),
              ],
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => MyAppPolicy()),
              );
            },
          ), */
          new ListTile(
            title: Row(
              children: <Widget>[
                Icon(Icons.import_contacts,size: 20.0),SizedBox(width: 5.0),
                new Text("User Guide", style: new TextStyle(fontSize: 14.0)),
              ],
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => UserGuide()),
              );
            },
          ),
          /*  new ListTile(
            title: Row(
              children: <Widget>[
                Icon(Icons.location_on,size: 20.0),SizedBox(width: 5.0),
                new Text("About Us", style: new TextStyle(fontSize: 14.0)),
              ],
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => MyAppAbout()),
              );
            },
          ),*/
          /* (admin_sts=='1' && buystatus != '0')?
          new ListTile(
            title: Row(
              children: <Widget>[
                Icon(Icons.help,size: 20.0),SizedBox(width: 5.0),
                new Text("Help", style: new TextStyle(fontSize: 15.0)),
              ],
            ),
            onTap: () {
              openWhatsApp();
            },
          ):Center(),*/
/*
          new ListTile(
            title: Row(
              children: <Widget>[
                Icon(Icons.contact_phone,size: 20.0),SizedBox(width: 5.0),
                new Text("Contact Us", style: new TextStyle(fontSize: 15.0)),
              ],
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ContactUs()),
              );
            },
          ),
*/

          new ListTile(
            title: Row(
              children: <Widget>[
                Icon(Icons.perm_device_information,size: 20.0),SizedBox(width: 5.0),
                new Text('About', style: new TextStyle(fontSize: 15.0)),
              ],
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => AboutApp()),
              );
            },
          ),
          new ListTile(
            title: Row(
              children: <Widget>[
                Icon(Icons.exit_to_app,size: 20.0),SizedBox(width: 5.0),
                new Text("Log out", style: new TextStyle(fontSize: 15.0)),
              ],
            ),
            onTap: () {
              logout();
            },
          ),

        ],
      ),
    );
  }

  openWhatsApp() async{

    prefix0.facebookChannel.invokeMethod("logContactEvent");

    print("Language is "+window.locale.countryCode);
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var name=prefs.getString("fname")??"";
    var org_name= prefs.getString('org_name') ?? '';
    String country=window.locale.countryCode;
    var message;

    message="Hello%20I%20am%20"+name+"%20from%20"+org_name+"%0AI%20need%20some%20help%20regarding%20ubiAttendance%20app";

    var url;
    if(country=="IN")
      url = "https://wa.me/917067822132?text="+message;
    else{
      url = "https://wa.me/971555524131?text="+message;
    }
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch Maps';
    }
  }

  FirebaseMessaging _firebaseMessaging = FirebaseMessaging();

  logout() async{
    final prefs = await SharedPreferences.getInstance();
    String countryTopic=prefs.get('CountryName')??'admin';
    String orgTopic=prefs.get('OrgTopic')??'admin';
    String currentOrgStatus=prefs.get('CurrentOrgStatus')??'admin';
    String employeeTopic = prefs.getString("EmployeeTopic") ?? '';
    prefs.remove('response');
    prefs.remove('fname');
    prefs.remove('lname');
    prefs.remove('empid');
    prefs.remove('email');
    prefs.remove('status');
    prefs.remove('sstatus');
    prefs.remove('orgid');
    prefs.remove('orgdir');
    prefs.remove('sstatus');
    prefs.remove('org_name');
    prefs.remove('destination');
    prefs.remove('profile');
    prefs.remove('latit');
    prefs.remove('longi');
    prefs.remove('aid');
    prefs.remove('shiftId');
    prefs.remove('OfflineModePermission');
    prefs.remove('ImageRequired');
    prefs.remove('glow');
    prefs.remove('OrgTopic');
    prefs.remove('CountryName');
    prefs.remove('CurrentOrgStatus');
    prefs.remove('date');
    prefs.remove('firstAttendanceMarked');
    prefs.remove('EmailVerifacitaionReminderShown');
    prefs.remove('companyFreshlyRegistered');
    prefs.remove('fname');
    prefs.remove('empid');
    prefs.remove('orgid');
    prefs.remove('ReferralValidFrom');
    prefs.remove('glow');
    prefs.remove('ReferralValidTo');
    prefs.remove('referrerAmt');
    prefs.remove('referrenceAmt');
    prefs.remove('referrerId');
    prefs.remove('TimeInTime');
    prefs.remove('showAppInbuiltCamera');
    prefs.remove('ShiftAdded');
    prefs.remove('EmployeeAdded');
    prefs.remove('attendanceNotMarkedButEmpAdded');
    prefs.remove('tool');
    prefs.remove('companyFreshlyRegistered');
    prefs.remove('showAppInbuiltCamera');
    prefs.remove('showPhoneCamera');

    _firebaseMessaging.unsubscribeFromTopic(employeeTopic.replaceAll(' ', ''));
    _firebaseMessaging.unsubscribeFromTopic("admin");
    _firebaseMessaging.unsubscribeFromTopic("employee");
    _firebaseMessaging.unsubscribeFromTopic(countryTopic.replaceAll(' ', ''));
    _firebaseMessaging.unsubscribeFromTopic(orgTopic.replaceAll(' ', ''));
    _firebaseMessaging.unsubscribeFromTopic(currentOrgStatus.replaceAll(' ', ''));




    //prefs.remove("TimeInToolTipShown");
    department_permission = 0;
    designation_permission = 0;
    leave_permission = 0;
    shift_permission = 0;
    timeoff_permission = 0;
    punchlocation_permission = 0;
    employee_permission = 0;
    permission_module_permission = 0;
    report_permission = 0;
    /* Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => LoginPage()),
    );*/
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => LoginPage()), (Route<dynamic> route) => false,
    );
    //Navigator.pushNamed(context, '/home');
    // Navigator.pushNamed(context, '/home');
  }


}