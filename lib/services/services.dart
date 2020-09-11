import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math' show cos, sqrt, asin;
import 'dart:math' show Random, asin, cos, sqrt;
import 'package:Shrine/globals.dart' as globals;
import 'package:Shrine/globals.dart';
import 'package:Shrine/model/model.dart';
import 'package:Shrine/offline_home.dart';
import 'package:android_intent/android_intent.dart';
import 'package:csv/csv.dart';
import 'package:dio/dio.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:geocoder/geocoder.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:share/share.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import '../home.dart';
import '../today_attendance_report.dart';


class Services {}


////////////////////Shashank///////////////////////////////

bool isOfflineHomeRedirected=false;
String trialstatus = '';

var refererId="0";

void initDynamicLinks() async {
  final PendingDynamicLinkData data = await FirebaseDynamicLinks.instance.getInitialLink();
  final Uri deepLink = data?.link;
  String ReferralValidFrom;
  String ReferralValidTo;
  String referrerAmt;
  String referrenceAmt;


  if (deepLink != null) {
    print("Deep Link"+deepLink.path);

    refererId=deepLink.path.split("/")[1];

    ReferralValidFrom=deepLink.path.split("/")[2];
    ReferralValidTo=deepLink.path.split("/")[3];
    referrerAmt=deepLink.path.split("/")[4].split('%')[0];
    referrenceAmt=deepLink.path.split("/")[5].split('%')[0];
    SharedPreferences prefs=await SharedPreferences.getInstance();

    prefs.setString("ReferralValidFrom", ReferralValidFrom.toString());
    prefs.setString("ReferralValidTo", ReferralValidTo.toString());
    prefs.setString("referrerAmt", referrerAmt.toString());
    prefs.setString("referrenceAmt", referrenceAmt.toString());
    prefs.setString("referrerId", refererId.toString());
    print("refeeeeeeeeeeeeeeeeeeeeeeeeeeee:   "+refererId+" "+ReferralValidFrom+" "+ReferralValidTo+" "+referrerAmt+" "+referrenceAmt);
  }




  FirebaseDynamicLinks.instance.onLink(
      onSuccess: (PendingDynamicLinkData dynamicLink) async {
        final Uri deepLink = dynamicLink?.link;

        if (deepLink != null) {
          print("Deep Link"+deepLink.path);

          refererId=deepLink.path.split("/")[1];

          ReferralValidFrom=deepLink.path.split("/")[2];
          ReferralValidTo=deepLink.path.split("/")[3];
          referrerAmt=deepLink.path.split("/")[4].split('%')[0]+'%';
          referrenceAmt=deepLink.path.split("/")[5].split('%')[0]+'%';
          SharedPreferences prefs=await SharedPreferences.getInstance();

          prefs.setString("referrerId", refererId.toString());
          print("refeeeeeeeeeeeeeeeeeeeeeeeeeeee:   "+refererId+" "+ReferralValidFrom+" "+ReferralValidTo+" "+referrerAmt+" "+referrenceAmt);
        }
      },
      onError: (OnLinkErrorException e) async {
        print('onLinkError');
        print(e.message);
      }
  );




}


navigateToPageAfterNotificationClicked(var pageString, BuildContext context){

  if(pageString=='reports'){
    Navigator.of(context).pushReplacement(new MaterialPageRoute(builder: (BuildContext context) => TodayAttendance(),maintainState: false));
  }

}

storeDeviceInfo(empid,deviceid,devicename) async{
  try{
    Dio dio = new Dio();
    /*
      FormData formData = new FormData.from({
        "uid": empid,
        "refno": orgid,
      });*/

    print(globals.path+"storedeviceinfo?empid=$empid&deviceid=$deviceid&devicename=$devicename");
    await dio.post(globals.path+"storedeviceinfo?empid=$empid&deviceid=$deviceid&devicename=$devicename");

  }catch(e)
  {
    print(e.toString());
  }
}
storeRating(empid,orgid,rating,remark) async{
  try{
    Dio dio = new Dio();
    /*
      FormData formData = new FormData.from({
        "uid": empid,
        "refno": orgid,
      });*/

    print(globals.path+"storeRating?empid=$empid&refid=$orgid&rating=$rating&remark=$remark");
    await dio.post(globals.path+"storeRating?empid=$empid&refid=$orgid&rating=$rating&remark=$remark");

  }catch(e)
  {
    print(e.toString());
  }
}





Future<Map<String, dynamic>> sendPushNotification(String title,String nBody,String topic) async {

  String url='https://fcm.googleapis.com/fcm/send';
  var body = json.encode({
    'condition': topic,
    'notification': {'body': nBody,
      'title': title,
      'click_action': 'FLUTTER_NOTIFICATION_CLICK'
    }
  });

  print('Body: $body');

  var response = await http.post(
    url,
    headers: {
      'Content-Type': 'application/json',
      'Authorization':'key=AAAAsVdW418:APA91bH-KAyzItecPhs8jP95ZlFNOzDKjmzmeMd2iH1HyUpO_T-_Baed-uIkuyYlosgLStcJZBqQFZuu7UdepvKX6lJcHjU__7FV19LLGn0nbveDBcTBJRJulb5fj_iOlsVRURzsu1Ch'
    },
    body: body,
  );

  // todo - handle non-200 status code, etc

  //return json.decode(response.body);
}

List<SuspiciousAttn> createTodaySuspiciousEmpList(List data) {
  // print('Create list called/*******************');
  List<SuspiciousAttn> list = new List();

  print("Tril status");
  print(trialstatus);
  int length = data.length;
  if(trialstatus=='2' && length>10)
  {
    length = 10;  // expired organization show only 10 records
  }

  /*int total_dept = 0;
   int total_abs = 0;
   int total_pre = 0;
   int total_emp = 0;*/
  if(length>0)
    for (int i = 0; i < length; i++) {
      String Id = data[i]['Id'].toString();
      String Name = data[i]["Name"].toString();
      String ProfileImage = data[i]["profileimage"].toString() == ''
          ? 'https://ubiattendance.ubihrm.com/assets/img/avatar.png'
          : data[i]["profileimage"].toString();
      String TimeInOut = data[i]["TimeInOut"].toString() == '00:00'
          ? '-'
          : data[i]["TimeInOut"].toString();
      String EntryExitImage = data[i]["EntryExitImage"].toString() == ''
          ? 'https://ubiattendance.ubihrm.com/assets/img/avatar.png'
          : data[i]["EntryExitImage"].toString();
      String TimeInOutConfidence = data[i]["TimeInOutConfidence"].toString();
      String Present = data[i]["present"].toString();
      String Absent = data[i]["absent"].toString();

      SuspiciousAttn tos = new SuspiciousAttn(
        Id: Id,
        Name: Name,
        TimeInOut: TimeInOut,
        EntryExitImage: EntryExitImage,
        ProfileImage: ProfileImage,
        TimeInOutConfidence: TimeInOutConfidence,
        Present: Present,
        Absent: Absent,
      );

      list.add(tos);
    }
  return list;
}

class SuspiciousAttn {
  String Id;
  String Name;
  String TimeInOut;
  String EntryExitImage;
  String ProfileImage;
  String TimeInOutConfidence;
  String Present;
  String Absent;

  SuspiciousAttn({
    this.Id,
    this.Name,
    this.TimeInOut,
    this.EntryExitImage,
    this.ProfileImage,
    this.TimeInOutConfidence,
    this.Present,
    this.Absent,
  });
}

Future<List<SuspiciousAttn>> getCDateSSAttn(listType, date) async {
  final prefs = await SharedPreferences.getInstance();
  String orgdir = prefs.getString('orgdir') ?? '';
  String empid = prefs.getString('empid') ?? '';
  print(globals.path + 'getSuspiciousAttn?refno=$orgdir&date=$date&datafor=$listType&empid=$empid');
  final response = await http.get(globals.path +
      'getSuspiciousAttn?refno=$orgdir&date=$date&datafor=$listType&empid=$empid');
  final res = json.decode(response.body);
  // print(res);
  List responseJson;
  if (listType == 'present')
    responseJson = res['present'];
  else if (listType == 'absent')
    responseJson = res['absent'];
  else if (listType == 'latecomings')
    responseJson = res['lateComings'];
  else if (listType == 'earlyleavings') responseJson = res['earlyLeavings'];
  List<SuspiciousAttn> userList = createTodaySuspiciousEmpList(responseJson);
  return userList;
}
disapprovesuspiciousattn(String id) async{
  try{
    Dio dio = new Dio();
    /*
      FormData formData = new FormData.from({
        "uid": empid,
        "refno": orgid,
      });*/

    print(globals.path+"disapprovesuspiciousattn?id=$id");
    await dio.post(globals.path+"disapprovesuspiciousattn?id=$id");

  }catch(e)
  {
    print(e.toString());
  }
}
disapprovefaceid(String empid,String orgid) async{
  var prefs = await SharedPreferences.getInstance();
  var orgTopic = prefs.getString("OrgTopic") ?? '';
  try{
    Dio dio = new Dio();
    /*
      FormData formData = new FormData.from({
        "uid": empid,
        "refno": orgid,
      });*/

    print(globals.path+"disapprovefaceid?empid=$empid&orgid=$orgid&orgTopic=$orgTopic");
    await dio.post(globals.path+"disapprovefaceid?empid=$empid&orgid=$orgid&orgTopic=$orgTopic");

  }catch(e)
  {
    print(e.toString());
  }
}
sendMailByAppToAdmin(String subject,String content) async{
  var prefs = await SharedPreferences.getInstance();
  String orgid = prefs.getString('orgid') ?? '';
  try{
    Dio dio = new Dio();
    /*
      FormData formData = new FormData.from({
        "uid": empid,
        "refno": orgid,
      });*/

    print(globals.path+"sendMailByAppToAdmin?subject=$subject&content=$content&orgid=$orgid");
    await dio.post(globals.path+"sendMailByAppToAdmin?subject=$subject&content=$content&orgid=$orgid");


  }catch(e)
  {
    print(e.toString());
  }
}
sendMailByAppToEmployee(String id,String content) async{
  try{
    Dio dio = new Dio();
    /*
      FormData formData = new FormData.from({
        "uid": empid,
        "refno": orgid,
      });*/

    print(globals.path+"sendMailByApp?id=$id&content=$content");
    await dio.post(globals.path+"sendMailByApp?id=$id&content=$content");

  }catch(e)
  {
    print(e.toString());
  }
}
class LeaveList {
  String Id;
  String Name;
  String AppliedDate;
  String FromDate;
  String ToDate;
  String Reason;
  String ApprovalStatus;
  String Remarks;
  String LeaveId;
  String NoofLeaves;

  LeaveList({
    this.Id,
    this.Name,
    this.AppliedDate,
    this.FromDate,
    this.ToDate,
    this.Reason,
    this.ApprovalStatus,
    this.Remarks,
    this.LeaveId,
    this.NoofLeaves
  });
}

Future<List<LeaveList>> getLeaveSummary() async{
  Dio dio = new Dio();
  final prefs = await SharedPreferences.getInstance();
  String orgid = prefs.getString('orgid') ?? '';
  String empid = prefs.getString('empid')??"";
  try {
    FormData formData = new FormData.from({
      "uid": empid,
      "refid":orgid
    });
    //Response response = await dio.post("https://sandbox.ubiattendance.com/index.php/services/getInfo", data: formData);
    Response response = await dio.post(globals.path+"getListofLeave", data: formData);
    print(globals.path+"getListofLeave?uid=$empid&refid=$orgid");
    //print(response.data.toString());
    //print('--------------------getLeaveSummary Called-----------------------');
    List responseJson = json.decode(response.data.toString());
      print("LEAVE LIST");
  //  print(userList);
    print(response.data.toString());
    print("LEAVE LIST");
    List<LeaveList> userList = createLeaveList(responseJson);

    return userList;

  }catch(e){
    //print(e.toString());
  }
}

List<LeaveList> createLeaveList(List data){
  List<LeaveList> list = new List();
  for (int i = 0; i < data.length; i++) {
    String Id = data[i]["Id"];
    String Name = data[i]["name"];
    String AppliedDate = data[i]["AppliedDate"];
    String Reason=data[i]["Reason"];
    String ApprovalStatus='';
    String Remarks=data[i]["Remarks"];
    String FromDate = data[i]["Date"].toString();
    String ToDate = data[i]["ToDate"].toString();
    String LeaveId = data[i]["LeaveId"].toString();
    String NoofLeaves = data[i]["NoofLeaves"].toString();
    if(data[i]["ApprovalStatus"].toString()=='1')
      ApprovalStatus='Pending';
    else  if(data[i]["ApprovalStatus"].toString()=='2')
      ApprovalStatus='Approved';
    else  if(data[i]["ApprovalStatus"].toString()=='3')
      ApprovalStatus='Rejected';
    else  if(data[i]["ApprovalStatus"].toString()=='4')
      ApprovalStatus='Withdraw';
    //print(LeaveDate);
    LeaveList leave = new LeaveList(Id: Id,Name: Name,AppliedDate: AppliedDate,FromDate :FromDate,ToDate: ToDate, Reason: Reason, ApprovalStatus: ApprovalStatus, Remarks: Remarks, LeaveId: LeaveId,NoofLeaves: NoofLeaves);
    list.add(leave);
     //print("LEAVE LIST");
   // print(list);
    print("LEAVE LIST Here");
  }
  return list;
}
class LeaveListAll {
  String Id;
  String name;
  String ApprovalStatus;
  String Reason;
  String applydate;
  String Fdate;
  String Tdate;
  String LeaveId;
  String Remark;
  int NoofLeaves;
  String EmployeeId;

  LeaveListAll(
      { this.Id,
        this.name,
        this.ApprovalStatus,
        this.Reason,
        this.applydate,
        this.Fdate,
        this.Tdate,
        this.LeaveId,
        this.Remark,
        this.NoofLeaves,
        this.EmployeeId
      });
}
class LeaveH {
  String Id;
  String LeaveId;
  String name;
  String Reason;
  String Date;
  String ApprovalStatus;
  String Remarks;
  String AppliedDate;
  LeaveH(
      { this.Id,
        this.LeaveId,
        this.name,
        this.Reason,
        this.Date,
        this.ApprovalStatus,
        this.Remarks,
        this.AppliedDate

      });
}
class Person {
  final String LeaveId;
  final String empid;

  Person(this.LeaveId,this.empid);
}

Future<List<LeaveListAll>> getLeaveApprovals() async {
  Dio dio = new Dio();
  final prefs = await SharedPreferences.getInstance();
  String orgid = prefs.getString('orgid') ?? '';
  print('====================HELLO==================');
  FormData formData = new FormData.from({
    "refid":orgid
  });
  Response response = await dio.post(globals.path+"getListofLeaveAll", data: formData);
  print(globals.path+"getListofLeaveAll?refid=$orgid");
  final res = json.decode(response.data.toString());

  print(res);
  List<LeaveListAll> userList1 = createTeamleaveapporval(res);

  return userList1;
}


