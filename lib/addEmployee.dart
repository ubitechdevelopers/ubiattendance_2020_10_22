// Copyright 2017 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.
import 'package:Shrine/drawer.dart';
import 'package:Shrine/globals.dart' as globals;
import 'package:Shrine/home.dart';
import 'package:Shrine/services/gethome.dart';
import 'package:Shrine/services/services.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:native_contact_picker/native_contact_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

import 'employee_list.dart';
import 'globals.dart';
class AddEmployee extends StatefulWidget {
  @override
  _AddEmployee createState() => _AddEmployee();
}
String _orgName = "";

class _AddEmployee extends State<AddEmployee> {
  bool isloading = false;
  final NativeContactPicker _contactPicker = new NativeContactPicker();
  Contact _contactpick;
  final _firstName = TextEditingController();
  final _lastName = TextEditingController();
  final _email = TextEditingController();
  final _countryCode = TextEditingController();
  final _countryId = TextEditingController();
  final _contact = TextEditingController();
  final _department1 = TextEditingController();
  final _pass = TextEditingController();
  String admin_sts = '0';
  String appstore="https://apps.apple.com/in/app/track-employee-attendance/id1375252261";
  String playstore="https://play.google.com/store/apps/details?id=org.ubitech.attendance";
  FocusNode __fullName = new FocusNode();
  FocusNode __email = new FocusNode();
  FocusNode __country = new FocusNode();
  FocusNode __contact = new FocusNode();
  FocusNode __pass = new FocusNode();
  final _formKey = GlobalKey<FormState>();
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  int response = 0;
  bool pageload = true;
  int _currentIndex = 2;
  String updatedcontact = '';
  String dept = '0', desg = '0', shift = '0', adminsts = '0';
  String org_name = "";
  String org_country = "";
  String admname = '';
  bool _obscureText = false;
  bool supervisor = true;
  String buysts = '0';
  bool _isButtonDisabled = false;
  TextEditingController deptctr = new TextEditingController();
  TextEditingController desgctrl = new TextEditingController();
  //TextEditingController deptind = new TextEditingController();
  String councode = "+91";
  String whatscontact = '';
  String _sts = 'Active';
  String _sts1 = 'Active';
  String shiftind = "0";
  String desgind ="0";
  String deptind="0";
  int flagd =0;
  bool visibilityTag = false;

