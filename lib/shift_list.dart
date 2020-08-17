import 'package:Shrine/addShift.dart';
import 'package:Shrine/services/services.dart';
import 'package:flutter/material.dart';
import 'package:pdf/widgets.dart' as prefix0;
import 'package:shared_preferences/shared_preferences.dart';

import 'Bottomnavigationbar.dart';
import 'drawer.dart';
import 'globals.dart';
import 'settings.dart';
class ShiftList extends StatefulWidget {
  @override
  _ShiftList createState() => _ShiftList();
}
TextEditingController dept;
//FocusNode f_dept ;
class _ShiftList extends State<ShiftList> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  String _sts1 = 'Active';
  String _orgName='';
  bool _isButtonDisabled = false;
  String admin_sts='0';
  // var _shifts;        //sgcode1

  @override
  void initState() {
    super.initState();
    getshiftName();
    checkNetForOfflineMode(context);
    dept = new TextEditingController();
    getOrgName();
    //getshiftName();
    // _shifts = getShifts();
  }
  formatTime(String time){
    if(time.contains(":")){
      var a=time.split(":");
      return a[0]+":"+a[1];
    }
    else return time;

  }
  getOrgName() async{
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _orgName= prefs.getString('org_name') ?? '';
      admin_sts= prefs.getString('sstatus') ?? '0';
    });
  }

  Future<List<Shift>> getshiftName() {    //sgcode1
    print("inistate");
    return getShifts();
    // print(_shifts);
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
            Navigator.pop(context);}),
          backgroundColor: appcolor,
        ),
        bottomNavigationBar:Bottomnavigationbar(),

        endDrawer: new AppDrawer(),
        body:
        Container(
          //   padding: EdgeInsets.only(left: 2.0, right: 2.0),
          child: Column(
            children: <Widget>[
              SizedBox(height: 8.0),
              Center(
                child: Text('Shifts',
                  style: new TextStyle(fontSize: 22.0, color: appcolor,),),
              ),
              //Divider(height: 1.5,),
              Divider(height: 10.0,color: Colors.black),
              SizedBox(height: 2.0),
              Container(
                padding: EdgeInsets.only(bottom:10.0,top: 10.0),
                width: MediaQuery.of(context).size.width*.9,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Container(
                      width: MediaQuery.of(context).size.width*0.30,
                      child: Text('Shifts', style: TextStyle(color: appcolor,fontSize: 16.0, fontWeight: FontWeight.bold),textAlign: TextAlign.left,),
                    ),
                    Container(
                      width: MediaQuery.of(context).size.width*0.22,
                      child: Text('Time In', style: TextStyle(color: appcolor,fontSize: 16.0, fontWeight: FontWeight.bold),textAlign: TextAlign.center,),
                    ),
                    Container(
                      width: MediaQuery.of(context).size.width*0.22,
                      child: Text('Time Out', style: TextStyle( color: appcolor,fontSize: 16.0, fontWeight: FontWeight.bold),textAlign: TextAlign.center),
                    ),
                    Container(
                      width: MediaQuery.of(context).size.width*0.16,
                      child: Text('Status', style: TextStyle(color: appcolor,fontSize: 16.0, fontWeight: FontWeight.bold),textAlign: TextAlign.center),
                    ),

                  ],
                ),
              ),
              Divider(height: 0.2,),
              new Expanded(
                child: getShiftWidget(),
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
              MaterialPageRoute(builder: (context) => addShift()),
            );
          },
          tooltip: 'Add Shift',
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

  getShiftWidget() {
    return new FutureBuilder<List<Shift>>(
        future: getshiftName() ,                 //sgcode1
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
                                      new Text(snapshot.data[index].Name.toString()),
                                      new Text('('+snapshot.data[index].Type.toString()+')',style: TextStyle(color: Colors.grey)),
                                    ],
                                  )
                              ),
                              new Container(
                                width: MediaQuery.of(context).size.width*0.22,
                                child: new Text(formatTime(snapshot.data[index].TimeIn.toString()),textAlign: TextAlign.center,),
                              ),
                              new Container(
                                width: MediaQuery.of(context).size.width*0.22,
                                child: new Text(formatTime(snapshot.data[index].TimeOut.toString()), textAlign: TextAlign.center,),
                              ),
                              new Container(
                                width: MediaQuery.of(context).size.width*0.16,
                                child: new Text(snapshot.data[index].Status.toString(),
                                  style: snapshot.data[index].Name.toUpperCase().toString() == "TRIAL SHIFT"
                                      ?TextStyle(color: Colors.blueGrey)
                                      :TextStyle(color: snapshot.data[index].Status.toString()!='Active'?Colors.deepOrange:Colors.green),
                                  textAlign: TextAlign.center,),
                              ),
                            ],
                          ),
                          onPressed: (){
                            if(snapshot.data[index].Name.toUpperCase().toString() != "TRIAL SHIFT")
                              editDept(context,snapshot.data[index].Name.toString(),snapshot.data[index].Status.toString(),snapshot.data[index].Id.toString());
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

  //////////edit department
  editDept(context,dept,sts,did) async {
    _sts1=sts;
    var new_dept = new TextEditingController();
    new_dept.text=dept;
    await showDialog<String>(
      context: context,
      // ignore: deprecated_member_use
      child: new AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        contentPadding: const EdgeInsets.all(16.0),
        content: Container(
          height: MediaQuery.of(context).size.height*0.20,
          child: Column(
            children: <Widget>[
              new Expanded(
                child: new TextField(
                  controller: new_dept,
                  //    focusNode: f_dept,
                  autofocus: false,
                  //   controller: client_name,
                  decoration: new InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide( color: Colors.grey.withOpacity(0.0), width: 1,),
                      ),
                      labelText: 'Shift', hintText: 'Shift Name'),
                ),
              ),
              new Expanded(
                child:  new InputDecorator(
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide( color: Colors.grey.withOpacity(0.0), width: 1,),
                    ),
                    labelText: 'Status',
                  ),
                  isEmpty: _sts1 == '',
                  child: new DropdownButtonHideUnderline(
                    child: new DropdownButton<String>(
                      value: _sts1,
                      isDense: true,
                      onChanged: (String newValue) {
                        setState(() {
                          _sts1 = newValue;
                          Navigator.of(context, rootNavigator: true).pop('dialog'); // here I pop to avoid multiple Dialogs
                          //print("this is set state"+_sts1);
                          editDept(context, dept, _sts1, did);
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
          new FlatButton(
              shape: Border.all(color: Colors.black54),
              child: const Text('CANCEL',style: TextStyle(color: Colors.black),),
              onPressed: () {
                Navigator.of(context, rootNavigator: true).pop('dialog');
              }),
          new RaisedButton(
              color: Colors.orangeAccent,
              child: const Text('UPDATE',style: TextStyle(color: Colors.white),),
              onPressed: ()
              {
                if( new_dept.text==''){
                  //  FocusScope.of(context).requestFocus(f_dept);
                  showInSnackBar('Input Shift Name');
                }
                else {
                  if(_isButtonDisabled)
                    return null;
                  setState(() {
                    _isButtonDisabled=true;
                  });
                  updateShift(new_dept.text,_sts1,did).
                  then((res) {
                    if(res=='0')
                      showInSnackBar('Unable to update shift');
                    else if(res=='-1')
                      showInSnackBar('Shift name already exist');
                    else {
                      Navigator.of(context, rootNavigator: true).pop('dialog');
                      showInSnackBar('Shift updated successfully');
                      getShiftWidget();
                      new_dept.text = '';
                      _sts1 = 'Active';
                    }

                    setState(() {
                      _isButtonDisabled=false;
                    });
                  }
                  );
                }

              }),
        ],
      ),









    );
  }
//////////edit department-end

}/////////mail class close