List<LeaveListAll> createTeamleaveapporval(List data) {

  List<LeaveListAll> list = new List();
  for (int i = 0; i < data.length; i++) {

    String Id = data[i]["Id"].toString();
    String name = data[i]["name"].toString();
    String Reason = data[i]["Reason"].toString();
    String applydate = data[i]["AppliedDate"].toString();
    String Fdate = data[i]["Date"].toString();
    String Tdate = data[i]["ToDate"].toString();
    String LeaveId = data[i]["LeaveId"].toString();
    int NoofLeaves = int.parse(data[i]["NoofLeaves"]);
    String EmployeeId = data[i]["EmployeeId"];
    String ApprovalStatus='';
    if(data[i]["ApprovalStatus"].toString()=='1')
       ApprovalStatus='Pending';
    else  if(data[i]["ApprovalStatus"].toString()=='2')
       ApprovalStatus='Approved';
    else  if(data[i]["ApprovalStatus"].toString()=='3')
       ApprovalStatus='Rejected';
    else  if(data[i]["ApprovalStatus"].toString()=='4')
       ApprovalStatus='Withdraw';


    LeaveListAll tos = new LeaveListAll(
        Id: Id,
        name: name,
        Reason: Reason,
        applydate: applydate,
        Fdate: Fdate,
        Tdate: Tdate,
        LeaveId: LeaveId,
        ApprovalStatus:  ApprovalStatus,
        NoofLeaves: NoofLeaves,
        EmployeeId: EmployeeId);
    list.add(tos);

  }
  return list;
}
withdrawLeave(LeaveId,orgid,empid) async{
  Dio dio = new Dio();
  try {
    final prefs = await SharedPreferences.getInstance();
    FormData formData = new FormData.from({
      "LeaveId": LeaveId,
      "uid": empid,
      "refid": orgid,
    });

    //Response response = await dio.post("https://sandbox.ubiattendance.com/index.php/services/getInfo", data: formData);
    print(globals.path+"withdrawLeave?refid=$orgid");
    Response response = await dio.post(
        globals.path+"withdrawLeave",
        data: formData);
    //print(response.toString());
    if (response.statusCode == 200) {
      Map leaveMap = json.decode(response.data);
      if(leaveMap["status"]=='true'){
        return "success";
      }else{
        return "failure";
      }
    }else{
      return "No Connection";
    }
  }catch(e){
    //print(e.toString());
    return "Poor network connection";
  }
}
ApproveLeave(Leaveid,comment,sts) async{
  String empid;
  String orgid;
  // Employee emp;
  Dio dio = new Dio();
  final prefs = await SharedPreferences.getInstance();
  empid = prefs.getString('empid');
  orgid =prefs.getString('orgid');
  //emp = new Employee(employeeid: empid, organization: organization);
  try {
    FormData formData = new FormData.from({
      "uid": empid,
      "refid": orgid,
      "LeaveId": Leaveid,
      "comment": comment,
      "sts": sts,
      // "leavests": leave.approverstatus
    });
    /*  print(comment);
    print(Leaveid);
    print(empid);
    print(organization);
    print(sts);*/
    //Response response = await dio.post("https://sandbox.ubiattendance.com/index.php/services/getInfo", data: formData);
//Response response = await dio.post(  path_hrm_india+"ApproveLeave",data: formData);
    print(globals.path+"Approveleave?LeaveId=$Leaveid&refid=$orgid&comment=$comment&sts=$sts");
    Response response = await dio.post(
        globals.path+"Approveleave",
        data: formData);
    final leaveMap = response.data.toString();
    print("-------------------");
    print(response.toString());
    if (leaveMap.contains("false"))
    {
      print("false approve leave function--->" + response.data.toString());
      return "false";
    } else {
      print("true  approve leave function---" + response.data.toString());
      return "true";
    }
    //print(response.toString());
    /* if (response.statusCode == 200) {
      Map leaveMap = json.decode(response.data);
      if(leaveMap["status"]==true){
        return "success";

      }else{
        return "failure";
      }
    }else{
      return "No Connection";
    }*/
  }catch(e){
    //print(e.toString());
    return "Poor network connection";
  }
}
ApproveLeaveEmp(Ids,comment,sts) async{
  String empid;
  String orgid;
  // Employee emp;
  Dio dio = new Dio();
  final prefs = await SharedPreferences.getInstance();
  empid = prefs.getString('empid');
  orgid =prefs.getString('orgid');
  //emp = new Employee(employeeid: empid, organization: organization);
  try {
    FormData formData = new FormData.from({
      "uid": empid,
      "refid": orgid,
      "Ids": Ids,
      "comment": comment,
      "sts": sts,
      // "leavests": leave.approverstatus
    });
    /*  print(comment);
    print(Leaveid);
    print(empid);
    print(organization);
    print(sts);*/
    //Response response = await dio.post("https://sandbox.ubiattendance.com/index.php/services/getInfo", data: formData);
//Response response = await dio.post(  path_hrm_india+"ApproveLeave",data: formData);
    print(globals.path+"ApproveleaveEmp?LeaveId=$Ids&refid=$orgid&comment=$comment&sts=$sts");
    Response response = await dio.post(
        globals.path+"ApproveleaveEmp",
        data: formData);
    final leaveMap = response.data.toString();
    print("-------------------");
    print(response.toString());
    if (leaveMap.contains("false"))
    {
      print("false approve leave function--->" + response.data.toString());
      return "false";
    } else {
      print("true  approve leave function---" + response.data.toString());
      return "true";
    }
    //print(response.toString());
    /* if (response.statusCode == 200) {
      Map leaveMap = json.decode(response.data);
      if(leaveMap["status"]==true){
        return "success";

      }else{
        return "failure";
      }
    }else{
      return "No Connection";
    }*/
  }catch(e){
    //print(e.toString());
    return "Poor network connection";
  }
}


Future<List<LeaveH>> getleavehistory(LeaveId,empid) async{
  final prefs = await SharedPreferences.getInstance();
  Dio dio = new Dio();
  String orgid = prefs.getString('orgid') ?? '';
  final response = await dio.post(globals.path + 'getListofLeaveEmployee?refid=$orgid&empid=$empid&LeaveId=$LeaveId');
  // print("leavetype22----------->");
  // print(response);
  List data = json.decode(response.data.toString());
  // print("leavetype----------->");
  // print(data);
  List<LeaveH> leavetype = createleavehistory(data);
  return leavetype;
}

List<LeaveH> createleavehistory(List data) {

  List<LeaveH> list = new List();
  for (int i = 0; i < data.length; i++) {

    String Id = data[i]["Id"].toString();
    String name = data[i]["name"].toString();
    String LeaveId =data[i]["LeaveId"].toString();
    String Reason=data[i]["Reason"].toString();
    String Date=data[i]["Date"].toString();
    String Remarks=data[i]["Remarks"].toString();
    String AppliedDate=data[i]["AppliedDate"].toString();
    String ApprovalStatus='';
    if(data[i]["ApprovalStatus"].toString()=='1')
      ApprovalStatus='Pending';
    else  if(data[i]["ApprovalStatus"].toString()=='2')
      ApprovalStatus='Approved';
    else  if(data[i]["ApprovalStatus"].toString()=='3')
      ApprovalStatus='Rejected';
    else  if(data[i]["ApprovalStatus"].toString()=='4')
      ApprovalStatus='Withdraw';


    //  print("********************"+Left+"***"+Used+"***"+Entitle);
    LeaveH tos = new LeaveH(
        Id: Id,
        name: name,
        LeaveId:LeaveId,
        Reason: Reason,
        Date: Date,
        ApprovalStatus:ApprovalStatus,
        Remarks:Remarks,
        AppliedDate:AppliedDate

    );
    list.add(tos);
  }
  return list;
}


sendNotificationtouser ()async
{
  var prefs=await SharedPreferences.getInstance();
  var empId = "4904";
  var phoneno="7440519273";
  var password= "123456";

  print('https://ubiattendance.com/'+empId+"/"+phoneno+"/"+password);

  final DynamicLinkParameters parameters = DynamicLinkParameters(
    uriPrefix: 'https://ubiattendance.page.link',
    link: Uri.parse('https://ubiattendance.com/'+empId+"/"+phoneno+"/"+password),
    androidParameters: AndroidParameters(
      packageName: 'org.ubitech.attendance',
      minimumVersion: 50009,
    ),
  );

  //final Uri dynamicUrl = await parameters.buildUrl();
  final ShortDynamicLink shortDynamicLink = await parameters.buildShortLink();
  final Uri shortUrl = shortDynamicLink.shortUrl;
  print("short URL"+shortUrl.toString());
  globals.referralLink=shortUrl.toString();
 var sms="Try ubiAttendance and get  off on your purchase amount";
  Share.share(sms+"\n"+shortUrl.toString());
}




generateAndShareReferralLink()async{
  List ReferrerenceMessagesList=new List(7);
  var prefs=await SharedPreferences.getInstance();
  var empId = prefs.getString("empid")??"0";
  var referrerName=prefs.getString("fname")??"";
  var validity=prefs.getString("ReferralValidity");
  var referrerAmt=prefs.getString("ReferrerDiscount")??"1%";
  var referrenceAmt=prefs.getString("ReferrenceDiscount")??"1%";
  var ReferralValidFrom=prefs.getString("ReferralValidFrom")??"1%";
  var ReferralValidTo=prefs.getString("ReferralValidTo")??"1%";

  print('https://ubiattendance.com/'+empId+"/"+ReferralValidFrom+"/"+ReferralValidTo+"/"+referrerAmt+"/"+referrenceAmt);

  final DynamicLinkParameters parameters = DynamicLinkParameters(
    uriPrefix: 'https://ubiattendance.page.link',
    link: Uri.parse('https://ubiattendance.com/'+empId+"/"+ReferralValidFrom+"/"+ReferralValidTo+"/"+referrerAmt+"/"+referrenceAmt),
    androidParameters: AndroidParameters(
      packageName: 'org.ubitech.attendance',
      minimumVersion: 50009,
    ),
  );

  //final Uri dynamicUrl = await parameters.buildUrl();
  final ShortDynamicLink shortDynamicLink = await parameters.buildShortLink();
  final Uri shortUrl = shortDynamicLink.shortUrl;
  print("short URL"+shortUrl.toString());
  globals.referralLink=shortUrl.toString();


  ReferrerenceMessagesList[0]="${referrerName} has invited you to try ubiAttendance App. You will get ${referrenceAmt} off on purchase. Try Now.";
  ReferrerenceMessagesList[1]="I am using a great App to monitor attendance. Give it a try. You will get ${referrenceAmt} off on your purchase. ";
  ReferrerenceMessagesList[2]="Attendance Analytics, Geo Fencing, Location Tracking  and more! Here’s ${referrenceAmt} off your order. Check it out!";
  ReferrerenceMessagesList[3]="Looking for a foolproof  attendance tracker? I suggest ubiAttendance. Sign up now: ${referrenceAmt} discount! via @${referrerName}";
  ReferrerenceMessagesList[4]="Use this link to get ${referrenceAmt} off on your first purchase at ubiAttendance – the best time tracker for your employees via @${referrerName}";
  ReferrerenceMessagesList[5]="Got headache Managing Attendance of your employees? Try ubiAttendance. Get ${referrenceAmt} off on your purchase amount via @${referrerName}";
  ReferrerenceMessagesList[6]="Try ubiAttendance and get ${referrenceAmt} off on your purchase amount";

  var rng = new Random();
  var referrenceRandom=rng.nextInt(6);



  Share.share(ReferrerenceMessagesList[referrenceRandom]+"\n"+shortUrl.toString());

}


appResumedPausedLogic(context,[bool isVisitPage]){
  if(showAppInbuiltCamera)
    globals.globalCameraOpenedStatus=false;

  SystemChannels.lifecycle.setMessageHandler((msg)async{
    if(msg=='AppLifecycleState.resumed' )
    {
      print("------------------------------------ App Resumed-----------------------------");

      //initDynamicLinks();
      cameraChannel.invokeMethod("openLocationDialog");
      var serverConnected= await checkConnectionToServer();
      if(globals.globalCameraOpenedStatus==false)
      {

        if(serverConnected!=1){
          print("inside condition");
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => OfflineHomePage()));

        }
        else{
          //Navigator.push(context, MaterialPageRoute(builder: (context) => HomePage()));
         // (context as Element).reassemble();
          if(globals.assign_lat==0.0||globals.assign_lat==null||!locationThreadUpdatedLocation)
          {
            cameraChannel.invokeMethod("openLocationDialog");
            print("dialog opened");
          }

        }
      }




    }
    if(msg=='AppLifecycleState.paused' ){
      if(globals.globalCameraOpenedStatus==false)
        locationThreadUpdatedLocation=false;
    }

  });
}

checkLocationEnabled(context) async{
  print("checkLocationEnabled function");

  bool isLocationEnabled = await Geolocator().isLocationServiceEnabled();
  print("isLocationEnabled:-------------------"+isLocationEnabled.toString());


  if(!isLocationEnabled){
    showDialog(
        context: context,
        barrierDismissible: false,
        // ignore: deprecated_member_use
        child: new AlertDialog(
          title: new Text(""),
          content: new Text("Sorry we can't continue without GPS"),
          actions: <Widget>[
            RaisedButton(
              child: new Text(
                "Turn On",
                style: new TextStyle(
                  color: Colors.white,
                ),
              ),
              color: Colors.orangeAccent,
              onPressed: () {
                openLocationSetting();
              },
            ),
            RaisedButton(
              child: new Text(
                "Done",
                style: new TextStyle(
                  color: Colors.white,
                ),
              ),
              color: Colors.orangeAccent,
              onPressed: () {
                cameraChannel.invokeMethod("startAssistant");
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => HomePage()),
                );
                Navigator.of(context, rootNavigator: true)
                    .pop();

              },
            ),
          ],
        ));
  }
}

void openLocationSetting() async {
  final AndroidIntent intent = new AndroidIntent(
    action: 'android.settings.LOCATION_SOURCE_SETTINGS',
  );
  await intent.launch();
}


encode5t(String str) async
{
  for(int i=0; i<5;i++)
  {
    String rev=str.split('').reversed.join('');

    str=base64Encode(str.codeUnits).split('').reversed.join(''); //apply base64 first and then reverse the string
  }
  return str;
}
decode5t(String str) async
{

  for(int i=0; i<5;i++)
  {
    String rev=str.split('').reversed.join('');

    str=String.fromCharCodes(base64Decode(rev)); //apply base64 first and then reverse the string}
  }
  return str;
}
var serverConnected=0;

Future<int> checkConnectionToServer () async{
  try {
    var uri = Uri.parse(path);
    var host=uri.host;
    //final result = await InternetAddress.lookup(host);
   //  final result = await InternetAddress.lookup("ubihrm.com")/*.timeout(const Duration(seconds: 2))*/;
   //http.Response response = await http.get('https://google.com')/*.timeout(const Duration(seconds: 7))*/;
   // print("response code"+response.statusCode.toString());
    //if (result.isNotEmpty && result[0].rawAddress.isNotEmpty &&response.statusCode==200 ) {

    final result = await InternetAddress.lookup('google.com');
    if (result.isNotEmpty && result[0].rawAddress.isNotEmpty){

//      if (response.statusCode==200 ) {
      print('connected');
      serverConnected=1;
    }else{
      serverConnected=0;
    }
  } on SocketException catch (_) {
    print('not connected');
    serverConnected=0;
  }on TimeoutException catch(_){
    serverConnected=0;
  }

  return serverConnected;
}
////////////////////Shashank////////////////////////////////////////




/////////// location punch
punch(comments, client_name, empid, location_addr1, lid, act, orgdir, latit,
    longi) {
  /* print('Location punch successfully');
  print("\nClient: " + client_name);
  print("\nComments: " + comments);
  print("\nempid: " + empid);
  print("\nlocation_addr1: " + location_addr1);
  print("\nlid: " + lid);
  print("\nact: " + act);
  print("\norgdir: " + orgdir);
  print("\nlatit: " + latit);
  print("\nlongi: " + longi);*/
}

Future UpdateStatus() async {
  try{
    final res = await http.get(globals.path + 'UpdateStatus?platform=Android1');
    return ((json.decode(res.body.toString()))[0]['status']).toString();
  }
  catch(e){
    print("Error finding current version of the app");
    return"error";
  }

}

Future checkNow() async {
  print('*--*-*-*-*-*-*-*-*-*-');
  try{
    final res = await http.get(globals.path + 'getAppVersion?platform=Android1');
    return ((json.decode(res.body.toString()))[0]['version']).toString();
  }
  catch(e){
    print("Error finding current version of the app");
    return"error";
  }

}

Future checkMandUpdate() async {
  final res = await http.get(globals.path + 'checkMandUpdate?platform=Android');
  print(globals.path + 'checkMandUpdate?platform=Android');
  // print('*****************************'+((json.decode(res.body.toString()))[0]['is_update']).toString()+'*****************************');
  return ((json.decode(res.body))[0]['is_update']).toString();
}

Future<String> PunchSkip(lid) async {
  // print('push skip called');
  Map MarkPunchMap = {'status': 'failure'};
  try {
    Dio dio = new Dio();
    FormData formData = new FormData.from({
      "lid": lid,
    });
    Response<String> response1 =
    await dio.post(globals.path + "skipPunch", data: formData);
    MarkPunchMap = json.decode(response1.data);
    //  print('STATUS-1:' + MarkPunchMap['status'].toString());
    if (MarkPunchMap['status'].toString() == 'success') setPunchPrefs('0');
    return MarkPunchMap['status'].toString();
  } catch (e) {
    //  print("Unable to set visit: " + e.toString());
    return MarkPunchMap['status'].toString();
  }
}

Future<Map> PunchInOut(comments, client_name, empid, location_addr1, lid, act,
    orgdir, latit, longi) async {
/*  print("Punch in/out called");
  print('Location punch successfully');
  print("\nClient: "+client_name);
  print("\nComments: "+comments);
  print("\nempid: "+empid);
  print("\nlocation_addr1: "+location_addr1);
  print("\nlid: "+lid);
  print("\nact: "+act);
  print("\norgdir: "+orgdir);
  print("\nlatit: "+latit);
  print("\nlongi: "+longi);*/
  Map MarkPunchMap;
  try {
    Dio dio = new Dio();
    FormData formData = new FormData.from({
      "comment": comments,
      "cname": client_name,
      "uid": empid,
      "orgid": orgdir,
      "loc": location_addr1,
      "longi": longi,
      "latit": latit,
      "act": act,
      "lid": lid,
    });

    Response<String> response1 =
    await dio.post(globals.path + "punchLocation", data: formData);

    print(response1.toString());
    MarkPunchMap = json.decode(response1.data);
//    PunchLocation pnch=new PunchLocation();

    if (MarkPunchMap["status"].toString() == 'success') {
      /* print('------response done----------' +
          MarkPunchMap["status"].toString() +
          " shared data: ");*/
      setPunchPrefs(MarkPunchMap["lid"].toString());
      return MarkPunchMap;
    } else
      /* print('------response failer----------' +
          MarkPunchMap["status"].toString());*/
      return MarkPunchMap;
  } catch (e) {
    // print("Unable to set visit: " + e.toString());
    MarkPunchMap = {'status': 'failure', 'lid': lid};
    return MarkPunchMap;
  }
}

///////// check punch in or punch out--- depricated (NOT IN USE)
/*checkPunch(String empid, String orgid) async {
  var dio = new Dio();
  final prefs = await SharedPreferences.getInstance();
  return "PunchIn";
}*/

Future<Map> registerEmp(name, email, pass, phone) async {
  final prefs = await SharedPreferences.getInstance();
  String orgdir = prefs.getString('orgdir') ?? '0';
  final response = await http.get(globals.path +
      "registerEmp?f_name= $name&username=$email&password=$pass"
          "&contact=$phone&org_id=$orgdir");
  /*print('globals.path+"registerEmp?f_name= $name&username=$email&password=$pass'
      '&contact=$phone&org_id=$orgdir');*/
  var res = json.decode(response.body.toString());
  print(res['id']);
  Map<String, String> data = {
    'id': res['id'].toString(),
    'sts': res['sts'].toString()
  };

  print('---------------------------------');
  print(data);
  print('---------------------------------');
  return data;
}