  List<Map> countrylist = [
    {"id": "0#", "name": "country"},
    {"id": "2#+93", "name": "Afghanistan"},
    {"id": "4#+355", "name": "Albania"},
    {"id": "50#+213", "name": "Algeria"},
    {"id": "5#+1", "name": "American Samoa"},
    {"id": "6#+376", "name": "Andorra"},
    {"id": "7#+244", "name": "Angola"},
    {"id": "11#+264", "name": "Anguilla"},
    {"id": "3#+1", "name": "Antigua and Barbuda"},
    {"id": "160#+54", "name": "Argentina"},
    {"id": "8#+374", "name": "Armenia"},
    {"id": "9#+297", "name": "Aruba"},
    {"id": "10#+61", "name": "Australia"},
    {"id": "1#+43", "name": "Austria"},
    {"id": "12#+994", "name": "Azerbaijan"},
    {"id": "27#+242", "name": "Bahamas"},
    {"id": "25#+973", "name": "Bahrain"},
    {"id": "14#+880", "name": "Bangladesh"},
    {"id": "15#+246", "name": "Barbados"},
    {"id": "29#+375", "name": "Belarus"},
    {"id": "13#+32", "name": "Belgium"},
    {"id": "30#+501", "name": "Belize"},
    {"id": "16#+229", "name": "Benin"},
    {"id": "17#+441", "name": "Bermuda"},
    {"id": "20#+975", "name": "Bhutan"},
    {"id": "23#+591", "name": "Bolivia"},
    {"id": "22#+387", "name": "Bosnia and Herzegovina"},
    {"id": "161#+267", "name": "Botswana"},
    {"id": "24#+55", "name": "Brazil"},
    {"id": "28#+284", "name": "British Virgin Islands"},
    {"id": "26#+673", "name": "Brunei"},
    {"id": "19#+359", "name": "Bulgaria"},
    {"id": "18#+226", "name": "Burkina Faso"},
    {"id": "21#+257", "name": "Burundi"},
    {"id": "101#+855", "name": "Cambodia"},
    {"id": "32#+237", "name": "Cameroon"},
    {"id": "34#+1", "name": "Canada"},
    {"id": "43#+238", "name": "Cape Verde"},
    {"id": "33#+345", "name": "Cayman Islands"},
    {"id": "163#+236", "name": "Central African Republic"},
    {"id": "203#+235", "name": "Chad"},
    {"id": "165#+56", "name": "Chile"},
    {"id": "205#+86", "name": "China"},
    {"id": "233#+61", "name": "Christmas Island"},
    {"id": "39#+891", "name": "Cocos Islands"},
    {"id": "38#+57", "name": "Colombia"},
    {"id": "40#+269", "name": "Comoros"},
    {"id": "41#+682", "name": "Cook Islands"},
    {"id": "42#+506", "name": "Costa Rica"},
    {"id": "36#+225", "name": "Cote dIvoire"},
    {"id": "90#+385", "name": "Croatia"},
    {"id": "31#+53", "name": "Cuba"},
    {"id": "44#+357", "name": "Cyprus"},
    {"id": "45#+420", "name": "Czech Republic"},
    {"id": "48#+45", "name": "Denmark"},
    {"id": "47#+253", "name": "Djibouti"},
    {"id": "226#+767", "name": "Dominica"},
    {"id": "49#+1", "name": "Dominican Republic"},
    {"id": "55#+593", "name": "Ecuador"},
    {"id": "58#+20", "name": "Egypt"},
    {"id": "57#+503", "name": "El Salvador"},
    {"id": "80#+240", "name": "Equatorial Guinea"},
    {"id": "56#+291", "name": "Eritrea"},
    {"id": "60#+372", "name": "Estonia"},
    {"id": "59#+251", "name": "Ethiopia"},
    {"id": "62#+500", "name": "Falkland Islands"},
    {"id": "63#+298", "name": "Faroe Islands"},
    {"id": "65#+679", "name": "Fiji"},
    {"id": "186#+358", "name": "Finland"},
    {"id": "61#+33", "name": "France"},
    {"id": "64#+594", "name": "French Guiana"},
    {"id": "67#+689", "name": "French Polynesia"},
    {"id": "69#+241", "name": "Gabon"},
    {"id": "223#+220", "name": "Gambia"},
    {"id": "70#+970", "name": "Gaza Strip"},
    {"id": "77#+995", "name": "Georgia"},
    {"id": "46#+49", "name": "Germany"},
    {"id": "78#+233", "name": "Ghana"},
    {"id": "75#+350", "name": "Gibraltar"},
    {"id": "81#+30", "name": "Greece"},
    {"id": "82#+299", "name": "Greenland"},
    {"id": "228#+473", "name": "Grenada"},
    {"id": "83#+590", "name": "Guadeloupe"},
    {"id": "84#+1", "name": "Guam"},
    {"id": "76#+502", "name": "Guatemala"},
    {"id": "72#+44", "name": "Guernsey"},
    {"id": "167#+224", "name": "Guinea"},
    {"id": "79#+245", "name": "Guinea-Bissau"},
    {"id": "85#+592", "name": "Guyana"},
    {"id": "168#+509", "name": "Haiti"},
    {"id": "218#+379", "name": "Holy See"},
    {"id": "87#+504", "name": "Honduras"},
    {"id": "89#+852", "name": "Hong Kong"},
    {"id": "86#+36", "name": "Hungary"},
    {"id": "97#+354", "name": "Iceland"},
    {"id": "93#+91", "name": "India"},
    {"id": "169#+62", "name": "Indonesia"},
    {"id": "94#+98", "name": "Iran"},
    {"id": "96#+964", "name": "Iraq"},
    {"id": "95#+353", "name": "Ireland"},
    {"id": "74#+44", "name": "Isle of Man"},
    {"id": "92#+972", "name": "Israel"},
    {"id": "91#+39", "name": "Italy"},
    {"id": "99#+876", "name": "Jamaica"},
    {"id": "98#+81", "name": "Japan"},
    {"id": "73#+44", "name": "Jersey"},
    {"id": "100#+962", "name": "Jordan"},
    {"id": "102#+7", "name": "Kazakhstan"},
    {"id": "52#+254", "name": "Kenya"},
    {"id": "104#+686", "name": "Kiribati"},
    {"id": "106#+383", "name": "Kosovo"},
    {"id": "107#+965", "name": "Kuwait"},
    {"id": "103#+996", "name": "Kyrgyzstan"},
    {"id": "109#+856", "name": "Laos"},
    {"id": "114#+371", "name": "Latvia"},
    {"id": "171#+961", "name": "Lebanon"},
    {"id": "112#+266", "name": "Lesotho"},
    {"id": "111#+231", "name": "Liberia"},
    {"id": "110#+218", "name": "Libya"},
    {"id": "66#+423", "name": "Liechtenstein"},
    {"id": "113#+370", "name": "Lithuania"},
    {"id": "108#+352", "name": "Luxembourg"},
    {"id": "117#+853", "name": "Macau"},
    {"id": "125#+389", "name": "Macedonia"},
    {"id": "172#+261", "name": "Madagascar"},
    {"id": "132#+265", "name": "Malawi"},
    {"id": "118#+60", "name": "Malaysia"},
    {"id": "131#+960", "name": "Maldives"},
    {"id": "173#+223", "name": "Mali"},
    {"id": "115#+356", "name": "Malta"},
    {"id": "124#+692", "name": "Marshall Islands"},
    {"id": "119#+596", "name": "Martinique"},
    {"id": "170#+222", "name": "Mauritania"},
    {"id": "130#+230", "name": "Mauritius"},
    {"id": "120#+262", "name": "Mayotte"},
    {"id": "123#+52", "name": "Mexico"},
    {"id": "68#+691", "name": "Micronesia"},
    {"id": "122#+373", "name": "Moldova"},
    {"id": "121#+377", "name": "Monaco"},
    {"id": "127#+976", "name": "Mongolia"},
    {"id": "126#+382", "name": "Montenegro"},
    {"id": "128#+664", "name": "Montserrat"},
    {"id": "116#+212", "name": "Morocco"},
    {"id": "129#+258", "name": "Mozambique"},
    {"id": "133#+95", "name": "Myanmar"},
    {"id": "136#+264", "name": "Namibia"},
    {"id": "137#+674", "name": "Nauru"},
    {"id": "139#+977", "name": "Nepal"},
    {"id": "142#+31", "name": "Netherlands"},
    {"id": "135#+599", "name": "Netherlands Antilles"},
    {"id": "138#+687", "name": "New Caledonia"},
    {"id": "146#+64", "name": "New Zealand"},
    {"id": "140#+505", "name": "Nicaragua"},
    {"id": "174#+227", "name": "Niger"},
    {"id": "225#+234", "name": "Nigeria"},
    {"id": "141#+683", "name": "Niue"},
    {"id": "145#+672", "name": "Norfolk Island"},
    {"id": "144#+850", "name": "North Korea"},
    {"id": "143#+1", "name": "Northern Mariana Islands"},
    {"id": "134#+47", "name": "Norway"},
    {"id": "147#+968", "name": "Oman"},
    {"id": "153#+92", "name": "Pakistan"},
    {"id": "150#+680", "name": "Palau"},
    {"id": "149#+507", "name": "Panama"},
    {"id": "155#+675", "name": "Papua New Guinea"},
    {"id": "157#+595", "name": "Paraguay"},
    {"id": "151#+51", "name": "Peru"},
    {"id": "178#+63", "name": "Philippines"},
    {"id": "152#+64", "name": "Pitcairn Islands"},
    {"id": "154#+48", "name": "Poland"},
    {"id": "148#+351", "name": "Portugal"},
    {"id": "156#+1", "name": "Puerto Rico"},
    {"id": "158#+974", "name": "Qatar"},
    {"id": "164#+243", "name": "Republic of the Congo"},
    {"id": "166#+262", "name": "Reunion"},
    {"id": "175#+40", "name": "Romania"},
    {"id": "159#+7", "name": "Russia"},
    {"id": "182#+250", "name": "Rwanda"},
    {"id": "88#+290", "name": "Saint Helena"},
    {"id": "105#+869", "name": "Saint Kitts and Nevis"},
    {"id": "229#+758", "name": "Saint Lucia"},
    {"id": "191#+1", "name": "Saint Martin"},
    {"id": "195#+508", "name": "Saint Pierre and Miquelon"},
    {"id": "232#+784", "name": "Saint Vincent and the Grenadines"},
    {"id": "230#+685", "name": "Samoa"},
    {"id": "180#+378", "name": "San Marino"},
    {"id": "197#+239", "name": "Sao Tome and Principe"},
    {"id": "184#+966", "name": "Saudi Arabia"},
    {"id": "193#+221", "name": "Senegal"},
    {"id": "196#+381", "name": "Serbia"},
    {"id": "200#+248", "name": "Seychelles"},
    {"id": "224#+232", "name": "Sierra Leone"},
    {"id": "187#+65", "name": "Singapore"},
    {"id": "188#+421", "name": "Slovakia"},
    {"id": "190#+386", "name": "Slovenia"},
    {"id": "189#+677", "name": "Solomon Islands"},
    {"id": "194#+252", "name": "Somalia"},
    {"id": "179#+27", "name": "South Africa"},
    {"id": "176#+82", "name": "South Korea"},
    {"id": "51#+34", "name": "Spain"},
    {"id": "37#+94", "name": "Sri Lanka"},
    {"id": "198#+249", "name": "Sudan"},
    {"id": "192#+597", "name": "Suriname"},
    {"id": "199#+47", "name": "Svalbard"},
    {"id": "185#+268", "name": "Swaziland"},
    {"id": "183#+46", "name": "Sweden"},
    {"id": "35#+41", "name": "Switzerland"},
    {"id": "201#+963", "name": "Syria"},
    {"id": "162#+886", "name": "Taiwan"},
    {"id": "202#+992", "name": "Tajikistan"},
    {"id": "53#+255", "name": "Tanzania"},
    {"id": "204#+66", "name": "Thailand"},
    {"id": "206#+670", "name": "Timor-Leste"},
    {"id": "181#+228", "name": "Togo"},
    {"id": "209#+676", "name": "Tonga"},
    {"id": "211#+868", "name": "Trinidad and Tobago"},
    {"id": "208#+216", "name": "Tunisia"},
    {"id": "210#+90", "name": "Turkey"},
    {"id": "207#+993", "name": "Turkmenistan"},
    {"id": "212#+1", "name": "Turks and Caicos Islands"},
    {"id": "213#+688", "name": "Tuvalu"},
    {"id": "219#+1", "name": "U.S. Virgin Islands"},
    {"id": "54#+256", "name": "Uganda"},
    {"id": "214#+380", "name": "Ukraine"},
    {"id": "215#+971", "name": "United Arab Emirates"},
    {"id": "71#+44", "name": "United Kingdom"},
    {"id": "216#+1", "name": "United States"},
    {"id": "177#+598", "name": "Uruguay"},
    {"id": "217#+998", "name": "Uzbekistan"},
    {"id": "221#+678", "name": "Vanuatu"},
    {"id": "235#+58", "name": "Venezuela"},
    {"id": "220#+84", "name": "Vietnam"},
    {"id": "222#+681", "name": "Wallis and Futuna"},
    {"id": "227#+970", "name": "West Bank"},
    {"id": "231#+212", "name": "Western Sahara"},
    {"id": "234#+967", "name": "Yemen"},
    {"id": "237#+243", "name": "Zaire"},
    {"id": "236#+260", "name": "Zambia"},
    {"id": "238#+263", "name": "Zimbabwe"}
  ];

