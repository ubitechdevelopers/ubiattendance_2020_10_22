import 'package:intl/intl.dart';

import 'database.dart';


class AttendanceOffline{


  int Id;
  int UserId;
  int Action; // 0 for time in and 1 for time out
  String Date;
  int OrganizationId;
  String PictureBase64;
  int IsSynced;
  String Latitude;
  String Longitude;
  String Time;
  int FakeLocationStatus;
  int FakeTimeStatus;
  String Geofence;
  String TimeInOutAppVersion;



  AttendanceOffline(this.Id,
  this.UserId,
  this.Action, // 0 for time in and 1 for time out
  this.Date,
  this.OrganizationId,
  this.PictureBase64,
  this.IsSynced,
  this.Latitude,
  this.Longitude,
  this.Time,
  this.FakeLocationStatus,
  this.FakeTimeStatus,
  this.Geofence,
  this.TimeInOutAppVersion
  );


  AttendanceOffline.empty();

  Map<String, dynamic> toMap() {
    Map map = <String, dynamic>{
      'Id':Id,
      'UserId':UserId,
      'Action':Action, // 0 for time in and 1 for time out
      'Date':Date,
      'OrganizationId':OrganizationId,
      'PictureBase64':PictureBase64,
      'IsSynced':IsSynced,
      'Latitude':Latitude,
      'Longitude':Longitude,
      'Time':Time,
      'FakeLocationStatus':FakeLocationStatus,
      'FakeTimeStatus':FakeTimeStatus,
      'Geofence':Geofence,
      'TimeInOutAppVersion':TimeInOutAppVersion


    };
    return map;
  }

  AttendanceOffline.fromMap(Map<String, dynamic> map){
    Id=map['Id'];
    UserId=map['UserId'];
    Action=map['Action']; // 0 for time in and 1 for time out
    Date=map['Date'];
    OrganizationId=map['OrganizationId'];
    PictureBase64=map['PictureBase64'];
    IsSynced=map['IsSynced'];
    Latitude=map['Latitude'];
    Longitude=map['Longitude'];
    Time=map['Time'];
    FakeLocationStatus=map['FakeLocationStatus'];
    FakeTimeStatus=map['FakeTimeStatus'];
    Geofence=map['Geofence'];
    TimeInOutAppVersion=map['TimeInOutAppVersion'];
  }


  Future<AttendanceOffline> saveObj(AttendanceOffline am) async{
    DbHelper dbHelper=new DbHelper();
    var dbClient = await dbHelper.db;

    am.Id= await dbClient.insert('AttendanceOffline', am.toMap());
    return am;
  }

  Future<AttendanceOffline> save() async{
    DbHelper dbHelper=new DbHelper();
    var dbClient = await dbHelper.db;

    this.Id= await dbClient.insert('AttendanceOffline', this.toMap());
    print("---------------------Attendance Saved------------------------ for action---- "+this.Action.toString());
    return this;

  }



  Future<List<AttendanceOffline>> select() async{
      DbHelper dbHelper=new DbHelper();
      var dbClient = await dbHelper.db;

      List<Map> maps= await dbClient.query('AttendanceOffline',columns: [
        'Id',
        'UserId',
        'Action', // 0 for time in and 1 for time out
        'Date',
        'OrganizationId',
        'PictureBase64',
        'IsSynced',
        'Latitude',
        'Longitude',
        'Time',
        'FakeTimeStatus',
        'FakeLocationStatus',
        'Geofence',
        'TimeInOutAppVersion'

      ],orderBy: "Id desc");
    List<AttendanceOffline> ams=[];
    if(maps.length>0){
      for (int i=0;i<maps.length;i++){
        ams.add(AttendanceOffline.fromMap(maps[i]));
      }

    }
    return ams;
  }

  Future<List<Map>> selectOnlyMaps() async{
    DbHelper dbHelper=new DbHelper();
    var dbClient = await dbHelper.db;

    List<Map> maps= await dbClient.query('AttendanceOffline',columns: [
      'Id',
      'UserId',
      'Action', // 0 for time in and 1 for time out
      'Date',
      'OrganizationId',
      'PictureBase64',
      'IsSynced',
      'Latitude',
      'Longitude',
      'Time',
      'FakeTimeStatus',
      'FakeLocationStatus',
      'Geofence',
      'TimeInOutAppVersion'

    ],orderBy: "Id desc");
    return maps;

  }

  Future<AttendanceOffline> getSingleAttendance(int Id) async{
    DbHelper dbHelper=new DbHelper();
    var dbClient = await dbHelper.db;

    List<Map> map= await dbClient.query('AttendanceOffline',columns: [
      'Id',
      'UserId',
      'Action', // 0 for time in and 1 for time out
      'Date',
      'OrganizationId',
      'PictureBase64',
      'IsSynced',
      'Latitude',
      'Longitude',
      'Time',
      'FakeTimeStatus',
      'FakeLocationStatus',
      'Geofence',
      'TimeInOutAppVersion'

    ],where: "Id=?",whereArgs: [Id]);
    AttendanceOffline ams=AttendanceOffline.fromMap(map[0]);
    return ams;

  }

