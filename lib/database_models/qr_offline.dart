import 'package:intl/intl.dart';

import 'database.dart';


class QROffline{


  int Id;
  int SupervisorId;
  int Action; // 0 for time in and 1 for time out
  String Date;
  int OrganizationId;
  String PictureBase64;
  int IsSynced;
  String Latitude;
  String Longitude;
  String Time;
  String UserName;
  String Password;
  int FakeLocationStatus;
  int FakeTimeStatus;
  String Geofence;
  String appVersion;



  QROffline(this.Id,
      this.SupervisorId,
      this.Action, // 0 for time in and 1 for time out
      this.Date,
      this.OrganizationId,
      this.PictureBase64,
      this.IsSynced,
      this.Latitude,
      this.Longitude,
      this.Time,
      this.UserName,
      this.Password,
      this.FakeLocationStatus,
      this.FakeTimeStatus,
      this.Geofence,
      this.appVersion
      );


  QROffline.empty();

  Map<String, dynamic> toMap() {
    Map map = <String, dynamic>{
      'Id':Id,
      'SupervisorId':SupervisorId,
      'Action':Action, // 0 for time in and 1 for time out
      'Date':Date,
      'OrganizationId':OrganizationId,
      'PictureBase64':PictureBase64,
      'IsSynced':IsSynced,
      'Latitude':Latitude,
      'Longitude':Longitude,
      'Time':Time,
      'UserName':UserName,
      'Password':Password,
      'FakeLocationStatus':FakeLocationStatus,
      'FakeTimeStatus':FakeTimeStatus,
      'Geofence':Geofence,
      'appVersion':appVersion

    };
    return map;
  }

  QROffline.fromMap(Map<String, dynamic> map){
    Id=map['Id'];
    SupervisorId=map['SupervisorId'];
    Action=map['Action']; // 0 for time in and 1 for time out
    Date=map['Date'];
    OrganizationId=map['OrganizationId'];
    PictureBase64=map['PictureBase64'];
    IsSynced=map['IsSynced'];
    Latitude=map['Latitude'];
    Longitude=map['Longitude'];
    Time=map['Time'];
    UserName=map['UserName'];
    Password=map['Password'];
    FakeLocationStatus=map['FakeLocationStatus'];
    FakeTimeStatus=map['FakeTimeStatus'];
    Geofence=map['Geofence'];
    appVersion=map['appVersion'];
  }


  Future<QROffline> saveObj(QROffline am) async{
    DbHelper dbHelper=new DbHelper();
    var dbClient = await dbHelper.db;

    am.Id= await dbClient.insert('QROffline', am.toMap());
    return am;
  }

  Future<QROffline> save() async{
    DbHelper dbHelper=new DbHelper();
    var dbClient = await dbHelper.db;

    this.Id= await dbClient.insert('QROffline', this.toMap());
    print("---------------------Attendance Saved------------------------ for action---- "+this.Action.toString());
    return this;

  }



  Future<List<QROffline>> select() async{
    DbHelper dbHelper=new DbHelper();
    var dbClient = await dbHelper.db;

    List<Map> maps= await dbClient.query('QROffline',columns: [
      'Id',
      'SupervisorId',
      'Action', // 0 for time in and 1 for time out
      'Date',
      'OrganizationId',
      'PictureBase64',
      'IsSynced',
      'Latitude',
      'Longitude',
      'Time',
      'UserName',
      'Password',
      'FakeTimeStatus',
      'FakeLocationStatus'

    ],orderBy: "Id desc");
    List<QROffline> ams=[];
    if(maps.length>0){
      for (int i=0;i<maps.length;i++){
        ams.add(QROffline.fromMap(maps[i]));
      }

    }
    return ams;

  }
  Future<List<Map>> selectOnlyMaps() async{
    DbHelper dbHelper=new DbHelper();
    var dbClient = await dbHelper.db;

    List<Map> maps= await dbClient.query('QROffline',columns: [
      'Id',
      'SupervisorId',
      'Action', // 0 for time in and 1 for time out
      'Date',
      'OrganizationId',
      'PictureBase64',
      'IsSynced',
      'Latitude',
      'Longitude',
      'Time',
      'UserName',
      'Password',
      'FakeTimeStatus',
      'FakeLocationStatus'

    ],orderBy: "Id desc");
    return maps;

  }

  Future<QROffline> getSingleQR(int Id) async{
    DbHelper dbHelper=new DbHelper();
    var dbClient = await dbHelper.db;  

    List<Map> map= await dbClient.query('QROffline',columns: [
      'Id',
      'SupervisorId',
      'Action', // 0 for time in and 1 for time out
      'Date',
      'OrganizationId',
      'PictureBase64',
      'IsSynced',
      'Latitude',
      'Longitude',
      'Time',
      'UserName',
      'Password',
      'FakeTimeStatus',
      'FakeLocationStatus'

    ],where: "Id=?",whereArgs: [Id]);
    QROffline ams=QROffline.fromMap(map[0]);
    return ams;

  }