  String country = "0#";
  List<Map> shiftList;

  // List<Map> statusList= [{"id":"1","name":"Admin"},{"id":"0","name":"User"}];

  @override
  void initState() {
    super.initState();
    initPlatformState();
    //  shiftList= getShifts();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  initPlatformState() async {
    appResumedPausedLogic(context);
    checkNetForOfflineMode(context);

    final prefs = await SharedPreferences.getInstance();
    response = prefs.getInt('response') ?? 0;
    _orgName = prefs.getString('org_name') ?? '';
    _pass.text = '123456';
    if (response == 1) {


      Home ho = new Home();
      setState(() {

        buysts = prefs.getString('buysts')??'0';
        org_name = prefs.getString('org_name') ?? '';
        org_country = prefs.getString('org_country') ?? '';
        councode = prefs.getString('countrycode') ?? '';
        admin_sts = prefs.getString('sstatus') ?? '0';
        //shift =  prefs.getString('shiftId')??'0';

        admname = prefs.getString('fname') ?? ''+' '+ prefs.getString('lname') ?? '';
        _department1.text = globals.departmentname;
        if (admin_sts == '2') supervisor = false;
        if(buysts=='0')
        {
          dept = globals.departmentid.toString();
          desg = globals.designationid.toString();
          shift =  prefs.getString('shiftId')??'0';
        }
        /*   response = prefs.getInt('response') ?? 0;
        fname = prefs.getString('fname') ?? '';
        lname = prefs.getString('lname') ?? '';
        empid = prefs.getString('empid') ?? '';
        email = prefs.getString('email') ?? '';
        status = prefs.getString('status') ?? '';
        orgid = prefs.getString('orgid') ?? '';
        orgdir = prefs.getString('orgdir') ?? '';
        sstatus = prefs.getString('sstatus') ?? '';

        desination = prefs.getString('desination') ?? '';
        profile = prefs.getString('profile') ?? '';
*/
      });
    }
    platform.setMethodCallHandler(_handleMethod);
    getdeptid();
    getdesgid();
    getshiftid();
  }
  getdeptid() async{
    getDepartmentsList(1).then((onValue){
      for(int i = 0 ; i < onValue.length; i++){
        if(onValue[i]["Name"].toUpperCase() == "TRIAL DEPARTMENT") {
          deptind = onValue[i]["Id"];
          print(deptind);
        }
      }
    });
  }
  getdesgid() async{
    getDesignationsList(0).then((onValue) {
      for(int i = 0 ; i < onValue.length; i++){
        if(onValue[i]["Name"].toUpperCase() == "TRIAL DESIGNATION") {
          desgind = onValue[i]["Id"];
          print(desgind);
        }
      }
    });
  }
  getshiftid() async{
    getShiftsList().then((onValue) {
      for(int i = 0 ; i < onValue.length; i++){
        if(onValue[i]["Name"].toUpperCase() == "TRIAL SHIFT") {
          shiftind = onValue[i]["Id"];
          print("shiftind");
          print(shiftind);
        }
      }
    });
  }

  static const platform = const MethodChannel('location.spoofing.check');
  Future<dynamic> _handleMethod(MethodCall call) async {
    /*
    switch(call.method) {

      case "locationAndInternet":
      // print(call.arguments["internet"].toString()+"akhakahkahkhakha");
      // Map<String,String> responseMap=call.arguments;

        if(call.arguments["TimeSpoofed"].toString()=="Yes"){
          timeSpoofed=true;
        }
        if(call.arguments["internet"].toString()=="Internet Not Available")
        {
          //internetAvailable=false;
          print("internet nooooot aaaaaaaaaaaaaaaaaaaaaaaavailable");

          Navigator
              .of(context)
              .pushReplacement(new MaterialPageRoute(builder: (BuildContext context) => OfflineHomePage()));

        }
        break;

        return new Future.value("");
    }*/
  }

  void _toggle() {
    setState(() {
      _obscureText = !_obscureText;
    });
  }

  @override
  Widget build(BuildContext context) {
    return getmainhomewidget();
  }

