import 'dart:convert';
import 'dart:math';
import 'package:Shrine/globals.dart' as globals;
import 'package:dio/dio.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../globals.dart';
import '../login.dart';

class Home{
  var dio = new Dio();


  updateTimeOut(String empid, String orgid) async{
    try{
    /*
      FormData formData = new FormData.from({
        "uid": empid,
        "refno": orgid,
      });*/

      print(globals.path+"updatetimeout?uid=$empid&refno=$orgid");

      Response response = await dio.post(globals.path+"updatetimeout?uid=$empid&refno=$orgid");

    }catch(e)
    {
      print(e.toString());
    }
  }

  checkTimeIn(String empid, String orgid,context) async{
    try {

      final prefs = await SharedPreferences.getInstance();
     /* prefs.getKeys();
      prefs.remove('aid');*/
      /*prefs.remove("aid");
      prefs.commit();*/
      //print(prefs.getString('aid'));
      FormData formData = new FormData.from({
        "uid": empid,
        "refno": orgid,
      });
      print(globals.path+"getInfo?uid=$empid&refno=$orgid");
      //Response response = await dio.post("https://sandbox.ubiattendance.com/index.php/services/getInfo", data: formData);
      Response response = await dio.post(globals.path+"getInfo", data: formData);
      print("<<------------------GET HOME-------------------->>");
      print(response.toString());
      print("this is status "+response.statusCode.toString());
      if (response.statusCode == 200) {

        Map timeinoutMap = json.decode(response.data);
        if(timeinoutMap['inactivestatus'] == 'inactive') {
          logout(context);
          return;
        }
        String aid = timeinoutMap['aid'].toString();
        print('aid'+aid);
        print("Timeoutdate "+timeinoutMap['timeoutdate'].toString());
        String sstatus = timeinoutMap['sstatus'].toString();
        String ReferrerDiscount = timeinoutMap['ReferrerDiscount'].toString()??"1%";
        String ReferrenceDiscount = timeinoutMap['ReferrenceDiscount'].toString()??"1%";
        String ReferralValidity = timeinoutMap['ReferralValidity'].toString()??"";
        String ReferralValidFrom = timeinoutMap['ReferralValidFrom'].toString()??"";
        String ReferralValidTo = timeinoutMap['ReferralValidTo'].toString()??"";
        String mail_varified = timeinoutMap['mail_varified'].toString();
        String profile = timeinoutMap['profile'].toString();
        String newpwd = timeinoutMap['pwd'].toString();
        String password_sts = timeinoutMap['password_sts'].toString(); //somya
        String changepasswordStatus = timeinoutMap['admin_password_sts'].toString();
        print('beforepushnotification');

        //////////////////// Push Notification Status ///////////////////////

        UnderTime = int.parse(timeinoutMap['UnderTime'])??0;
        Visit = int.parse(timeinoutMap['Visit'])??0;
        OutsideGeofence=int.parse(timeinoutMap['OutsideGeofence'])??0;
        FakeLocation=int.parse(timeinoutMap['FakeLocation'])??0;
        FaceIdReg=int.parse(timeinoutMap['FaceIdReg'])??0;
        FaceIdDisapproved=int.parse(timeinoutMap['FaceIdDisapproved'])??0;
        SuspiciousSelfie = int.parse(timeinoutMap['SuspiciousSelfie'])??0;
        SuspiciousDevice = int.parse(timeinoutMap['SuspiciousDevice'])??0;
        DisapprovedAtt = int.parse(timeinoutMap['DisapprovedAtt'])??0;
        AttEdited = int.parse(timeinoutMap['AttEdited'])??0;
        ChangedPassword = int.parse(timeinoutMap['ChangedPassword'])??0;
        TimeOffStartStatus = int.parse(timeinoutMap['TimeOffStart'])??0;
        TimeOffEndStatus = int.parse(timeinoutMap['TimeOffEnd'])??0;

        UnderTimeMessage = timeinoutMap['UnderTimeMessage'].toString();
        VisitMessage = timeinoutMap['VisitMessage'].toString();
        OutsideGeofenceMessage=timeinoutMap['OutsideGeofenceMessage'].toString();
        FakeLocationMessage=timeinoutMap['FakeLocationMessage'].toString();
        FaceIdRegMessage=timeinoutMap['FaceIdRegMessage'].toString();
        FaceIdDisapprovedMessage=timeinoutMap['FaceIdDisapprovedMessage'].toString();
        SuspiciousSelfieMessage = timeinoutMap['SuspiciousSelfieMessage'].toString();
        SuspiciousDeviceMessage = timeinoutMap['SuspiciousDeviceMessage'].toString();
        DisapprovedAttMessage = timeinoutMap['DisapprovedAttMessage'].toString();
        AttEditedMessage = timeinoutMap['AttEditedMessage'].toString();
        ChangedPasswordMessage = timeinoutMap['ChangedPasswordMessage'].toString();
        TimeOffStartStatusMessage = timeinoutMap['TimeOffStartStatusMessage'].toString();
        TimeOffEndStatusMessage = timeinoutMap['TimeOffEndStatusMessage'].toString();



        //////////////////// Push Notification Status ///////////////////////

        print('afterpushnotification');

        String org_country = timeinoutMap['orgcountry'].toString();
        prefs.setString('countrycode',timeinoutMap['countrycode']);
        int Is_Delete = int.parse(timeinoutMap['Is_Delete']);
        globals.departmentname = timeinoutMap['departmentname'].toString();
        globals.timeoutdate = timeinoutMap['timeoutdate'].toString();
        globals.departmentid = int.parse(timeinoutMap['departmentid']);
        globals.defaultShiftTimings = timeinoutMap['defaultShiftTimings'];
        globals.shiftId = timeinoutMap['shiftId'];
        globals.shiftType = timeinoutMap['ShiftType'];
        globals.designationid = int.parse(timeinoutMap['designationid']);
        print("Testing line");
        globals.bulkAttn=int.parse(timeinoutMap['Addon_BulkAttn']);
        globals.geoFence=int.parse(timeinoutMap['Addon_GeoFence']);
        globals.tracking=int.parse(timeinoutMap['Addon_Tracking']);
        globals.payroll=int.parse(timeinoutMap['Addon_Payroll']);
        globals.ShiftPlanner=int.parse(timeinoutMap['Addon_ShiftPlanner'])??0;

        print("Testing line11111111111111111111111111111"+globals.shiftType);
        print("Testing line1");
        globals.visitpunch=int.parse(timeinoutMap['Addon_VisitPunch']);
        globals.timeOff=int.parse(timeinoutMap['Addon_TimeOff']);
        globals.flexi_permission=int.parse(timeinoutMap['Addon_flexi_shif']);
        globals.offline_permission=int.parse(timeinoutMap['Addon_offline_mode']);
        globals.deviceverification=int.parse(timeinoutMap['Addon_DeviceVerification']);
        globals.facerecognition=int.parse(timeinoutMap['Addon_FaceRecognition'])??0;
        globals.covidsurvey=int.parse(timeinoutMap['addon_COVID19']);
        globals.BasicLeave=int.parse(timeinoutMap['Addon_BasicLeave'])??0;
        globals.persistedface=timeinoutMap['persistedface'].toString();
        globals.deviceid=timeinoutMap['deviceid'].toString();
        globals.visitImage=int.parse(timeinoutMap['visitImage']);

        globals.userlimit=int.parse(timeinoutMap['User_limit']);
        globals.registeruser=int.parse(timeinoutMap['registeremp']);
        globals.locationTrackingAddon=timeinoutMap['addon_livelocationtracking'];
        globals.trackLocationForCurrentUser=timeinoutMap['TrackLocationEnabled'];

        print("Testing line2");
        globals.attImage=int.parse(timeinoutMap['attImage']);
        print("Testing line3");
        globals.ableToMarkAttendance = int.parse(timeinoutMap['ableToMarkAttendance']);
        globals.areaId=int.parse(timeinoutMap['areaId']);
        print("Testing line4");

        print("Area Id :"+globals.areaId.toString()+" geofence :"+globals.geoFence.toString());
        prefs.setString('buysts', timeinoutMap["buysts"]);
        prefs.setString("nextWorkingDay", timeinoutMap['nextWorkingDay']);
        prefs.setString("ReferralValidFrom", ReferralValidFrom);
        prefs.setString("ReferralValidTo", ReferralValidTo);
        prefs.setInt("OfflineModePermission", int.parse(timeinoutMap['Addon_offline_mode']));
        prefs.setInt("ImageRequired", int.parse(timeinoutMap['attImage']));
        prefs.setInt("VisitImageRequired", int.parse(timeinoutMap['visitImage']));
        globals.assigned_lat=  (timeinoutMap['assign_lat']).toDouble();
        globals.assigned_long=    (timeinoutMap['assign_long']).toDouble();
        globals.assign_radius=  (timeinoutMap['assign_radius']).toDouble();
        print("----visitImage------>"+globals.visitImage.toString());
      //  print(newpwd+" new pwd  and old pwd "+  prefs.getString('userpwd'));
       // print(timeinoutMap['pwd']);
        prefs.setString('covid_first', timeinoutMap['covid_first'].toString());
        prefs.setString('covid_second', timeinoutMap['covid_second'].toString());
        prefs.setString("ReferrerDiscount", ReferrerDiscount);
        prefs.setString("ReferrenceDiscount", ReferrenceDiscount);
        prefs.setString("ReferralValidity", ReferralValidity);
        prefs.setString("ReferralValidFrom", ReferralValidFrom);
        prefs.setString("ReferralValidTo", ReferralValidTo);
        prefs.setString('aid', aid);
        prefs.setString('sstatus', sstatus);
        prefs.setString('mail_varified', mail_varified);
        prefs.setString('OrgTopic', timeinoutMap['OrgTopic']);
        prefs.setString('profile', profile);
        prefs.setString('newpwd', newpwd);

        prefs.setString("password_sts",password_sts);
        prefs.setString("admin_password_sts",changepasswordStatus);

        prefs.setString('org_country',org_country);
        prefs.setString('shiftId', timeinoutMap['shiftId']);
        prefs.setString('leavetypeid', timeinoutMap['leavetypeid']);
        prefs.setString('ShiftTimeOut', timeinoutMap['ShiftTimeOut']);
        prefs.setString('ShiftTimeIn', timeinoutMap['ShiftTimeIn']);
        prefs.setString('nextWorkingDay', timeinoutMap['nextWorkingDay']);
        prefs.setString('CountryName', timeinoutMap['CountryName']);
        globals.globalCountryTopic=timeinoutMap['CountryName'].toString();
        globals.globalOrgTopic= timeinoutMap['OrgTopic'].toString();
        globals.globalEmployeeTopic= timeinoutMap['EmployeeTopic'].toString();
        print('countru name'+timeinoutMap['CountryName'].toString());

        prefs.setString('OutPushNotificationStatus', timeinoutMap['OutPushNotificationStatus']);
        prefs.setString('TimeInTime', timeinoutMap['TimeInTime']);
        prefs.setString('InPushNotificationStatus', timeinoutMap['InPushNotificationStatus']);
        print("Next working day"+timeinoutMap['nextWorkingDay']);
        prefs.setInt('Is_Delete', Is_Delete);
        print('lastact'+prefs.getString('aid'));

        globals.currentOrgStatus=timeinoutMap['CurrentOrgStatus'];
        String createdDate = timeinoutMap['CreatedDate'].toString();
        prefs.setString('CreatedDate',createdDate);
        globals.inactivestatus=timeinoutMap['inactivestatus'];

       /* if(timeinoutMap['inactivestatus'] == 'inactive') {
          print("somya code");
          logout(context);
          print("logout called");
          return;
        }*/
        String orgid = prefs.getString('orgdir') ?? '';
       // if(orgid =='10932') { // this calculation only for welspun
          List areaids = json.decode(timeinoutMap['areaIds']);
          double calculateDistance(lat1, lon1, lat2, lon2) {
            var p = 0.017453292519943295;
            var c = cos;
            var a = 0.5 - c((lat2 - lat1) * p) / 2 +
                c(lat1 * p) * c(lat2 * p) * (1 - c((lon2 - lon1) * p)) / 2;
            return 12742 * asin(sqrt(a));
          }
          double totalDistance = 0.0;
          double lat = globals.assign_lat;
          double long = globals.assign_long;
          for (var i = 0; i < areaids.length; i++) {
            double user_lat = double.parse(areaids[i]['lat']);
            double user_long = double.parse(areaids[i]['long']);
            globals.assign_radius = double.parse(areaids[i]['radius']);

            double Temp_totalDistance = calculateDistance(
                user_lat, user_long, lat, long);
            if (i == 0) {
              totalDistance = Temp_totalDistance;
              globals.areaId = int.parse(areaids[i]['id']);
              globals.assigned_lat = double.parse(areaids[i]['lat']);
              globals.assigned_long = double.parse(areaids[i]['long']);
              globals.assign_radius = double.parse(areaids[i]['radius']);
            }
            else {
              if (totalDistance > Temp_totalDistance) {
                totalDistance = Temp_totalDistance;
                globals.areaId = int.parse(areaids[i]['id']);
                print("Area Id :"+globals.areaId.toString());
                globals.assigned_lat = double.parse(areaids[i]['lat']);
                globals.assigned_long = double.parse(areaids[i]['long']);
                globals.assign_radius = double.parse(areaids[i]['radius']);
              }
            }
          }
      //  }
        return timeinoutMap['act'];
      }
      else {
        print('8888');
        return "Poor network connection";
      }
    }catch(e){
      print('9999');
     print(e.toString());
      return "Poor network connection";
    }
  }