  Future<String> findCurrentDateAttendance(int Id) async{
    DbHelper dbHelper=new DbHelper();
    var dbClient = await dbHelper.db;
    var now = new DateTime.now();
    var formatter = new DateFormat('yyyy-MM-dd');

    var today = formatter.format(now);



    List<Map> maps= await dbClient.query('QROffline',columns: [
      'Id',
      'SupervisorId',
      'Action', // 0 for time in and 1 for time out
      'Date',
      'OrganizationId',
      'PictureBase64',
      'IsSynced',
      'Latitude',
      'Longitude',
      'Time',
      'UserName',
      'Password',
      'FakeTimeStatus',
      'FakeLocationStatus'

    ],where: "SupervisorId=? and Date=? and Action=0",whereArgs: [Id,today]);
    if(maps.isEmpty){

      List<Map> map2= await dbClient.query('QROffline',columns: [
        'Id',
        'SupervisorId',
        'Action', // 0 for time in and 1 for time out
        'Date',
        'OrganizationId',
        'PictureBase64',
        'IsSynced',
        'Latitude',
        'Longitude',
        'Time',
        'UserName',
        'Password',
        'FakeTimeStatus',
        'FakeLocationStatus'

      ],where: "SupervisorId=? and Date=? and Action=1",whereArgs: [Id,today]);
      if(map2.isEmpty){
        return "Both Not Marked";
      }
      else{
        return "Only Time Out Marked";
      }
    }
    else{
      List<Map> map1= await dbClient.query('QROffline',columns: [
        'Id',
        'SupervisorId',
        'Action', // 0 for time in and 1 for time out
        'Date',
        'OrganizationId',
        'PictureBase64',
        'IsSynced',
        'Latitude',
        'Longitude',
        'Time',
        'UserName',
        'Password',
        'FakeTimeStatus',
        'FakeLocationStatus'

      ],where: "SupervisorId=? and Date=? and Action=1",whereArgs: [Id,today]);
      if(map1.isEmpty){
        return "Time In Marked";
      }
      else{
        return "Both Marked";
      }


    }

  }





  Future<int> delete(int id) async{
    DbHelper dbHelper=new DbHelper();
    var dbClient = await dbHelper.db;
    int ids= await dbClient.delete('QROffline',where:'Id =?',whereArgs: [id]);
    print('offline attendance record deleted');
    return ids;

  }

  Future<int> deleteCurrentDateQRTimeIn(int SupervisorId) async{

    ////////////////////////////////////// Only Last Time In will get deleted///////////////////////////////////////////

    DbHelper dbHelper=new DbHelper();
    var dbClient = await dbHelper.db;
    var now = new DateTime.now();
    var formatter = new DateFormat('yyyy-MM-dd');

    var today = formatter.format(now);

    List<Map> lastRecordOfdate= await dbClient.query('QROffline',where:'SupervisorId =? and Date=? and Action=1 order by Id DESC LIMIT 1',whereArgs: [SupervisorId,today]);
    QROffline lastAttOfDate=QROffline.fromMap(lastRecordOfdate[0]);
    int id=lastAttOfDate.Id;
    int deleted=await dbClient.delete("QROffline",where: 'Id=?',whereArgs: [id]);
    print('offline qr time In deleted');

  }
  Future<int> deleteCurrentDateQRTimeOut(int SupervisorId) async{

    ////////////////////////////////////// Only Last Time Out will get deleted///////////////////////////////////////////
    DbHelper dbHelper=new DbHelper();
    var dbClient = await dbHelper.db;
    var now = new DateTime.now();
    var formatter = new DateFormat('yyyy-MM-dd');

    var today = formatter.format(now);

    List<Map> lastRecordOfdate= await dbClient.query('QROffline',where:'SupervisorId =? and Date=? and Action=1 order by Id DESC LIMIT 1',whereArgs: [SupervisorId,today]);
    QROffline lastAttOfDate=QROffline.fromMap(lastRecordOfdate[0]);
    int id=lastAttOfDate.Id;
    int deleted=await dbClient.delete("QROffline",where: 'Id=?',whereArgs: [id]);
    print('offline time out deleted');
    //return ids;

  }

  Future<int> update(QROffline am) async{
    DbHelper dbHelper=new DbHelper();
    var dbClient = await dbHelper.db;
    return dbClient.update('QROffline', am.toMap(),where:'Id=?',whereArgs: [am.Id]);
  }

  Future close() async{
    DbHelper dbHelper=new DbHelper();
    var dbClient = await dbHelper.db;

    return dbClient.close();
  }



}