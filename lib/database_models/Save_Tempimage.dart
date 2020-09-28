import 'package:intl/intl.dart';
import 'database.dart';
class TempImage{

  int Id;
  int EmployeeId;
  String Action;
  int ActionId;
  String PictureBase64;
  int OrganizationId;
  String Module;
  String interimAttendanceId;
  String shiftId;

  TempImage(this.Id,
      this.EmployeeId,
      this.Action,
      this.ActionId,
      this.interimAttendanceId,
      this.PictureBase64,
      this.OrganizationId,
      this.Module,
      this.shiftId

      );


  TempImage.empty();

  Map<String, dynamic> toMap() {
    Map map = <String, dynamic>{
      'Id':Id,
      'EmployeeId':EmployeeId,
      'Action':Action, // 0 for time in and 1 for time out
      'ActionId':ActionId,
      'PictureBase64':PictureBase64,
      'OrganizationId':OrganizationId,
      'Module':Module,
      'InterimAttendanceId':interimAttendanceId,
      'ShiftId':shiftId,
    };
    return map;
  }

  TempImage.fromMap(Map<String, dynamic> map){
    Id=map['Id'];
    EmployeeId=map['EmployeeId'];
    Action=map['Action']; // 0 for time in and 1 for time out
    ActionId=map['ActionId'];
    PictureBase64=map['PictureBase64'];
    OrganizationId=map['OrganizationId'];
    Module=map['Module'];
    interimAttendanceId=map['InterimAttendanceId'];
    shiftId=map['ShiftId'];
  }


  Future<TempImage> saveObj(TempImage am) async{
    DbHelper dbHelper=new DbHelper();
    var dbClient = await dbHelper.db;

    am.Id= await dbClient.insert('TempImage', am.toMap());
    return am;
  }

  Future<TempImage> save() async{
    DbHelper dbHelper=new DbHelper();
    var dbClient = await dbHelper.db;

    this.Id= await dbClient.insert('TempImage', this.toMap());
    print("---------------------Attendance Saved------------------------ for action---- "+this.Action.toString());
    print( this.Id);
    return this;

  }



  Future<List<TempImage>> select() async{
    DbHelper dbHelper=new DbHelper();
    var dbClient = await dbHelper.db;

    List<Map> maps= await dbClient.query('TempImage',columns: [
      'Id',
      'EmployeeId',
      'Action', // 0 for time in and 1 for time out
      'ActionId',
      'PictureBase64',
      'OrganizationId',
      'Module',
      'InterimAttendanceId',
      'ShiftId',


    ],orderBy: "Id desc");
    List<TempImage> ams=[];
    if(maps.length>0){
      for (int i=0;i<maps.length;i++){
        ams.add(TempImage.fromMap(maps[i]));
      }

    }
    return ams;
  }

  Future<List<Map>> selectOnlyMaps() async{
    DbHelper dbHelper=new DbHelper();
    var dbClient = await dbHelper.db;

    List<Map> maps= await dbClient.query('TempImage',columns: [
      'Id',
      'EmployeeId',
      'Action', // 0 for time in and 1 for time out
      'ActionId',
      'PictureBase64',
      'OrganizationId',
      'Module',
      'InterimAttendanceId',
      'ShiftId',

    ],orderBy: "Id desc");
    return maps;

  }

  Future<TempImage> getSingleAttendance(int Id) async{
    DbHelper dbHelper=new DbHelper();
    var dbClient = await dbHelper.db;

    List<Map> map= await dbClient.query('TempImage',columns: [
      'Id',
      'EmployeeId',
      'Action', // 0 for time in and 1 for time out
      'ActionId',
      'PictureBase64',
      'OrganizationId',
      'Module',
      'InterimAttendanceId',
      'ShiftId',

    ],where: "Id=?",whereArgs: [Id]);
    TempImage ams=TempImage.fromMap(map[0]);
    return ams;

  }

  Future<int> delete(int id) async{
    DbHelper dbHelper=new DbHelper();
    var dbClient = await dbHelper.db;
    int ids= await dbClient.delete('TempImage',where:'Id =?',whereArgs: [id]);
    print('Temp Image  deleted');
    return ids;

  }


  Future<int> update(TempImage am , int ) async{
    DbHelper dbHelper=new DbHelper();
    var dbClient = await dbHelper.db;
    return dbClient.update('TempImage', am.toMap(),where:'id=?',whereArgs: [am.Id]);
  }

  Future close() async{
    DbHelper dbHelper=new DbHelper();
    var dbClient = await dbHelper.db;

    return dbClient.close();
  }



}