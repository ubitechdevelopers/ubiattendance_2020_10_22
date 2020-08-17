import 'dart:convert';
import 'dart:io';

import 'package:Shrine/globals.dart';
import 'package:Shrine/home.dart';
import 'package:Shrine/photoviewController.dart';
import 'package:Shrine/smile_painter.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:firebase_ml_vision/firebase_ml_vision.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:flutter_native_image/flutter_native_image.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:photo_view/photo_view.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:ui' as ui show Image;
import 'grpAttPhotoViewController.dart';
import 'model/timeinout.dart';
import 'utils.dart';
import 'package:screen/screen.dart';
import 'package:Shrine/globals.dart' as globals;
import 'package:audioplayers/audio_cache.dart';
import 'package:audioplayers/audioplayers.dart';
class FaceDetectionFromLiveCamera extends StatefulWidget {
 // FaceDetectionFromLiveCamera({Key key}) : super(key: key);
var mk;
FaceDetectionFromLiveCamera(this.mk);
  @override
  FaceDetectionFromLiveCameraState createState() =>
      FaceDetectionFromLiveCameraState(mk);
}

class FaceDetectionFromLiveCameraState
    extends State<FaceDetectionFromLiveCamera> {
var mk;
FaceDetectionFromLiveCameraState(this.mk);
bool alertShowing=false;
  final FaceDetector faceDetector = FirebaseVision.instance.faceDetector();
  Future<void> _initializeControllerFuture;
  double _brightness = 1.0;
  bool _isKeptOn = true;
  List<Face> faces;
  CameraController _camera;
  String statusatt="";
  String org_name='';

  bool _isDetecting = false;
  CameraLensDirection _direction = CameraLensDirection.back;
  //BuildContext ctx;

  @override
  void initState() {
    super.initState();
    initializeCamera();
    initPlatformState();

  }
  initPlatformState() async {

    var prefs = await SharedPreferences.getInstance();


    setState((){
      org_name = prefs.getString('org_name') ?? '';

    });
  }
  stopimagestream() async{
    await _camera.stopImageStream();
  }

Future<AudioPlayer> playLocalAsset() async {
  AudioCache cache = new AudioCache();
  return await cache.play("Beep_Short.mp3");
}
/*
  clickpicture() async{
    print('Hello Wassup?');

    //await _initializeControllerFuture;
    // print("Path of dcim ------------------->"+await AlbumSaver.getDcimPath());
    // Construct the path where the image should be saved using the
    // pattern package.
    final path = p.join(
      // Store the picture in the temp directory.
      // Find the temp directory using the `path_provider` plugin.
      (await getTemporaryDirectory()).path,
      //  (await getApplicationDocumentsDirectory()).path,
      '${DateTime.now()}.png',
    );

    // Attempt to take a picture and log where it's been saved.
    Future.delayed(Duration(seconds: 1), () => stopimagestream());
    //await _camera.stopImageStream();
    await _camera.takePicture(path);
    print("Length of file"+File(path).lengthSync().toString());
    //print(result.lengthSync());
    //Navigator.of(context).pushReplacement(new MaterialPageRoute(builder: (BuildContext context) => TodayAttendance(),maintainState: false));
    var takenImage = await Navigator.push(context, new MaterialPageRoute(
      builder: (BuildContext context) => new GrpAttControllerExample(image:File(path)),
      fullscreenDialog: true,)
    );

    print("Image Taken successfully");
    print("-------------------------------------------------------");
    print(takenImage);
    File imageFile=await File(path).writeAsBytes(takenImage);

    Navigator.pop(context,imageFile);
    await _camera.dispose();
  }
*/
  void initializeCamera() async {

    print("Camera Initialized again.......................");

    CameraDescription description = await getCamera(_direction);
    ImageRotation rotation = rotationIntToImageRotation(
      description.sensorOrientation,
    );

    _camera = CameraController(
      description,
      defaultTargetPlatform == TargetPlatform.android
          ? ResolutionPreset.low
          : ResolutionPreset.medium,
    );
    await _camera.initialize();

    _camera.startImageStream((CameraImage image) {

      if (_isDetecting) return;

      _isDetecting = true;

      detect(image, FirebaseVision.instance.faceDetector().processImage,
          rotation)
          .then(
            (dynamic result) {
          setState(() {
            faces = result;
           // _initializeControllerFuture = _camera.initialize();
           print("This is the result"+alertShowing.toString()+faces.length.toString()+clickPictureCalled.toString());
            if( faces.length>0&&!alertShowing) {
              print(_isDetecting.toString()+"camera is detecting............");
              //faces.clear();
              print(_isDetecting.toString()+"camera is detecting............"+faces.length.toString());
              if(!clickPictureCalled){
                clickPictureCalled=true;
                clickpicture();

              }
             // print("This is the result"+result.toString());
             // clickpicture();
              //Future.delayed(Duration(seconds: 3), () => clickpicture());
            }
          });

          _isDetecting = false;
        },
      ).catchError(
            (_) {
          _isDetecting = false;
        },
      );
    });
  }

  Widget _buildResults() {
    const Text noResultsText = const Text('No results!');

    if (faces == null ||
        _camera == null ||
        !_camera.value.isInitialized) {
      return noResultsText;
    }

    CustomPainter painter;

    final Size imageSize = Size(
      _camera.value.previewSize.height,
      _camera.value.previewSize.width,
    );

    if (faces is! List<Face>) return noResultsText;
    painter = SmilePainterLiveCamera(imageSize, faces,_camera,context,mk);

    return CustomPaint(
      painter: painter,
    );
  }

clickpicture() async{


  //await _initializeControllerFuture;
  // print("Path of dcim ------------------->"+await AlbumSaver.getDcimPath());
  // Construct the path where the image should be saved using the
  // pattern package.

  if(_camera!=null){
    if (_camera.value.isInitialized)


      if(!started){
        started=true;
        print('Picture Clicked?');
        await _camera.stopImageStream();
        Future.delayed(Duration(milliseconds: 200),() async{
          final path = p.join(
            // Store the picture in the temp directory.
            // Find the temp directory using the `path_provider` plugin.
            (await getTemporaryDirectory()).path,
            //  (await getApplicationDocumentsDirectory()).path,
            '${DateTime.now()}.png',
          );


          await _camera.takePicture(path);
          startCameraAgain();
          //await _camera.dispose();



          var takenImage = await Navigator.push(context, new MaterialPageRoute(
            builder: (BuildContext context) => new GrpAttControllerExample(image:File(path)),
            fullscreenDialog: true,)
          );

          print("Image Taken successfully");
          print("-------------------------------------------------------");
          print(takenImage);
          File imageFile=await File(path).writeAsBytes(takenImage);
          File compressedImageFile= await testCompressAndGetFile(imageFile, path);
          print("Image File"+imageFile.toString());
          //Navigator.pop(context,imageFile);

          saveTimeInOutImagePickerGroupAttFaceCamera(mk,context,compressedImageFile);
          //await _camera.stopImageStream();
          //await _camera.dispose();

          //   FaceDetectionFromLiveCameraState f = new FaceDetectionFromLiveCameraState(mk);

          // f.initializeCamera();
clickPictureCalled=false;

        });

      }

    //  _camera.startImageStream((CameraImage availableImage) {



    //});

    // print("Length of file"+File(path).lengthSync().toString());
    //print(result.lengthSync());
    //Navigator.of(context).pushReplacement(new MaterialPageRoute(builder: (BuildContext context) => TodayAttendance(),maintainState: false));


    // Attempt to take a picture and log where it's been saved.
    // Future.delayed(Duration(seconds: 1), () => stopimagestream());




  }


}

Future<bool> saveTimeInOutImagePickerGroupAttFaceCamera(MarkTime mk,context,imagei) async {

  try{
    //File imagei = null;
    print('checking savetime');
    var isNextDayAWorkingDay=0;
    var prefs=await SharedPreferences.getInstance();


    imageCache.clear();






      if (imagei != null) {
        //print("---------------actionb   ----->"+mk.act);


        alertShowing=true;

        List<int> imageBytes = await imagei.readAsBytes();
        String  PictureBase64 = base64.encode(imageBytes);

        /*
      final tempDir = await getTemporaryDirectory();
      String path = tempDir.path;
      int rand = new Math.Random().nextInt(10000);
      im.Image image1 = im.decodeImage(imagei.readAsBytesSync());
      imagei.deleteSync();
      im.Image smallerImage = im.copyResize(image1, 500); // choose the size here, it will maintain aspect ratio
      File compressedImage = new File('$path/img_$rand.jpg')..writeAsBytesSync(im.encodeJpg(smallerImage, quality: 50));
    */
        //// sending this base64image string +to rest api

        //For cropping image
          ImageProperties properties =
          await FlutterNativeImage.getImageProperties(imagei.path);
          print("image cropped successfully");

          int width = properties.width;
          var offset = (properties.height - properties.width) / 2;

          File croppedFile = await FlutterNativeImage.cropImage(
              imagei.path, 0, offset.round(), width, width);

          // _resizePhoto(imagei.toString());

          imagei= croppedFile;


        Dio dio = new Dio();
        String location = globals.globalstreamlocationaddr;
        //String deviceidmobile= prefs.getString("deviceid")??"";

        String lat = globals.assign_lat.toString();
        String long = globals.assign_long.toString();
        print("saveImageGrpAttFace?uid=" + mk.uid + "&location=" + location + "&aid=" +
            mk.aid + "&act=" + mk.act + "&shiftid=" + mk.shiftid + "&refid=" +
            mk.refid + "&latit=" + lat + "&longi=" + long);
        print("global Address: " + location);
        print("global lat" + lat);
        print("global long" + long);
        print(mk.uid + " " + location + " " + mk.aid + " " + mk.act + " " +
            mk.shiftid + " " + mk.refid + " " + lat + " " + long);
        FormData formData = new FormData.from({
          "uid": mk.uid,
          "location": location,
          "aid": mk.aid,
          "act": mk.act,
          "shiftid": mk.shiftid,
          "refid": mk.refid,
          "latit": lat,
          "longi": long,
          "file": new UploadFileInfo(imagei, "image.png"),
          "FakeLocationStatus" : mk.FakeLocationStatus,
          "platform":'android',
          "tempimagestatus":1,
          "appVersion": globals.appVersion
          //"deviceidmobile":deviceidmobile,
          //"devicenamebrand":globals.devicenamebrand
        });
        print(formData);

        //attendanceMarked=false;


        Response<String> response1 = await dio.post(
            globals.path + "saveImageGrpAttFace", data: formData);
        print("Response from save image:"+response1.toString());
        //Response<String> response1=await dio.post("https://ubiattendance.ubihrm.com/index.php/services/saveImage",data:formData);
        //Response<String> response1=await dio.post("http://192.168.0.200/ubiattendance/index.php/services/saveImage",data:formData);
        //Response<String> response1 = await dio.post("https://ubitech.ubihrm.com/services/saveImage", data: formData);
        imagei.deleteSync();
        imageCache.clear();
        // globals.cameraChannel.invokeMethod("cameraClosed");
        /*getTempImageDirectory();*/
        Map MarkAttMap = json.decode(response1.data);

       // Future.delayed(Duration(seconds: 2),(){

       // });



        print(MarkAttMap["status"].toString());
        print(MarkAttMap["groupface"].toString());
        print(MarkAttMap["statusatt"].toString());
        if(MarkAttMap["statusatt"].toString()=='1'){
           statusatt='Time In';
        }else
          if(MarkAttMap["statusatt"].toString()=='2'){
            statusatt='Time Out';
          }
        if (MarkAttMap["status"] == 1 || MarkAttMap["status"] == 2) {

          //TempImage tempimage = new TempImage(null, int.parse(mk.uid),mk.act, MarkAttMap["insert_updateid"], PictureBase64, int.parse(mk.refid) , 'Attendance');
          // tempimage.save();
          await playLocalAsset();

          showDialog(
              context: context,
              barrierDismissible: false,
              builder: (context) {
                Future.delayed(Duration(seconds: 3), () {


                  Navigator.of(context).pop(true);
                  alertShowing=false;


                });
                return AlertDialog(
                  //title: Text('Title'),
                  content: Text(statusatt.toString()+" punched for "+MarkAttMap["groupface"].toString()),
                );
              });
          return true;
        }else if (MarkAttMap["status"].toString() == '4')

        {
          showDialog(
              context: context,
              barrierDismissible: false,
              builder: (context) {
                Future.delayed(Duration(seconds: 3), () {


                  Navigator.of(context).pop(true);
                  alertShowing=false;


                });
                return AlertDialog(
                  //title: Text('Title'),
                  content: Text('Attendance is already punched for '+MarkAttMap["groupface"].toString()),
                );
              });
          return false;

        }
        else if (MarkAttMap["status"].toString() == '6')

        {
          showDialog(
              context: context,
              barrierDismissible: false,
              builder: (context) {
                Future.delayed(Duration(seconds: 3), () {


                  Navigator.of(context).pop(true);
                  alertShowing=false;


                });
                return AlertDialog(
                  //title: Text('Title'),
                  content: Text('Please register your Face ID first'),
                );
              });
          return false;

        }

        else if (MarkAttMap["status"].toString() == '7')

        {
          showDialog(
              context: context,
              barrierDismissible: false,
              builder: (context) {
                Future.delayed(Duration(seconds: 3), () {


                  Navigator.of(context).pop(true);
                  alertShowing=false;


                });
                return AlertDialog(
                  //title: Text('Title'),
                  content: Text('Time Out can not be marked soon after Time In'),
                );
              });
          return false;

        }
        else
          {
           // startCameraAgain();
            //attendanceMarked=true;
            print('inside ifelse');
            showDialog(
                context: context,
                barrierDismissible: false,
                builder: (context) {
                  Future.delayed(Duration(seconds: 3), () {
                    Navigator.of(context).pop(true);
                    alertShowing=false;

                  });
                  return AlertDialog(
                   // title: Text('Title'),
                    content: Text("Face could not be recognized"),
                  );
                });

            return false;

          }

      }
      else {
        globals.globalCameraOpenedStatus=false;
        print("6");
        return false;
      }

  } catch (e) {
    print(e.toString());
    globals.globalCameraOpenedStatus=false;
    return false;

  }


}
  void startCameraAgain() {
    started=false;
   // FaceDetectionFromLiveCameraState f = new FaceDetectionFromLiveCameraState(mk);

    reInitialize();
    //_camera.startCamera()


  }


Widget _buildImage() {
    return Container(
      constraints: const BoxConstraints.expand(),
      child: _camera == null
          ? const Center(
        child: Text(
          '',
          style: TextStyle(
            color: Colors.green,
            fontSize: 30.0,
          ),
        ),
      )
          : Stack(
        fit: StackFit.expand,
        children: <Widget>[
          CameraPreview(_camera),
          _buildResults(),
          /*
          Positioned(
            bottom: 0.0,
            left: 0.0,
            right: 0.0,
            child: Container(
              color: Colors.white,
              height: 50.0,
             /* child: ListView(
                children: faces
                    .map((face) =>
                    Text(face.boundingBox.center.toString()))
                    .toList(),
              ),*/
            ),
          ),*/
        ],
      ),
    );
  }

  void toggleCameraDirection() async {
    if (_direction == CameraLensDirection.back) {
      _direction = CameraLensDirection.front;
    } else {
      _direction = CameraLensDirection.back;
    }

    await _camera.stopImageStream();
    await _camera.dispose();

    setState(() {
      _camera = null;
    });

    initializeCamera();
  }