Future<String> checkAdminSts() async {
  final prefs = await SharedPreferences.getInstance();
  String orgdir = prefs.getString('orgdir') ?? '0';
  String empid = prefs.getString('empid') ?? '0';
  final response = await http
      .get(globals.path + "getSuperviserSts?uid=$empid&refid=$orgdir");
  var res = json.decode(response.body.toString());
  print('------------checkAdminSts called-123------');
  print(res[0]['appSuperviserSts']);
  prefs.setString('sstatus', res[0]['appSuperviserSts'].toString());
  employee_permission = int.parse(res[0]['appSuperviserSts']);
  return res[0]['appSuperviserSts'].toString();
}

setPunchPrefs(lid) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  prefs.setString('lid', lid);
  /* print('Preferences set successfully: new lid- ' +
      prefs.getString('lid').toString());*/
}


////////////////////////////////////////////////-----
Future<List<Punch>> getSummaryPunch(date) async {
  final prefs = await SharedPreferences.getInstance();
  String empid = prefs.getString('empid') ?? '';
  String orgdir = prefs.getString('orgdir') ?? '';
  print('getSummaryPunch called');
  print(globals.path + 'getPunchInfo?date=$date&uid=$empid&orgid=$orgdir');
  final response =
  await http.get(globals.path + 'getPunchInfo?date=$date&uid=$empid&orgid=$orgdir');
  List responseJson = json.decode(response.body.toString());
  print("get summary punch" + responseJson.toString());
  List<Punch> userList = createUserList(responseJson);
  return userList;
}

List<Punch> createUserList(List data) {
  List<Punch> list = new List();
  for (int i = data.length - 1; i >= 0; i--) {
    String id = data[i]["Id"];
    String client = data[i]["client"];
    String pi_time = data[i]["time_in"] == "00:00:00"
        ? '-'
        : data[i]["time_in"].toString().substring(0, 5);
    String pi_loc = data[i]["loc_in"];
    String po_time = data[i]["time_out"] == "00:00:00"
        ? '-'
        : data[i]["time_out"].toString().substring(0, 5);
    String po_loc = data[i]["loc_out"];
    String emp = data[i]["emp"];
    String empId = data[i]["empId"];
    String latit_in = data[i]["latit"];
    String longi_in = data[i]["longi"];
    String latit_out = data[i]["latit_in"];
    String longi_out = data[i]["longi_out"];
    String desc = data[i]["desc"];
    String pi_img = data[i]["checkin_img"].toString() == ''
        ? 'https://ubiattendance.ubihrm.com/assets/img/avatar.png'
        : data[i]["checkin_img"].toString();
    String po_img = data[i]["checkout_img"].toString() == ''
        ? 'https://ubiattendance.ubihrm.com/assets/img/avatar.png'
        : data[i]["checkout_img"].toString();
    //print(data[i]["loc_out"]);
    Punch punches = new Punch(
        Id: id,
        Emp: emp,
        empId: empId,
        client: client,
        pi_time: pi_time,
        pi_loc: pi_loc.length > 40 ? pi_loc.substring(0, 40) + '...' : pi_loc,
        po_time: po_time == '00:00' ? '-' : po_time,
        po_loc: po_loc.length > 40 ? po_loc.substring(0, 40) + '...' : po_loc,
        pi_latit: latit_in,
        pi_longi: longi_in,
        po_latit: latit_out,
        po_longi: longi_out,
        desc: desc.length > 40 ? desc.substring(0, 40) + '...' : desc,
        pi_img: pi_img,
        po_img: po_img);
    list.add(punches);
  }
  return list;
}

class Punch {
  String Id;
  String Emp;
  String empId;
  String client;
  String pi_time;
  String pi_loc;
  String po_time;
  String po_loc;
  String pi_longi;
  String pi_latit;
  String po_longi;
  String po_latit;
  String desc;
  String pi_img;
  String po_img;

  Punch(
      {this.Id,
        this.Emp,
        this.empId,
        this.client,
        this.pi_time,
        this.pi_loc,
        this.po_time,
        this.po_loc,
        this.pi_latit,
        this.pi_longi,
        this.po_latit,
        this.po_longi,
        this.desc,
        this.pi_img,
        this.po_img});
}

////////////////////////////////////////////////-----
///
/// ///////////////////common function
String Formatdate(String date_) {
  // String date_='2018-09-2';
  var months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec'
  ];
  var dy = [
    'st',
    'nd',
    'rd',
    'th',
    'th',
    'th',
    'th',
    'th',
    'th',
    'th',
    'th',
    'th',
    'th',
    'th',
    'th',
    'th',
    'th',
    'th',
    'th',
    'th',
    'st',
    'nd',
    'rd',
    'th',
    'th',
    'th',
    'th',
    'th',
    'th',
    'th',
    'st'
  ];
  var date = date_.split("-");
  return (date[2] +
      "" +
      dy[int.parse(date[2]) - 1] +
      " " +
      months[int.parse(date[1]) - 1]);
}

String Formatdate1(String date_) {
  // String date_='2018-09-2';
  var months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec'
  ];
  var date = date_.split("-");
  return (date[2] +
      " " +
      months[int.parse(date[1]) - 1]);
}

goToMap(String lat, String long) async {
  if ((lat.toString()).startsWith('0', 0) ||
      (long.toString()).startsWith('0', 0)) return false;
  String url = "https://maps.google.com/?q=" + lat + "," + long;
  if (await canLaunch(url)) {
    await launch(url);
  } else {
    //print( 'Could not launch $url');
  }
}

/////////////////////
Future<List<Map>> getDepartmentsList(int label) async {
  final prefs = await SharedPreferences.getInstance();
  String orgid = prefs.getString('orgdir') ?? '';
  final response =
  await http.get(globals.path + 'DepartmentMaster?orgid=$orgid');
  List data = json.decode(response.body.toString());
  List<Map> depts = createList(data, label);
  return depts;
}

List<Map> createList(List data, int label) {
  List<Map> list = new List();
  if (label == 1) // with -All- label
    list.add({"Id": "0", "Name": "-All-"});
  else
    list.add({"Id": "0", "Name": "-Select-"});
  for (int i = 0; i < data.length; i++) {
    if (data[i]["archive"].toString() == '1') {
      Map tos = {
        "Name": data[i]["Name"].toString(),
        "Id": data[i]["Id"].toString()
      };
      list.add(tos);
    }
  }
  return list;
}

Future<List<Map>> getDesignationsList(int label) async {
  final prefs = await SharedPreferences.getInstance();
  String orgid = prefs.getString('orgdir') ?? '';
  final response =
  await http.get(globals.path + 'DesignationMaster?orgid=$orgid');
  List data = json.decode(response.body.toString());
  List<Map> depts = createList(data, label);
  return depts;
}

Future<List<Map>> getShiftsList() async {
  final prefs = await SharedPreferences.getInstance();
  String orgid = prefs.getString('orgdir') ?? '';
  final response = await http.get(globals.path + 'shiftMaster?orgid=$orgid');
  debugPrint(response.body.toString()+">>>>>>>>>>>>>>>>>>>>>>>>>>>>");
  List data = json.decode(response.body.toString());
  List<Map> depts = createList(data, 0);
  return depts;
}

bool validateMobile(String value) {
// Indian Mobile number are of 10 digit only
  if (value.length < 6)
    return false;
  else
    return true;
}

bool validateEmail(String value) {
  Pattern pattern =
      r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
  RegExp regex = new RegExp(pattern);
  if (!regex.hasMatch(value))
    return false;
  else
    return true;
}

/// ///////////////////common function/
///
/// ///////////////////////////////--generate employees list for DD
Future<List<Map>> getEmployeesList(int label) async {
  final prefs = await SharedPreferences.getInstance();
  String orgid = prefs.getString('orgdir') ?? '';
  var empid = prefs.getString('empid') ?? '';
  print(empid);
  print(globals.path + 'getEmployeesList?orgid=$orgid&empid=$empid');
  final response =
  await http.get(globals.path + 'getEmployeesList?orgid=$orgid&empid=$empid');
  List data = json.decode(response.body.toString());
  List<Map> depts = createEMpListDD(data, label);
  // print(depts);
  return depts;
}

List<Map> createEMpListDD(List data, int label) {
  List<Map> list = new List();
  if (label == 1) // with -All- label
    list.add({"Id": "0", "Name": "-All-", "Code": ""});
  else
    list.add({"Id": "0", "Name": "-Select-", "Code": ""});
  for (int i = 0; i < data.length; i++) {
    Map tos;
    if (data[i]["Name"].toString() != '' && data[i]["Name"].toString() != null)
      tos = {
        "Name": data[i]["name"].toString(),
        "Id": data[i]["Id"].toString(),
        "Code": data[i]["ecode"].toString()
      };
    list.add(tos);
  }
  return list;
}

Future<List<Attn>> getEmpHistoryOf30(listType, emp) async {
  final prefs = await SharedPreferences.getInstance();
  String orgdir = prefs.getString('orgdir') ?? '';
  print( globals.path + 'getEmpHistoryOf30?refno=$orgdir&datafor=$listType&emp=$emp');
  final response = await http.get(globals.path + 'getEmpHistoryOf30?refno=$orgdir&datafor=$listType&emp=$emp');
  // print('================='+dept+'===================');
  final res = json.decode(response.body);
  // print('*************response**************');
  print(res);
  List responseJson;
  if (listType == 'present')
    responseJson = res['present'];
  else if (listType == 'absent')
    responseJson = res['absent'];
  else if (listType == 'latecomings')
    responseJson = res['lateComings'];
  else if (listType == 'earlyleavings')
    responseJson = res['earlyLeavings'];
  List<Attn> userList = createListEmpHistoryOf30(responseJson);
  return userList;
}

navigateToPaymentsPage()async{
  var url="https://buy.ubiattendance.com";
  if (await canLaunch(url)) {
    await launch(url);
  } else {
    //print( 'Could not launch $url');
  }
}

List<Attn> createListEmpHistoryOf30(List data){
  // print('Create list called/*******************');
  List<Attn> list = new List();
  for (int i = 0; i < data.length; i++) {
    String Name = Formatdate1(data[i]["AttendanceDate"].toString());
    String TimeIn = data[i]["TimeIn"].toString();
    String TimeOut = data[i]["TimeOut"].toString() == '00:00'
        ? '-'
        : data[i]["TimeOut"].toString();
    String EntryImage = data[i]["EntryImage"].toString() == ''
        ? 'https://ubiattendance.ubihrm.com/assets/img/avatar.png'
        : data[i]["EntryImage"].toString();
    String ExitImage = data[i]["ExitImage"].toString() == ''
        ? 'https://ubiattendance.ubihrm.com/assets/img/avatar.png'
        : data[i]["ExitImage"].toString();
    String CheckInLoc = data[i]["checkInLoc"].toString();
    String CheckOutLoc = data[i]["CheckOutLoc"].toString();
    String LatitIn = data[i]["latit_in"].toString();
    String LatitOut = data[i]["latit_out"].toString();
    String LongiIn = data[i]["longi_in"].toString();
    String LongiOut = data[i]["longi_out"].toString();
    Attn tos = new Attn(
        Name: Name,
        TimeIn: TimeIn,
        TimeOut: TimeOut,
        EntryImage: EntryImage,
        ExitImage: ExitImage,
        CheckInLoc: CheckInLoc,
        CheckOutLoc: CheckOutLoc,
        LatitIn: LatitIn,
        LatitOut: LatitOut,
        LongiIn: LongiIn,
        LongiOut: LongiOut);
    list.add(tos);
  }
  return list;
}

/*Future<List<Map<String, String>>> getEmpHistoryOf30Count(emp) async {
  final prefs = await SharedPreferences.getInstance();
  String orgdir = prefs.getString('orgdir') ?? '';
  print( globals.path + 'getEmpHistoryOf30Count?refno=$orgdir&emp=$emp');
  final response = await http.get(globals.path + 'getEmpHistoryOf30Count?refno=$orgdir&emp=$emp');
  // print('================='+dept+'===================');
  final data = json.decode(response.body);
  // print('*************response**************');
  List<Map<String, String>> res = [
    {
      "present": data['present'].toString(),
      "absent": data['absent'].toString(),
      "latecomings": data['latecomings'].toString(),
      "earlyleavings": data['earlyleavings'].toString()
    }
  ];
  // print('==========');
  print(res);
  return res;
}*/


/// ///////////////////////////////--generate employees list for DD/
/// ////////////////////////////////////////////////-----
Future<List<TimeOff>> getTimeOffSummary() async {
  final prefs = await SharedPreferences.getInstance();
  String empid = prefs.getString('empid') ?? '';
  print(globals.path + 'fetchTimeOffList?uid=$empid');
  final response = await http.get(globals.path + 'fetchTimeOffList?uid=$empid');
  // print(response.body);
//  print('--------------------getTimeOffList Called-----------------------');
  List responseJson = json.decode(response.body.toString());
  List<TimeOff> userList = createTimeOffList(responseJson);

  //timeoffRunning=  userList[0].TimeTo.toString()=='00:00'?true:false;
  print('timeoff running'+globals.timeoffRunning.toString());
  return userList;
}

List<TimeOff> createTimeOffList_old(List data) {
  List<TimeOff> list = new List();
  for (int i = 0; i < data.length; i++) {
    String TimeofDate = data[i]["date"];
    String TimeFrom = data[i]["from"];
    String TimeTo = data[i]["to"];
    String hrs = data[i]["hrs"];
    String Reason = data[i]["reason"];
    String ApprovalSts = data[i]["status"];
    String ApproverComment = data[i]["comment"];
    bool withdrawlsts = data[i]["withdrawlsts"];
    String TimeOffId = data[i]["timeoffid"];
    TimeOff tos = new TimeOff(
        TimeofDate: TimeofDate,
        TimeFrom: TimeFrom,
        TimeTo: TimeTo,
        hrs: hrs,
        Reason: Reason,
        ApprovalSts: ApprovalSts,
        ApproverComment: ApproverComment,
        withdrawlsts: withdrawlsts,
        TimeOffId: TimeOffId);
    list.add(tos);
  }
  return list;
}

List<TimeOff> createTimeOffList(List data) {
  List<TimeOff> list = new List();
  for (int i = 0; i < data.length; i++) {
    String TimeofDate = data[i]["date"];
    String TimeFrom = data[i]["from"];
    String TimeTo = data[i]["to"];
    String hrs = data[i]["hrs"];
    String Reason = data[i]["reason"];
    String ApprovalSts = data[i]["status"];
    String ApproverComment = data[i]["comment"];
    bool withdrawlsts = data[i]["withdrawlsts"];
    String TimeOffId = data[i]["timeoffid"];
    String StartLoc = data[i]["startloc"];
    String LatIn = data[i]["latin"];
    String LongIn = data[i]["longout"];
    String EndLoc = data[i]["endloc"];
    String LatOut = data[i]["latout"];
    String LongOut = data[i]["longout"];
    TimeOff tos = new TimeOff(
        TimeofDate: TimeofDate,
        TimeFrom: TimeFrom,
        TimeTo: TimeTo,
        hrs: hrs,
        Reason: Reason,
        ApprovalSts: ApprovalSts,
        ApproverComment: ApproverComment,
        withdrawlsts: withdrawlsts,
        TimeOffId: TimeOffId,
        StartLoc: StartLoc,
        LatIn: LatIn,
        LongIn: LongIn,
        EndLoc: EndLoc,
        LatOut: LatOut,
        LongOut: LongOut
    );
    list.add(tos);
  }
  return list;
}
////////////////////////////////////////////////-----

Future<bool> getOrgPerm(perm) async {
  final prefs = await SharedPreferences.getInstance();
  String org_perm = prefs.getString('org_perm') ?? '';
  List<String> permissions = org_perm.split(',');
  // for (var x = 0; x < permissions.length; x++)
  // print(permissions.contains(perm.toString()));
  //print("check perm: "+perm.toString());
  return permissions
      .contains(perm.toString()); // return true if permission found in list set
}

//********************************************************************************************//

//////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////
/////////////////////////DEPARTMENT CODE START////////////////////////
//////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////
//********************************************************************************************//
Future<List<Dept>> getDepartments() async {
  final prefs = await SharedPreferences.getInstance();
  String orgid = prefs.getString('orgdir') ?? '';
//  print('getDept called');
  final response =
  await http.get(globals.path + 'DepartmentMaster?orgid=$orgid');
  // print(response.body);
  List responseJson = json.decode(response.body.toString());
  List<Dept> deptList = createDeptList(responseJson);
  return deptList;
}

List<Dept> createDeptList(List data) {
  List<Dept> list = new List();
  for (int i = 0; i < data.length; i++) {
    String dept = data[i]["Name"];
    String status = data[i]["archive"] == '1' ? 'Active' : 'Inactive';
    String id = data[i]["Id"];
    Dept dpt = new Dept(dept: dept, status: status, id: id);
    list.add(dpt);
  }
  return list;
}

class Dept {
  String dept;
  String status;
  String id;

  Dept({this.dept, this.status, this.id});
}

Future<String> addDept(name, status) async {
  //print('RECIEVED STATUS: '+status.toString());
  final prefs = await SharedPreferences.getInstance();
  String empid = prefs.getString('empid') ?? '';
  String orgdir = prefs.getString('orgdir') ?? '';
  status = status.toString() == 'Active' ? '1' : '0';
  final response = await http.get(globals.path +
      'addDept?uid=$empid&orgid=$orgdir,&name=$name&sts=$status');

  print('Add dept response----------==' + response.body.toString());
  return response.body.toString();
}

