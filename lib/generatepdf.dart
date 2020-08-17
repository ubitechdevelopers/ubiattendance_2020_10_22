import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart';
import 'package:permission_handler/permission_handler.dart';

CreateDeptpdf(pdata, HeaderText, Total, pdfName, name) async {

  PermissionStatus permission = await PermissionHandler().checkPermissionStatus(PermissionGroup.storage);
  //print(permission);
  Map<PermissionGroup, PermissionStatus> permissions;
  if(permission.toString()!='PermissionStatus.granted'){
      permissions = await PermissionHandler().requestPermissions([PermissionGroup.storage]);
      permission = await PermissionHandler().checkPermissionStatus(PermissionGroup.storage);
  }
//final res='';
  /*final res = await SimplePermissions.requestPermission(
      Permission.WriteExternalStorage);
  bool checkPermission =
      await SimplePermissions.checkPermission(Permission.WriteExternalStorage);*/
//  print('res: '+res);
  if (permission.toString() == "PermissionStatus.granted") {
    // print(pdata);
    final Document pdf = Document(deflate: zlib.encode);
    List<List<String>> list = new List<List<String>>();
    List<String> a2 = new List<String>();

    if (name == 'dept') {
      a2.add('Department');
      a2.add('Total');
      a2.add('Present');
      a2.add('Absent');
      list.add(a2);
      for (var i = 0; i < pdata.length; i++) {
        List<String> a1 = new List<String>();
        a1.add(pdata[i].Name.toString());
        a1.add(pdata[i].Total.toString());
        a1.add(pdata[i].Present.toString());
        a1.add(pdata[i].Absent.toString());
        list.add(a1);
      }
    } else {
      a2.add('Name');
      if (name != 'absent') {
        a2.add('Time In');
        a2.add('Time In Location');
        a2.add('Time Out');
        a2.add('Time Out Location');
      }
      list.add(a2);
      for (var i = 0; i < pdata.length; i++) {
        List<String> a1 = new List<String>();
        a1.add(pdata[i].Name.toString());
        if (name != 'absent') {
          a1.add(pdata[i].TimeIn.toString());
          a1.add(pdata[i].CheckInLoc.toString());
          a1.add(pdata[i].TimeOut.toString());
          a1.add(pdata[i].CheckOutLoc.toString());
        }
        list.add(a1);
      }
    }

    pdf.addPage(MultiPage(
        pageFormat:
            PdfPageFormat.letter.copyWith(marginBottom: 1.5 * PdfPageFormat.cm),
        crossAxisAlignment: CrossAxisAlignment.start,
        header: (Context context) {
          if (context.pageNumber == 1) {
            return null;
          }
          return Container(
              alignment: Alignment.centerRight,
              margin: const EdgeInsets.only(bottom: 3.0 * PdfPageFormat.mm),
              padding: const EdgeInsets.only(bottom: 3.0 * PdfPageFormat.mm),
              decoration: const BoxDecoration(
                  border: BoxBorder(
                      bottom: true, width: 0.5, color: PdfColors.grey)),
              child: Text(HeaderText,
                  style: Theme.of(context)
                      .defaultTextStyle
                      .copyWith(color: PdfColors.grey)));
        },
        footer: (Context context) {
          return Container(
              alignment: Alignment.centerRight,
              margin: const EdgeInsets.only(top: 1.0 * PdfPageFormat.cm),
              child: Text('Page ${context.pageNumber} of ${context.pagesCount}',
                  style: Theme.of(context)
                      .defaultTextStyle
                      .copyWith(color: PdfColors.grey)));
        },
        build: (Context context) => <Widget>[
              Header(
                  level: 0,
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Text(HeaderText, textScaleFactor: 2),
                        PdfLogo()
                      ])),
              Bullet(text: "Total: " + Total),
              Table.fromTextArray(context: context, data: list),
            ]));
    /*String dir =
      (await getExternalStorageDirectory()).absolute.path + "/documents/"; */
    String dir = (await getExternalStorageDirectory()).absolute.path;
    String file = "$dir/ubiattendance_files/";
    await new Directory('$file').create(recursive: true);
    File f = File(file + pdfName + '.pdf');
    print(f);
    f.writeAsBytesSync(pdf.save());
    return file + pdfName + '.pdf';
  }
  return 'false';
}