  void showInSnackBar(String value) {
    final snackBar = SnackBar(
        content: Text(
          value,
          textAlign: TextAlign.center,
        ));
    _scaffoldKey.currentState.showSnackBar(snackBar);
  }

  getmainhomewidget() {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            new Text(_orgName, style: new TextStyle(fontSize: 20.0)),
          ],
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
            /* Navigator.push(
            context,
           MaterialPageRoute(builder: (context) => HomePage()),
          ); */
          },
        ),
        backgroundColor: globals.appcolor,
      ),
      bottomNavigationBar: Container(

        height: 70.0,
        decoration: new BoxDecoration(
            color: Colors.white,
            boxShadow: [new BoxShadow(
              color: Colors.grey,
              blurRadius: 3.0,
            ),]
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Container(
              //margin: const EdgeInsets.only(left: 50.0),
              child: ButtonBar(
                children: <Widget>[
                  FlatButton(
                    highlightColor: Colors.transparent,
                    focusColor: Colors.transparent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5),
                      side: BorderSide( color: Colors.grey.withOpacity(0.5), width: 1,),
                    )
                    ,
                    child: Text('CANCEL'),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => HomePage()),
                      );
                    },
                  ),
                  SizedBox(width: 10.0),
                  RaisedButton(
                    elevation: 2.0,
                    highlightElevation: 5.0,
                    highlightColor: Colors.transparent,
                    disabledElevation: 0.0,
                    focusColor: Colors.transparent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: _isButtonDisabled
                        ? Text(
                      'Processing..',
                      style: TextStyle(color: Colors.white),
                    )
                        : Text(
                      'ADD',
                      style: TextStyle(color: Colors.white),
                    ),
                    color: globals.buttoncolor,
                    onPressed: () {


                      if (_formKey.currentState.validate()) {
                        if (_isButtonDisabled)
                          return null;

                        if (admin_sts == '2') {
                          deptind = globals.departmentid.toString();
                        }
                        if (deptind == '0' ) {
                          showInSnackBar("Please select the department");
                          return null;
                        }
                        if (desgind == '0') {
                          showInSnackBar("Please select the designation");
                          return null;
                        }
                        if (shiftind == '0' ) {
                          showInSnackBar("Please select the shift");
                          return null;
                        }

                        setState(() {
                          _isButtonDisabled = true;
                        });
                        whatscontact=_contact.text.trim();
                        updatedcontact=_contact.text.trim();
                        if(!_contact.text.contains('+')){
                          whatscontact=councode.trim()+_contact.text.trim();
                        }
                        print(org_country);
                        print('org_country');
                        if(org_country=='93') {
                          updatedcontact = updatedcontact = updatedcontact.replaceAll('+91', '');
                        }
                        updatedcontact = updatedcontact.replaceAll('+', '');
                        updatedcontact = updatedcontact.replaceAll('-', '');
                        updatedcontact = updatedcontact.replaceAll(' ', '');
                        print('updatedcontact');
                        print(updatedcontact);
                        _countryId.text = '0';
                        _countryCode.text = '0'; // prevented by parth sir
                        addEmployee(
                            _firstName.text.trim(),
                            _lastName.text.trim(),
                            _email.text.trim(),
                            _countryCode.text,
                            _countryId.text,
                            updatedcontact.trim(),
                            _pass.text,
                            dept,
                            desg,
                            shift,
                            deptind,
                            desgind,
                            shiftind
                        ).then((res) async{
                          //showInSnackBar(res.toString());
                          //   showInSnackBar('Employee registeed Successfully');
                          if (res == 1) {

                            var prefs=await SharedPreferences.getInstance();
                            var employeeAdded=prefs.getBool("EmployeeAdded")??false;
                            prefs.setBool("glow", false);
                            if(!employeeAdded) {
                              prefs.setBool("EmployeeAdded", true);
                            }
                            var firstAttendanceMarked=prefs.getBool('firstAttendanceMarked')??false;

                            if(!firstAttendanceMarked)
                              prefs.setBool("attendanceNotMarkedButEmpAdded", true);

                            prefs.setBool('tool',true );
                            //   showInSnackBar('Contact Already Exist');
                            //Navigator.pop(context);
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => EmployeeList()),
                            );
                            //generateAndShareReferralLink();
                            //openWhatsApp('aa','+918871653803');
                            /*
                            dialogwidget(
                                'Hello+'+_firstName.text+'+%0A%0ADownload+ubiAttendance+App+from+the+link+https%3A%2F%2Fplay.google.com%2Fstore%2Fapps%2Fdetails%3Fid%3Dorg.ubitech.attendance%26hl%3Den_IN%0A%0ASign+In+to+the+App+with%0A%0AUser+Name%3A+'+updatedcontact.trim()+'%0APassword%3A+'+_pass.text+'%0A%0AMark+your+%E2%80%9CTime+In%E2%80%9D+now!+Start+punching+Attendance+daily.',
                                whatscontact);

                             */
                            if((_firstName.text.trim()).contains(" ")){
                              var name=_firstName.text.split(" ");
                              _firstName.text=name[0];
                              _lastName.text=name[1];
                              print('First name and Last name');
                              dialogwidget(
                                  'Hello+'+_firstName.text+'+'+_lastName.text+'+%0A%0ADownload+ubiAttendance+android+app+from+the+link+%0A'+playstore+'+%0A%0AiPhone+users+can+download+through+%0A'+appstore+'+%0A%0ASign+In+to+the+App+with%0A%0AUser+Name%3A+'+updatedcontact.trim()+'%0APassword%3A+'+_pass.text+'%0A%0AMark+your+%E2%80%9CTime+In%E2%80%9D+now!+Start+punching+Attendance+daily.',
                                  whatscontact);
                            }
                            else{
                              print('First name');
                              dialogwidget(
                                  'Hello+'+_firstName.text+'+%0A%0ADownload+ubiAttendance+android+app+from+the+link+%0A'+playstore+'+%0A%0AiPhone+users+can+download+through+%0A'+appstore+'+%0A%0ASign+In+to+the+App+with%0A%0AUser+Name%3A+'+updatedcontact.trim()+'%0APassword%3A+'+_pass.text+'%0A%0AMark+your+%E2%80%9CTime+In%E2%80%9D+now!+Start+punching+Attendance+daily.',
                                  whatscontact);
                            }

                          } else if (res == 3)
                            showInSnackBar('Contact already exists');
                          else if (res == 2)
                            showInSnackBar('Email already exists');
                          else
                            showInSnackBar('Unable to add this employee');
                          setState(() {
                            _isButtonDisabled = false;
                          });
                          // TimeOfDay.fromDateTime(10000);
                        }).catchError((exp) {
                          showInSnackBar('Unable to call the service');
                          print(exp.toString());
                          setState(() {
                            _isButtonDisabled = false;
                          });
                        });
                      }
                    },
                  ),
                ],
              ),
            ),

          ],
        ),
      ),
      endDrawer: new AppDrawer(),
      body: checkalreadylogin(),
    );
  }

  checkalreadylogin() {
    if (response == 1) {
      return new IndexedStack(
        index: _currentIndex,
        children: <Widget>[
          underdevelopment(),
          underdevelopment(),
          mainbodyWidget(),
        ],
      );
    } else {
      /* Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => LoginPage()),
      );*/
    }
  }

  loader() {
    return new Container(
      child: Center(
        child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              Image.asset('assets/spinner.gif', height: 30.0, width: 30.0),
            ]),
      ),
    );
  }

  underdevelopment() {
    return new Container(
      child: Center(
        child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              Icon(
                Icons.android,
                color: globals.appcolor,
              ),
              Text(
                "Under development",
                style: new TextStyle(fontSize: 30.0, color: globals.appcolor),
              )
            ]),
      ),
    );
  }

  mainbodyWidget() {
    _pass.text = '123456';
    if (pageload == true) loader();

    return Center(
      child: Form(
        key: _formKey,
        child: SafeArea(
            child: Column(children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(bottom: 20.0),
                /* child: Center(
                  child:Text("Add Employee",style: new TextStyle(fontSize: 22.0,color:Colors.teal)),
                ),*/
              ),
              new Expanded(
                // padding: EdgeInsets.only(left:10.0,right:10.0),
                //    margin: EdgeInsets.only(top:25.0),
                child: ListView(
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.only(left:15.0,right: 15.0),
                      child: Text(
                        'Add Employee',
                        style: TextStyle(
                          fontSize: 20.0,
                          letterSpacing: 0.5,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    //Divider(color: Colors.black87,height: 1.5),
                    SizedBox(height: 10,),

                    Padding(
                      padding: const EdgeInsets.only(left:15.0,right: 15.0),
                      child: Container(
                        width: MediaQuery.of(context).size.width * 0.70,
                        child: TextFormField(
                          focusNode: __fullName,
                          controller: _firstName,
                          keyboardType: TextInputType.text,
                          decoration: InputDecoration(
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide( color: Colors.grey.withOpacity(0.0), width: 1,),
                              ),
                              prefixIcon: Icon(Icons.person),
                              labelText: 'Name',
                              suffixIcon: IconButton(
                                onPressed: ()async {
                                  Contact contact = await _contactPicker.selectContact();
                                  setState(() {
                                    _contactpick = contact;
                                    _contact.text = _contactpick.phoneNumber;
                                    _firstName.text = _contactpick.fullName;
                                  });
                                },
                                icon: Icon(
                                  const IconData(0xe826, fontFamily: 'CustomIcon'),
                                  color: Colors.grey,),
                              )
                          ),
                          validator: (value) {
                            if (value.trim().isEmpty) {
                              FocusScope.of(context).requestFocus(__fullName);
                              return 'Please enter the name';
                            }
                          },
                          onFieldSubmitted: (String value) {
                            if (!_formKey.currentState.validate()) {
                              FocusScope.of(context).requestFocus(__fullName);
                            }
                          },

                        ),
                      ),
                    ),
                    SizedBox(height: 15.0),

                    Padding(
                      padding: const EdgeInsets.only(left: 15.0,right: 15.0),
                      child: Container(
                        width: MediaQuery.of(context).size.width * .9,
                        child: TextFormField(
                          // textInputAction: TextInputAction.done,
                          focusNode: __contact,
                          controller: _contact,
                          keyboardType: TextInputType.phone,
                          decoration: InputDecoration(
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide(color: Colors.grey.withOpacity(0.0), width: 1,),
                              ),
                              labelText: 'Phone',
                              prefixIcon: Padding(
                                padding: EdgeInsets.all(0.0),
                                child: Icon(
                                  Icons.call,
                                  color: Colors.grey,
                                ), // icon is 48px widget.
                              )),
                          validator: (value) {
                            if (value.isEmpty ||
                                value.length < 6 ||
                                value.length > 15) {
                              FocusScope.of(context).requestFocus(__contact);
                              return 'Please enter a valid Phone No.';
                            }
                          },
                          onFieldSubmitted: (String value) {
                            if (!_formKey.currentState.validate()) {
                              FocusScope.of(context).requestFocus(__contact);
                            }
                          },
                        ),
                      ),
                    ),
                    SizedBox(height: 15.0),

                    Padding(
                      padding: const EdgeInsets.only(left: 15.0,right: 15.0),
                      child: Container(
                        width: MediaQuery.of(context).size.width * .9,
                        child: TextFormField(
                          textInputAction: TextInputAction.next,
                          focusNode: __email,
                          controller: _email,
                          keyboardType: TextInputType.emailAddress,
                          decoration: InputDecoration(
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide(color: Colors.grey.withOpacity(0.0), width: 1,),
                              ),
                              labelText: 'Email(optional)',
                              //hintText: 'Email(optional)',
                              prefixIcon: Icon(
                                Icons.email,
                                color: Colors.grey,
                              )),
                          validator: (value) {
                            Pattern pattern =
                                r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
                            RegExp regex = new RegExp(pattern);
                            if (value.isNotEmpty && !regex.hasMatch(value)) {
                              FocusScope.of(context).requestFocus(__email);
                              return 'Enter a valid Email ID';
                            }
                          },
                          onFieldSubmitted: (String value) {
                            if (!_formKey.currentState.validate()) {
                              FocusScope.of(context).requestFocus(__email);
                            }
                            else{
                              FocusScope.of(context).requestFocus(__pass);
                            }
                          },
                        ),
                      ),
                    ),
                    SizedBox(height: 15.0),

                    Padding(
                      padding: const EdgeInsets.only(left: 15.0,right: 15.0),
                      child: Container(
                          width: MediaQuery.of(context).size.width * .9,
                          child: TextFormField(
                            enabled: false,
                            //   initialValue: '12345678',
                            controller: _pass,
                            keyboardType: TextInputType.text,
                            obscureText: _obscureText,
                            decoration: InputDecoration(
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide( color: Colors.grey.withOpacity(0.0), width: 1,),
                              ),
                              hintText: 'Password',
                              labelText: 'Password',
                              prefixIcon: Icon(Icons.lock_open),
//                              suffixIcon: IconButton(
//                                onPressed: _toggle,
//                                icon: Icon(_obscureText
//                                    ? Icons.visibility_off
//                                    : Icons.visibility,
//                                    color: Colors.grey,),
//                              )
                            ),
                            validator: (value) {
                              if (value.isEmpty || value.length < 6) {
                                return 'Password is too short';
                              }
                            },
                            onFieldSubmitted: (String value) {
                              if (_formKey.currentState.validate()) {
                                //requesttimeoff(_dateController.text ,_starttimeController.text,_endtimeController.text,_reasonController.text, context);
                              }
                            },

                          )),

                    ),
                    SizedBox(height: 15.0),
                    new Container(
                        padding: EdgeInsets.only(left: 15.0, right: 2.0),
                        child:new Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            //Padding(padding: EdgeInsets.only(right: 100.0),),
                            visibilityTag == false ?new InkWell(
                              onTap:() {
                                setState((){
                                  visibilityTag=true;
                                });
                              },
                              child:Text("Show Details",textAlign: TextAlign.justify,
                                  style: new TextStyle(fontSize:18.0,color: appcolor ,
                                    decoration: TextDecoration.underline,
                                  )

                              ),
                            ):
                            //Padding(padding: EdgeInsets.only(right: 10.0),),
                            new InkWell(
                                onTap:() {
                                  setState(() {
                                    visibilityTag = false;
                                  } );
                                  //visibilityTag = false;
                                  //print(visibilityTag);
                                  getdeptid();
                                  getdesgid();
                                  getshiftid();
                                },
                                child:Text("Hide Details",textAlign: TextAlign.center,
                                    style: new TextStyle( fontSize:18.0, color: appcolor ,
                                      decoration: TextDecoration.underline,)))
                          ],
                        )


                    ),

                    /*Padding(
                      padding: const EdgeInsets.only(left:15.0,right: 15.0),
                      child: Text(
                        'Add Employee',
                        style: TextStyle(
                          fontSize: 20.0,
                          letterSpacing: 0.5,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),*/
                    ////////////////////-----------------

                    (admin_sts == '1') && (visibilityTag == true) ? getDepartments_DD() : Container(),
                    (admin_sts == '2') && (visibilityTag == true) ? getDepartments_DD1(): Container(),
                    visibilityTag ?getDesignations_DD(): Container(),
                    visibilityTag ?getShifts_DD():Container(),


                    ////////////////////-----------------

//                    ButtonBar(
//                      alignment: MainAxisAlignment.spaceEvenly,
//                      mainAxisSize: MainAxisSize.max,
//                      children: <Widget>[
//
//                      ],
//                    ),
                  ],
                ),
              ),
              //---------------------------------------------------

              //---------------------------------------------------
            ])),
      ),
    );
  }

  ////////////////common dropdowns

  permission() async
  {
    // Map<PermissionGroup, PermissionStatus> permissions = await PermissionHandler().requestPermissions([PermissionGroup.contacts]);
    PermissionStatus permission = await PermissionHandler().checkPermissionStatus(PermissionGroup.contacts);
    return permission;
  }

  Widget getDepartments_DD() {

    String dc = "0";
    return new FutureBuilder<List<Map>>(
        future: getDepartmentsList(0), //with -select- label
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            //getdptId();

            return Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[

                InkWell(
                  onTap: (){
                    _showDialog(context);
                    // Navigator.push(context, MaterialPageRoute(builder: (context) => Department()),);
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.only(left:15.0,right: 15.0),
                        child: Text(
                          'Department',
                          style: TextStyle(
                            fontSize:15.0,
                            letterSpacing: 0.5,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),

                      Padding(
                        padding: const EdgeInsets.only(top:5.0,bottom: 5.0,right: 15.0,),
                        child: InkWell(
                          child: Row(
                            children: <Widget>[
                              Icon(
                                Icons.add,
                                size: 24,
                                color: Colors.black,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 5,),
                Padding(
                  padding: const EdgeInsets.only(left: 15.0,right: 15.0),
                  child: new Container(
                    width: MediaQuery.of(context).size.width * .9,
                    //    width: MediaQuery.of(context).size.width*.45,
                    child: InputDecorator(
                      decoration: InputDecoration(

                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide( color: Colors.grey.withOpacity(0.0), width: 1,),
                        ),
                        labelText: 'Department',
                        prefixIcon: Icon(
                          Icons.group,
                          color: Colors.grey,
                        ),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: ButtonTheme(
                          child: new DropdownButton<String>(
                            isDense: true,
                            style: new TextStyle(fontSize: 15.0, color: Colors.black),
                            hint: new Text("Select Department"),
                            value: deptind == ""? "0" : deptind,
                            onChanged: (String newValue) {
                              setState(() {
                                deptind = newValue;
                              });
                            },
                            items: snapshot.data.map((Map map) {
                              return new DropdownMenuItem<String>(
                                value: map["Id"].toString(),
                                child: new SizedBox(
                                    child: new Text(
                                      map["Name"],
                                    )),
                              );
                            }).toList(),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            );
          } else if (snapshot.hasError) {
            return new Text("${snapshot.error}");
          }
          // return loader();
          return new Center(
            child: SizedBox(
              child: CircularProgressIndicator(
                strokeWidth: 2.2,
              ),
              height: 20.0,
              width: 20.0,
            ),
          );
        });
  }
  ////////////////drop down- start

  _showDialog(context) async {
    await showDialog<String>(
      context: context,
      child: new AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        contentPadding: const EdgeInsets.all(15.0),
        content: Container(
          height: MediaQuery.of(context).size.height*0.27,
          width: MediaQuery.of(context).size.width*0.32,
          child: Column(
            children: <Widget>[
              SizedBox(height: 5.0),
              Center(
                child:Text("Add Department",style: new TextStyle(fontSize: 22.0,color: appcolor)),
              ),
              SizedBox(height: 15.0),
              new Expanded(
                child: new TextField(
                  controller: deptctr,
                  //  focusNode: f_dept,
                  autofocus: false,
                  //   controller: client_name,
                  decoration: new InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide( color: Colors.grey.withOpacity(0.0), width: 1,),
                      ),
                      labelText: 'Department ', hintText: 'Department Name'),
                ),
              ),
              SizedBox(height: 5.0),
              new Expanded(
                child:  new InputDecorator(
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide( color: Colors.grey.withOpacity(0.0), width: 1,),
                    ),
                    labelText: 'Status',
                  ),
                  isEmpty: _sts == '',
                  child: new DropdownButtonHideUnderline(
                    child: new DropdownButton<String>(
                      value: _sts,
                      isDense: true,
                      onChanged: (String newValue) {
                        setState(() {
                          _sts = newValue;
                          print("this is new _sts " + newValue);
                          Navigator.of(context, rootNavigator: true).pop('dialog'); // here I pop to avoid multiple Dialogs
                          _showDialog(context);
                        });
                      },
                      items: <String>['Active', 'Inactive'].map((String value) {
                        return new DropdownMenuItem<String>(
                          value: value,
                          child: new Text(value),
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        actions: <Widget>[
          Padding(
            padding: const EdgeInsets.only(right:8.0),
            child: new FlatButton(
                highlightColor: Colors.transparent,
                focusColor: Colors.transparent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(5),
                  side: BorderSide( color: Colors.grey.withOpacity(0.5), width: 1,),
                ),
                child: const Text('CANCEL',style: TextStyle(color: Colors.black),),
                onPressed: () {
                  deptctr.text='';
                  _sts='Active';
                  // Navigator.pop(context);
                  Navigator.of(context, rootNavigator: true).pop('dialog');
                }),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: new RaisedButton(
                elevation: 2.0,
                highlightElevation: 5.0,
                highlightColor: Colors.transparent,
                disabledElevation: 0.0,
                focusColor: Colors.transparent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(5),
                ),

                color: buttoncolor,
                child: (_isButtonDisabled)?Text('WAIT...'):Text('SAVE',style: TextStyle(color: Colors.white),),
                onPressed: ()
                {
                  if( deptctr.text.trim()==''){
                    //    FocusScope.of(context).requestFocus(f_dept);
                    showInSnackBar('Enter a Department Name');
                  }
                  else {
                    if(_isButtonDisabled)
                      return null;
                    setState(() {
                      _isButtonDisabled=true;
                    });
                    addDept(deptctr.text, _sts).
                    then((res) {
                      if(int.parse(res)==0) {
                        showInSnackBar('Unable to add the department');
                      }
                      else if(int.parse(res)==-1)
                        showInSnackBar('Department already exists');
                      else {
                        Navigator.of(context, rootNavigator: true).pop('dialog');
                        showInSnackBar('Department added successfully');
                        // getDeptWidget();
                        deptctr.text = '';
                        _sts = 'Active';
                      }
                      setState(() {
                        _isButtonDisabled=false;
                      });

                    }
                    ).catchError((err){
                      showInSnackBar('unable to call the service');
                      setState(() {
                        _isButtonDisabled=false;
                      });
                    });
                  }

                }),
          ),
        ],
      ),
    );
  }

  _showDialog_desg(context) async {
    await showDialog<String>(
      context: context,
      child: new AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        contentPadding: const EdgeInsets.all(15.0),
        content: Container(
          height: MediaQuery.of(context).size.height*0.27,
          width: MediaQuery.of(context).size.width*0.32,
          child: Column(
            children: <Widget>[
              SizedBox(height: 5.0),
              Center(
                child:Text("Add  Designation",style: new TextStyle(fontSize: 22.0,color: appcolor)),
              ),
              SizedBox(height: 15.0),
              new Expanded(
                child: new TextField(
                  controller: desgctrl,
                  autofocus: false,
                  //   controller: client_name,
                  decoration: new InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide( color: Colors.grey.withOpacity(0.0), width: 1,),
                      ),
                      labelText: 'Designation ', hintText: 'Designation Name'),
                ),
              ),
              SizedBox(height: 5.0),
              new Expanded(
                child:  new InputDecorator(
                  decoration:  InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide( color: Colors.grey.withOpacity(0.0), width: 1,),
                    ),
                    labelText: 'Status',
                  ),
                  isEmpty: _sts == '',
                  child: new DropdownButtonHideUnderline(
                    child: new DropdownButton<String>(
                      value: _sts,
                      isDense: true,
                      onChanged: (String newValue) {
                        setState(() {
                          _sts = newValue;
                          Navigator.of(context, rootNavigator: true).pop('dialog');
                          _showDialog(context);
                        });
                      },
                      items: <String>['Active', 'Inactive'].map((String value) {
                        return new DropdownMenuItem<String>(
                          value: value,
                          child: new Text(value),
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        actions: <Widget>[
          Padding(
            padding: const EdgeInsets.only(right:8.0),
            child: new FlatButton(
                highlightColor: Colors.transparent,
                focusColor: Colors.transparent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(5),
                  side: BorderSide( color: Colors.grey.withOpacity(0.5), width: 1,),
                ),
                child: const Text('CANCEL',style: TextStyle(color: Colors.black),),
                onPressed: () {
                  desgctrl.text='';
                  _sts='Active';
                  Navigator.of(context, rootNavigator: true).pop('dialog');
                }),
          ),
          Padding(
            padding: const EdgeInsets.only(right:8.0),
            child: new RaisedButton(
                elevation: 2.0,
                highlightElevation: 5.0,
                highlightColor: Colors.transparent,
                disabledElevation: 0.0,
                focusColor: Colors.transparent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(5),
                ),
                color: buttoncolor,
                child: (_isButtonDisabled)?Text('WAIT...'):Text('SAVE',style: TextStyle(color: Colors.white),),
                onPressed: ()
                {

                  if(desgctrl.text.trim()==''){
                    showInSnackBar('Enter a Designation');
                  }
                  else {
                    if(_isButtonDisabled)
                      return null;
                    setState(() {
                      _isButtonDisabled=true;
                    });

                    addDesg(desgctrl.text, _sts).
                    then((res) {
                      if(int.parse(res)==0) {
                        Navigator.of(context, rootNavigator: true).pop('dialog');
                        showInSnackBar('Unable to add this designation');
                      }
                      else if(int.parse(res)==-1) {
                        Navigator.of(context, rootNavigator: true).pop('dialog');
                        showInSnackBar('Designation already exists');
                      }
                      else {
                        Navigator.of(context, rootNavigator: true).pop('dialog');
                        showInSnackBar('Designation added successfully');
                        // getDesgWidget();
                        desgctrl.text = '';
                        _sts = 'Active';
                      }

                      setState(() {
                        _isButtonDisabled=false;
                      });
                    }
                    ).catchError((err){
                      showInSnackBar('Unable to call the service');
                      setState(() {
                        _isButtonDisabled=false;
                      });
                    });
                  }

                }),
          ),
        ],
      ),
    );
  }

  Widget getDepartments_DD1() {

    return Column(
      children: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(left:15.0,right: 15.0),
              child: Text(
                'Department',
                style: TextStyle(
                  fontSize: 15.0,
                  letterSpacing: 0.5,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        Padding(
          padding: const EdgeInsets.only(left: 15.0,right: 15.0),
          child: Container(
            width: MediaQuery.of(context).size.width * .9,
            child: TextFormField(
//              onFieldSubmitted: (String value) {
//                FocusScope.of(context).requestFocus(__newPass);
//              },
              controller: _department1,
              enabled: false,
              keyboardType: TextInputType.text,
              decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide( color: Colors.grey.withOpacity(0.0), width: 1,),
                  ),
                  labelText: 'Department',
                  prefixIcon: Icon(
                    Icons.phone_android,
                    color: Colors.grey,
                  )),
              /* validator: (value) {
                if (value.isEmpty || value.length <6 || value.length >15 ) {
                  return 'Please Enter valid department';
                }
              },*/
              /* onFieldSubmitted: (String value) {
                if (_formKey.currentState.validate()) {
                  //requesttimeoff(_dateController.text ,_starttimeController.text,_endtimeController.text,_reasonController.text, context);
                }
              },*/
            ),
          ),
        ),
      ],
    );
  }

  ////////////////////////////////////////////////////////////////
  Widget getDesignations_DD() {
    print(admin_sts);
    print(supervisor);
    print("supervisor list");
    String dc = "0";
    return new FutureBuilder<List<Map>>(
        future: getDesignationsList(0),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
//            for(int i = 0 ; i < snapshot.data.length; i++){
//              if(snapshot.data[i]["Name"] == "Dummy Designation"){
//                desgind = snapshot.data[i]["Id"];
//              }
//            }
            return Column(
              children: <Widget>[
                InkWell(
                  onTap: (){
                    _showDialog_desg(context);
                    //Navigator.push(context, MaterialPageRoute(builder: (context) => Designation()),);
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.only(left:15.0,right: 15.0),
                        child: Text(
                          'Designation',
                          style: TextStyle(
                            fontSize: 15.0,
                            letterSpacing: 0.5,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top:5.0,bottom: 5.0,right: 15.0),
                        child: InkWell(
                          child: Row(
                            children: <Widget>[
                              Icon(
                                Icons.add,
                                size: 24,
                                color: Colors.black,
                              ),
                            ],
                          ),
                        ),
                      )
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 15.0,right: 15.0),
                  child: new Container(
                    width: MediaQuery.of(context).size.width * .9,
                    //    width: MediaQuery.of(context).size.width*.45,
                    child: InputDecorator(
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide( color: Colors.grey.withOpacity(0.0), width: 1,),
                        ),
                        labelText: 'Designation',
                        hintText: "Select Designation",
                        prefixIcon: Icon(
                          Icons.desktop_windows,
                          color: Colors.grey,
                        ),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: ButtonTheme(
                          child: new DropdownButton<String>(
                            isDense: true,
                            style: new TextStyle(fontSize: 15.0, color: Colors.black),
                            hint: new Text("Select Designation"),

                            value: desgind== "0"? "0":desgind,
                            onChanged: (String newValue) {
                              setState(() {
                                desgind = newValue;
                              });
                            },
                            items: snapshot.data.map((Map map) {
                              return new DropdownMenuItem<String>(
                                value: map["Id"].toString(),
                                child: new SizedBox(
                                    width: 200.0,
                                    child: new Text(
                                      map["Name"],
                                    )),
                              );
                            }).toList(),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            );
          } else if (snapshot.hasError) {
            return new Text("${snapshot.error}");
          }
          // return loader();
          return new Center(
            child: SizedBox(
              child: CircularProgressIndicator(
                strokeWidth: 2.2,
              ),
              height: 20.0,
              width: 20.0,
            ),
          );
        });
  } /////////////////////////////////////////////////////////////

  Widget getShifts_DD() {
    return new FutureBuilder<List<Map>>(
        future: getShiftsList(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
//            for(int i = 0 ; i < snapshot.data.length; i++){
//              if(snapshot.data[i]["Name"] == "Dummy Shift"){
//                 shiftind = snapshot.data[i]["Id"];
//              }
//            }
            return Column(
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.only(left:15.0,right: 15.0,top: 5.0,bottom: 5.0),
                      child: Text(
                        'Shift',
                        style: TextStyle(
                          fontSize: 15.0,
                          letterSpacing: 0.5,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                new Container(
                  width: MediaQuery.of(context).size.width * .9,
                  //    width: MediaQuery.of(context).size.width*.45,
                  child: InputDecorator(
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide( color: Colors.grey.withOpacity(0.0), width: 1,),
                      ),
                      labelText: 'Shift',
                      hintText: "Select Shift",
                      prefixIcon: Icon(
                        Icons.access_alarm,
                        color: Colors.grey,
                      ),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: ButtonTheme(
                        child: new DropdownButton<String>(
                          isDense: true,
                          style: new TextStyle(fontSize: 15.0, color: Colors.black),
                          hint: new Text("Select Shift"),

                          value:  shiftind == "0"? "0":shiftind ,
                          onChanged: (String newValue) {
                            setState(() {
                              shiftind = newValue;
                            });
                          },
                          items: snapshot.data.map((Map map) {
                            return new DropdownMenuItem<String>(
                              value: map["Id"].toString(),
                              child: new SizedBox(
                                  width: 200.0,
                                  child: new Text(
                                    map["Name"],
                                  )),
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            );
          } else if (snapshot.hasError) {
            return new Text("${snapshot.error}");
          }
          // return loader();
          return new Center(
            child: SizedBox(
              child: CircularProgressIndicator(
                strokeWidth: 2.2,
              ),
              height: 20.0,
              width: 20.0,
            ),
          );
        });
  }

  openWhatsApp(msg, number) async {
    var url = "https://wa.me/" + number + "?text=" + msg;
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch Maps';
    }
  }

//  _launchURL(url) async {
//    print(url);
//    print("lunchURl");
//    //  const url = 'https://flutter.io';
//    if (await canLaunch(url)) {
//      await launch(url);
//    } else {
//      throw 'Could not launch $url';
//    }
//  }

  dialogwidget(msg, number) {
    print("launch");
    showDialog(
        context: context,
        child: new AlertDialog(
          content: new Text('Do you want to notify the user?'),
          actions: <Widget>[
            FlatButton(
              child: Text('Close',style: TextStyle(color: Colors.black),),
              shape: Border.all( color: Colors.grey),
              onPressed: () {
                Navigator.of(context, rootNavigator: true).pop();
              },
            ),
            RaisedButton(
              child: Text(
                'Notify user',
                style: TextStyle(color: Colors.white),
              ),
              color: Colors.amber,
              onPressed: () async {
                Navigator.of(context, rootNavigator: true).pop();
                openWhatsApp(msg, number);
//                var whatsappUrl ="whatsapp://send?phone=$number";
//                await canLaunch(whatsappUrl)? launch(whatsappUrl)
//                    //:print("open whatsapp app link or do a snackbar with notification that there is no whatsapp installed");
//                    : _launchURL( 'sms:' + number.toString());
                //_launchURL( 'sms:' + number.toString());
              },
            ),
          ],
        ));
  }

////////////////common dropdowns/
}