resendOTP(username1, password1) async {
  //print('RECIEVED STATUS: '+status.toString());

  final prefs = await SharedPreferences.getInstance();
  Dio dio = new Dio();
  FormData formData = new FormData.from({
    "username":username1,
    "password":password1                        //to save city everytime, while marking timein and timeout
    // "file": new UploadFileInfo(imagei, "image.png"),
  });
  print(globals.path + "resend_otp?username=${ username1}&password=${password1}");

  try {
    //print(globals.path + "resend_otp", data: formData);
    Response<String> response1 = await dio.post(
        globals.path + "resend_otp", data: formData);
    print(response1.toString());
    var a = await jsonDecode(response1.toString());

    if (a['sts'] == 'true')
      return true;
    else
      return false;
  }catch(e){
    return false;
  }
}

Future<String> updateDept(dept, sts, did) async {
  //print('RECIEVED STATUS: '+status.toString());
  final prefs = await SharedPreferences.getInstance();
  String empid = prefs.getString('empid') ?? '';
  sts = sts.toString() == 'Active' ? '1' : '0';
  final response = await http
      .get(globals.path + 'updateDept?uid=$empid,&dept=$dept&sts=$sts&id=$did');
  return response.body.toString();
}
//********************************************************************************************//
//////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////
/////////////////////////DEPARTMENT CODE End////////////////////////
//////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////

//////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////
/////////////////////////DESIGNATION CODE START////////////////////////
//////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////

Future<List<Desg>> getDesignation() async {
  final prefs = await SharedPreferences.getInstance();
  String orgid = prefs.getString('orgdir') ?? '';
  // print('getDesg called');
  final response =
  await http.get(globals.path + 'DesignationMaster?orgid=$orgid');
  // print(response.body);
  List responseJson = json.decode(response.body.toString());
  List<Desg> desgList = createDesgList(responseJson);
  return desgList;
}

List<Desg> createDesgList(List data) {
  List<Desg> list = new List();
  for (int i = 0; i < data.length; i++) {
    String desg = data[i]["Name"];
    String status = data[i]["archive"] == '1' ? 'Active' : 'Inactive';
    String id = data[i]["Id"];
    Desg dpt = new Desg(desg: desg, status: status, id: id);
    list.add(dpt);
  }
  return list;
}

class Desg {
  String desg;
  String status;
  String id;
  List modulepermissions;

  Desg({this.desg, this.status, this.id, this.modulepermissions});
}

Future<String> addDesg(name, status) async {
  //print('RECIEVED STATUS: '+status.toString());
  final prefs = await SharedPreferences.getInstance();
  String empid = prefs.getString('empid') ?? '';
  String orgdir = prefs.getString('orgdir') ?? '';
  status = status.toString() == 'Active' ? '1' : '0';
  final response = await http.get(globals.path +
      'addDesg?uid=$empid&orgid=$orgdir,&name=$name&sts=$status');
  return response.body.toString();
}

Future<String> updateDesg(desg, sts, did) async {
  //print('RECIEVED STATUS: '+status.toString());
  print(desg + "   " + sts + "   " + did);
  final prefs = await SharedPreferences.getInstance();
  String empid = prefs.getString('empid') ?? '';
  sts = sts.toString() == 'Active' ? '1' : '0';
  final response = await http
      .get(globals.path + 'updateDesg?uid=$empid,&desg=$desg&sts=$sts&id=$did');
  print(response.body.toString());
  return response.body.toString();
}

//********************************************************************************************//
//////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////
/////////////////////////DESIGNATION CODE End////////////////////////
//////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////

//////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////
/////////////////////////Employee CODE START////////////////////////
//////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////

Future<List<Emp>> getEmployee($empname) async {

  final prefs = await SharedPreferences.getInstance();
  String orgid = prefs.getString('orgdir') ?? '';
  String empid = prefs.getString('empid')?? '0';
  String empname = $empname;
  print('getEmp called');
  print(responseJson.length);
  if(!(responseJson.length!=0 && empname !='')) {
    print(globals.path +
        'getUsersMobile?refno=$orgid&empid=$empid');
    final response = await http.get(
        globals.path + 'getUsersMobile?refno=$orgid&empid=$empid');
    responseJson = json.decode(response.body.toString());
    print(responseJson);
  }
  List<Emp> empList = createEmpList(responseJson,empname);
  print('fun end here3');
  print(empList);
  return empList;
}

List<Emp> createEmpList(List data, String empname) {
  List<Emp> list = new List();
  if(empname !='' )
    for (int i = 0; i < data.length; i++) {
      print('Sohan');
      String name = data[i]["name"].length > 20 ? data[i]["name"].substring(0, 15) + '..' : data[i]["name"];
      String dept = data[i]["Department"].length > 20 ? data[i]["Department"].substring(0, 15) + '..' : data[i]["Department"];
      String desg = data[i]["Designation"].length > 20 ? data[i]["Designation"].substring(0, 15) + '..' : data[i]["Designation"];

      String shift = data[i]["Shift"];

      String deptid = data[i]["DepartmentId"];
      String desgid = data[i]["DesignationId"];
      String shiftid = data[i]["ShiftId"];
      String password = data[i]["Password"];
      String status = data[i]["archive"] == '1' ? 'Active' : 'Inactive';
      String id = data[i]["Id"];
      String Email = data[i]["Email"];
      String Mobile = data[i]["Mobile"];
      String Admin = data[i]["Admin"] == '1' ? 'Mobile Admin' : 'User';
      String Profile = data[i]["Profile"];

      Emp emp = new Emp(
          Name: name,
          Department: dept,
          Designation: desg,
          Shift: shift,
          DepartmentId: deptid,
          DesignationId: desgid,
          ShiftId: shiftid,
          Status: status,
          Email: Email,
          Mobile: Mobile,
          Admin: Admin,
          Profile: Profile,
          Id: id,
          Password: password
      );
      if(name.toLowerCase().contains(empname.toLowerCase()))
        list.add(emp);
    }
  else
    for (int i = 0; i < data.length; i++) {
      String name = data[i]["name"].length > 20 ? data[i]["name"].substring(0, 15) + '..' : data[i]["name"];
      String dept = data[i]["Department"].length > 20 ? data[i]["Department"].substring(0, 15) + '..' : data[i]["Department"];
      String desg = data[i]["Designation"].length > 20 ? data[i]["Designation"].substring(0, 15) + '..' : data[i]["Designation"];

      String shift = data[i]["Shift"];

      String deptid = data[i]["DepartmentId"];
      String desgid = data[i]["DesignationId"];
      String shiftid = data[i]["ShiftId"];
      String password = data[i]["Password"];

      String status = data[i]["archive"] == '1' ? 'Active' : 'Inactive';
      String id = data[i]["Id"];
      String Email = data[i]["Email"];
      String Mobile = data[i]["Mobile"];
      String Admin = data[i]["Admin"] == '1' ? 'Mobile Admin' : 'User';
      String Profile = data[i]["Profile"];
      Emp emp = new Emp(
          Name: name,
          Department: dept,
          Designation: desg,
          Shift: shift,
          DepartmentId: deptid,
          DesignationId: desgid,
          ShiftId: shiftid,
          Status: status,
          Email: Email,
          Mobile: Mobile,
          Admin: Admin,
          Profile: Profile,
          Id: id,
          Password: password

      );
      print("ABCSBJSBJ132");
      list.add(emp);
      print("Add list");
      print(list);

    }
  print("Last return");
  return list;

}

class Emp {
  String Name;
  String Department;
  String Designation;
  String Shift;
  String DepartmentId;
  String DesignationId;
  String ShiftId;
  String Status;
  String Email;
  String Mobile;
  String Admin;
  String Profile;
  String Id;
  String Password;


  // Emp({this.Name, this.Department, this.Designation, this.Status, this.Id});
  Emp(
      { this.Name,
        this.Department,
        this.Designation,
        this.Shift,
        this.DepartmentId,
        this.DesignationId,
        this.ShiftId,
        this.Status,
        this.Email,
        this.Mobile,
        this.Admin,
        this.Profile,
        this.Id,
        this.Password
      });
}





Future<int> sendsms(sms) async {

  final prefs = await SharedPreferences.getInstance();
  String empid = prefs.getString('empid') ?? '';
  String orgdir = prefs.getString('orgdir') ?? '';

  print(globals.path+'sendsms?uid=$empid&org_id=$orgdir&sms=$sms');
  final response = await http.get(globals.path+'sendsms?uid=$empid&org_id=$orgdir&sms=$sms');
  var res = json.decode(response.body);
  print(res);
  return res;

}



Future<int> addEmployee(fname, lname, email, countryCode, countryId, contact,
    password, dept, desg, shift, String deptind, String desgind, String shiftind,) async {
  //print('RECIEVED STATUS: '+status.toString());
  final prefs = await SharedPreferences.getInstance();
  print(dept);
  print(password);
  print("002200220020");
  String empid = prefs.getString('empid') ?? '';
  String orgdir = prefs.getString('orgdir') ?? '';
//  print('addEmp function called, parameters :');
  print(deptind);
  print("-----1");
  print(desgind);
  print("-----2");
  print(shiftind);

  print(globals.path + 'registerEmp?uid=$empid&org_id=$orgdir&f_name=$fname&l_name=$lname&password=$password&username=$email&contact=$contact&country=$countryId&countrycode=$countryCode&admin=1&designation=$desgind&department=$deptind&shift=$shiftind');
  final response = await http.get(globals.path + 'registerEmp?uid=$empid&org_id=$orgdir&f_name=$fname&l_name=$lname&password=$password&username=$email&contact=$contact&country=$countryId&countrycode=$countryCode&admin=1&designation=$desgind&department=$deptind&shift=$shiftind');
  var res = json.decode(response.body);
  print("--------> Adding employee" + res.toString());
  return res['sts'];
}


Future<int> editEmployee(fname, lname, email, countryCode, countryId, contact,
    password, dept, desg, shift , empid) async {
  //print('RECIEVED STATUS: '+status.toString());

  final prefs = await SharedPreferences.getInstance();
  String uid = prefs.getString('empid') ?? '';
  String orgdir = prefs.getString('orgdir') ?? '';
//  print('addEmp function called, parameters :');
/*  print(fname +
      '--' +
      lname +
      '--' +
      email +
      '--' +
      countryCode +
      '--' +
      countryId +
      '--' +
      contact +
      '--' +
      password);*/
  print(globals.path+'updateEmp?uid=$uid&org_id=$orgdir&f_name=$fname&l_name=$lname&password=$password&username=$email&contact=$contact&country=$countryId&countrycode=$countryCode&admin=1&designation=$desg&department=$dept&shift=$shift&empid=$empid');
  final response = await http.get(globals.path +'updateEmp?uid=$uid&org_id=$orgdir&f_name=$fname&l_name=$lname&password=$password&username=$email&contact=$contact&country=$countryId&countrycode=$countryCode&admin=1&designation=$desg&department=$dept&shift=$shift&empid=$empid');
  var res = json.decode(response.body);
  print("--------> Adding employee" + res.toString());
  return res['sts'];
}
//********************************************************************************************//
//////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////
/////////////////////////Employee CODE End////////////////////////
//////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////

// //////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////
/////////////////////////SHIFT HANDELING START////////////////////////
//////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////
//********************************************************************************************//

Future<List<Shift>> getShifts() async {
  // print('shifts called');
  final prefs = await SharedPreferences.getInstance();
  String orgid = prefs.getString('orgdir') ?? '';
  // print(globals.path + 'shiftMaster?orgid=10');
  final response = await http.get(globals.path + 'shiftMaster?orgid=$orgid');
  List responseJson = json.decode(response.body.toString());
  List<Shift> shiftList = createShiftList(responseJson);
//  print(shiftList);
  return shiftList;
}

List<Shift> createShiftList(List data) {
  List<Shift> list = new List();
  for (int i = 0; i < data.length; i++) {
    String name = data[i]["Name"];
    String timein = data[i]["TimeIn"];
    String timeout = data[i]["TimeOut"];
    String id = data[i]["Id"];
    String status = data[i]["archive"] == '0' ? 'Inactive' : 'Active';
    String type =
    data[i]["shifttype"] == '1' ? 'Single Date' : 'Multi Date';

    Shift shift = new Shift(
        Id: id,
        Name: name,
        TimeIn: timein,
        TimeOut: timeout,
        Status: status,
        Type: type);
    list.add(shift);
  }
  return list;
}

class Shift {
  String Id;
  String Name;
  String TimeIn;
  String TimeOut;
  String Status;
  String Type;

  Shift(
      {this.Id, this.Name, this.TimeIn, this.TimeOut, this.Status, this.Type});
}

Future<int> createShift(name, type, from, to, from_b, to_b) async {
  final prefs = await SharedPreferences.getInstance();
  String empid = prefs.getString('empid') ?? '';
  String orgdir = prefs.getString('orgdir') ?? '';
  final response = await http.get(globals.path +
      'addShift?name=$name&org_id=$orgdir&ti=$from&to=$to&tib=$from_b&tob=$to_b&sts=1&shifttype=$type');
  int res = int.parse(response.body);
  return res;
}

Future<String> updateShift(shift, sts, did) async {
  //print('RECIEVED STATUS: '+status.toString());
  print(shift + "   " + sts + "   " + did);
  final prefs = await SharedPreferences.getInstance();
  String empid = prefs.getString('empid') ?? '';
  sts = sts.toString() == 'Active' ? '1' : '0';
  final response = await http.get(
      globals.path + 'updateShift?uid=$empid,&shift=$shift&sts=$sts&id=$did');
  print(response.body.toString());
  return response.body.toString();
}

//********************************************************************************************//
// //////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////
/////////////////////////SHIFT HANDELING End////////////////////////
//////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////

// ////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////
/////////////////////////RESET/Forgot PASSWORD START////////////////////////
//////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////
//********************************************************************************************//
Future<int> changeMyPassword(oldPass, newPass) async {
  final prefs = await SharedPreferences.getInstance();
  String empid = prefs.getString('empid') ?? '';
  String orgdir = prefs.getString('orgdir') ?? '';
  //  print(oldPass+'--'+newPass);
  final response = await http.get(globals.path +
      'changePassword?uid=$empid&refno=$orgdir&pwd=$oldPass&npwd=$newPass');
  if (int.parse(response.body) == 1) {
    prefs.setString('usrpwd', newPass);
  }
  return int.parse(response.body);
}
//////////////////////////////////////////////////////////sgCode/////////////////////////////////////////////////

Future<int> firstPassword(oldPass, newPass, String password_sts) async {
  final prefs = await SharedPreferences.getInstance();
  print(oldPass);
  print("-----------------1");
  print(newPass);
  print("-----------------2");
  print(password_sts);

  String empid = prefs.getString('empid') ?? '';
  String orgdir = prefs.getString('orgdir') ?? '';
  //  print(oldPass+'--'+newPass);
  print("change psswrd" + globals.path + 'firstPassword?uid=$empid&refno=$orgdir&newpwd=$newPass&password_sts=$password_sts');
  final response = await http.get(globals.path + 'firstPassword?uid=$empid&refno=$orgdir&newpwd=$newPass&password_sts=$password_sts');
  if (int.parse(response.body) == 1) {
    prefs.setString('usrpwd', newPass);
  }
  return int.parse(response.body);
}

///////////////////////////////////////////////////////sgCODE////////////////////////////////////////////////////////

Future<int> resetMyPassword(username) async {
  final prefs = await SharedPreferences.getInstance();
  prefs.setString('username', username);
  print('Forgot password rew sbmit' + username);
  final response =
  await http.get(globals.path + 'resetPasswordLink?una=$username');
  print("response for forgot pass::::" + response.body.toString());
  return int.parse(response.body);
} //'https://ubiattendance.ubihrm.com/index.php/services/resetPasswordLink?una='+una+'&refno='+refno,
//********************************************************************************************//
// ////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////
/////////////////////////RESET/FORGOT PASSWORD END////////////////////////
//////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////

// ////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////
/////////////////////////REPORTS SERVICES STARTS////////////////////////
//////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////
//********************************************************************************************//
Future<List<Attn>> getTodaysAttn(listType) async {
  final prefs = await SharedPreferences.getInstance();
  trialstatus = prefs.getString('trialstatus') ?? '';
  String orgdir = prefs.getString('orgdir') ?? '';
  String empid = prefs.getString('empid') ?? '';
  final response = await http.get(globals.path +
      'getAttendances_new?refno=$orgdir&datafor=$listType&empid=$empid');
  final res = json.decode(response.body);
  // print(res);
  List responseJson;
  if (listType == 'present')
    responseJson = res['present'];
  else if (listType == 'absent')
    responseJson = res['absent'];
  else if (listType == 'latecomings')
    responseJson = res['lateComings'];
  else if (listType == 'earlyleavings') responseJson = res['earlyLeavings'];
  List<Attn> userList = createTodayEmpList(responseJson);
  return userList;
}

Future<List<SyncNotification>> getNotifications() async {
  final prefs = await SharedPreferences.getInstance();
  String orgid = prefs.getString('orgid') ?? '0';
  String empid = prefs.getString('empid') ?? '0';
  print(globals.path +
      'getNotifications'
          '?EmployeeId=$empid&OrganizationId=$orgid');

  final response = await http.get(globals.path +
      'getNotifications'
          '?EmployeeId=$empid&OrganizationId=$orgid');
  print(globals.path +
      'getNotifications'
          '?EmployeeId=$empid&OrganizationId=$orgid');
  final res = json.decode(response.body);

  print(res);

  List responseJson=res;

  List<SyncNotification> userList = createNotificationList(responseJson);
  return userList;
}

