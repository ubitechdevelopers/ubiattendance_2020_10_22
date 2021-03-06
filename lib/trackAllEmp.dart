// Copyright 2017 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.
import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:Shrine/visits_list_emp.dart';
import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart' as intl;
import 'package:shared_preferences/shared_preferences.dart';
import 'globals.dart';
import 'location_tracking/map_pin_pill.dart';
import 'location_tracking/pin_pill_info.dart';
import 'services/services.dart';
import 'dart:ui' as ui;
import 'package:Shrine/globals.dart' as globals;
import 'package:image/image.dart' as image;
import 'package:flutter/services.dart';
// This app is a stateful, it tracks the user's current choice.

const double CAMERA_ZOOM = 13;
const double CAMERA_TILT = 0;
const double CAMERA_BEARING = 30;
const LatLng SOURCE_LOCATION = LatLng(26.19675, 78.1970444);
const LatLng DEST_LOCATION = LatLng(26.19675, 78.1970424);
double pinPillPosition = -470;
PinInformation currentlySelectedPin = PinInformation(pinPath: '', avatarPath: '', location: LatLng(0, 0), client: '',description: '', labelColor: Colors.grey,in_time: '',out_time: '');
PinInformation sourcePinInfo;
PinInformation destinationPinInfo;
var cameraSource=LatLng(26.19675, 78.1970424);


class TrackAllEmp extends StatefulWidget {
  String empId;
  @override
  _TrackAllEmpState createState() => _TrackAllEmpState();
}

class Locations {
  String longitude;
  String latitude;
  String accuracy;
  String activity;
  String altitude;
  String battery_level;
  String heading;
  String is_charging;
  String is_moving;
  String odometer;
  String speed;
  String uuid;
  String time;
  Locations.fromFireBase1(Map<String,dynamic> map) {
    var snapshot;
    var key;
    map.forEach((k,v){
            this.time=k;
            snapshot=v;
    });

    this.longitude = snapshot["longitude"] ?? '0.0';
    this.latitude = snapshot["latitude"] ?? '0.0';
    this.accuracy = snapshot["accuracy"] ?? '.0';
    this.activity = snapshot["activity"] ?? 'Unknown user';
    this.altitude = snapshot["altitude"] ?? 'Unknown user';
    this.battery_level = snapshot["battery_level"] ?? 'Unknown user';
    this.heading = snapshot["heading"] ?? 'Unknown user';
    this.is_charging = snapshot["is_charging"] ?? 'Unknown user';
    this.is_moving = snapshot["is_moving"] ?? 'Unknown user';
    this.odometer = snapshot["odometer"] ?? 'Unknown user';
    this.speed = snapshot["speed"] ?? 'Unknown user';
    this.uuid = snapshot["uuid"] ?? 'Unknown user';

  }



  Locations.fromFireBase(DataSnapshot snapshot) {
    this.longitude = snapshot.value["longitude"] ?? '0.0';
    this.latitude = snapshot.value["latitude"] ?? '0.0';
    this.accuracy = snapshot.value["accuracy"] ?? '.0';
    this.activity = snapshot.value["activity"] ?? 'Unknown user';
    this.altitude = snapshot.value["altitude"] ?? 'Unknown user';
    this.battery_level = snapshot.value["battery_level"] ?? 'Unknown user';
    this.heading = snapshot.value["heading"] ?? 'Unknown user';
    this.is_charging = snapshot.value["is_charging"] ?? 'Unknown user';
    this.is_moving = snapshot.value["is_moving"] ?? 'Unknown user';
    this.odometer = snapshot.value["odometer"] ?? 'Unknown user';
    this.speed = snapshot.value["speed"] ?? 'Unknown user';
    this.uuid = snapshot.value["uuid"] ?? 'Unknown user';
    this.time = snapshot.key ?? '00:00:00';

  }
}


class _TrackAllEmpState extends State<TrackAllEmp>  with SingleTickerProviderStateMixin{
  Completer<GoogleMapController> _controller = Completer();
  // this set will hold my markers
  Set<Marker> _markers = {};
  List<LatLng> latlng = List();
  LatLng _new = SOURCE_LOCATION;
  LatLng _news = DEST_LOCATION ;
  // this will hold the generated polylines
  Set<Polyline> _polylines = {};
  // this will hold each polyline coordinate as Lat and Lng pairs
  List<LatLng> polylineCoordinates = [];