Createpdf(pdata, HeaderText, Total, pdfName, name) async {

  PermissionStatus permission = await PermissionHandler().checkPermissionStatus(PermissionGroup.storage);
  //print(permission);
  Map<PermissionGroup, PermissionStatus> permissions;
  if(permission.toString()!='PermissionStatus.granted'){
    permissions = await PermissionHandler().requestPermissions([PermissionGroup.storage]);
    permission = await PermissionHandler().checkPermissionStatus(PermissionGroup.storage);
  }
//final res='';
  /*final res = await SimplePermissions.requestPermission(
      Permission.WriteExternalStorage);
  bool checkPermission =
      await SimplePermissions.checkPermission(Permission.WriteExternalStorage);*/
//  print('res: '+res);
  if (permission.toString() == "PermissionStatus.granted") {
    // print(pdata);
    final Document pdf = Document(deflate: zlib.encode);
    List<List<String>> list = new List<List<String>>();
    List<String> a2 = new List<String>();

    if (name == 'lateComers') {
      a2.add('Name');
      a2.add('Shift');
      a2.add('Time In');
      a2.add('Late By');
      list.add(a2);
      for (var i = 0; i < pdata.length; i++) {
        List<String> a1 = new List<String>();
        a1.add(pdata[i].name.toString());
        a1.add(pdata[i].shift.toString());
        a1.add(pdata[i].timeAct.toString());
        a1.add(pdata[i].diff.toString());
        list.add(a1);
      }
    }else if(name == 'earlyLeavers'){
      a2.add('Name');
      a2.add('Shift');
      a2.add('TimOut');
      a2.add('Early By');
      list.add(a2);
      for (var i = 0; i < pdata.length; i++) {
        List<String> a1 = new List<String>();
        a1.add(pdata[i].name.toString());
        a1.add(pdata[i].shift.toString());
        a1.add(pdata[i].timeAct.toString());
        a1.add(pdata[i].diff.toString());
        list.add(a1);
      }
    }else if(name == 'visitlist'){
      a2.add('Name');
      a2.add('Client Name');
      a2.add('Visit In');
      a2.add('Visit In Location');
      a2.add('Visit Out');
      a2.add('Visit Out Location');
      a2.add('Remarks');
      list.add(a2);
      for (var i = 0; i < pdata.length; i++) {
        List<String> a1 = new List<String>();
        a1.add(pdata[i].Emp.toString());
        a1.add(pdata[i].client.toString());
        a1.add(pdata[i].pi_time.toString());
        a1.add(pdata[i].pi_loc.toString());
        a1.add(pdata[i].po_time.toString());
        a1.add(pdata[i].po_loc.toString());
        a1.add(pdata[i].desc.toString());
        list.add(a1);
      }
    }

    pdf.addPage(MultiPage(
        pageFormat: PdfPageFormat.letter.copyWith(marginRight: 0.5*PdfPageFormat.cm, marginLeft: 0.5*PdfPageFormat.cm),
        crossAxisAlignment: CrossAxisAlignment.start,
        header: (Context context) {
          if (context.pageNumber == 1) {
            return null;
          }
          return Container(
              alignment: Alignment.centerRight,
              margin: const EdgeInsets.only(bottom: 3.0 * PdfPageFormat.mm),
              padding: const EdgeInsets.only(bottom: 3.0 * PdfPageFormat.mm),
              decoration: const BoxDecoration(
                  border: BoxBorder(
                      bottom: true, width: 0.5, color: PdfColors.grey)),
              child: Text(HeaderText,
                  style: Theme.of(context)
                      .defaultTextStyle
                      .copyWith(color: PdfColors.grey)));
        },
        footer: (Context context) {
          return Container(
              alignment: Alignment.centerRight,
              margin: const EdgeInsets.only(top: 1.0 * PdfPageFormat.cm),
              child: Text('Page ${context.pageNumber} of ${context.pagesCount}',
                  style: Theme.of(context)
                      .defaultTextStyle
                      .copyWith(color: PdfColors.grey)));
        },
        build: (Context context) => <Widget>[
          Header(
              level: 0,
              child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text(HeaderText, textScaleFactor: 2),
                    PdfLogo()
                  ])),
          Bullet(text: "Total: " + Total),
          Table.fromTextArray(context: context, data: list),
        ]));
    /*String dir =
      (await getExternalStorageDirectory()).absolute.path + "/documents/"; */
    String dir = (await getExternalStorageDirectory()).absolute.path;
    String file = "$dir/ubiattendance_files/";
    await new Directory('$file').create(recursive: true);
    File f = File(file + pdfName + '.pdf');
    print(f);
    f.writeAsBytesSync(pdf.save());
    return file + pdfName + '.pdf';
  }
  return 'false';
}