  Future<String> findCurrentDateAttendance(int Id) async{
    DbHelper dbHelper=new DbHelper();
    var dbClient = await dbHelper.db;
    var now = new DateTime.now();
    var formatter = new DateFormat('yyyy-MM-dd');

    var today = formatter.format(now);



    List<Map> maps= await dbClient.query('AttendanceOffline',columns: [
      'Id',
      'UserId',
      'Action', // 0 for time in and 1 for time out
      'Date',
      'OrganizationId',
      'PictureBase64',
      'IsSynced',
      'Latitude',
      'Longitude',
      'Time',
      'FakeTimeStatus',
      'FakeLocationStatus',
      'Geofence',
      'TimeInOutAppVersion'


    ],where: "UserId=? and Date=? and Action=0",whereArgs: [Id,today]);
    if(maps.isEmpty){

      List<Map> map2= await dbClient.query('AttendanceOffline',columns: [
        'Id',
        'UserId',
        'Action', // 0 for time in and 1 for time out
        'Date',
        'OrganizationId',
        'PictureBase64',
        'IsSynced',
        'Latitude',
        'Longitude',
        'Time',
        'FakeTimeStatus',
        'FakeLocationStatus',
        'Geofence',
        'TimeInOutAppVersion'

      ],where: "UserId=? and Date=? and Action=1",whereArgs: [Id,today]);
      if(map2.isEmpty){
        return "Both Not Marked";
      }
      else{
        return "Only Time Out Marked";
      }
    }
    else{
      List<Map> map1= await dbClient.query('AttendanceOffline',columns: [
        'Id',
        'UserId',
        'Action', // 0 for time in and 1 for time out
        'Date',
        'OrganizationId',
        'PictureBase64',
        'IsSynced',
        'Latitude',
        'Longitude',
        'Time',
        'FakeTimeStatus',
        'FakeLocationStatus',
        'Geofence',
        'TimeInOutAppVersion'

      ],where: "UserId=? and Date=? and Action=1",whereArgs: [Id,today]);
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
    int ids= await dbClient.delete('AttendanceOffline',where:'Id =?',whereArgs: [id]);
    print('offline attendance record deleted');
    return ids;

  }

  Future<int> deleteCurrentDateTimeIn(int UserId) async{

    ////////////////////////////////////// Only Last Time In will get deleted///////////////////////////////////////////

    DbHelper dbHelper=new DbHelper();
    var dbClient = await dbHelper.db;
    var now = new DateTime.now();
    var formatter = new DateFormat('yyyy-MM-dd');

    var today = formatter.format(now);

    List<Map> lastRecordOfdate= await dbClient.query('AttendanceOffline',where:'UserId =? and Date=? and Action=1 order by Id DESC LIMIT 1',whereArgs: [UserId,today]);
    AttendanceOffline lastAttOfDate=AttendanceOffline.fromMap(lastRecordOfdate[0]);
    int id=lastAttOfDate.Id;
    int deleted=await dbClient.delete("AttendanceOffline",where: 'Id=?',whereArgs: [id]);
    print('offline time In deleted');

  }
  Future<int> deleteCurrentDateTimeOut(int UserId) async{

    ////////////////////////////////////// Only Last Time Out will get deleted///////////////////////////////////////////
    DbHelper dbHelper=new DbHelper();
    var dbClient = await dbHelper.db;
    var now = new DateTime.now();
    var formatter = new DateFormat('yyyy-MM-dd');

    var today = formatter.format(now);

    List<Map> lastRecordOfdate= await dbClient.query('AttendanceOffline',where:'UserId =? and Date=? and Action=1 order by Id DESC LIMIT 1',whereArgs: [UserId,today]);
    AttendanceOffline lastAttOfDate=AttendanceOffline.fromMap(lastRecordOfdate[0]);
    int id=lastAttOfDate.Id;
    int deleted=await dbClient.delete("AttendanceOffline",where: 'Id=?',whereArgs: [id]);
    print('offline time out deleted');
    //return ids;

  }

  Future<int> update(AttendanceOffline am) async{
    DbHelper dbHelper=new DbHelper();
    var dbClient = await dbHelper.db;
    return dbClient.update('AttendanceOffline', am.toMap(),where:'id=?',whereArgs: [am.Id]);
  }

  Future close() async{
    DbHelper dbHelper=new DbHelper();
    var dbClient = await dbHelper.db;

    return dbClient.close();
  }



}