List<SyncNotification> createNotificationList(List data) {
  // print('Create list called/*******************');
  List<SyncNotification> list = new List();
  for (int i = 0; i < data.length; i++) {
    int Id=int.parse(data[i]['Id']);
    int EmployeeId=int.parse(data[i]['EmployeeId']);
    int OrganizationId=int.parse(data[i]['OrganizationId']);
    String SyncDate=data[i]['SyncDate'];
    String OfflineMarkedDate=data[i]['OfflineMarkedDate'];
    String Time=data[i]['Time'];;
    String Action=data[i]['Action'];
    String Latitude=data[i]['Latitude'];
    String Longitude=data[i]['Longitude'];
    String ReasonForFailure=data[i]['ReasonForFailure'];
    String image=data[i]['image'];


    SyncNotification tos = new SyncNotification(
        Id,
        EmployeeId,
        OrganizationId,
        SyncDate,
        OfflineMarkedDate,
        Time,
        Action,
        Latitude,
        Longitude,
        ReasonForFailure,
        image
    );
    list.add(tos);
  }
  return list;
}



List<Attn> createTodayEmpList(List data) {
  // print('Create list called/*******************');
  List<Attn> list = new List();

  print("Tril status");
  print(trialstatus);
  int length = data.length;
  if(trialstatus=='2' && length>10)
  {
    length = 10;  // expired organization show only 10 records
  }

  /*int total_dept = 0;
   int total_abs = 0;
   int total_pre = 0;
   int total_emp = 0;*/

  for (int i = 0; i < length; i++) {
    String Id = data[i]['id'].toString();
    String Name = data[i]["name"].toString();
    String TimeIn = data[i]["TimeIn"].toString();
    String TimeOut = data[i]["TimeOut"].toString() == '00:00'
        ? '-'
        : data[i]["TimeOut"].toString();
    String EntryImage = data[i]["EntryImage"].toString() == ''
        ? 'https://ubiattendance.ubihrm.com/assets/img/avatar.png'
        : data[i]["EntryImage"].toString();
    String ExitImage = data[i]["ExitImage"].toString() == ''
        ? 'https://ubiattendance.ubihrm.com/assets/img/avatar.png'
        : data[i]["ExitImage"].toString();
    String CheckInLoc = data[i]["checkInLoc"].toString();
    String CheckOutLoc = data[i]["CheckOutLoc"].toString();
    String LatitIn = data[i]["latit_in"].toString();
    String LatitOut = data[i]["latit_out"].toString();
    String LongiIn = data[i]["longi_in"].toString();
    String LongiOut = data[i]["longi_out"].toString();
    String Total = data[i]["total"].toString();
    String Present = data[i]["present"].toString();
    String Absent = data[i]["absent"].toString();

    Attn tos = new Attn(
      Id: Id,
      Name: Name,
      TimeIn: TimeIn,
      TimeOut: TimeOut,
      EntryImage: EntryImage,
      ExitImage: ExitImage,
      CheckInLoc: CheckInLoc,
      CheckOutLoc: CheckOutLoc,
      LatitIn: LatitIn,
      LatitOut: LatitOut,
      LongiIn: LongiIn,
      LongiOut: LongiOut,
      Total: Total,
      Present: Present,
      Absent: Absent,
    );

    list.add(tos);
  }
  return list;
}

class Attn {
  String Id;
  String Name;
  String TimeIn;
  String TimeOut;
  String EntryImage;
  String ExitImage;
  String CheckInLoc;
  String CheckOutLoc;
  String LatitIn;
  String LatitOut;
  String LongiIn;
  String LongiOut;
  String Total;
  String Present;
  String Absent;

  Attn({
    this.Id,
    this.Name,
    this.TimeIn,
    this.TimeOut,
    this.EntryImage,
    this.ExitImage,
    this.CheckInLoc,
    this.CheckOutLoc,
    this.LatitIn,
    this.LatitOut,
    this.LongiIn,
    this.LongiOut,
    this.Total,
    this.Present,
    this.Absent,
  });
}
List<FaceIdLists> createFaceEmpList(var data) {
   print('Create list called/*******************');
  List<FaceIdLists> list = new List();

  print("Tril status");
  print("Tril status>>>>>>>>>>>>>>>,"+data.toString());

  print(trialstatus);
  if(data!=null) {
    int length = data.length;
    if (trialstatus == '2' && length > 10) {
      length = 10; // expired organization show only 10 records
    }

    /*int total_dept = 0;
   int total_abs = 0;
   int total_pre = 0;
   int total_emp = 0;*/

    for (int i = 0; i < length; i++) {
      String Id = data[i]['Id'].toString();
      String Name = data[i]["name"].toString();
      String Image = data[i]["Profile"].toString();
      String orgid = data[i]["orgid"].toString();


      FaceIdLists tos = new FaceIdLists(
        Id: Id,
        Name: Name,
        Image: Image,
        orgid: orgid,
      );

      list.add(tos);
    }
  }
  return list;
}
class FaceIdLists {
  String Id;
  String Name;
  String Image;
  String orgid;

  FaceIdLists({
    this.Id,
    this.Name,
    this.Image,
    this.orgid,
  });
}

class SyncNotification {
  int Id;
  int EmployeeId;
  int OrganizationId;
  String SyncDate;
  String OfflineMarkedDate;
  String Time;
  String Action;
  String Latitude;
  String Longitude;
  String ReasonForFailure;
  String image;

  SyncNotification(
      this.Id,
      this.EmployeeId,
      this.OrganizationId,
      this.SyncDate,
      this.OfflineMarkedDate,
      this.Time,
      this.Action,
      this.Latitude,
      this.Longitude,
      this.ReasonForFailure,
      this.image,

      );
}



//******************Cdate Attn List Data
Future<List<Attn>> getCDateAttn(listType, date) async {
  final prefs = await SharedPreferences.getInstance();
  trialstatus = prefs.getString('trialstatus') ?? '';
  String orgdir = prefs.getString('orgdir') ?? '';
  String empid = prefs.getString('empid') ?? '';
  print(globals.path + 'getCDateAttendances_new?trialstatus=$trialstatus&refno=$orgdir&date=$date&datafor=$listType&empid=$empid');
  final response = await http.get(globals.path + 'getCDateAttendances_new?trialstatus=$trialstatus&refno=$orgdir&date=$date&datafor=$listType&empid=$empid');
  final res = json.decode(response.body);
// print(res);
  List responseJson;
  if (listType == 'present')
    responseJson = res['present'];
  else if (listType == 'absent')
    responseJson = res['absent'];
  else if (listType == 'latecomings')
    responseJson = res['lateComings'];
  else if (listType == 'earlyleavings') responseJson = res['earlyLeavings'];
  List<Attn> userList = createTodayEmpList(responseJson);
  return userList;
}


Future<List<FaceIdLists>> getregisteredFaceIDList(listType) async {
  final prefs = await SharedPreferences.getInstance();


  String orgdir = prefs.getString('orgdir') ?? '';
  String empid = prefs.getString('empid') ?? '';
  print(globals.path + 'registeredFaceIDList?refno=$orgdir&datafor=$listType&empid=$empid');
  final response = await http.get(globals.path +
      'registeredFaceIDList?refno=$orgdir&datafor=$listType&empid=$empid');
  final res = await json.decode(response.body);
  //debugPrint(res.toString());
  List responseJson;
  if (listType == 'registered')
    responseJson = res['registered'];
  else if (listType == 'unregistered'){
    responseJson = res['unregistered'];
    print("pppppppppp"+responseJson.toString());
  }

  print(responseJson.toString());
  List<FaceIdLists> userList = createFaceEmpList(responseJson);
  return userList;
}

//******************Cdate Attn List Data

//******************Cdate Attn DepartmentWise
Future<List<Attn>> getCDateAttnDeptWise(listType, date, dept) async {
  final prefs = await SharedPreferences.getInstance();
  String orgdir = prefs.getString('orgdir') ?? '';
  print( globals.path + 'getCDateAttnDeptWise_new?refno=$orgdir&date=$date&datafor=$listType&dept=$dept');
  final response = await http.get(globals.path +
      'getCDateAttnDeptWise_new?refno=$orgdir&date=$date&datafor=$listType&dept=$dept');
  // print('================='+dept+'===================');
  final res = json.decode(response.body);
  // print('*************response**************');
  print(res);
  List responseJson;
  if (listType == 'present')
    responseJson = res['present'];
  else if (listType == 'absent')
    responseJson = res['absent'];
  else if (listType == 'latecomings')
    responseJson = res['lateComings'];
  else if (listType == 'earlyleavings') responseJson = res['earlyLeavings'];
  List<Attn> userList = createTodayEmpList(responseJson);
  return userList;
}

Future<List<Attn>> getEmpdataDepartmentWise(date) async {
  final prefs = await SharedPreferences.getInstance();
  String orgdir = prefs.getString('orgdir') ?? '';
//print( globals.path + 'getCDateAttnDeptWise_new?refno=$orgdir&date=$date&datafor=$listType&dept=$dept');
  final response = await http
      .get(globals.path + 'getEmpdataDepartmentWise?refno=$orgdir&date=$date');
  print('=================''===================');
  print(globals.path + 'getEmpdataDepartmentWise?refno=$orgdir&date=$date');
  final res = json.decode(response.body);
  // print('*************response**************');
  print(res);
  List responseJson;
  responseJson = res['departments'];
  List<Attn> userList = createTodayEmpList(responseJson);
  return userList;
}

Future<List<Map<String, String>>> getEmpdataDepartmentWiseCount(date) async {
  final prefs = await SharedPreferences.getInstance();
  String orgdir = prefs.getString('orgdir') ?? '';
//print( globals.path + 'getCDateAttnDeptWise_new?refno=$orgdir&date=$date&datafor=$listType&dept=$dept');
  final response = await http
      .get(globals.path + 'getEmpdataDepartmentWiseCount?refno=$orgdir&date=$date');
  print('=================''===================');
  print(globals.path + 'getEmpdataDepartmentWiseCount?refno=$orgdir&date=$date');
  final data = json.decode(response.body);
  List<Map<String, String>> res = [
    {
      "departments": data['departments'].toString(),
      "total": data['total'].toString(),
      "present": data['present'].toString(),
      "absent": data['absent'].toString()
    }
  ];
  // print('==========');
  // print(res);
  return res;
}

//******************Cdate Attn DepartmentWise//
//******************Cdate Attn DesignationWise

Future<List<Attn>> getCDateAttnDesgWise(listType, date, desg) async {
  final prefs = await SharedPreferences.getInstance();
  String orgdir = prefs.getString('orgdir') ?? '';
  print(globals.path +
      'getCDateAttnDesgWise_new?refno=$orgdir&date=$date&datafor=$listType&desg=$desg');
  final response = await http.get(globals.path +
      'getCDateAttnDesgWise_new?refno=$orgdir&date=$date&datafor=$listType&desg=$desg');
  // print('================='+dept+'===================');
  final res = json.decode(response.body);
  // print('*************response**************');
  print(res);
  List responseJson;
  if (listType == 'present')
    responseJson=res['present'];
  else if (listType == 'absent')
    responseJson=res['absent'];
  else if (listType == 'latecomings')
    responseJson=res['lateComings'];
  else if (listType == 'earlyleavings')
    responseJson=res['earlyLeavings'];
  List<Attn> userList = createTodayEmpList(responseJson);
  return userList;
}

/*Future<List<Map<String, String>>> getCDateAttnDesgWiseCount(date, desg) async {
  final prefs = await SharedPreferences.getInstance();
  String orgdir = prefs.getString('orgdir') ?? '';
  print("Sohan");
   print(globals.path +
       'getCDateAttnDesgWiseCount_new?refno=$orgdir&date=$date&desg=$desg');
  final response = await http.get(globals.path +
      'getCDateAttnDesgWiseCount_new?refno=$orgdir&date=$date&desg=$desg');
  print('=================ssss===================');
  final data = json.decode(response.body);
  print("patel");
  print(data);
  List<Map<String, String>> res = [
    {
      "present": data['present'].toString(),
      "absent": data['absent'].toString(),
      "latecomings": data['latecomings'].toString(),
      "earlyleavings": data['earlyleavings'].toString()
    }
  ];
  // print('==========');
  //print(res);
  return res;
  // print('*************response**************');
}*/

getCsvAlldata(associateListP,associateListA,associateListL,associateListE, fname, name) async {
  //create an element rows of type list of list. All the above data set are stored in associate list
//Let associate be a model class with attributes name,gender and age and associateList be a list of associate model class.

  List<List<dynamic>> rows = List<List<dynamic>>();
  List<dynamic> row1 = List();

  row1.add('Name');
  row1.add('Time In');
  row1.add('Time In Location');
  row1.add('Time Out');
  row1.add('Time Out Location');
  rows.add(row1);

  row1 = List();
  row1.add("  ");
  row1.add("  ");
  row1.add("  ");
  row1.add("  ");
  row1.add("  ");
  rows.add(row1);

  row1 = List();
  row1.add("Presents");
  row1.add("  ");
  row1.add("  ");
  row1.add("  ");
  row1.add("  ");
  rows.add(row1);

  for (int i = 0; i < associateListP.length; i++) {
//row refer to each column of a row in csv file and rows refer to each row in a file
    List<dynamic> row = List();
    row.add(associateListP[i].Name);
    row.add(associateListP[i].TimeIn);
    row.add(associateListP[i].CheckInLoc);
    row.add(associateListP[i].TimeOut);
    row.add(associateListP[i].CheckOutLoc);

    rows.add(row);
  }

  row1 = List();
  row1.add("  ");
  row1.add("  ");
  row1.add("  ");
  row1.add("  ");
  row1.add("  ");
  rows.add(row1);
  rows.add(row1);
  row1 = List();
  row1.add("Absent");
  row1.add("  ");
  row1.add("  ");
  row1.add("  ");
  row1.add("  ");
  rows.add(row1);
  for (int i = 0; i < associateListA.length; i++) {
//row refer to each column of a row in csv file and rows refer to each row in a file
    List<dynamic> row = List();
    row.add(associateListA[i].Name);
    row.add('-');
    row.add('-');
    row.add('-');
    row.add('-');
    rows.add(row);
  }

  row1 = List();
  row1.add("  ");
  row1.add("  ");
  row1.add("  ");
  row1.add("  ");
  row1.add("  ");
  rows.add(row1);
  rows.add(row1);
  row1 = List();
  row1.add("Late Comers");
  row1.add("  ");
  row1.add("  ");
  row1.add("  ");
  row1.add("  ");
  rows.add(row1);
  for (int i = 0; i < associateListL.length; i++) {
//row refer to each column of a row in csv file and rows refer to each row in a file
    List<dynamic> row = List();
    row.add(associateListL[i].Name);
    row.add(associateListL[i].TimeIn);
    row.add(associateListL[i].CheckInLoc);
    row.add(associateListL[i].TimeOut);
    row.add(associateListL[i].CheckOutLoc);
    rows.add(row);
  }

  row1 = List();
  row1.add("  ");
  row1.add("  ");
  row1.add("  ");
  row1.add("  ");
  row1.add("  ");
  rows.add(row1);
  rows.add(row1);
  row1 = List();
  row1.add("Early Leavers");
  row1.add("  ");
  row1.add("  ");
  row1.add("  ");
  row1.add("  ");
  rows.add(row1);

  for (int i = 0; i < associateListE.length; i++){
//row refer to each column of a row in csv file and rows refer to each row in a file
    List<dynamic> row = List();
    row.add(associateListE[i].Name);
    row.add(associateListE[i].TimeIn);
    row.add(associateListE[i].CheckInLoc);
    row.add(associateListE[i].TimeOut);
    row.add(associateListE[i].CheckOutLoc);
    rows.add(row);
  }

  PermissionStatus permission = await PermissionHandler().checkPermissionStatus(PermissionGroup.storage);
  print(permission);
  Map<PermissionGroup, PermissionStatus> permissions;
  if(permission.toString()!='PermissionStatus.granted'){
    permissions = await PermissionHandler().requestPermissions([PermissionGroup.storage]);
    permission = await PermissionHandler().checkPermissionStatus(PermissionGroup.storage);
  }

  //PermissionStatus res = await SimplePermissions.requestPermission(Permission. WriteExternalStorage);
  /*final res = await SimplePermissions.requestPermission(
      Permission.WriteExternalStorage);
  bool checkPermission =
      await SimplePermissions.checkPermission(Permission.WriteExternalStorage);*/
  if (permission.toString() == "PermissionStatus.granted") {
//store file in documents folder
    String dir = (await getExternalStorageDirectory()).absolute.path;
    String file = "$dir/ubiattendance_files/";
    await new Directory('$file').create(recursive: true);
    print(" FILE " + file);
    File f = new File(file + fname + ".csv");

// convert rows to String and write as csv file
    String csv = const ListToCsvConverter().convert(rows);
    f.writeAsString(csv);
    return file + fname + ".csv";
  }
}

//******************Cdate Attn DesignationWise//

//******************yesterday Attn List Data
Future<List<Attn>> getYesAttn(listType) async {
  final prefs = await SharedPreferences.getInstance();
  trialstatus = prefs.getString('trialstatus') ?? '';
  String orgdir = prefs.getString('orgdir') ?? '';
  String empid = prefs.getString('empid') ?? '';
  final response = await http
      .get(globals.path + 'getAttendances_yes?refno=$orgdir&datafor=$listType&empid=$empid');
  final res = json.decode(response.body);
  // print(res);
  List responseJson;
  if (listType == 'present')
    responseJson = res['present'];
  else if (listType == 'absent')
    responseJson = res['absent'];
  else if (listType == 'latecomings')
    responseJson = res['lateComings'];
  else if (listType == 'earlyleavings') responseJson = res['earlyLeavings'];
  List<Attn> userList = createTodayEmpList(responseJson);
  return userList;
}
//******************yesterday Attn List Data