  showPopupForReferral(var createdDate){

  }


  managePermission(String empid, String orgid, String designation) async{
//print("This is called manage permissions-------------------->");
    /*Comment permission module below as per discussion with badi ma'am @ 5 nov- Abhinav*/
   /* try {
      final prefs = await SharedPreferences.getInstance();
      FormData formData = new FormData.from({
        "uid": empid,
        "refid": orgid,
        "roleid": designation
      });

      Response response = await dio.post(
          globals.path+"getUserPermission",
          data: formData
      );

      //print("<<------------------GET USER PERMISSION-------------------->>");
      //print(response.toString());
      //print("this is user permission "+response.statusCode.toString());
      if (response.statusCode == 200) {
        Map permissionMap = json.decode(response.data.toString());
        //print(permissionMap["userpermission"]["DepartmentMaster"]);
        globals.department_permission = permissionMap["userpermission"]["DepartmentMaster"]==1 ? permissionMap["userpermission"]["DepartmentMaster"]: 0;
        globals.designation_permission = permissionMap["userpermission"]["DesignationMaster"]==1 ? permissionMap["userpermission"]["DesignationMaster"]: 0;
        globals.leave_permission = permissionMap["userpermission"]["EmployeeLeave"]==1 ? permissionMap["userpermission"]["EmployeeLeave"]: 0;
        globals.shift_permission = permissionMap["userpermission"]["ShiftMaster"]==1 ? permissionMap["userpermission"]["ShiftMaster"]: 0;
        globals.timeoff_permission = permissionMap["userpermission"]["Timeoff"]==1 ? permissionMap["userpermission"]["Timeoff"]: 0;
        globals.punchlocation_permission = permissionMap["userpermission"]["checkin_master"]==1 ? permissionMap["userpermission"]["checkin_master"]: 0;
        globals.employee_permission = permissionMap["userpermission"]["EmployeeMaster"]==1 ? permissionMap["userpermission"]["EmployeeMaster"]: 0;
        globals.permission_module_permission = permissionMap["userpermission"]["UserPermission"]==1 ? permissionMap["userpermission"]["UserPermission"]: 0;
        globals.report_permission = permissionMap["userpermission"]["ReportMaster"]==1 ? permissionMap["userpermission"]["ReportMaster"]: 0;
      } else {
        return "Poor network connection";
      }
    }catch(e){
      //print(e.toString());
      return "Poor network connection";
    }*/

   /*Putting Admin_sts instead of permissions*/
    final prefs = await SharedPreferences.getInstance();
    String admin_sts=prefs.getString('sstatus') ?? '0';
    //print("---------> this is admin status from get home "+admin_sts);
    if(admin_sts=='1'){
      globals.department_permission = 1;
      globals.designation_permission = 1;
      //globals.leave_permission = 1;
      globals.shift_permission = 1;
      globals.timeoff_permission = 1;
      globals.punchlocation_permission = 1;
      globals.employee_permission = 1;
      //globals.permission_module_permission = 1;
      globals.report_permission = 1;
    }
  }