  List <Locations> locationList = [];
  String _orgName = "";
  StreamSubscription <Event> updates;

  // this is the key object - the PolylinePoints
  // which generates every polyline between start and finish
  PolylinePoints polylinePoints = PolylinePoints();
  String googleAPIKey = "AIzaSyDYh77SKpI6kAD1jiILwbiISZEwEOyJLtM";
  // for my custom icons
  BitmapDescriptor sourceIcon;
  BitmapDescriptor destinationIcon;
String empId;

  var _scaffoldKey;

  @override
  void initState() {
    super.initState();

    initPlatformState();
    getOrgName();
  }
  // Platform messages are asynchronous, so we initialize in an async method.
  getOrgName() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _orgName = prefs.getString('org_name') ?? '';

    });
  }
  TabController _controller1;
  initPlatformState() async {
    print("adsadadadsadadadadsadsadadsadad");
    _controller1 = new TabController(length: 2, vsync: this);
    var prefs= await SharedPreferences.getInstance();

    var orgId=prefs.get("orgid");
    final GoogleMapController controller = await _controller.future;

    updates = FirebaseDatabase.instance.reference().child("Locations").child(orgId).onChildAdded.listen((data)async {
     // locationList.insert(0, Locations.fromFireBase(data.snapshot));
      var date=DateTime.now().toString().split(".")[0].split(" ")[0];
      var empId=data.snapshot.key.toString();
      if(data.snapshot.value[date]!=null) {
        var timesMap = new Map<String, dynamic>.from(data.snapshot.value[date]);
        List<Map<String, dynamic>> locationList = List();
        timesMap.forEach((k, v) => locationList.add({k:v}));

        locationList.sort((a,b) {
          return DateTime.parse(date+" "+a.keys.first).compareTo(DateTime.parse(date+" "+b.keys.first));
        });

        print("adsadadadsadadadadsadsadadsadad>>>>>>>>>>>>>"+locationList.length.toString()
            +
            locationList.toString() + ">>>" +
            locationList[locationList.length - 1].toString());
//var lastLocation=timesList[timesList.length - 1];
        var currentLoc=Locations.fromFireBase1(locationList[locationList.length - 1]);
      setState(() {
        // create a Polyline instance
        // with an id, an RGB color and the list of LatLng pairs
        controller.animateCamera(CameraUpdate.newCameraPosition(
          CameraPosition(
            bearing: 0,
            target: LatLng(double.parse(currentLoc.latitude),double.parse(currentLoc.longitude)),
            zoom: 17.0,
          ),
        ));
        /*
        latlng.add(LatLng(double.parse(currentLoc.latitude),double.parse(currentLoc.longitude)));
        _polylines.add(Polyline(
          polylineId: PolylineId("1"),
          visible: true,
          //latlng is List<LatLng>

          points: latlng,
          color: Colors.blue,
        ));*/
      });

    var res=await Dio().post(globals.path+"getProfile?uid="+empId);
    Map employeeMap =await json.decode(res.data);
    //print("https://ubitech.ubihrm.com/public/uploads/"+orgId+"/"+employeeMap["info"][0]['ImageName'].toString());
    print(globals.path+"getProfile?uid="+empId);
    var generatedIcon;
    BitmapDescriptor generatedIcons;
    var j=0;

        var address= await getAddressFromLati_offline(double.parse(currentLoc.latitude), double.parse(currentLoc.longitude));
      var m=Marker(
          markerId: MarkerId('sourcePin$j'),
          position: LatLng(double.parse(currentLoc.latitude),double.parse(currentLoc.longitude)),
          icon: await getMarkerIcon("https://ubitech.ubihrm.com/public/uploads/"+orgId+"/"+employeeMap["info"][0]['ImageName'], Size(150.0, 150.0),j+1),
          onTap: () {


var moving=currentLoc.is_moving=="false"?"Still":"Moving";

      setState(() {
      currentlySelectedPin = PinInformation(pinPath: 'assets/friend1.jpg', avatarPath: "https://ubitech.ubihrm.com/public/uploads/"+orgId+"/"+employeeMap["info"][0]['ImageName'], location: LatLng(0, 0), client: employeeMap["info"][0]['FirstName']+" "+employeeMap["info"][0]['LastName'],description: 'At: '+address,in_time: currentLoc.time.toString()+" ("+moving+")",out_time: '-', labelColor: Colors.grey);
      pinPillPosition = 50;
      });
      //print(visit.po_time);

      },
      /*
          infoWindow: InfoWindow(
              title: visits[i].client,
              snippet:visits[i].desc
          ),*/
      );
      Future.delayed(Duration(seconds: 1),(){
      setState(() {
      _markers.add(m);
      });
      });

      j++;



      }
    } );

    setSourceAndDestinationIcons();








  }

  Future<BitmapDescriptor> getMarkerIcon(String imagePath, Size size,int number) async {
    final ui.PictureRecorder pictureRecorder = ui.PictureRecorder();
    final Canvas canvas = Canvas(pictureRecorder);

    final Radius radius = Radius.circular(size.width / 2);

    final Paint tagPaint = Paint()..color = Colors.blue;
    final double tagWidth = 40.0;

    final Paint shadowPaint = Paint()..color = Colors.blue.withAlpha(100);
    final double shadowWidth = 15.0;

    final Paint borderPaint = Paint()..color = Colors.white;
    final double borderWidth = 3.0;

    final double imageOffset = shadowWidth + borderWidth;

    // Add shadow circle
    canvas.drawRRect(
        RRect.fromRectAndCorners(
          Rect.fromLTWH(
              0.0,
              0.0,
              size.width,
              size.height
          ),
          topLeft: radius,
          topRight: radius,
          bottomLeft: radius,
          bottomRight: radius,
        ),
        shadowPaint);

    // Add border circle
    canvas.drawRRect(
        RRect.fromRectAndCorners(
          Rect.fromLTWH(
              shadowWidth,
              shadowWidth,
              size.width - (shadowWidth * 2),
              size.height - (shadowWidth * 2)
          ),
          topLeft: radius,
          topRight: radius,
          bottomLeft: radius,
          bottomRight: radius,
        ),
        borderPaint);

    // Add tag circle
    canvas.drawRRect(
        RRect.fromRectAndCorners(
          Rect.fromLTWH(
              size.width - tagWidth,
              0.0,
              tagWidth,
              tagWidth
          ),
          topLeft: radius,
          topRight: radius,
          bottomLeft: radius,
          bottomRight: radius,
        ),
        tagPaint);

    // Add tag text
    TextPainter textPainter = TextPainter(textDirection: TextDirection.ltr);
    textPainter.text = TextSpan(
      text: number.toString(),
      style: TextStyle(fontSize: 20.0, color: Colors.white),
    );

    textPainter.layout();
    textPainter.paint(
        canvas,
        Offset(
            size.width - tagWidth / 2 - textPainter.width / 2,
            tagWidth / 2 - textPainter.height / 2
        )
    );

    // Oval for the image
    Rect oval = Rect.fromLTWH(
        imageOffset,
        imageOffset,
        size.width - (imageOffset * 2),
        size.height - (imageOffset * 2)
    );

    // Add path for oval image
    canvas.clipPath(Path()
      ..addOval(oval));

    // Add image
    ui.Image image = await getImageFromNetwork(imagePath); // Alternatively use your own method to get the image
    paintImage(canvas: canvas, image: image, rect: oval, fit: BoxFit.fitWidth);

    // Convert canvas to image
    final ui.Image markerAsImage = await pictureRecorder.endRecording().toImage(
        size.width.toInt(),
        size.height.toInt()
    );

    // Convert image to bytes
    final ByteData byteData = await markerAsImage.toByteData(format: ui.ImageByteFormat.png);
    final Uint8List uint8List = byteData.buffer.asUint8List();

    return BitmapDescriptor.fromBytes(uint8List);
  }
  Future<ui.Image> getUiImage(String imageAssetPath, int height, int width) async {
    final ByteData assetImageByteData = await rootBundle.load(imageAssetPath);
    image.Image baseSizeImage = image.decodeImage(assetImageByteData.buffer.asUint8List());
    image.Image resizeImage = image.copyResize(baseSizeImage, height: height, width: width);
    ui.Codec codec = await ui.instantiateImageCodec(image.encodePng(resizeImage));
    ui.FrameInfo frameInfo = await codec.getNextFrame();
    return frameInfo.image;
  }

  Future<ui.Image> getImageFromNetwork(String path) async {
    Completer<ImageInfo> completer = Completer();;
    var img = new NetworkImage(path);
    img.resolve(ImageConfiguration()).addListener(ImageStreamListener((ImageInfo info,bool _){
      completer.complete(info);
    }));
    ImageInfo imageInfo = await completer.future;
    return imageInfo.image;
  }



  Future<ui.Image> getImageFromPath(String imagePath) async {
    File imageFile = File(imagePath);

    Uint8List imageBytes = imageFile.readAsBytesSync();

    final Completer<ui.Image> completer = new Completer();

    ui.decodeImageFromList(imageBytes, (ui.Image img) {
      return completer.complete(img);
    });

    return completer.future;
  }

  void setSourceAndDestinationIcons() async {
    sourceIcon = await BitmapDescriptor.fromAssetImage(
        ImageConfiguration(devicePixelRatio: 2.5), 'assets/driving_pin.png');
    destinationIcon = await BitmapDescriptor.fromAssetImage(
        ImageConfiguration(devicePixelRatio: 2.5),
        'assets/destination_map_marker.png');
  }
  var formatter = new intl.DateFormat('dd-MMM-yyyy');

  @override
  Widget build(BuildContext context) {
    CameraPosition initialLocation = CameraPosition(
        zoom: CAMERA_ZOOM,
        bearing: CAMERA_BEARING,
        tilt: CAMERA_TILT,
        target: cameraSource);

    return new Scaffold(
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
        leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.pop(context);
            }),
        backgroundColor: appcolor,
      ),
      body: new ListView(
        physics: NeverScrollableScrollPhysics(),
        children: <Widget>[
          /*
          Container(
            color: Colors.white,
            child: DateTimeField(
              //dateOnly: true,
              format: formatter,
              controller: today,
              onShowPicker: (context, currentValue) {
                return showDatePicker(
                    context: context,
                    firstDate: DateTime(1900),
                    initialDate: currentValue ?? DateTime.now(),
                    lastDate: DateTime.now());

              },
              readOnly: true,
              decoration: InputDecoration(
                border: InputBorder.none,
                prefixIcon: Padding(
                  padding: EdgeInsets.all(0.0),
                  child: Icon(
                    Icons.date_range,
                    color: Colors.grey,
                  ), // icon is 48px widget.
                ), // icon is 48px widget.
                labelText: 'Select Date',
              ),
              onChanged: (date) {
                setState(() {

                });
              },
              validator: (date) {
                if (date == null) {
                  return 'Please select date';
                }
              },
            ),
          ),*/
          new Container(
            decoration: new BoxDecoration(color: Colors.black54),
            child: new TabBar(
              indicator: BoxDecoration(color: buttoncolor,),
              controller: _controller1,
              tabs: [
                new Tab(
                  text: 'Visited Locations',
                ),
                InkWell(
                  child: new Tab(
                    text: 'Punched Visits',

                  ),
                  onTap: (){
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => VisitListEmp(empId)),
                    );
                  },
                ),

              ],
            ),
          ),

                //////////////TABB 2 Start
      new Container(
        height: MediaQuery.of(context).size.height*0.90,
        child:Stack(
          children: <Widget>[

            GoogleMap(
              myLocationEnabled: false,
              compassEnabled: true,
              tiltGesturesEnabled: false,
              markers: _markers,
              polylines: _polylines,
              mapType: MapType.normal,
              initialCameraPosition: initialLocation,
              onMapCreated: onMapCreated,
              onTap: (LatLng location) {
                setState(() {
                  pinPillPosition = -470;
                });
              },

            ),



            MapPinPillComponent(
                pinPillPosition: pinPillPosition,
                currentlySelectedPin: currentlySelectedPin
            )

          ],

        ),
      )  /////////////TAB 2 Ends



                /////////////TAB 3 STARTS



        ],
      ),
    );
    /*
    return Scaffold(
      body: ListView(
        physics: NeverScrollableScrollPhysics(),
        children: <Widget>[
          Container(
            decoration: new BoxDecoration(color: Colors.black54),
            child: new TabBar(
              indicator: BoxDecoration(color: buttoncolor,),
              controller: _controller1,
              tabs: [
                new Tab(
                  text: 'Present',
                ),
                new Tab(
                  text: 'Absent',
                ),

              ],
            ),
          ),
          GoogleMap(
            myLocationEnabled: false,
            compassEnabled: true,
            tiltGesturesEnabled: false,
            markers: _markers,
            polylines: _polylines,
            mapType: MapType.normal,
            initialCameraPosition: initialLocation,
            onMapCreated: onMapCreated,
            onTap: (LatLng location) {
              setState(() {
                pinPillPosition = -400;
              });
            },

          ),


          Stack(
            children: <Widget>[





              MapPinPillComponent(
                  pinPillPosition: pinPillPosition,
                  currentlySelectedPin: currentlySelectedPin
              )

            ],

          ),
        ],
      ),
    );*/
  }


  void onMapCreated(GoogleMapController controller) {
    controller.setMapStyle(Utils.mapStyles);
    _controller.complete(controller);
    setMapPins();
    setPolylines();
  }

  void setMapPins() {
    setState(() {
      // source pin
      _markers.add(Marker(
          markerId: MarkerId('sourcePin'),
          position: SOURCE_LOCATION,
          icon: sourceIcon,
      /*  infoWindow: InfoWindow(
        title: 'I am a marker',
          snippet:'hbhs hsvgvs cshgfhgsf gschgfs sfhsfh gsfhfshfsh hgsfhfsfs '
      ),*/
      ));
      // destination pin
      _markers.add(Marker(
          markerId: MarkerId('destPin'),
          position: DEST_LOCATION,
          icon: destinationIcon));
    });
  }

  setPolylines() async {

   // latlng.add(_new);
   // latlng.add(_news);
    setState(() {
      // create a Polyline instance
      // with an id, an RGB color and the list of LatLng pairs
      _polylines.add(Polyline(
        polylineId: PolylineId("1"),
        visible: true,
        //latlng is List<LatLng>
        points: latlng,
        color: Colors.blue,
      ));
    });

  }





}