// getData list for last 7/30 days- start
Future<List<Attn>> getAttnDataLast(days, listType) async {
  final prefs = await SharedPreferences.getInstance();
  String orgdir = prefs.getString('orgdir') ?? '';
  print(days);
  print(listType);
  print(globals.path + 'getAttnDataLast?refno=$orgdir&datafor=$listType&limit=$days');
  final response = await http.get(globals.path + 'getAttnDataLast?refno=$orgdir&datafor=$listType&limit=$days');
  final res = json.decode(response.body);
//  print(res);
  List responseJson;
  responseJson = res['elist'];

  /*if (listType == 'present')
    responseJson = res['elist'];
  else if (listType == 'absent')
    responseJson = res['absent'];
  else if (listType == 'latecomings')
    responseJson = res['lateComings'];
  else if (listType == 'earlyleavings')
    responseJson = res['earlyLeavings'];*/
  List<Attn> userList = createLastEmpList(responseJson);
  return userList;
}

// getData list for last 7/30 days- close
List<Attn> createLastEmpList(List data) {
  data = data.reversed.toList();
  List<Attn> list = new List();

  for (int i = 0; i < data.length; i++) {
    //  print('Create list called*******************');
    // print(data[i][0]['name']);
    String Name = '';
    String TimeIn = '';
    String TimeOut = '';
    String date = '';
    String ExitImage = '';
    String CheckInLoc = '';
    String CheckOutLoc = '';
    String LatitIn = '';
    String LatitOut = '';
    String LongiIn = '';
    String LongiOut = '';
    if (data[i].length != 0) {
      for (int j = 0; j < data[i].length; j++) {
        Name = data[i][j]["name"].toString();
        TimeIn = data[i][j]["TimeIn"].toString() == '00:00:00' ||
            data[i][j]["TimeIn"].toString() == '-'
            ? '-'
            : data[i][j]["TimeIn"].toString().substring(0, 5);
        TimeOut = data[i][j]["TimeOut"].toString() == '00:00:00' ||
            data[i][j]["TimeOut"].toString() == '-'
            ? '-'
            : data[i][j]["TimeOut"].toString().substring(0, 5);
        //date = Formatdate(data[i][j]["AttendanceDate"].toString());
        date = Formatdate1(data[i][j]["AttendanceDate"].toString());
        //print(date);
        //print('date');
        ExitImage = '';
        CheckInLoc = '';
        CheckOutLoc = '';
        LatitIn = '';
        LatitOut = '';
        LongiIn = '';
        LongiOut = '';

        Attn tos = new Attn(
            Name: Name,
            TimeIn: TimeIn,
            TimeOut: TimeOut,
            EntryImage: date,
            ExitImage: ExitImage,
            CheckInLoc: CheckInLoc,
            CheckOutLoc: CheckOutLoc,
            LatitIn: LatitIn,
            LatitOut: LatitOut,
            LongiIn: LongiIn,
            LongiOut: LongiOut);
        list.add(tos);
      }
    }
  }
  return list;
}

//********************************************************************************************//
// ////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////
/////////////////////////REPORTS SERVICES ENDS///////////////////////
//////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////

// ////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////
/////////////////////////Get chart data start///////////////////////
//////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////
//********************************************************************************************//
Future<List<Map<String, String>>> getChartDataToday() async {
  final prefs = await SharedPreferences.getInstance();
  String orgdir = prefs.getString('orgdir') ?? '';
  String empid = prefs.getString('empid') ?? '';

  final response =
  await http.get(globals.path + 'getChartDataToday?refno=$orgdir&empid=$empid');
  final data = json.decode(response.body);
  List<Map<String, String>> val = [
    {
      "present": data['present'].toString(),
      "absent": data['absent'].toString(),
      "late": data['late'].toString(),
      "early": data['early'].toString()
    }
  ];
  // print('==========');
  // print(val);
  return val;
}

Future<List<Map<String, String>>> getChartDataYes() async {
  final prefs = await SharedPreferences.getInstance();
  String orgdir = prefs.getString('orgdir') ?? '';
  String empid = prefs.getString('empid') ?? '';
  final response =
  await http.get(globals.path + 'getChartDataYes?refno=$orgdir&empid=$empid');
  final data = json.decode(response.body);
  List<Map<String, String>> val = [
    {
      "present": data['present'].toString(),
      "absent": data['absent'].toString(),
      "late": data['late'].toString(),
      "early": data['early'].toString()
    }
  ];
  // print('==========');
  // print(val);
  return val;
}

Future<List<Map<String, String>>> getChartDataCDate(date) async {
  final prefs = await SharedPreferences.getInstance();
  String orgdir = prefs.getString('orgdir') ?? '';
  print(globals.path + 'getChartDataCDate?refno=$orgdir&date=$date');
  final response = await http
      .get(globals.path + 'getChartDataCDate?refno=$orgdir&date=$date');
  final data = json.decode(response.body);
  //print(response);
  List<Map<String, String>> val = [
    {
      "present": data['present'].toString(),
      "absent": data['absent'].toString(),
      "late": data['late'].toString(),
      "early": data['early'].toString()
    }
  ];
  // print('==========');
  // print(val);
  return val;
}

Future<List<Map<String, String>>> getChartDataLast(dys) async {
  // dys: no. of days
  print(dys);
  print("1234567788");
  final prefs = await SharedPreferences.getInstance();
  String orgdir = prefs.getString('orgdir') ?? '';
  List<Map<String, String>> val = [];
  print(globals.path + 'getChartDataLast_7_30?refno=$orgdir&limit=$dys');
  final response = await http.get(globals.path + 'getChartDataLast_7_30?refno=$orgdir&limit=$dys');
  final data = json.decode(response.body);
  for (int i = 0; i < data.length; i++)
    val.add({
      "date": data[i]['event'].toString(),
      "total": data[i]['total'].toString()
    });

  return val;
}
/*
Future<List<Map<String, String>>> getChartDataLast(dys) async {
  // dys: no. of days
  final prefs = await SharedPreferences.getInstance();
  String orgdir = prefs.getString('orgdir') ?? '';
  List<Map<String, String>> val = [];
  if (dys.toString() == 'l7') {
    final response = await http
        .get(globals.path + 'getChartDataLast_7?refno=$orgdir&limit=$dys');
    final data = json.decode(response.body);
    for (int i = 0; i < data.length; i++)
      val.add({
        "date": data[i]['event'].toString(),
        "total": data[i]['total'].toString()
      });
  } else if (dys.toString() == 'l30') {
    final response = await http
        .get(globals.path + 'getChartDataLast_30?refno=$orgdir&limit=$dys');
    final data = json.decode(response.body);
    for (int i = 0; i < data.length; i++)
      val.add({
        "date": data[i]['event'].toString(),
        "total": data[i]['total'].toString()
      });
  }
  return val;
}*/
//********************************************************************************************//
// ////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////
/////////////////////////Get chart data ends///////////////////////
//////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////

// ////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////
/////////////////////////Get late/early/timeoff emp reports///////////////////////
//////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////
//********************************************************************************************//
Future<List<EmpList>> getLateEmpDataList(date) async {
  if (date == '' || date == null) return null;
  // print('shifts called');
  final prefs = await SharedPreferences.getInstance();
  String orgid = prefs.getString('orgdir') ?? '';
  final response =
  await http.get(globals.path + 'getlateComings?refno=$orgid&cdate=$date');
  List responseJson = json.decode(response.body.toString());
  List<EmpList> list = createListLateComings(responseJson);
  //print(list);
  return list;
}

List<EmpList> createListLateComings(List data) {
  List<EmpList> list = new List();
  for (int i = 0; i < data.length; i++) {
    String diff = data[i]["lateby"];
    String timeAct = data[i]["timein"];
    String name = data[i]["name"];
    String shift = data[i]["shift"];
    String date = data[i]["date"];
    EmpList row = new EmpList(
        diff: diff, timeAct: timeAct, name: name, shift: shift, date: date);
    list.add(row);
  }
  return list;
}

class EmpList {
  String diff;
  String timeAct; // timein or timeout
  String name;
  String shift;
  String date;

  EmpList({this.diff, this.timeAct, this.name, this.shift, this.date});
}

////*********************************************************************
Future<List<EmpList>> getEarlyEmpDataList(date) async {
  if (date == '' || date == null) return null;
  // print('shifts called');
  final prefs = await SharedPreferences.getInstance();
  String orgid = prefs.getString('orgdir') ?? '';
  final response = await http
      .get(globals.path + 'getEarlyLeavings?refno=$orgid&cdate=$date');
  List responseJson = json.decode(response.body.toString());
  List<EmpList> list = createListEarlyLeaving(responseJson);
  // print(list);
  return list;
}

List<EmpList> createListEarlyLeaving(List data) {
  List<EmpList> list = new List();
  for (int i = 0; i < data.length; i++) {
    String diff = data[i]["earlyby"];
    String timeAct = data[i]["timeout"];
    String name = data[i]["name"];
    String shift = data[i]["shift"];
    String date = data[i]["date"];
    EmpList row = new EmpList(
        diff: diff, timeAct: timeAct, name: name, shift: shift, date: date);
    list.add(row);
  }
  return list;
}

//*******************************************************
Future<List<EmpListTimeOff>> getTimeOFfDataList(date) async {
  if (date == '' || date == null) return null;
  final prefs = await SharedPreferences.getInstance();
  String orgid = prefs.getString('orgdir') ?? '';
  print(globals.path + 'getTimeoffList?fd=$date&to=$date&refno=$orgid');
  final response = await http.get(globals.path + 'getTimeoffList?fd=$date&to=$date&refno=$orgid');

  List responseJson = await json.decode(response.body.toString());
  // print(responseJson.toString());
  List<EmpListTimeOff> list = createTimeOFfDataList(responseJson);
//  print(list);
  return list;
}

List<EmpListTimeOff> createTimeOFfDataList_old(List data) {
  List<EmpListTimeOff> list = new List();
  for (int i = 0; i < data.length; i++) {
    String diff = data[i]["diff"];
    String to = data[i]["TimeTo"];
    String from = data[i]["TimeFrom"];
    String name = data[i]["name"];
    String date = data[i]["tod"];
    String ApprovalSts = data[i]["ApprovalSts"];
    EmpListTimeOff row = new EmpListTimeOff(
        diff: diff, to: to, from: from, name: name, date: date,ApprovalSts:ApprovalSts);
    list.add(row);
  }
  return list;
}

List<EmpListTimeOff> createTimeOFfDataList(List data) {
  List<EmpListTimeOff> list = new List();
  print("aaaabbbcc>>>>"+data.toString());
  for (int i = 0; i < data.length; i++) {
    String diff = data[i]["diff"];
    String to = data[i]["TimeTo"];
    String from = data[i]["TimeFrom"];
    String name = data[i]["name"];
    String date = data[i]["tod"];
    String ApprovalSts = data[i]["ApprovalSts"];
    String Reason = data[i]["reason"];
    String StartLoc = data[i]["startloc"];
    String LatIn = data[i]["latin"].toString();
    String LongIn = data[i]["longin"].toString();
    String EndLoc = data[i]["endloc"].toString();
    String LatOut = data[i]["latout"].toString();
    String LongOut = data[i]["longout"].toString();
    EmpListTimeOff row = new EmpListTimeOff(
        diff: diff,
        to: to,
        from: from,
        name: name,
        date: date,
        ApprovalSts:ApprovalSts,
        Reason:Reason,
        StartLoc: StartLoc,
        LatIn: LatIn,
        LongIn: LongIn,
        EndLoc: EndLoc,
        LatOut: LatOut,
        LongOut: LongOut
    );
    list.add(row);
  }
  return list;
}

class EmpListTimeOff {
  String diff;
  String to;
  String from;
  String name;
  String date;
  String ApprovalSts;
  String Reason;
  String StartLoc;
  String LatIn;
  String LongIn;
  String EndLoc;
  String LatOut;
  String LongOut;

  EmpListTimeOff({this.diff, this.to, this.from, this.name, this.date,this.ApprovalSts,this.Reason,this.StartLoc,this.LatIn,this.LongIn,this.EndLoc,this.LatOut,this.LongOut});
}
//********************************************************************************************//
// ////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////
/////////////////////////Get late/early emp reports/timeoff close///////////////////////
//////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////

///////////////////////////////////////////////////////////////////////
////////////////////////////Punch location/visits  reports start////////////////////////
///////////////////////////////////////////////////////////////////////

Future<List<Punch>> getVisitsDataList(date,emp) async {
  final prefs = await SharedPreferences.getInstance();
  String empid = prefs.getString('empid') ?? '';
  String orgdir = prefs.getString('orgdir') ?? '';
  print(globals.path + 'getPunchInfo?orgid=$orgdir&date=$date&uid=$emp&loginemp=$empid');
  final response =
  await http.get(globals.path + 'getPunchInfo?orgid=$orgdir&date=$date&uid=$emp&loginemp=$empid');
  List responseJson = json.decode(response.body.toString());
  List<Punch> userList = createUserList(responseJson);
  // print('getSummaryPunch called--1');
//  print(userList);
  // print('getSummaryPunch called--2');
  return userList;
}

// ///////////////////////////////////////////////////////////////////
////////////////////////////Punch location/visits  reports ends////////////////////////
///////////////////////////////////////////////////////////////////////
Future<Map> checkOrganization(crn) async {
  final response =
  await http.get(globals.path + 'checkOrganization?refid=$crn');

  var responseJson = json.decode(response.body.toString());
  Map<String, String> res;
  if (responseJson['sts'].toString() == '1')
    res = {
      'sts': responseJson['sts'].toString(),
      'Id': responseJson['result'][0]['Id'].toString(),
      'Name': responseJson['result'][0]['Name'].toString()
    };
  else
    res = {'sts': responseJson['sts'].toString()};
  return res;
}

Future<List> getAttentancees() async {
  final prefs = await SharedPreferences.getInstance();
  String orgid = prefs.getString('orgdir') ?? '';
  final response =
  await http.get(globals.path + 'getAttendancees?orgid=$orgid');
  List responseJson = json.decode(response.body.toString());
  print(responseJson);
  return responseJson;
  // List<Shift> shiftList = createShiftList(responseJson);

  // return shiftList;
}

MarkAttendance(data) {
  print('bulk attendance mark successfully');
  //print(data);
}

// ///////////////////////////////////////////////////////////////////
////////////////////////////Bulk Attendance////////////////////////
///////////////////////////////////////////////////////////////////////

class grpattemp {
  String Name;
  String Department;
  String Designation;
  String Status;
  String Id;
  String img;
  String attsts;
  String timein;
  String timeout;
  String rtimein;
  String rtimeout;
  String todate;
  String shift;
  String shifttype;
  int csts;
  String Attid;
  String data_date;
  String device;
  String InPushNotificationStatus;
  String OutPushNotificationStatus;

  grpattemp(
      {this.Name,
        this.Department,
        this.Designation,
        this.Status,
        this.csts,
        this.img,
        this.attsts,
        this.timein,
        this.timeout,
        this.rtimein,
        this.rtimeout,
        this.todate,
        this.shift,
        this.shifttype,
        this.Id,
        this.Attid,
        this.data_date,
        this.device,
        this.InPushNotificationStatus,
        this.OutPushNotificationStatus});
}

Future<List<grpattemp>> getDeptEmp(value) async {
  final prefs = await SharedPreferences.getInstance();
  String orgid = prefs.getString('orgdir') ?? '';
  String empid = prefs.getString('empid')?? '0';
  print(value);

  String formattedDate;
  if (value == "Today") {
    var now = new DateTime.now();
    print(now);
    var formatter = new DateFormat('yyyy-MM-dd');
    formattedDate = formatter.format(now);
    print(formattedDate);
    print("bbbbbb");
  }

  if (value == "Yesterday") {
    var today = new DateTime.now();
    DateTime onedayago = today.subtract(new Duration(days: 1));
    var formatter = new DateFormat('yyyy-MM-dd');
    formattedDate = formatter.format(onedayago);
    print(formattedDate);
  }
  //print(globals.path + 'getDeptEmp?orgid=$orgid&dept=13');
  final response =
  await http.get(globals.path + 'getDeptEmp?orgid=$orgid&datafor=$value&empid=$empid');

  print(globals.path + 'getDeptEmp?orgid=$orgid&datafor=$value&empid=$empid');
  List responseJson = json.decode(response.body.toString());
  responseEmplist = responseJson; // set employee data in globle var
  // print(responseJson);
  List<grpattemp> deptList = createDeptempList(responseJson);
  // print(responseJson);
  return deptList;
}



