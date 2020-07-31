import 'dart:convert';

import 'package:Shrine/globals.dart' as globals;
import 'package:Shrine/model/employee.dart';
import 'package:Shrine/model/timeinout.dart';
import 'package:Shrine/model/user.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'gethome.dart';
import 'saveimage.dart';

class Login{

  var dio = new Dio();
  checkLogin(User user) async{
    String usrpwd = user.userPassword;

    try {
      final prefs = await SharedPreferences.getInstance();
      print(user.userName + "----");
      print(user.userPassword + "----");
      FormData formData = new FormData.from({
        "userName": user.userName,
        "password": user.userPassword,
        "device": "Android"
      });
print(globals.path+"checkLogin?userName="+user.userName+"&password="+user.userPassword+"&device=Android");
     // Response response1 = await dio.post("https://sandbox.ubiattendance.com/index.php/services/checkLogin",data: formData);
     // Response response1 = await dio.post("https://ubiattendance.ubihrm.com/index.php/services/checkLogin",data: formData);
      Response response1 = await dio.post(globals.path+"checkLogin", data: formData);
     // Response response1 = await dio.post("http://192.168.0.200/UBIHRM/HRMINDIA/services/checkLogin", data: formData);
      print("------->"+response1.toString());
      print(response1.statusCode.toString());

      if (response1.statusCode == 200) {
        Map employeeMap = json.decode(response1.data);
        print(employeeMap.toString());
        globals.mailstatus=employeeMap["mailstatus"]??'0';
        if(employeeMap["response"] == '2') {
          return 'inactive user';
        }

        if(globals.mailstatus.toString()=='1'){
          return 'MailNotVerified';
        }

        if (employeeMap["response"] == 1) {
          var user = new Employee.fromJson(employeeMap);
          print(user.fname + " " + user.lname);
          print(user.org_perm);
          if(user.orgid=='10932'){
            prefs.setInt('response', 0);
            return "failure";
          }
          prefs.setInt('response', user.response);
          prefs.setString('fname', user.fname);
          prefs.setString('lname', user.lname);
          prefs.setString('empid', user.empid);
          prefs.setString('email', user.email);
          prefs.setString('status', user.status);
          prefs.setString('orgid', user.orgid);
          prefs.setString('orgdir', user.orgid);
          prefs.setString('sstatus', user.sstatus);
          prefs.setString('org_name', user.org_name);
          prefs.setString('desination', user.desination);
          prefs.setString('desinationId', user.desinationId);
          prefs.setString('profile', user.profile);
          prefs.setString('org_perm', user.org_perm);
          prefs.setString('store', employeeMap["store"]);
          prefs.setString('buysts', employeeMap["buysts"]);
          prefs.setString('trialstatus', employeeMap["trialstatus"]);
          prefs.setString('orgmail', employeeMap["orgmail"]);
          prefs.setString('usrpwd', usrpwd);
          prefs.setString('lid', '0');
          globals.mailverifiedstatus=employeeMap["mail_varified"];
          //print(user.orgid+" "+user.org_name +" "+user.fname+" "+user.email);
          // default 0, check punch location id
         // prefs.setString('profile', "http://ubiattendance.ubihrm.com/assets/img/avatar.png");
          // prefs.setString('profile', "https://sandbox.ubiattendance.com/public/uploads/"+user.orgid+"/"+user.profile);
          //prefs.setString('profile', "http://192.168.0.200/UBIHRM/HRMINDIA/public/uploads/"+user.orgdir+"/"+user.profile);
          //prefs.setString('profile',"https://ubitech.ubihrm.com/public/uploads/" + user.orgdir + "/" +user.profile);
        //  print(user.orgdir);

          print(prefs.getString('profile'));
          return "success";
        } else {
          prefs.setInt('response', employeeMap["response"]);
          //print("asdfa");
          return "failure";
        }
      } else {
        return "Poor network connection.";
      }
    }catch(e){
      print(e.toString());
      return "Poor network connection.";
    }
    //print(userMap["response"]);
    //var values = userMap.keys.toList();
    //print(values);
  }