class Utils {
  static String mapStyles = '''[
  {
    "elementType": "geometry",
    "stylers": [
      {
        "color": "#f5f5f5"
      }
    ]
  },
  {
    "elementType": "labels.icon",
    "stylers": [
      {
        "visibility": "off"
      }
    ]
  },
  {
    "elementType": "labels.text.fill",
    "stylers": [
      {
        "color": "#616161"
      }
    ]
  },
  {
    "elementType": "labels.text.stroke",
    "stylers": [
      {
        "color": "#f5f5f5"
      }
    ]
  },
  {
    "featureType": "administrative.land_parcel",
    "elementType": "labels.text.fill",
    "stylers": [
      {
        "color": "#bdbdbd"
      }
    ]
  },
  {
    "featureType": "poi",
    "elementType": "geometry",
    "stylers": [
      {
        "color": "#eeeeee"
      }
    ]
  },
  {
    "featureType": "poi",
    "elementType": "labels.text.fill",
    "stylers": [
      {
        "color": "#757575"
      }
    ]
  },
  {
    "featureType": "poi.park",
    "elementType": "geometry",
    "stylers": [
      {
        "color": "#e5e5e5"
      }
    ]
  },
  {
    "featureType": "poi.park",
    "elementType": "labels.text.fill",
    "stylers": [
      {
        "color": "#9e9e9e"
      }
    ]
  },
  {
    "featureType": "road",
    "elementType": "geometry",
    "stylers": [
      {
        "color": "#ffffff"
      }
    ]
  },
  {
    "featureType": "road.arterial",
    "elementType": "labels.text.fill",
    "stylers": [
      {
        "color": "#757575"
      }
    ]
  },
  {
    "featureType": "road.highway",
    "elementType": "geometry",
    "stylers": [
      {
        "color": "#dadada"
      }
    ]
  },
  {
    "featureType": "road.highway",
    "elementType": "labels.text.fill",
    "stylers": [
      {
        "color": "#616161"
      }
    ]
  },
  {
    "featureType": "road.local",
    "elementType": "labels.text.fill",
    "stylers": [
      {
        "color": "#9e9e9e"
      }
    ]
  },
  {
    "featureType": "transit.line",
    "elementType": "geometry",
    "stylers": [
      {
        "color": "#e5e5e5"
      }
    ]
  },
  {
    "featureType": "transit.station",
    "elementType": "geometry",
    "stylers": [
      {
        "color": "#eeeeee"
      }
    ]
  },
  {
    "featureType": "water",
    "elementType": "geometry",
    "stylers": [
      {
        "color": "#c9c9c9"
      }
    ]
  },
  {
    "featureType": "water",
    "elementType": "labels.text.fill",
    "stylers": [
      {
        "color": "#9e9e9e"
      }
    ]
  }
]''';
}