List<grpattemp> createDeptempList(List data) {
  List<grpattemp> list = new List();
  for (int i = 0; i < data.length; i++) {
    String name = data[i]["name"];
    // String status=data[i]["archive"]=='1'?'Active':'Inactive';
    String id = data[i]["id"];
    int csts = data[i]["csts"];
    String img = data[i]["img"];
    // String timein=data[i]["timein"];
    String timein = data[i]["timein"];
    String timeout = data[i][
    "timeout"]; //(hour: data[i]["timeout"].split(":")[0], minute: data[i]["timeout"].split(":")[1]);
    //print(timein+' and '+timeout);
    String attsts = '1';
    String todate = data[i]["todate"];
    String shift = data[i]["shift"];
    String shifttype = data[i]["shifttype"];
    String rtimein = data[i]["rtimein"];
    String rtimeout = data[i]["rtimeout"];
    String attid = data[i]["Attid"];
    String data_date = data[i]["data_date"];
    String device = data[i]["device"];
    String InPushNotificationStatus = data[i]["InPushNotificationStatus"];
    String OutPushNotificationStatus = data[i]["OutPushNotificationStatus"];
    //String timein='';
    //String timeout ='';
    if (data[i]["rtimein"] != '') {
      timein = data[i]["rtimein"];
    }
    if (data[i]["rtimeout"] != '') {
      timeout = data[i]["rtimeout"];
    }
    print("......");
    print(timein);
    print(timeout);
    grpattemp dpt = new grpattemp(
        Name: name,
        csts: csts,
        img: img,
        attsts: attsts,
        timein: timein,
        timeout: timeout,
        todate: todate,
        shift: shift,
        shifttype: shifttype,
        Id: id,
        Attid: attid,
        data_date: data_date,
        device: device,
        InPushNotificationStatus:InPushNotificationStatus,
        OutPushNotificationStatus:OutPushNotificationStatus);
    list.add(dpt);
  }
  return list;
}

Future<List<grpattemp>> getDeptEmp_Search($val) async {
  List<grpattemp> deptList = createDeptempList_search(responseEmplist, $val);
  return deptList;
}


updateEmployeePushNotificationStatus(bool valueOfSwitch,var empid,String action) async{
  empid=empid.toString();
  int value=valueOfSwitch?1:0;
  print(globals.path + 'updatePushNotificationStatusForEmployee?employeeId=$empid&action=$action&value=$value');

  final response =
  await http.get(globals.path+'updatePushNotificationStatusForEmployee?employeeId=$empid&action=$action&value=$value');

}



List<grpattemp> createDeptempList_search(List data , String empname){
  List<grpattemp> list = new List();
  for (int i = 0; i < data.length; i++) {
    String name = data[i]["name"];
    // String status=data[i]["archive"]=='1'?'Active':'Inactive';
    String id = data[i]["id"];
    int csts = data[i]["csts"];
    String img = data[i]["img"];
    // String timein=data[i]["timein"];
    String timein = data[i]["timein"];
    String timeout = data[i][
    "timeout"]; //(hour: data[i]["timeout"].split(":")[0], minute: data[i]["timeout"].split(":")[1]);
    //print(timein+' and '+timeout);
    String attsts = '1';
    String todate = data[i]["todate"];
    String shift = data[i]["shift"];
    String shifttype = data[i]["shifttype"];
    String rtimein = data[i]["rtimein"];
    String rtimeout = data[i]["rtimeout"];
    String attid = data[i]["Attid"];
    String data_date = data[i]["data_date"];
    String device = data[i]["device"];
    String InPushNotificationStatus = data[i]["InPushNotificationStatus"];
    String OutPushNotificationStatus = data[i]["OutPushNotificationStatus"];

    //String timein='';
    //String timeout ='';
    if (data[i]["rtimein"] != '') {
      timein = data[i]["rtimein"];
    }
    if (data[i]["rtimeout"] != '') {
      timeout = data[i]["rtimeout"];
    }
    print("......");
    print(timein);
    print(timeout);
    grpattemp dpt = new grpattemp(
        Name: name,
        csts: csts,
        img: img,
        attsts: attsts,
        timein: timein,
        timeout: timeout,
        todate: todate,
        shift: shift,
        shifttype: shifttype,
        Id: id,
        Attid: attid,
        data_date: data_date,
        device: device,
        InPushNotificationStatus:InPushNotificationStatus,
        OutPushNotificationStatus:OutPushNotificationStatus
    );
    if(name.toLowerCase().contains(empname.toLowerCase()))
      list.add(dpt);


  }
  return list;
}



addBulkAtt(List<grpattemp> data) async {
  var dio = new Dio();
  String location = globals.globalstreamlocationaddr;

  String lat = globals.assign_lat.toString();
  String long = globals.assign_long.toString();
  print("global Address: " + location);
  print("global lat" + lat);
  print("global long" + long);
  print("_updatetimeoutt");
  // print(_updatetimeout);
  List<Map> list = new List();
  print(data);
  //print(list);
  for (int i = 0; i < data.length; i++) {
    String Attid = data[i].Attid.toString();
    Map per = {
      "Id": data[i].Id.toString(),
      "Name": data[i].Name.toString(),
      "timein": data[i].timein,
      "timeout": data[i].timeout,
      "attsts": data[i].attsts.toString(),
      "todate": data[i].todate.toString(),
      "shift": data[i].shift.toString(),
      "Attid": data[i].Attid.toString(),
      "data_date": data[i].data_date.toString(),

    };
    list.add(per);
  }
  var jsonlist;
  jsonlist = json.encode(list);
  print(jsonlist);
  //print('RECIEVED STATUS: '+status.toString());
  final prefs = await SharedPreferences.getInstance();
  String empid = prefs.getString('empid') ?? '';
  String orgdir = prefs.getString('orgdir') ?? '';
//  print('addEmp function called, parameters :');
  String plateform = 'android';
  print(globals.path +
      'CreateBulkAtt?uid=$empid&org_id=$orgdir&attlist=$jsonlist&platform=$plateform');
  try {
    FormData formData = new FormData.from({
      "attlist": jsonlist,
      "org_id": orgdir,
      "uid": empid,
      "location": location,
      "lat": lat,
      "long": long,
      "platform":plateform
    });
    Response response = await dio.post(globals.path + "CreateBulkAtt/",
        data:
        formData); //, options: new Options(contentType:ContentType.parse("application/json"))
    //print(response.data.toString());
    //Map permissionMap = json.decode(response.data.toString());
    if (response.statusCode == 200) {
      print("successfully");
      return "success";
    } else {
      //print("failed");
      return "failed";
    }
  } catch (e) {
    //print("connection error");
    return "connection error";
    //print(e.toString());
  }
  final response = await http.get(globals.path +
      'CreateBulkAtt?uid=$empid&org_id=$orgdir&attlist=$jsonlist');
  var res = json.decode(response.body);
  print("--------> Adding Bulk Attendance" + res.toString());
  return res['sts'];
}
///////////////////////////////////////////////////////////
////////////////////////////group attendance ends///////////////////////////////
///////////////////////////////////////////////////////////

////////////check net
Future<int> checkNet() async {
  try {
    final result = await InternetAddress.lookup('google.com');
    if (result.isNotEmpty && result[0].rawAddress.isNotEmpty){
    //http.Response response = await http.get('https://google.com')/*.timeout(const Duration(seconds: 7))*/;
    //final result = await InternetAddress.lookup('ubihrm.com')/*.timeout(const Duration(seconds: 2))*/;
    //if (response.statusCode==200) {
      print('connected');
      varCheckNet = 1;
    } else {
      varCheckNet = 0;
    }
  } on SocketException catch (_) {
    print('not connected');
    varCheckNet = 0;
  }on TimeoutException catch(_){
    varCheckNet = 0;
  }
  return varCheckNet;
}
////////////check net/

getAddressFromLati( String Latitude,String Longitude) async{
  try {
    ///print(_currentLocation);
    //print("${_currentLocation["latitude"]},${_currentLocation["longitude"]}");
    if (globals.assign_lat.compareTo(0.0) != 0&& globals.assign_lat!=null) {
      var addresses = await Geocoder.local.findAddressesFromCoordinates(
          Coordinates(
              globals.assign_lat, globals.assign_long));
      var first = addresses.first;
      //streamlocationaddr = "${first.featureName} : ${first.addressLine}";
      var streamlocationaddr = "${first.addressLine}";
      var city = "${first.locality}";
      print(city);

      globalstreamlocationaddr = streamlocationaddr;
      globalcity = city;
      return streamlocationaddr;
    }
    else{
      globalstreamlocationaddr="Location not fetched.";

      return globalstreamlocationaddr;
    }

  }catch(e){
    print(e.toString());
    if (globals.assign_lat.compareTo(0.0) != 0&&globals.assign_lat!=null) {
      globalstreamlocationaddr = "$Latitude,$Longitude";
      print("inside iffffffffffffffffffffffffffffffffffffffffffffff"+globals.assign_lat.toString());
    }
    else{
      globalstreamlocationaddr="Location not fetched.";
    }

    return globals.globalstreamlocationaddr;
  }
}

getAddressFromLati_offline( double Latitude,double Longitude) async{
  try {
    ///print(_currentLocation);
    //print("${_currentLocation["latitude"]},${_currentLocation["longitude"]}");

    if (Latitude.compareTo(0.0) != 0&& Latitude!=null) {
      var addresses = await Geocoder.local.findAddressesFromCoordinates(
          Coordinates(
              Latitude, Longitude));
      var first = addresses.first;
      //streamlocationaddr = "${first.featureName} : ${first.addressLine}";
      var streamlocationaddr = "${first.addressLine}";

      globalstreamlocationaddr = streamlocationaddr;
      return streamlocationaddr;
    }
    else{
      globalstreamlocationaddr="Location not fetched.";

      return globalstreamlocationaddr;
    }

  }catch(e){
    print(e.toString());
    if (Latitude.compareTo(0.0) != 0&& Latitude!=null) {
      globalstreamlocationaddr = "$Latitude,$Longitude";
      print("inside iffffffffffffffffffffffffffffffffffffffffffffff"+globals.assign_lat.toString());
    }
    else{
      globalstreamlocationaddr="Location not fetched.";
    }

    return globals.globalstreamlocationaddr;
  }
}



checkNetForOfflineMode(context) {
 // checkLocationEnabled(context);
  checkNet().then((value) async {
    var prefs=await SharedPreferences.getInstance();
    var isLoggedIn=prefs.getInt("response");
  var OfflineModePermitted=prefs.getInt("OfflineModePermission")??0;


    if (value == 0) {
      print(
          '====================internet checked...Not connected=====================');
      SchedulerBinding.instance.addPostFrameCallback((_) {
      if(isLoggedIn==1 && OfflineModePermitted==1) {
        Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => OfflineHomePage()), (Route<dynamic> route) => false,);
      }
      });
    }
  });
}


appResumedFromBackground(context){
appResumedPausedLogic(context);
}



checknetonpage(context) {
  checkNet().then((value) {
    if (value == 0) {
      print(
          '====================internet checked...Not connected=====================');
      SchedulerBinding.instance.addPostFrameCallback((_) {
        Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => OfflineHomePage()), (Route<dynamic> route) => false,);
      /*  Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => OfflineHomePage()),
        );*/
      });
    }
  });
}

Future<String> getAreaStatus() async {
  //print('getAreaStatus 1');
 // LocationData _currentLocation = globals.list[globals.list.length - 1];
  double lat = globals.assign_lat;
  double long = globals.assign_long;
  double assign_lat = globals.assigned_lat;
  double assign_long = globals.assigned_long;
  double assign_radius = globals.assign_radius;

  /*print("${assign_long}");
  print("${assign_lat}");
  print("${assign_radius}");*/
  final prefs = await SharedPreferences.getInstance();
  String empid = prefs.getString('empid') ?? '';
  //print('SERVICE CALLED: '+globals.path + 'getAreaStatus?lat=$lat&long=$long&empid=$empid');
  String status = '0';
  /*if(empid!=null && empid!='' && empid!=0) {
    final response =
    await http.get(
        globals.path + 'getAreaStatus?lat=$lat&long=$long&empid=$empid');
    status = json.decode(response.body.toString());
  }*/
  //print('-------status----------->');
  //print(status);
  // print('<-------status-----------');
  if (empid != null && empid != '' && empid != 0) {
    double calculateDistance(lat1, lon1, lat2, lon2) {
      var p = 0.017453292519943295;
      var c = cos;
      var a = 0.5 -
          c((lat2 - lat1) * p) / 2 +
          c(lat1 * p) * c(lat2 * p) * (1 - c((lon2 - lon1) * p)) / 2;
      return 12742 * asin(sqrt(a));
    }

    double totalDistance =
        calculateDistance(lat, long, assign_lat, assign_long);
    status = (assign_radius >= totalDistance) ? '1' : '0';
    // print("sohan ${status}");
  }
 // print(status);
  return status;
}

getCsv(associateList, fname, name) async {
  //create an element rows of type list of list. All the above data set are stored in associate list
//Let associate be a model class with attributes name,gender and age and associateList be a list of associate model class.

  List<List<dynamic>> rows = List<List<dynamic>>();
  List<dynamic> row1 = List();

  if (name == 'dept') {
    row1.add('Department');
    row1.add('Total');
    row1.add('Present');
    row1.add('Absent');
    rows.add(row1);
    for (int i = 0; i < associateList.length; i++) {
//row refer to each column of a row in csv file and rows refer to each row in a file
      List<dynamic> row = List();
      row.add(associateList[i].Name);
      row.add(associateList[i].Total);
      row.add(associateList[i].Present);
      row.add(associateList[i].Absent);
      rows.add(row);
    }
  } else {
    row1.add('Name');
    if (name != 'absent') {
      row1.add('Time In');
      row1.add('Time In Location');
      row1.add('Time Out');
      row1.add('Time Out Location');
    }
    rows.add(row1);
    for (int i = 0; i < associateList.length; i++) {
//row refer to each column of a row in csv file and rows refer to each row in a file
      List<dynamic> row = List();
      row.add(associateList[i].Name);
      if (name != 'absent') {
        row.add(associateList[i].TimeIn);
        row.add(associateList[i].CheckInLoc);
        row.add(associateList[i].TimeOut);
        row.add(associateList[i].CheckOutLoc);
      }
      rows.add(row);
    }
  }


  PermissionStatus permission = await PermissionHandler().checkPermissionStatus(PermissionGroup.storage);
  print(permission);
  Map<PermissionGroup, PermissionStatus> permissions;
  if(permission.toString()!='PermissionStatus.granted'){
    permissions = await PermissionHandler().requestPermissions([PermissionGroup.storage]);
    permission = await PermissionHandler().checkPermissionStatus(PermissionGroup.storage);
  }

  //PermissionStatus res = await SimplePermissions.requestPermission(Permission. WriteExternalStorage);
  /*final res = await SimplePermissions.requestPermission(
      Permission.WriteExternalStorage);
  bool checkPermission =
      await SimplePermissions.checkPermission(Permission.WriteExternalStorage);*/
  if (permission.toString() == "PermissionStatus.granted") {
//store file in documents folder
    String dir = (await getExternalStorageDirectory()).absolute.path;
    String file = "$dir/ubiattendance_files/";
    await new Directory('$file').create(recursive: true);
    print(" FILE " + file);
    File f = new File(file + fname + ".csv");

// convert rows to String and write as csv file
    String csv = const ListToCsvConverter().convert(rows);
    f.writeAsString(csv);
    return file + fname + ".csv";
  }
}

getCsvDesg(associateList, fname, name) async {
  //create an element rows of type list of list. All the above data set are stored in associate list
//Let associate be a model class with attributes name,gender and age and associateList be a list of associate model class.

  List<List<dynamic>> rows = List<List<dynamic>>();
  List<dynamic> row1 = List();
  row1.add('Name');
  if (name == 'desg') {
    row1.add('Time In');
    row1.add('Time In Location');
    row1.add('Time Out');
    row1.add('Time Out Location');
    rows.add(row1);
    for (int i = 0; i < associateList.length; i++) {
//row refer to each column of a row in csv file and rows refer to each row in a file
      List<dynamic> row = List();
      row.add(associateList[i].Name);
      row.add(associateList[i].TimeIn);
      row.add(associateList[i].CheckInLoc);
      row.add(associateList[i].TimeOut);
      row.add(associateList[i].CheckOutLoc);
      rows.add(row);
    }
  }

  PermissionStatus permission = await PermissionHandler().checkPermissionStatus(PermissionGroup.storage);
  print(permission);
  Map<PermissionGroup, PermissionStatus> permissions;
  if(permission.toString()!='PermissionStatus.granted'){
    permissions = await PermissionHandler().requestPermissions([PermissionGroup.storage]);
    permission = await PermissionHandler().checkPermissionStatus(PermissionGroup.storage);
  }

  //PermissionStatus res = await SimplePermissions.requestPermission(Permission. WriteExternalStorage);
  /*final res = await SimplePermissions.requestPermission(
      Permission.WriteExternalStorage);
  bool checkPermission =
      await SimplePermissions.checkPermission(Permission.WriteExternalStorage);*/
  if (permission.toString() == "PermissionStatus.granted") {
//store file in documents folder
    String dir = (await getExternalStorageDirectory()).absolute.path;
    String file = "$dir/ubiattendance_files/";
    await new Directory('$file').create(recursive: true);
    print(" FILE " + file);
    File f = new File(file + fname + ".csv");

// convert rows to String and write as csv file
    String csv = const ListToCsvConverter().convert(rows);
    f.writeAsString(csv);
    return file + fname + ".csv";
  }
}