CreateDesgpdfAll(pdata, adata, ldata, edata, HeaderText, Total, pdfName, name) async {

  PermissionStatus permission = await PermissionHandler().checkPermissionStatus(PermissionGroup.storage);
  //print(permission);
  Map<PermissionGroup, PermissionStatus> permissions;
  if(permission.toString()!='PermissionStatus.granted'){
    permissions = await PermissionHandler().requestPermissions([PermissionGroup.storage]);
    permission = await PermissionHandler().checkPermissionStatus(PermissionGroup.storage);
  }
//final res='';
  /*final res = await SimplePermissions.requestPermission(
      Permission.WriteExternalStorage);
  bool checkPermission =
      await SimplePermissions.checkPermission(Permission.WriteExternalStorage);*/
//  print('res: '+res);
  if (permission.toString() == "PermissionStatus.granted") {
    // print(pdata);
    final Document pdf = Document(deflate: zlib.encode);
    List<List<String>> list = new List<List<String>>();
    List<String> a2 = new List<String>();


    a2.add('Name');
    a2.add('Time In');
    a2.add('Time In Location');
    a2.add('Time Out');
    a2.add('Time Out Location');
    list.add(a2);
    a2 = new List<String>();
    a2.add(' ');
    a2.add(' ');
    a2.add(' ');
    a2.add(' ');
    a2.add(' ');
    list.add(a2);
    a2 = new List<String>();
    a2.add(' Present ');
    a2.add(' ');
    a2.add(' ');
    a2.add(' ');
    a2.add(' ');
    list.add(a2);

    for (var i = 0; i < pdata.length; i++) {
      List<String> a1 = new List<String>();
      a1.add(pdata[i].Name.toString());

      a1.add(pdata[i].TimeIn.toString());
      a1.add(pdata[i].CheckInLoc.toString());
      a1.add(pdata[i].TimeOut.toString());
      a1.add(pdata[i].CheckOutLoc.toString());
      list.add(a1);
    }


    a2 = new List<String>();
    a2.add(' ');
    a2.add(' ');
    a2.add(' ');
    a2.add(' ');
    a2.add(' ');
    list.add(a2);
    a2 = new List<String>();
    a2.add(' Absent ');
    a2.add(' ');
    a2.add(' ');
    a2.add(' ');
    a2.add(' ');
    list.add(a2);

    for (var i = 0; i < adata.length; i++) {
      List<String> a1 = new List<String>();
      a1.add(adata[i].Name.toString());
      a1.add('-');
      a1.add('-');
      a1.add('-');
      a1.add('-');

      list.add(a1);
    }

    a2 = new List<String>();
    a2.add(' ');
    a2.add(' ');
    a2.add(' ');
    a2.add(' ');
    a2.add(' ');
    list.add(a2);
    a2 = new List<String>();
    a2.add(' Late Comers ');
    a2.add(' ');
    a2.add(' ');
    a2.add(' ');
    a2.add(' ');
    list.add(a2);

    for (var i = 0; i < ldata.length; i++) {
      List<String> a1 = new List<String>();
      a1.add(ldata[i].Name.toString());
      a1.add(ldata[i].TimeIn.toString());
      a1.add(ldata[i].CheckInLoc.toString());
      a1.add(ldata[i].TimeOut.toString());
      a1.add(ldata[i].CheckOutLoc.toString());

      list.add(a1);
    }

    a2 = new List<String>();
    a2.add(' ');
    a2.add(' ');
    a2.add(' ');
    a2.add(' ');
    a2.add(' ');
    list.add(a2);
    a2 = new List<String>();
    a2.add(' Early Leavers ');
    a2.add(' ');
    a2.add(' ');
    a2.add(' ');
    a2.add(' ');
    list.add(a2);

    for (var i = 0; i < edata.length; i++) {
      List<String> a1 = new List<String>();
      a1.add(pdata[i].Name.toString());
      a1.add(edata[i].TimeIn.toString());
      a1.add(edata[i].CheckInLoc.toString());
      a1.add(edata[i].TimeOut.toString());
      a1.add(edata[i].CheckOutLoc.toString());

      list.add(a1);
    }

    pdf.addPage(MultiPage(
        pageFormat:
        PdfPageFormat.letter.copyWith(marginBottom: 1.5 * PdfPageFormat.cm),
        crossAxisAlignment: CrossAxisAlignment.start,
        header: (Context context) {
          if (context.pageNumber == 1) {
            return null;
          }
          return Container(
              alignment: Alignment.centerRight,
              margin: const EdgeInsets.only(bottom: 3.0 * PdfPageFormat.mm),
              padding: const EdgeInsets.only(bottom: 3.0 * PdfPageFormat.mm),
              decoration: const BoxDecoration(
                  border: BoxBorder(
                      bottom: true, width: 0.5, color: PdfColors.grey)),
              child: Text(HeaderText,
                  style: Theme.of(context)
                      .defaultTextStyle
                      .copyWith(color: PdfColors.grey)));
        },
        footer: (Context context) {
          return Container(
              alignment: Alignment.centerRight,
              margin: const EdgeInsets.only(top: 1.0 * PdfPageFormat.cm),
              child: Text('Page ${context.pageNumber} of ${context.pagesCount}',
                  style: Theme.of(context)
                      .defaultTextStyle
                      .copyWith(color: PdfColors.grey)));
        },
        build: (Context context) => <Widget>[
          Header(
              level: 0,
              child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text(HeaderText, textScaleFactor: 2),
                    PdfLogo()
                  ])),
          Bullet(text: "Total: " + Total),
          Table.fromTextArray(context: context, data: list),
        ]));
    /*String dir =
      (await getExternalStorageDirectory()).absolute.path + "/documents/"; */
    String dir = (await getExternalStorageDirectory()).absolute.path;
    String file = "$dir/ubiattendance_files/";
    await new Directory('$file').create(recursive: true);
    File f = File(file + pdfName + '.pdf');
    print(f);
    f.writeAsBytesSync(pdf.save());
    return file + pdfName + '.pdf';
  }
  return 'false';
}


