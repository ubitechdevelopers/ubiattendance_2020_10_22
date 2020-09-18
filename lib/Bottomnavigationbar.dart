
import 'package:Shrine/attendance_logs_for_flexi_shift.dart';
import 'package:Shrine/attendance_summary.dart';
import 'package:Shrine/globals.dart' as prefix0;
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'AdminShiftCalendar.dart';
//import 'NewHomePage.dart';
import 'ShiftPlannerList.dart';
import 'UserShiftCalendar.dart';
import 'globals.dart';
import 'globals.dart';
import 'home.dart';
import 'profile.dart';
import 'reports.dart';
import 'settings.dart';

class Bottomnavigationbar extends StatefulWidget {
  @override
  _Bottomnavigationbar createState() => new _Bottomnavigationbar();
}
class _Bottomnavigationbar extends State<Bottomnavigationbar> {
  String admin_sts='0';
  var _currentIndex=1;



  // Platform messages are asynchronous, so we initialize in an async method.
  initPlatformState() async {
    final prefs = await SharedPreferences.getInstance();
    //String admin= await getUserPerm();
    setState(() {
      admin_sts=prefs.getString('sstatus').toString();

    });
  }

  void initState() {
    initPlatformState();
  }

  @override
  Widget build(BuildContext context) {
    return new BottomNavigationBar(
      backgroundColor: Colors.teal,
      currentIndex: _currentIndex,
//      fixedColor: Colors.yellowAccent,
      type: BottomNavigationBarType.fixed,
      onTap: (newIndex) {
        if(newIndex==0){
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => HomePage()),
          );
          return;
        }else if (newIndex == 1) {
          (admin_sts == '1' || admin_sts == '2')
              ? Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => Reports()),
          )
              : Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => ProfilePage()),
          );
          return;
        }else if (newIndex == 2) {

          if(shiftType.toString()=='3'){
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => MyAppFlexi()),
            );

          }
          else{
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => userShiftCalendar()),
            );

          }


          return;
        }
        if(newIndex==3){
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => Settings()),
          );
          return;
        }
        /*else if(newIndex == 3){
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => Notifications()),
            );

          }*/
        setState((){_currentIndex = newIndex;});

      }, // this will be set when a new tab is tapped
      items:  [
        BottomNavigationBarItem(
          icon: new Icon(Icons.home,color: Colors.white,size: 30.0,),
          title: new Text('Home', textAlign: TextAlign.center,style: TextStyle(color: Colors.white,)),
        ),

        (admin_sts == '1' || admin_sts == '2' )
            ? BottomNavigationBarItem(
          icon:new Icon(Icons.library_books,color: Colors.white,size: 30.0),
          title: new Text('Reports',style: TextStyle(color: Colors.white,)),
        )
            : BottomNavigationBarItem(
          icon: new Icon(
              Icons.person, color: Colors.white,size: 30.0),
          title: new Text('Profile',style: TextStyle(color: Colors.white,)),
        ),
        BottomNavigationBarItem(
          icon:new Icon(Icons.date_range,color: Colors.white,size: 30.0),
          title: new Text('Log', textAlign: TextAlign.center,style: TextStyle(color: Colors.white,)),
        ),
        BottomNavigationBarItem(
            icon: Icon(Icons.settings,color: Colors.white,size: 30.0),
            title: Text('Settings',style: TextStyle(color: Colors.white,)
        )),
        /* BottomNavigationBarItem(
              icon: Icon(
                Icons.notifications
                ,color: Colors.black54,
              ),
              title: Text('Notifications',style: TextStyle(color: Colors.black54))),*/
      ],
    );
  }



}