getCsvEmpWise(associateList, fname, name) async {
  //create an element rows of type list of list. All the above data set are stored in associate list
//Let associate be a model class with attributes name,gender and age and associateList be a list of associate model class.

  List<List<dynamic>> rows = List<List<dynamic>>();
  List<dynamic> row1 = List();
  row1.add('Name');
  if (name == 'desg' && name != 'absent') {
    row1.add('Time In');
    row1.add('Time In Location');
    row1.add('Time Out');
    row1.add('Time Out Location');
    rows.add(row1);
    for (int i = 0; i < associateList.length; i++) {
//row refer to each column of a row in csv file and rows refer to each row in a file
      List<dynamic> row = List();
      row.add(associateList[i].Name);
      if (name != 'absent') {
        row.add(associateList[i].TimeIn);
        row.add(associateList[i].CheckInLoc);
        row.add(associateList[i].TimeOut);
        row.add(associateList[i].CheckOutLoc);
      }
      rows.add(row);
    }
  }

  PermissionStatus permission = await PermissionHandler().checkPermissionStatus(PermissionGroup.storage);
  print(permission);
  Map<PermissionGroup, PermissionStatus> permissions;
  if(permission.toString()!='PermissionStatus.granted'){
    permissions = await PermissionHandler().requestPermissions([PermissionGroup.storage]);
    permission = await PermissionHandler().checkPermissionStatus(PermissionGroup.storage);
  }

  //PermissionStatus res = await SimplePermissions.requestPermission(Permission. WriteExternalStorage);
  /*final res = await SimplePermissions.requestPermission(
      Permission.WriteExternalStorage);
  bool checkPermission =
      await SimplePermissions.checkPermission(Permission.WriteExternalStorage);*/
  if (permission.toString() == "PermissionStatus.granted") {
//store file in documents folder
    String dir = (await getExternalStorageDirectory()).absolute.path;
    String file = "$dir/ubiattendance_files/";
    await new Directory('$file').create(recursive: true);
    print(" FILE " + file);
    File f = new File(file + fname + ".csv");

// convert rows to String and write as csv file
    String csv = const ListToCsvConverter().convert(rows);
    f.writeAsString(csv);
    return file + fname + ".csv";
  }
}

getCsv1(associateList, fname, name) async {
  //create an element rows of type list of list. All the above data set are stored in associate list
//Let associate be a model class with attributes name,gender and age and associateList be a list of associate model class.

  List<List<dynamic>> rows = List<List<dynamic>>();
  List<dynamic> row1 = List();

  if (name == 'lateComers') {
    row1.add('Name');
    row1.add('Shift');
    row1.add('Time In');
    row1.add('Late By');
    rows.add(row1);
    for (int i = 0; i < associateList.length; i++) {
//row refer to each column of a row in csv file and rows refer to each row in a file
      List<dynamic> row = List();
      row.add(associateList[i].name);
      row.add(associateList[i].shift);
      row.add(associateList[i].timeAct);
      row.add(associateList[i].diff);
      rows.add(row);
    }
  } else if(name == 'earlyLeavers'){
    row1.add('Name');
    row1.add('Shift');
    row1.add('Time Out');
    row1.add('Early By');
    rows.add(row1);
    for (int i = 0; i < associateList.length; i++) {
  //row refer to each column of a row in csv file and rows refer to each row in a file
    List<dynamic> row = List();
    row.add(associateList[i].name);
    row.add(associateList[i].shift);
    row.add(associateList[i].timeAct);
    row.add(associateList[i].diff);
    rows.add(row);
    }
  }else if(name == 'visitlist') {
    row1.add('Name');
    row1.add('Client Name');
    row1.add('Visit In');
    row1.add('Visit In Location');
    row1.add('Visit Out');
    row1.add('Visit Out Location');
    row1.add('Remarks');
    rows.add(row1);
    for (int i = 0; i < associateList.length; i++) {
//row refer to each column of a row in csv file and rows refer to each row in a file
      List<dynamic> row = List();
      row.add(associateList[i].Emp);
      row.add(associateList[i].client);
      row.add(associateList[i].pi_time);
      row.add(associateList[i].pi_loc);
      row.add(associateList[i].po_time);
      row.add(associateList[i].po_loc);
      row.add(associateList[i].desc);
      rows.add(row);
    }
  }

  PermissionStatus permission = await PermissionHandler().checkPermissionStatus(PermissionGroup.storage);
  print(permission);
  Map<PermissionGroup, PermissionStatus> permissions;
  if(permission.toString()!='PermissionStatus.granted'){
    permissions = await PermissionHandler().requestPermissions([PermissionGroup.storage]);
    permission = await PermissionHandler().checkPermissionStatus(PermissionGroup.storage);
  }

  //PermissionStatus res = await SimplePermissions.requestPermission(Permission. WriteExternalStorage);
  /*final res = await SimplePermissions.requestPermission(
      Permission.WriteExternalStorage);
  bool checkPermission =
      await SimplePermissions.checkPermission(Permission.WriteExternalStorage);*/
  if (permission.toString() == "PermissionStatus.granted") {
//store file in documents folder
    String dir = (await getExternalStorageDirectory()).absolute.path;
    String file = "$dir/ubiattendance_files/";
    await new Directory('$file').create(recursive: true);
    print(" FILE " + file);
    File f = new File(file + fname + ".csv");

// convert rows to String and write as csv file
    String csv = const ListToCsvConverter().convert(rows);
    f.writeAsString(csv);
    return file + fname + ".csv";
  }
}




///Flexi Attendance start///

class FlexiAtt {
  String Id;
  String Emp;
  String client;
  String pi_time;
  String pi_loc;
  String po_time;
  String po_loc;
  String timeindate;
  String timeoutdate;
  String pi_longi;
  String pi_latit;
  String po_longi;
  String po_latit;
  String desc;
  String pi_img;
  String po_img;

  FlexiAtt(
      {this.Id,
      this.Emp,
      this.client,
      this.pi_time,
      this.pi_loc,
      this.po_time,
      this.po_loc,
      this.timeindate,
      this.timeoutdate,
      this.pi_latit,
      this.pi_longi,
      this.po_latit,
      this.po_longi,
      this.desc,
      this.pi_img,
      this.po_img});
}


Future<List<FlexiAtt>> getFlexiDataList(date) async {
  final prefs = await SharedPreferences.getInstance();
  String empid = prefs.getString('empid') ?? '';
  String orgdir = prefs.getString('orgdir') ?? '';

  print(globals.path + 'getFlexiInfo?uid=$empid&orgid=$orgdir&date=$date');
  final response = await http
      .get(globals.path + 'getFlexiInfo?uid=$empid&orgid=$orgdir&date=$date');
  List responseJson = json.decode(response.body.toString());
  List<FlexiAtt> userList = createUserListFlexi(responseJson);
  print('getSummaryPunch called--1');
  print(userList);
  print('getSummaryPunch called--2');
  return userList;
}

List<FlexiAtt> createUserListFlexi(List data) {
  List<FlexiAtt> list = new List();
  for (int i = data.length - 1; i >= 0; i--) {
    String id = data[i]["Id"];
    String client = data[i]["client"];
    String pi_time = data[i]["time_in"] == "00:00:00"
        ? '-'
        : data[i]["time_in"].toString().substring(0, 5);
    String pi_loc = data[i]["loc_in"];
    String po_time = data[i]["time_out"] == "00:00:00"
        ? '-'
        : data[i]["time_out"].toString().substring(0, 5);
    String po_loc = data[i]["loc_out"];
    String timeindate = data[i]["date"];
    String timeoutdate = data[i]["timeout_date"];
    String emp = data[i]["emp"];
    String latit_in = data[i]["latit"];
    String longi_in = data[i]["longi"];
    String latit_out = data[i]["latit_in"];
    String longi_out = data[i]["longi_out"];
    String desc = data[i]["desc"];
    String pi_img = data[i]["checkin_img"].toString() == ''
        ? 'https://ubiattendance.ubihrm.com/assets/img/avatar.png'
        : data[i]["checkin_img"].toString();
    String po_img = data[i]["checkout_img"].toString() == ''
        ? 'https://ubiattendance.ubihrm.com/assets/img/avatar.png'
        : data[i]["checkout_img"].toString();
    print(data[i]["id"]);

    FlexiAtt flexi = new FlexiAtt(
        Id: id,
        Emp: emp,
        client: client,
        pi_time: pi_time,
        pi_loc: pi_loc.length > 40 ? pi_loc.substring(0, 40) + '...' : pi_loc,
        po_time: po_time == '00:00' ? '-' : po_time,
        po_loc: po_loc.length > 40 ? po_loc.substring(0, 40) + '...' : po_loc,
        timeindate: timeindate,
        timeoutdate: timeoutdate,
        pi_latit: latit_in,
        pi_longi: longi_in,
        po_latit: latit_out,
        po_longi: longi_out,
        desc: desc.length > 40 ? desc.substring(0, 40) + '...' : desc,
        pi_img: pi_img,
        po_img: po_img);
    list.add(flexi);
  }
  return list;
}

class Flexi {
  String fid;
  String sts;

  Flexi({this.fid, this.sts});
}
Future checkTimeOff() async {
  final prefs = await SharedPreferences.getInstance();
  String empid = prefs.getString('empid') ?? '';
  String orgdir = prefs.getString('orgdir') ?? '';

  print(globals.path + 'checkTimeOff?empid=$empid');
  final res =
  await http.get(globals.path + 'checkTimeOff?empid=$empid');
  print("99999");
  print(res.body.toString());
  // return res.body.toString();
  List<Flexi> list = new List();

  String fid = ((json.decode(res.body.toString()))['id']).toString();
  String sts = ((json.decode(res.body.toString()))['sts']).toString();
  Flexi flexi = new Flexi(fid: fid, sts: sts);
  list.add(flexi);
  print("kkkkkk");
  print(list);
//return ((json.decode(res.body.toString()))['sts']).toString();
  return list;
}
Future checkTimeinflexi() async {
  final prefs = await SharedPreferences.getInstance();
  String empid = prefs.getString('empid') ?? '';
  String orgdir = prefs.getString('orgdir') ?? '';
  print('*--*-*-*-*-*-*-*-*-*-');
  final res =
      await http.get(globals.path + 'getAttendanceesFlexi?empid=$empid');
  print("99999");
  print(res.body.toString());
  // return res.body.toString();
  List<Flexi> list = new List();

  String fid = ((json.decode(res.body.toString()))['id']).toString();
  String sts = ((json.decode(res.body.toString()))['sts']).toString();
  Flexi flexi = new Flexi(fid: fid, sts: sts);
  list.add(flexi);
  print("kkkkkk");
  print(list);
//return ((json.decode(res.body.toString()))['sts']).toString();
  return list;
}

Future<List<FlexiAtt>> getFlexiDataListReport(date, emp) async {
  final prefs = await SharedPreferences.getInstance();
  String empid = prefs.getString('empid') ?? '';
  String orgdir = prefs.getString('orgdir') ?? '';

  print(globals.path +
      'getFlexiInfoReport?seid=$emp&uid=$empid&orgid=$orgdir&date=$date');
  final response = await http.get(globals.path +
      'getFlexiInfoReport?seid=$emp&uid=$empid&orgid=$orgdir&date=$date');
  List responseJson = json.decode(response.body.toString());
  List<FlexiAtt> userList = createUserListFlexi(responseJson);
  print('getSummaryPunch called--1');
  print(userList);
  print('getSummaryPunch called--2');
  return userList;
}


List<FlexiAtt> createListFlexiReport(List data) {
  List<FlexiAtt> list = new List();
  for (int i = data.length - 1; i >= 0; i--) {
    String id = data[i]["Id"];
    String client = data[i]["client"];
    String pi_time = data[i]["time_in"] == "00:00:00"
        ? '-'
        : data[i]["time_in"].toString().substring(0, 5);
    String pi_loc = data[i]["loc_in"];
    String po_time = data[i]["time_out"] == "00:00:00"
        ? '-'
        : data[i]["time_out"].toString().substring(0, 5);
    String po_loc = data[i]["loc_out"];
    String timeindate = data[i]["date"];
    String timeoutdate = data[i]["timeout_date"];
    String emp = data[i]["emp"];
    String latit_in = data[i]["latit"];
    String longi_in = data[i]["longi"];
    String latit_out = data[i]["latit_in"];
    String longi_out = data[i]["longi_out"];
    String desc = data[i]["desc"];
    String pi_img = data[i]["checkin_img"].toString() == ''
        ? 'https://ubiattendance.ubihrm.com/assets/img/avatar.png'
        : data[i]["checkin_img"].toString();
    String po_img = data[i]["checkout_img"].toString() == ''
        ? 'https://ubiattendance.ubihrm.com/assets/img/avatar.png'
        : data[i]["checkout_img"].toString();
    print(data[i]["id"]);

    FlexiAtt flexi = new FlexiAtt(
        Id: id,
        Emp: emp,
        client: client,
        pi_time: pi_time,
        pi_loc: pi_loc.length > 40 ? pi_loc.substring(0, 40) + '...' : pi_loc,
        po_time: po_time == '00:00' ? '-' : po_time,
        po_loc: po_loc.length > 40 ? po_loc.substring(0, 40) + '...' : po_loc,
        timeindate: timeindate,
        timeoutdate: timeoutdate,
        pi_latit: latit_in,
        pi_longi: longi_in,
        po_latit: latit_out,
        po_longi: longi_out,
        desc: desc.length > 40 ? desc.substring(0, 40) + '...' : desc,
        pi_img: pi_img,
        po_img: po_img);
    list.add(flexi);
  }
  return list;
}


///flexi attendance end////

class OutsideAttendance {
  String Id;
  String empname;
  String timein;
  String timeout;
  String locationin;
  String locationout;
  String attdate;
  String latin;
  String lonin;
  String latout;
  String lonout;
  String outstatus;
  String instatus;
  String incolor;
  String outcolor;


  OutsideAttendance(
      {
        this.Id,
        this.empname,
        this.timein,
        this.timeout,
        this.locationin,
        this.locationout,
        this.attdate,
        this.latin,
        this.lonin,
        this.latout,
        this.lonout,
        this.outstatus,
        this.instatus,
        this.incolor,
        this.outcolor,
      });
}
Future<List<OutsideAttendance>> getOutsidegeoReport(date, emp) async {
  final prefs = await SharedPreferences.getInstance();
  String empid = prefs.getString('empid') ?? '';
  String orgdir = prefs.getString('orgdir') ?? '';

  print(globals.path +
      'getOutsidegeoReport?seid=$emp&uid=$empid&orgid=$orgdir&date=$date');
  final response = await http.get(globals.path +
      'getOutsidegeoReport?seid=$emp&uid=$empid&orgid=$orgdir&date=$date');

  List responseJson = json.decode(response.body.toString());
  print("Json responce ");

  List<OutsideAttendance> userList = createListOutsidefance(responseJson);
  print('getSummaryPunch called--1');
  print('getSummaryPunch called--2');
  return userList;


}


List<OutsideAttendance> createListOutsidefance(List data) {
  List<OutsideAttendance> list = new List();
  print("Data length");
  print(data.length);

  for (int i = data.length - 1; i >= 0; i--) {
    String id = data[i]["id"];
    String timein = data[i]["timein"] == "00:00:00" ? '-'
        : data[i]["timein"].toString().substring(0, 5);
    String timeout = data[i]["timeout"] == "00:00:00" ? '-'
        : data[i]["timeout"].toString().substring(0, 5);
    String locationin = data[i]["locationin"];
    String locationout = data[i]["locationout"];
    String attdate = data[i]["attdate"];
    String empname = data[i]["empname"];
    String latin = data[i]["latin"];
    String lonin = data[i]["lonin"];
    String latout = data[i]["latout"];
    String lonout = data[i]["lonout"];
    String outstatus = data[i]["outstatus"];
    String instatus = data[i]["instatus"];
    String incolor = data[i]["incolor"];
    String outcolor = data[i]["outcolor"];


    OutsideAttendance Outsid = new OutsideAttendance(
        Id: id,
        empname: empname,
        timein: timein == '00:00' ? '-' : timein,
        timeout: timeout == '00:00' ? '-' : timeout,
        locationin: locationin.length > 40 ? locationin.substring(0, 40) + '...' : locationin,
        locationout: locationout.length > 40 ? locationout.substring(0, 40) + '...' : locationout,
        attdate: attdate,
        latin: latin,
        lonin: lonin,
        latout: latout,
        lonout: lonout,
        outstatus: outstatus,
        instatus: instatus,
        incolor: incolor,
        outcolor: outcolor,
        );
    list.add(Outsid);
  }
  return list;
}

/************************************************************************
****************************Start Holiday functions*********************
************************************************************************/


Future<List<Holiday>> getHolidays() async {
  print('holidays called');
  final prefs = await SharedPreferences.getInstance();
  String orgid = prefs.getString('orgdir') ?? '';
  print(globals.path + 'getAllHoliday?orgid=$orgid');
  final response = await http.get(globals.path + 'getAllHoliday?orgid=$orgid');
  List responseJson = json.decode(response.body.toString());
  print(responseJson);
  List<Holiday> holidayList = createHolidayList(responseJson);
//  print(shiftList);
  return holidayList;
}

List<Holiday> createHolidayList(List data) {
  List<Holiday> list = new List();
  for (int i = 0; i < data.length; i++) {
    String name = data[i]["Name"];
    String from = (data[i]["fromDate"]);
    String to =   (data[i]["DateTo"]);
    String days = data[i]["DiffDate"];
    Holiday holiday = new Holiday(
        Name: name,
        From: from,
        To: to,
        Days: days
    );
    list.add(holiday);
  }
  return list;
}



class Holiday {
  //String Id;
  String Name;
  String From;
  String To;
  String Days;

  Holiday(
      {this.Name, this.From, this.To, this.Days});
}


Future<int> createHoliday(name, from, to, description) async {
  final prefs = await SharedPreferences.getInstance();
  String empid = prefs.getString('empid') ?? '';
  String orgdir = prefs.getString('orgdir') ?? '';
  print(globals.path +
      'addHoliday?name=$name&org_id=$orgdir&from=$from&to=$to&description=$description&empid=$empid');
  final response = await http.get(globals.path +
      'addHoliday?name=$name&org_id=$orgdir&from=$from&to=$to&description=$description&empid=$empid');
  int res = int.parse(response.body);
  print(response.body);
  return res;
}


/************************************************************************
 ****************************End Holiday functions*********************
 ************************************************************************/