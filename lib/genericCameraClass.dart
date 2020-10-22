import 'dart:async';
import 'dart:io';

import 'package:Shrine/globals.dart';
import 'package:Shrine/photoviewController.dart';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path/path.dart' show join;
import 'package:path_provider/path_provider.dart';
import 'package:photo_view/photo_view.dart';
// A screen that allows users to take a picture using a given camera.
class TakePictureScreen extends StatefulWidget {
  @override
  TakePictureScreenState createState() => TakePictureScreenState();
}

class TakePictureScreenState extends State<TakePictureScreen> {
  CameraDescription camera;
  CameraDescription frontCamera;

  CameraController _controller;
  bool frontPressed=false;
  Future<void> _initializeControllerFuture;
  bool frontCameraAvailable=false;

  @override
  void initState() {
    super.initState();
    // To display the current output from the Camera,
    // create a CameraController.
    initialize();


    // Next, initialize the controller. This returns a Future.

  }
  initialize()async{
    final cameras = await availableCameras();

    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    // Get a specific camera from the list of available cameras.
    var firstCamera = cameras.first;
    var secondCamera = cameras[1];
    print("------------------------Camera Available------------------------");
    print(cameras.length);
    bool frontCameraAvailable=false;
    if(cameras.length>1){
      frontCameraAvailable=true;
    }
    setState(() {
      this.frontCameraAvailable=frontCameraAvailable;
      this.camera=secondCamera;

      this.frontCamera=firstCamera;
      _controller = CameraController(
        // Get a specific camera from the list of available cameras.
        this.camera,
        // Define the resolution to use.
        ResolutionPreset.medium,
          enableAudio: false,
      );
      _initializeControllerFuture = _controller.initialize();

    });

  }
  @override
  void dispose() {
    // Dispose of the controller when the widget is disposed.
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(

        // Wait until the controller is initialized before displaying the
        // camera preview. Use a FutureBuilder to display a loading spinner
        // until the controller has finished initializing.
        appBar: AppBar(title: Text('Take a picture'),backgroundColor: appcolor,),
        body: FutureBuilder<void>(

          future: _initializeControllerFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              // If the Future is complete, display the preview.
              return AspectRatio(
                aspectRatio: _controller.value.aspectRatio,
                child: CameraPreview(_controller),
              );
              //return CameraPreview(_controller);
            } else {
              // Otherwise, display a loading indicator.
              return Center(child: CircularProgressIndicator());
            }
          },
        ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        floatingActionButton:
    Container(
    //color: Colors.black.withOpacity(0.7),
        padding: new EdgeInsets.all(20.0),
        child:
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,

          children: <Widget>[

            FloatingActionButton(
              heroTag: null,
            
              backgroundColor: Colors.orange,

              child: Icon(Icons.camera_alt),

              //  shape: RoundedRectangleBorder(side: BorderSide(color: Colors.white, width: 2.0),borderRadius: BorderRadius.all(Radius.circular(50.0))),
              // Provide an onPressed callback.
              onPressed: () async {
                // Take the Picture in a try / catch block. If anything goes wrong,
                // catch the error.
                try {
                  // Ensure that the camera is initialized.
                  await _initializeControllerFuture;
                  // print("Path of dcim ------------------->"+await AlbumSaver.getDcimPath());
                  // Construct the path where the image should be saved using the
                  // pattern package.
                  final path = join(
                    // Store the picture in the temp directory.
                    // Find the temp directory using the `path_provider` plugin.
                    (await getTemporaryDirectory()).path,
                    //  (await getApplicationDocumentsDirectory()).path,
                    '${DateTime.now()}.png',
                  );

                  // Attempt to take a picture and log where it's been saved.
                  await _controller.takePicture(path);
                  print("Length of file"+File(path).lengthSync().toString());
                  //print(result.lengthSync());

                  var takenImage = await Navigator.push(context, new MaterialPageRoute(
                    builder: (BuildContext context) => new ControllerExample(image:File(path)),
                    fullscreenDialog: true,)
                  );

                  print("Image Taken successfully");
                  print("-------------------------------------------------------");
                  print(takenImage);
                  File imageFile=await File(path).writeAsBytes(takenImage);
                  File compressedImageFile= await testCompressAndGetFile(imageFile, path);

                  Navigator.pop(context,compressedImageFile);

                  /*
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ControllerExample(image: File(path)),
              ),
            );*/
                  /*
           testCompressAndGetFile(File(path),path).then((File file){
             //GallerySaver.saveImage(file.path);
            // AlbumSaver.createAlbum(albumName: "YourAlbumName");
            // AlbumSaver.saveToAlbum(filePath: file.path, albumName: "YourAlbumName");

// Create album
// In Android, it will create a folder in DCIM folder

             Navigator.push(
               context,
               MaterialPageRoute(
                 builder: (context) => ControllerExample(image: file),
               ),
             );

           });*/
                  //
                  // If the picture was taken, display it on a new screen.

                } catch (e) {
                  // If an error occurs, log the error to the console.
                  print(e);
                }
              },
            ),SizedBox(width:10),
            if(frontCameraAvailable)
              FloatingActionButton(
                  heroTag: null,
                  child: Icon(Icons.rotate_left),
                  //shape: RoundedRectangleBorder(side: BorderSide(color: Colors.white, width: 2.0),borderRadius: BorderRadius.all(Radius.circular(50.0))),
                  backgroundColor: Colors.orange,
                  foregroundColor: Colors.white,
                  onPressed: () async {
                    setState(() {
                      if(frontPressed){
                        frontPressed=false;
                        _controller = CameraController(
                          // Get a specific camera from the list of available cameras.
                          this.camera,
                          // Define the resolution to use.
                          ResolutionPreset.medium,
                            enableAudio: false
                        );
                      }
                      else{
                        frontPressed=true;
                        _controller = CameraController(
                          // Get a specific camera from the list of available cameras.
                          this.frontCamera,
                          // Define the resolution to use.
                          ResolutionPreset.medium,
                            enableAudio: false
                        );
                      }


                      // Next, initialize the controller. This returns a Future.
                      _initializeControllerFuture = _controller.initialize();
                    });

                  }
              ),
            ],))
    );
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
    final path = join(
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

}

// A widget that displays the picture taken by the user.
class DisplayPictureScreen extends StatelessWidget {
  final File image;

  const DisplayPictureScreen({Key key, this.image}) : super(key: key);

  @override
  Widget build(BuildContext context) {

    //File file=testCompressAndGetFile(File(imagePath),imagePath);
    return Scaffold(
        appBar: AppBar(title: Text('Display the Picture')),
        backgroundColor: Colors.white,
        // The image is stored as a file on the device. Use the `Image.file`
        // constructor with the given path to display the image.
        body:
        Container(
            child: PhotoView(
              imageProvider: FileImage(image),
            )
        )

    );
  }
}