void reInitialize() async {
    /*
    if (_direction == CameraLensDirection.back) {
    _direction = CameraLensDirection.front;
  } else {
    _direction = CameraLensDirection.back;
  }

  await _camera.stopImageStream();

*/

    if(mounted)
      {
        _isDetecting=false;
        await _camera.dispose();
        setState(() {
          _camera = null;
          faces.clear();

        });
        print('face list value.......'+faces.toString());
        initializeCamera();

      }


}
  Future<File> testCompressAndGetFile(File file, String targetPath) async {
    var result = await FlutterImageCompress.compressAndGetFile(
      file.absolute.path, targetPath,
      quality: 100,

      minHeight: 200,
      minWidth: 200,
    );

    print("Length of file"+result.lengthSync().toString());
    print(result.lengthSync());
    final path = p.join(
      // Store the picture in the temp directory.
      // Find the temp directory using the `path_provider` plugin.
      // (await getTemporaryDirectory()).path,
      (await getApplicationDocumentsDirectory()).path,
      '${DateTime.now()}.png',
    );

    print("-----------------------------------path of image--------------------------------->"+path);
    result.copy(path);
    //GallerySaver.saveImage(result.path);
    return result;
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(org_name,style: new TextStyle(fontSize: 20.0)),
          automaticallyImplyLeading: false,
          backgroundColor: appcolor
      ),
      body: _buildImage(),
      floatingActionButton: Stack(
        children: <Widget>[
          Positioned(
            bottom: 10.0,
            right: 100.0,
            child: FloatingActionButton(
              heroTag: 'change camera',
              onPressed: toggleCameraDirection,
              child: _direction == CameraLensDirection.back
                  ? const Icon(Icons.rotate_left)
                  : const Icon(Icons.rotate_left),
              backgroundColor: Colors.green,
//              shape: RoundedRectangleBorder(
//                borderRadius: BorderRadius.circular(5.0),
//              ),

            ),
          ),
          Positioned(
            bottom: 10.0,
            right: 160.0,
            child: FloatingActionButton(
              heroTag: 'Done',
              onPressed: () async{
                await _camera.dispose();
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => HomePage()),
                );
              },
              child: Icon(Icons.arrow_back),
              backgroundColor: Colors.red,
//              shape: RoundedRectangleBorder(
//                borderRadius: BorderRadius.circular(5.0),
//              ),
            ),
          ),
        ],
      ),
      /*
      floatingActionButton: FloatingActionButton(
        onPressed: _toggleCameraDirection,
        child: _direction == CameraLensDirection.back
            ? const Icon(Icons.camera_front)
            : const Icon(Icons.camera_rear),
      ),
    */
    );
  }
}


