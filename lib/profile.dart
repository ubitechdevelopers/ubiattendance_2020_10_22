
// Copyright 2017 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:io';

import 'package:Shrine/globals.dart' as prefix0;
import 'package:Shrine/model/model.dart';
import 'package:Shrine/services/gethome.dart';
import 'package:Shrine/services/newservices.dart';
import 'package:Shrine/services/services.dart';
import 'package:admob_flutter/admob_flutter.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'globals.dart' as globals;
import 'Bottomnavigationbar.dart';
import 'drawer.dart';
import 'globals.dart';
import 'home.dart';
import 'login.dart';
// This app is a stateful, it tracks the user's current choice.
class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  /*var _defaultimage = new NetworkImage(
      "http://ubiattendance.ubihrm.com/assets/img/avatar.png");*/

  AdmobBannerSize bannerSize;
  GlobalKey<ScaffoldState> scaffoldState = GlobalKey();

  AdmobInterstitial interstitialAd;
  AdmobReward rewardAd;
  var profileimage;
  List<Map> countryList = [{"id":"0","name":"Country"},{"id":"2","name":"Afghanistan"},{"id":"4","name":"Albania"},{"id":"50","name":"Algeria"},{"id":"5","name":"American Samoa"},{"id":"6","name":"Andorra"},{"id":"7","name":"Angola"},{"id":"11","name":"Anguilla"},{"id":"3","name":"Antigua and Barbuda"},{"id":"160","name":"Argentina"},{"id":"8","name":"Armenia"},{"id":"9","name":"Aruba"},{"id":"10","name":"Australia"},{"id":"1","name":"Austria"},{"id":"12","name":"Azerbaijan"},{"id":"27","name":"Bahamas"},{"id":"25","name":"Bahrain"},{"id":"14","name":"Bangladesh"},{"id":"15","name":"Barbados"},{"id":"29","name":"Belarus"},{"id":"13","name":"Belgium"},{"id":"30","name":"Belize"},{"id":"16","name":"Benin"},{"id":"17","name":"Bermuda"},{"id":"20","name":"Bhutan"},{"id":"23","name":"Bolivia"},{"id":"22","name":"Bosnia and Herzegovina"},{"id":"161","name":"Botswana"},{"id":"24","name":"Brazil"},{"id":"28","name":"British Virgin Islands"},{"id":"26","name":"Brunei"},{"id":"19","name":"Bulgaria"},{"id":"18","name":"Burkina Faso"},{"id":"21","name":"Burundi"},{"id":"101","name":"Cambodia"},{"id":"32","name":"Cameroon"},{"id":"34","name":"Canada"},{"id":"43","name":"Cape Verde"},{"id":"33","name":"Cayman Islands"},{"id":"163","name":"Central African Republic"},{"id":"203","name":"Chad"},{"id":"165","name":"Chile"},{"id":"205","name":"China"},{"id":"233","name":"Christmas Island"},{"id":"39","name":"Cocos Islands"},{"id":"38","name":"Colombia"},{"id":"40","name":"Comoros"},{"id":"41","name":"Cook Islands"},{"id":"42","name":"Costa Rica"},{"id":"36","name":"Cote dIvoire"},{"id":"90","name":"Croatia"},{"id":"31","name":"Cuba"},{"id":"44","name":"Cyprus"},{"id":"45","name":"Czech Republic"},{"id":"48","name":"Denmark"},{"id":"47","name":"Djibouti"},{"id":"226","name":"Dominica"},{"id":"49","name":"Dominican Republic"},{"id":"55","name":"Ecuador"},{"id":"58","name":"Egypt"},{"id":"57","name":"El Salvador"},{"id":"80","name":"Equatorial Guinea"},{"id":"56","name":"Eritrea"},{"id":"60","name":"Estonia"},{"id":"59","name":"Ethiopia"},{"id":"62","name":"Falkland Islands"},{"id":"63","name":"Faroe Islands"},{"id":"65","name":"Fiji"},{"id":"186","name":"Finland"},{"id":"61","name":"France"},{"id":"64","name":"French Guiana"},{"id":"67","name":"French Polynesia"},{"id":"69","name":"Gabon"},{"id":"223","name":"Gambia"},{"id":"70","name":"Gaza Strip"},{"id":"77","name":"Georgia"},{"id":"46","name":"Germany"},{"id":"78","name":"Ghana"},{"id":"75","name":"Gibraltar"},{"id":"81","name":"Greece"},{"id":"82","name":"Greenland"},{"id":"228","name":"Grenada"},{"id":"83","name":"Guadeloupe"},{"id":"84","name":"Guam"},{"id":"76","name":"Guatemala"},{"id":"72","name":"Guernsey"},{"id":"167","name":"Guinea"},{"id":"79","name":"Guinea-Bissau"},{"id":"85","name":"Guyana"},{"id":"168","name":"Haiti"},{"id":"218","name":"Holy See"},{"id":"87","name":"Honduras"},{"id":"89","name":"Hong Kong"},{"id":"86","name":"Hungary"},{"id":"97","name":"Iceland"},{"id":"93","name":"India"},{"id":"169","name":"Indonesia"},{"id":"94","name":"Iran"},{"id":"96","name":"Iraq"},{"id":"95","name":"Ireland"},{"id":"74","name":"Isle of Man"},{"id":"92","name":"Israel"},{"id":"91","name":"Italy"},{"id":"99","name":"Jamaica"},{"id":"98","name":"Japan"},{"id":"73","name":"Jersey"},{"id":"100","name":"Jordan"},{"id":"102","name":"Kazakhstan"},{"id":"52","name":"Kenya"},{"id":"104","name":"Kiribati"},{"id":"106","name":"Kosovo"},{"id":"107","name":"Kuwait"},{"id":"103","name":"Kyrgyzstan"},{"id":"109","name":"Laos"},{"id":"114","name":"Latvia"},{"id":"171","name":"Lebanon"},{"id":"112","name":"Lesotho"},{"id":"111","name":"Liberia"},{"id":"110","name":"Libya"},{"id":"66","name":"Liechtenstein"},{"id":"113","name":"Lithuania"},{"id":"108","name":"Luxembourg"},{"id":"117","name":"Macau"},{"id":"125","name":"Macedonia"},{"id":"172","name":"Madagascar"},{"id":"132","name":"Malawi"},{"id":"118","name":"Malaysia"},{"id":"131","name":"Maldives"},{"id":"173","name":"Mali"},{"id":"115","name":"Malta"},{"id":"124","name":"Marshall Islands"},{"id":"119","name":"Martinique"},{"id":"170","name":"Mauritania"},{"id":"130","name":"Mauritius"},{"id":"120","name":"Mayotte"},{"id":"123","name":"Mexico"},{"id":"68","name":"Micronesia"},{"id":"122","name":"Moldova"},{"id":"121","name":"Monaco"},{"id":"127","name":"Mongolia"},{"id":"126","name":"Montenegro"},{"id":"128","name":"Montserrat"},{"id":"116","name":"Morocco"},{"id":"129","name":"Mozambique"},{"id":"133","name":"Myanmar"},{"id":"136","name":"Namibia"},{"id":"137","name":"Nauru"},{"id":"139","name":"Nepal"},{"id":"142","name":"Netherlands"},{"id":"135","name":"Netherlands Antilles"},{"id":"138","name":"New Caledonia"},{"id":"146","name":"New Zealand"},{"id":"140","name":"Nicaragua"},{"id":"174","name":"Niger"},{"id":"225","name":"Nigeria"},{"id":"141","name":"Niue"},{"id":"145","name":"Norfolk Island"},{"id":"144","name":"North Korea"},{"id":"143","name":"Northern Mariana Islands"},{"id":"134","name":"Norway"},{"id":"147","name":"Oman"},{"id":"153","name":"Pakistan"},{"id":"150","name":"Palau"},{"id":"149","name":"Panama"},{"id":"155","name":"Papua New Guinea"},{"id":"157","name":"Paraguay"},{"id":"151","name":"Peru"},{"id":"178","name":"Philippines"},{"id":"152","name":"Pitcairn Islands"},{"id":"154","name":"Poland"},{"id":"148","name":"Portugal"},{"id":"156","name":"Puerto Rico"},{"id":"158","name":"Qatar"},{"id":"164","name":"Republic of the Congo"},{"id":"166","name":"Reunion"},{"id":"175","name":"Romania"},{"id":"159","name":"Russia"},{"id":"182","name":"Rwanda"},{"id":"88","name":"Saint Helena"},{"id":"105","name":"Saint Kitts and Nevis"},{"id":"229","name":"Saint Lucia"},{"id":"191","name":"Saint Martin"},{"id":"195","name":"Saint Pierre and Miquelon"},{"id":"232","name":"Saint Vincent and the Grenadines"},{"id":"230","name":"Samoa"},{"id":"180","name":"San Marino"},{"id":"197","name":"Sao Tome and Principe"},{"id":"184","name":"Saudi Arabia"},{"id":"193","name":"Senegal"},{"id":"196","name":"Serbia"},{"id":"200","name":"Seychelles"},{"id":"224","name":"Sierra Leone"},{"id":"187","name":"Singapore"},{"id":"188","name":"Slovakia"},{"id":"190","name":"Slovenia"},{"id":"189","name":"Solomon Islands"},{"id":"194","name":"Somalia"},{"id":"179","name":"South Africa"},{"id":"176","name":"South Korea"},{"id":"51","name":"Spain"},{"id":"37","name":"Sri Lanka"},{"id":"198","name":"Sudan"},{"id":"192","name":"Suriname"},{"id":"199","name":"Svalbard"},{"id":"185","name":"Swaziland"},{"id":"183","name":"Sweden"},{"id":"35","name":"Switzerland"},{"id":"201","name":"Syria"},{"id":"162","name":"Taiwan"},{"id":"202","name":"Tajikistan"},{"id":"53","name":"Tanzania"},{"id":"204","name":"Thailand"},{"id":"206","name":"Timor-Leste"},{"id":"181","name":"Togo"},{"id":"209","name":"Tonga"},{"id":"211","name":"Trinidad and Tobago"},{"id":"208","name":"Tunisia"},{"id":"210","name":"Turkey"},{"id":"207","name":"Turkmenistan"},{"id":"212","name":"Turks and Caicos Islands"},{"id":"213","name":"Tuvalu"},{"id":"219","name":"U.S. Virgin Islands"},{"id":"54","name":"Uganda"},{"id":"214","name":"Ukraine"},{"id":"215","name":"United Arab Emirates"},{"id":"71","name":"United Kingdom"},{"id":"216","name":"United States"},{"id":"177","name":"Uruguay"},{"id":"217","name":"Uzbekistan"},{"id":"221","name":"Vanuatu"},{"id":"235","name":"Venezuela"},{"id":"220","name":"Vietnam"},{"id":"222","name":"Wallis and Futuna"},{"id":"227","name":"West Bank"},{"id":"231","name":"Western Sahara"},{"id":"234","name":"Yemen"},{"id":"237","name":"Zaire"},{"id":"236","name":"Zambia"},{"id":"238","name":"Zimbabwe"}];
  String _country;
  PersistentBottomSheetController controller;
  bool _checkLoaded = true;
  bool _isButtonDisabled= false;
  bool _isProfileUploading= false;
  int _currentIndex = 2;
  //bool _visible = true;
  String location_addr="";
  String location_addr1="";
  String admin_sts='0';
  String act="";
  String act1="";
  int response;
  String fname="", lname="", empid="", email="", status="", orgid="", orgdir="", sstatus="", org_name="", desination="", shifttiming="", profile,latit="",longi="";
  String department, shift, mobile;
  TextEditingController _phone;
  TextEditingController _city;
  String aid="";
  String shiftId="";
  @override
  void initState() {
    super.initState();

    bannerSize = AdmobBannerSize.FULL_BANNER;
    checkNetForOfflineMode(context);
    appResumedPausedLogic(context);
    checknetonpage(context);
    initPlatformState();

  }


  void handleEvent(
      AdmobAdEvent event, Map<String, dynamic> args, String adType) {
    switch (event) {
      case AdmobAdEvent.loaded:
      //showSnackBar('New Admob $adType Ad loaded!');
        break;
      case AdmobAdEvent.opened:
      //showSnackBar('Admob $adType Ad opened!');
        break;
      case AdmobAdEvent.closed:
      //showSnackBar('Admob $adType Ad closed!');
        break;
      case AdmobAdEvent.failedToLoad:
      //showSnackBar('Admob $adType failed to load. :(');
        break;
      case AdmobAdEvent.rewarded:
//        showDialog(
//          context: scaffoldState.currentContext,
//          builder: (BuildContext context) {
//            return WillPopScope(
//              child: AlertDialog(
//                content: Column(
//                  mainAxisSize: MainAxisSize.min,
//                  children: <Widget>[
//                    Text('Reward callback fired. Thanks Andrew!'),
//                    Text('Type: ${args['type']}'),
//                    Text('Amount: ${args['amount']}'),
//                  ],
//                ),
//              ),
//              onWillPop: () async {
//                scaffoldState.currentState.hideCurrentSnackBar();
//                return true;
//              },
//            );
//          },
//        );
        break;
      default:
    }
  }

  void showSnackBar(String content) {
    scaffoldState.currentState.showSnackBar(SnackBar(
      content: Text(content),
      duration: Duration(milliseconds: 1500),
    ));
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  initPlatformState() async {
    appResumedPausedLogic(context);
    final prefs = await SharedPreferences.getInstance();
    empid = prefs.getString('empid') ?? '';
    orgdir = prefs.getString('orgdir') ?? '';
    admin_sts = prefs.getString('sstatus') ?? '';
    response = prefs.getInt('response') ?? 0;
    if(response==1) {
      NewServices po = new NewServices();
      Map profileMap = await po.getProfile(empid);

      Home ho = new Home();
      act = await ho.checkTimeIn(empid, orgdir,context);
      setState(() {
        response = prefs.getInt('response') ?? 0;
        fname = prefs.getString('fname') ?? '';
        lname = prefs.getString('lname') ?? '';
        empid = prefs.getString('empid') ?? '';
        email = prefs.getString('email') ?? '';
        status = prefs.getString('status') ?? '';
        orgid = prefs.getString('orgid') ?? '';
        orgdir = prefs.getString('orgdir') ?? '';
        sstatus = (int.parse(prefs.getString('sstatus')))==1 ? 'You have logged in as an admin':'';
        org_name = prefs.getString('org_name') ?? '';
        desination = prefs.getString('desination') ?? '';
        profile = prefs.getString('profile') ?? '';
        print(profile);
        profileimage = new NetworkImage(profile);
        profileimage.resolve(new ImageConfiguration()).addListener(new ImageStreamListener((_, __) {
          if (mounted) {
            setState(() {
              _checkLoaded = false;
            });
          }
        }));
        //print("2-"+_checkLoaded.toString());
        act1=act;
        department = profileMap["dept"]??'';
        shift = profileMap["shift"]??'';
        desination = profileMap["desg"]??'';
        shifttiming = profileMap["shifttiming"]??'';
        _phone = new TextEditingController(text: profileMap["PersonalNo"]??'');
        _city = new TextEditingController(text: profileMap["PersonalNo"]??'');
        _country = profileMap["CurrentCountry"]??'';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return (response==0) ? new LoginPage() : getmainhomewidget();
  }

  void showInSnackBar(String value) {
    final snackBar = SnackBar(
    content: Text(value,textAlign: TextAlign.center,));
    _scaffoldKey.currentState.showSnackBar(snackBar);
  }

  void showBottomNavigation(){
    controller = _scaffoldKey.currentState
        .showBottomSheet<Null>((BuildContext context) {
      return new Container(
          color: appcolor.withOpacity(0.1),
          child: new Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              SizedBox(height: 20.0,),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                Text("Update profile photo", style: TextStyle(fontWeight: FontWeight.bold),)
              ],),
              SizedBox(height: 20.0,),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: <Widget>[
                  Column(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: <Widget>[
                  new RawMaterialButton(
                    onPressed: () {
                     controller.close();
                     updatePhoto(1);
                    },
                    child: new Icon(
                      Icons.photo,
                      size: 18.0,
                    ),
                    shape: new CircleBorder(),
                    elevation: 0.5,
                    fillColor: Colors.teal[100],
                    padding: const EdgeInsets.all(1.0),
                  ),
                      Text("Gallery\n")
                      ]
                  ),
                  Column(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: <Widget>[
                        new RawMaterialButton(
                          onPressed: () {
                            controller.close();
                            updatePhoto(2);
                          },
                          child: new Icon(
                            Icons.camera_alt,
                            size: 18.0,
                          ),
                          shape: new CircleBorder(),
                          elevation: 0.5,
                          fillColor: Colors.teal[100],
                          padding: const EdgeInsets.all(1.0),
                        ),
                        Text("Camera\n")
                      ]
                  ),
                  Column(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: <Widget>[
                        new RawMaterialButton(
                          onPressed: () {
                            controller.close();
                            updatePhoto(3);
                          },
                          child: new Icon(
                            Icons.delete,
                            size: 18.0,
                          ),
                          shape: new CircleBorder(),
                          elevation: 0.5,
                          fillColor: Colors.teal[100],
                          padding: const EdgeInsets.all(1.0),
                        ),
                        Text("Remove\n photo")
                      ]
                  )
                ],
              ),
              SizedBox(height: 20.0,),
              Divider(color: Colors.black,height: 3.0,),
              Container(
                color: appcolor.withOpacity(0.15),
              child:Column(
                children: <Widget>[
                  Center(
                  child:FlatButton(child:Text("Cancel"),onPressed: (){
                    controller.close();
                  },)
                  )
                ],
              )
      )

            ],
          ));
    });
  }

  getmainhomewidget(){
    return new Scaffold(
          key: _scaffoldKey,
          appBar: AppBar(
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                new Text(org_name, style: new TextStyle(fontSize: 20.0)),
              ],
            ),
            leading: IconButton(icon:Icon(Icons.arrow_back),onPressed:(){
              Navigator.pop(context);}),
            backgroundColor: appcolor,
          ),
      bottomNavigationBar: Bottomnavigationbar(),

          endDrawer: new AppDrawer(),
          body: (act1=='') ? Center(child : loader()) : checkalreadylogin(),
        );

  }
  checkalreadylogin(){
    //print("---->"+response.toString());
    if(response==1) {
      return new IndexedStack(
        index: _currentIndex,
        children: <Widget>[
          underdevelopment(),
          underdevelopment(),
          mainbodyWidget(),
        ],
      );
    }else{
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => LoginPage()),
      );
    }
  }
  loader(){
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
  underdevelopment(){
    return new Container(
      child: Center(
        child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              Icon(Icons.android,color: appcolor,),Text("Under development",style: new TextStyle(fontSize: 30.0,color: appcolor),)
            ]),
      ),
    );
  }

  poorNetworkWidget(){
    return Container(
      child: Center(
        child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Icon(Icons.error,color: appcolor,),
                    Text("Poor network connection.",style: new TextStyle(fontSize: 20.0,color: appcolor),),
                  ]),
              SizedBox(height: 5.0),
              FlatButton(
                child: new Text("Refresh location", style: new TextStyle(
                    color: Colors.blue, decoration: TextDecoration.underline),),
                onPressed: () {
                  //print("pushed");
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => ProfilePage()),
                  );
                },
              ),

            ]),
      ),
    );
  }

  mainbodyWidget(){
    ////to do check act1 for poor network connection

    if(act1=="Poor network connection") {
      return poorNetworkWidget();
    }else {
      return SafeArea(
        child: ListView(
          children: <Widget>[
            Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                SizedBox(height: 10.0),
                new Stack(
                    children: <Widget>[
                  _isProfileUploading?new Container(
                      width: 50.0,
                      height: 50.0,
                      decoration: new BoxDecoration(
                          shape: BoxShape.circle,
                          image: new DecorationImage(
                            fit: BoxFit.fill,
                            image:AssetImage('assets/spinner.gif'),
                          )
                      )
                  ):Container(
                    width: 110.0,
                    height: 110.0,
                    decoration: new BoxDecoration(
                        shape: BoxShape.circle,
                        image: new DecorationImage(
                          fit: BoxFit.fill,
                          image: _checkLoaded ? AssetImage('assets/avatar.png') : profileimage,
                        )
                    )
                  ),
                  new Positioned(
                    left: MediaQuery.of(context).size.width*.11,
                    top: MediaQuery.of(context).size.height*.09,
                    child: new RawMaterialButton(
                      onPressed: () {
                        //controller.close();
                        showBottomNavigation();
                      },
                      child: new Icon(
                        Icons.camera_alt,
                        size: 18.0,
                      ),
                      shape: new CircleBorder(),
                      elevation: 0.5,
                      fillColor: appcolor,
                      padding: const EdgeInsets.all(1.0),
                    ),
                  ),
               ] ),
                SizedBox(height: MediaQuery.of(context).size.height*.01),
                //Image.asset('assets/logo.png',height: 150.0,width: 150.0),
                // SizedBox(height: 5.0),
                Container( // Detailed box of employee
                  padding: new EdgeInsets.only(left: 15.0, right: 10.0),
                  decoration: new ShapeDecoration(
                      shape: new RoundedRectangleBorder(borderRadius: new BorderRadius.circular(20.0)),
                      color: Colors.white.withOpacity(0.1)
                  ) ,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: <Widget>[
                      //SizedBox(height: MediaQuery.of(context).size.height*.1),
                      Row(
                        children: <Widget>[
                          Icon(Icons.perm_identity,size: 20.0,color: Colors.black54,),SizedBox(width: 5.0),
                          new Text("Name: ", style: new TextStyle(fontSize: 15.0)),
                          new Text(" "+fname+" "+lname, style: new TextStyle(fontSize: 15.0,fontWeight: FontWeight.bold)),
                        ],
                      ),
                      SizedBox(height: MediaQuery.of(context).size.height*.01),
                      Row(
                        children: <Widget>[
                          Icon(Icons.work,size: 20.0,color: Colors.black54,),SizedBox(width: 5.0),
                          new Text("Designation: ", style: new TextStyle(fontSize: 15.0)),
                          new Text(" "+desination, style: new TextStyle(fontSize: 15.0,fontWeight: FontWeight.bold)),
                        ],
                      ),
                      SizedBox(height: MediaQuery.of(context).size.height*.01),
                      Row(
                        children: <Widget>[
                          Icon(Icons.account_balance,size: 20.0,color: Colors.black54,),SizedBox(width: 5.0),
                          new Text("Department: ", style: new TextStyle(fontSize: 15.0)),
                          new Text(" "+department, style: new TextStyle(fontSize: 15.0,fontWeight: FontWeight.bold)),
                        ],
                      ),
                      SizedBox(height: MediaQuery.of(context).size.height*.01),
                      Row(
                        children: <Widget>[
                          Icon(Icons.timelapse,size: 20.0,color: Colors.black54,),SizedBox(width: 5.0),
                          new Text("Shift: ", style: new TextStyle(fontSize: 15.0)),
                          new Text(" "+shift, style: new TextStyle(fontSize: 15.0,fontWeight: FontWeight.bold)),
                        ],
                      ),
                      SizedBox(height: MediaQuery.of(context).size.height*.01),
                      Row(
                        children: <Widget>[
                          Icon(Icons.timer,size: 20.0,color: Colors.black54,),SizedBox(width: 5.0),
                          new Text("Shift Timings: ", style: new TextStyle(fontSize: 15.0)),
                          new Text(" "+shifttiming, style: new TextStyle(fontSize: 15.0,fontWeight: FontWeight.bold)),
                        ],
                      ),
                      SizedBox(height: MediaQuery.of(context).size.height*.02),
                      new TextFormField(
                        style: new TextStyle(
                            fontSize: 15.0,
                            color: Colors.black
                        ),
                        decoration:  InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide( color: Colors.grey.withOpacity(0.0), width: 1,),
                          ),
                          prefixIcon: const Icon(Icons.phone,size: 20.0,),
                          labelText: 'Phone',
                        ),
                        controller: _phone,
                        keyboardType: TextInputType.phone,
                        validator: (date) {
                          if (_phone.text==null||_phone.text.trim()==''){
                            return 'Please enter Phone Number';
                          }
                        },
                      ),
                      ButtonBar(
                        children: <Widget>[
                          FlatButton(
                            highlightColor: Colors.transparent,
                            focusColor: Colors.transparent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(5),
                              side: BorderSide( color: Colors.grey.withOpacity(0.5), width: 1,),
                            ),
                            child: Text('CANCEL'),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => HomePage()),
                              );
                            },
                          ),
                          RaisedButton(
                            elevation: 2.0,
                            highlightElevation: 5.0,
                            highlightColor: Colors.transparent,
                            disabledElevation: 0.0,
                            focusColor: Colors.transparent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(5),
                            ),
                            child: _isButtonDisabled?Text(
                              'Processing..',
                              style: TextStyle(color: Colors.white),
                            ):Text(
                              'SAVE',
                              style: TextStyle(color: Colors.white)
                              ,),
                            color: buttoncolor,
                            onPressed: () {
                              if(_isButtonDisabled)
                                return null;
                              if(_phone.text.trim()==''){
                                showInSnackBar('Please enter Phone no.');
                                return null;
                              }

                              setState(() {
                                _isButtonDisabled=true;
                              });
                              updateProfile(_phone.text.trim(),'');
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                  width: MediaQuery.of(context).size.width*.9,
                  height: MediaQuery.of(context).size.height*.5,
                ),

                /////////////////////// edit box of Employee ///////////////////
                /*new Stack(
                  children: <Widget>[
                Container( // Detailed box of employee
                  padding: new EdgeInsets.only(left: 10.0, right: 10.0),
                  decoration: new ShapeDecoration(
                      shape: new RoundedRectangleBorder(borderRadius: new BorderRadius.circular(20.0)),
                      color: Colors.white10
                  ) ,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: <Widget>[

                      new TextFormField(
                        style: new TextStyle(
                            fontSize: 15.0,
                            color: Colors.black
                        ),
                        decoration: const InputDecoration(
                          icon: const Icon(Icons.phone,size: 20.0,),
                          labelText: 'Phone',
                        ),
                        controller: _phone,
                        keyboardType: TextInputType.phone,
                      ),

                      ButtonBar(
                        children: <Widget>[
                          FlatButton(
                            shape: Border.all(color: Colors.black54),
                            child: Text('CANCEL'),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => HomePage()),
                              );
                            },
                          ),
                          RaisedButton(
                            child: _isButtonDisabled?Text('Processing..',style: TextStyle(color: Colors.white),):Text('SAVE',style: TextStyle(color: Colors.white),),
                            color: Colors.orangeAccent,
                            onPressed: () {
                              if(_isButtonDisabled)
                                return null;
                              setState(() {
                                _isButtonDisabled=true;
                              });
                              updateProfile(_phone.text,'');
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                  width: MediaQuery.of(context).size.width*.9,
                  height: MediaQuery.of(context).size.height*.35,
                ),

                ]
                ),*/

              ],
            ),
            if(globals.currentOrgStatus=="TrialOrg" )
            Container(
              margin: EdgeInsets.only(bottom: 0.0),
              child: AdmobBanner(
                adUnitId: getBannerAdUnitId(),
                adSize: bannerSize,
                listener:
                    (AdmobAdEvent event, Map<String, dynamic> args) {
                  //handleEvent(event, args, 'Banner');
                },
              ),
            ),
          ],
        ),

      );
    }
  }

  updatePhoto(int uploadtype) async{
    setState(() {
      _isProfileUploading = true;
    });
    NewServices ns = NewServices();

    var prefs= await SharedPreferences.getInstance();
    prefix0.showAppInbuiltCamera=prefs.getBool("showAppInbuiltCamera")??false;
    bool isupdate = showAppInbuiltCamera?await ns.updateProfilePhotoAppCamera(uploadtype,empid,orgid,context):await ns.updateProfilePhoto(uploadtype,empid,orgid,context);
    print('Image status');
    print(isupdate);
   // bool isupdate = true;
    if(isupdate){
      var smstext = "Profile image has been changed.";
      setState(() {
        _isProfileUploading = false;
      });
      if(uploadtype==3){
        setState(() {
          _checkLoaded = true;
          smstext = "Profile image has been removed.";
        });
      }
      // ignore: deprecated_member_use
      showDialog(context: context, child:
      new AlertDialog(
        content: new Text(smstext),
      )
      );
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => ProfilePage()),
      );
    }else{
      setState(() {
        _isProfileUploading = false;
      });
      if(selectimg)
      // ignore: deprecated_member_use
      showDialog(context: context, child:
      new AlertDialog(
        //title: new Text("Congrats!"),
        content: new Text("Couldn't load this photo, Please try again."),
      )
      );
    }
  }

  updateProfile(String mobile, String countryid) async{
    var profile = Profile(empid, orgid, mobile, countryid);
    NewServices ns = NewServices();
    var islogin = await ns.updateProfile(profile);;
    //print(islogin);
    if(islogin=="success"){
      setState(() {
        _isButtonDisabled=false;
      });
     /* Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => HomePage()),
      );*/
      // ignore: deprecated_member_use
      showDialog(context: context, child:
      new AlertDialog(
        title: new Text("Congrats!"),
        content: new Text("Your Profile is updated."),
      )
      );
    }else if(islogin=="failure"){
      setState(() {
        _isButtonDisabled=false;
      });
      // ignore: deprecated_member_use
      showDialog(context: context, child:
      new AlertDialog(
        //title: new Text("Sorry!"),
        content: new Text('No Changes Found.'),
      )
      );
    }else{
      setState(() {
        _isButtonDisabled=false;
      });
      // ignore: deprecated_member_use
      showDialog(context: context, child:
      new AlertDialog(
        title: new Text("Sorry!"),
        content: new Text("Poor network connection."),
      )
      );
    }
  }

  String getBannerAdUnitId() {
    if (Platform.isIOS) {
      return 'ca-app-pub-3940256099942544/2934735716';
    } else if (Platform.isAndroid) {
      return 'ca-app-pub-3940256099942544/6300978111';
    }
    return null;
  }
}