  checkLoginForQr(User user,int FakeLocationStatus,context) async{
    try {
      final prefs = await SharedPreferences.getInstance();
      print(user.userName + "----");
      print(user.userPassword + "----");
      if(user.userName=='' || user.userPassword=='')
        return "failure";
      FormData formData = new FormData.from({
        "userName": user.userName,
        "password": user.userPassword,
        "qr":true,
      });
      print("attendance mark by qr");
       print(globals.path+"checkLogin?userName="+user.userName+"&password="+user.userPassword+"&qr=true");
      // Response response1 = await dio.post("https://sandbox.ubiattendance.com/index.php/services/checkLogin",data: formData);
      // Response response1 = await dio.post("https://ubiattendance.ubihrm.com/index.php/services/checkLogin",data: formData);
      Response response1 = await dio.post(globals.path+"checkLogin", data: formData);
      // Response response1 = await dio.post("http://192.168.0.200/UBIHRM/HRMINDIA/services/checkLogin", data: formData);
      print(response1.toString());
      print(response1.statusCode.toString());
      if (response1.statusCode == 200) {
        Map employeeMap = json.decode(response1.data);
        //print(employeeMap["response"]);

        if (employeeMap["response"] == 1) {
          var user = new Employee.fromJson(employeeMap);
          print(user.fname + " //" + user.lname);
          globals.attImage = int.parse(user.imgstatus);
          print(user.org_perm);
          prefs.setString('empid', user.empid);
          Home ho = new Home();
          print("no error here1");
          Map timeinout = await ho.checkTimeInQR(user.empid, user.orgid);
        //  print(timeinout);
          print("no error here3");
          if(timeinout["latit"]=='0.0' && timeinout["longi"]=='0.0'){
            print("Location not fetched...");
            return "nolocation";
          }else {
            var marktimeinout = MarkTime(
                timeinout["uid"].toString(),
                timeinout["location"],
                timeinout["aid"].toString(),
                timeinout["act"],
                timeinout["shiftId"],
                timeinout["refid"].toString(),
                timeinout["latit"].toString(),
                timeinout["longi"].toString(),
                FakeLocationStatus,
                timeinout["city"].toString());
            if (timeinout["act"] != "Imposed") {
              SaveImage mark = new SaveImage();

              var prefs= await SharedPreferences.getInstance();
              globals.showAppInbuiltCamera=prefs.getBool("showAppInbuiltCamera")??true;
              bool res = globals.showAppInbuiltCamera?await mark.saveTimeInOutQRAppCamera(marktimeinout,context):await mark.saveTimeInOutQR(marktimeinout,context);
              if (res)
                if(timeinout["aid"].toString() != '0')
                  return "success1";
                else
                  return "success";
              else
                return "poor network";
            } else {
              return "imposed";
            }
          }
        } else {
          return "failure";
        }
      } else {
        return "poor network";
      }
    }catch(e){
      print(e.toString());
      return "poor network";
    }
  }



  checkLoginForQrBulk(User user,int FakeLocationStatus,context) async{
    try {
      final prefs = await SharedPreferences.getInstance();
      print(user.userName + "----");
      print(user.userPassword + "----");
      if(user.userName=='' || user.userPassword=='')
        return "failure";
      FormData formData = new FormData.from({
        "userName": user.userName,
        "password": user.userPassword,
        "qr":true,
      });
      print("attendance mark by qr");
      print(globals.path+"checkLogin?userName="+user.userName+"&password="+user.userPassword+"&qr=true");
      // Response response1 = await dio.post("https://sandbox.ubiattendance.com/index.php/services/checkLogin",data: formData);
      // Response response1 = await dio.post("https://ubiattendance.ubihrm.com/index.php/services/checkLogin",data: formData);
      Response response1 = await dio.post(globals.path+"checkLogin", data: formData);
      // Response response1 = await dio.post("http://192.168.0.200/UBIHRM/HRMINDIA/services/checkLogin", data: formData);
      print(response1.toString());
      print(response1.statusCode.toString());
      if (response1.statusCode == 200) {
        Map employeeMap = json.decode(response1.data);
        //print(employeeMap["response"]);

        if (employeeMap["response"] == 1) {
          var user = new Employee.fromJson(employeeMap);
          print(user.fname + " //" + user.lname);
          globals.attImage = int.parse(user.imgstatus);
          print(user.org_perm);
          //prefs.setString('empid', user.empid);
          Home ho = new Home();
          print("no error here1");
          Map timeinout = await ho.checkTimeInQR(user.empid, user.orgid);
          //  print(timeinout);
          print("no error here3");
          if(timeinout["latit"]=='0.0' && timeinout["longi"]=='0.0'){
            print("Location not fetched...");
            return "nolocation";
          }else {
            var marktimeinout = MarkTime(
                timeinout["uid"].toString(),
                timeinout["location"],
                timeinout["aid"].toString(),
                timeinout["act"],
                timeinout["shiftId"],
                timeinout["refid"].toString(),
                timeinout["latit"].toString(),
                timeinout["longi"].toString(),
                FakeLocationStatus,
                timeinout["city"].toString());
            if (timeinout["act"] != "Imposed") {
              SaveImage mark = new SaveImage();

              var prefs= await SharedPreferences.getInstance();
              globals.showAppInbuiltCamera=prefs.getBool("showAppInbuiltCamera")??true;
              bool res = globals.showAppInbuiltCamera?await mark.saveTimeInOutQRAppCamera(marktimeinout,context):await mark.saveTimeInOutQR(marktimeinout,context);
              if (res)
                if(timeinout["aid"].toString() != '0')
                  return "success1";
                else
                  return "success";
              else
                return "poor network";
            } else {
              return "imposed";
            }
          }
        } else {
          return "failure";
        }
      } else {
        return "poor network";
      }
    }catch(e){
      print(e.toString());
      return "poor network";
    }
  }




  markAttByQR(String qr,int FakeLocationStatus,context) async{
    print("first function");
    List splitstring = qr.split("ykks==");
    User qruser = new User(splitstring[0], splitstring[1]);
    String result = await checkLoginForQr(qruser,FakeLocationStatus,context);
    return result;
    print(splitstring[0]);
    print(splitstring[1]);
    print(qr);
   //return "success";
  }



  markAttByQRBulk(String qr,int FakeLocationStatus,context) async{
    print("first function");
    List splitstring = qr.split("ykks==");
    User qruser = new User(splitstring[0], splitstring[1]);
    String result = await checkLoginForQrBulk(qruser,FakeLocationStatus,context);
    return result;
    print(splitstring[0]);
    print(splitstring[1]);
    print(qr);
    //return "success";
  }


}