  checkTimeInQR(String empid, String orgid) async{

    try {
      final prefs = await SharedPreferences.getInstance();

      FormData formData = new FormData.from({
        "uid": empid,
        "refid": orgid,
      });
      //Response response = await dio.post("https://sandbox.ubiattendance.com/index.php/services/getInfo", data: formData);
      print(globals.path+"getInfo?uid=$empid&refid=$orgid");
      Response response = await dio.post(globals.path+"getInfo", data: formData);

      //Response response = await dio.post("http://192.168.0.20 0/UBIHRM/HRMINDIA/services/getInfo", data: formData);
      //Response response = await dio.post("https://ubitech.ubihrm.com/services/getInfo", data: formData);

         print(response.toString());
      //print("this is status "+response.statusCode.toString());
      if (response.statusCode == 200) {
        Map timeinoutMap = json.decode(response.data);
        /*Loc lock = new Loc();
        Map location = await lock.fetchlatilongi();*/
        String lat="",long="";
        String streamlocationaddr = "";
        if(globals.assign_lat!=null ||globals.assign_lat!=0.0 ) {

          lat = globals.assign_lat.toString();
          long = globals.assign_long.toString();
          streamlocationaddr = globals.globalstreamlocationaddr;

          print("--------------------------- Location detection for qr-----------------------------------");
          print(lat+""+long);
          print(streamlocationaddr);

          print("--------------------------- Location detection for qr-----------------------------------");
          timeinoutMap.putIfAbsent('latit', ()=> lat );
          timeinoutMap.putIfAbsent('longi', ()=> long );
        }else{
          timeinoutMap.putIfAbsent('latit', ()=> 0.0 );
          timeinoutMap.putIfAbsent('longi', ()=> 0.0 );
        }
        timeinoutMap.putIfAbsent('location', ()=> streamlocationaddr );
        timeinoutMap.putIfAbsent('uid', ()=> empid );
        timeinoutMap.putIfAbsent('refid', ()=> orgid );
        return timeinoutMap;
      } else {
        return "Poor network connection";
      }
    }catch(e){
      //print(e.toString());
      return "Poor network connection";
    }
  }

  FirebaseMessaging _firebaseMessaging = FirebaseMessaging();

  logout(context) async{
    final prefs = await SharedPreferences.getInstance();
    String countryTopic=prefs.get('CountryName')??'admin';
    String orgTopic=prefs.get('OrgTopic')??'admin';
    String currentOrgStatus=prefs.get('CurrentOrgStatus')??'admin';
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

    _firebaseMessaging.unsubscribeFromTopic("admin");
    _firebaseMessaging.unsubscribeFromTopic("employee");

    if(countryTopic != null)
    _firebaseMessaging.unsubscribeFromTopic(countryTopic.replaceAll(' ', ''));
    if(orgTopic!=null)
    _firebaseMessaging.unsubscribeFromTopic(orgTopic.replaceAll(' ', ''));
    if(currentOrgStatus!=null)
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

    Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => LoginPage()), (Route<dynamic> route) => false,
    );
    //Navigator.pushNamed(context, '/home');
    // Navigator.pushNamed(context, '/home');
  }



}