// this function only for employees report, there is no need of name column
CreateEmployeeWisepdf(pdata, adata, ldata, edata, HeaderText, pdfName, name) async {

  PermissionStatus permission = await PermissionHandler().checkPermissionStatus(PermissionGroup.storage);
  //print(permission);
  Map<PermissionGroup, PermissionStatus> permissions;
  if(permission.toString()!='PermissionStatus.granted'){
    permissions = await PermissionHandler().requestPermissions([PermissionGroup.storage]);
    permission = await PermissionHandler().checkPermissionStatus(PermissionGroup.storage);
  }
//final res='';
  /*final res = await SimplePermissions.requestPermission(
      Permission.WriteExternalStorage);
  bool checkPermission =
      await SimplePermissions.checkPermission(Permission.WriteExternalStorage);*/
//  print('res: '+res);
  if (permission.toString() == "PermissionStatus.granted") {
    // print(pdata);
    final Document pdf = Document(deflate: zlib.encode);
    List<List<String>> list = new List<List<String>>();
    List<String> a2 = new List<String>();


   // a2.add('Name');
    a2.add('Date');
    a2.add('Time In ');
    a2.add('Time In Location');
    a2.add('Time Out ');
    a2.add('Time Out Location');
    list.add(a2);
   /* a2 = new List<String>();
  //  a2.add(' ');
    a2.add(' ');
    a2.add(' ');
    a2.add(' ');
    a2.add(' ');
    a2.add(' ');
    list.add(a2);*/
    a2 = new List<String>();
    a2.add(' Present ');
   // a2.add(' ');
    list.add(a2);

    for (var i = 0; i < pdata.length; i++) {
      List<String> a1 = new List<String>();
     // a1.add(pdata[i].Name.toString());
      a1.add(pdata[i].Name.toString());
      a1.add(pdata[i].TimeIn.toString());
      a1.add(pdata[i].CheckInLoc.toString());
      a1.add(pdata[i].TimeOut.toString());
      a1.add(pdata[i].CheckOutLoc.toString());
      list.add(a1);
    }


   /* a2 = new List<String>();
    a2.add(' ');
    a2.add(' ');
    a2.add(' ');
    a2.add(' ');
    a2.add(' ');
    list.add(a2);*/
    a2 = new List<String>();
    a2.add(' Absent ');
    a2.add(' ');
    a2.add(' ');
    a2.add(' ');
  //  a2.add(' ');
    list.add(a2);

    for (var i = 0; i < adata.length; i++) {
      List<String> a1 = new List<String>();
      a1.add(adata[i].Name.toString());
      a1.add('-');
      a1.add('-');
      a1.add('-');
      a1.add('-');
      list.add(a1);
    }
/*
    a2 = new List<String>();
    a2.add(' ');
    a2.add(' ');
    a2.add(' ');
    a2.add(' ');
    a2.add(' ');
    list.add(a2);*/
    a2 = new List<String>();
    a2.add(' Late Comers ');
    a2.add(' ');
    a2.add(' ');
    a2.add(' ');
    a2.add(' ');
    list.add(a2);

    for (var i = 0; i < ldata.length; i++) {
      List<String> a1 = new List<String>();
      a1.add(ldata[i].Name.toString());
      a1.add(ldata[i].TimeIn.toString());
      a1.add(ldata[i].CheckInLoc.toString());
      a1.add(ldata[i].TimeOut.toString());
      a1.add(ldata[i].CheckOutLoc.toString());

      list.add(a1);
    }

 /*   a2 = new List<String>();
    a2.add(' ');
    a2.add(' ');
    a2.add(' ');
    a2.add(' ');
    a2.add(' ');
    list.add(a2);*/
    a2 = new List<String>();
    a2.add(' Early Leavers ');
    a2.add(' ');
    a2.add(' ');
    a2.add(' ');
    a2.add(' ');
    list.add(a2);

    for (var i = 0; i < edata.length; i++) {
      List<String> a1 = new List<String>();
      a1.add(pdata[i].Name.toString());
      a1.add(edata[i].TimeIn.toString());
      a1.add(edata[i].CheckInLoc.toString());
      a1.add(edata[i].TimeOut.toString());
      a1.add(edata[i].CheckOutLoc.toString());

      list.add(a1);
    }

    pdf.addPage(MultiPage(
        pageFormat:
        PdfPageFormat.letter.copyWith(marginBottom: 1.5 * PdfPageFormat.cm),
        crossAxisAlignment: CrossAxisAlignment.start,
        header: (Context context) {
          if (context.pageNumber == 1) {
            return null;
          }
          return Container(
              alignment: Alignment.centerRight,
              margin: const EdgeInsets.only(bottom: 3.0 * PdfPageFormat.mm),
              padding: const EdgeInsets.only(bottom: 3.0 * PdfPageFormat.mm),
              decoration: const BoxDecoration(
                  border: BoxBorder(
                      bottom: true, width: 0.5, color: PdfColors.grey)),
              child: Text(HeaderText,
                  style: Theme.of(context)
                      .defaultTextStyle
                      .copyWith(color: PdfColors.grey)));
        },
        footer: (Context context) {
          return Container(
              alignment: Alignment.centerRight,
              margin: const EdgeInsets.only(top: 1.0 * PdfPageFormat.cm),
              child: Text('Page ${context.pageNumber} of ${context.pagesCount}',
                  style: Theme.of(context)
                      .defaultTextStyle
                      .copyWith(color: PdfColors.grey)));
        },
        build: (Context context) => <Widget>[
          Header(
              level: 0,
              child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text(HeaderText, textScaleFactor: 2),
                    PdfLogo()
                  ])),
          //Bullet(text: "Total: " + Total),
          Table.fromTextArray(context: context, data: list),
        ]));
    /*String dir =
      (await getExternalStorageDirectory()).absolute.path + "/documents/"; */
    String dir = (await getExternalStorageDirectory()).absolute.path;
    String file = "$dir/ubiattendance_files/";
    await new Directory('$file').create(recursive: true);
    File f = File(file + pdfName + '.pdf');
    print(f);
    f.writeAsBytesSync(pdf.save());
    return file + pdfName + '.pdf';
  }
  return 'false';
}
