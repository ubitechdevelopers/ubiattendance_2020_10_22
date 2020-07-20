import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:Shrine/globals.dart' as prefix0;
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/rendering.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:photo_view/photo_view.dart';

class ControllerExample extends StatefulWidget {
  final File image;
  const ControllerExample({Key key, this.image}) : super(key: key);
  @override
  _ControllerExampleState createState() => _ControllerExampleState(image);
}

const double min = pi * -2;
const double max = pi * 2;

const double minScale = 0.03;
const double defScale = 1;
const double maxScale = 2.6;

class _ControllerExampleState extends State<ControllerExample> {

  final File image;


  bool captureClicked=false;
  _ControllerExampleState(this.image) ;
  GlobalKey _globalKey = new GlobalKey();
  PhotoViewControllerBase controller;
  PhotoViewScaleStateController scaleStateController;

  int calls = 0;

  @override
  void initState() {
    controller = PhotoViewController()
      ..scale = defScale
      ..outputStateStream.listen(onControllerState);

    scaleStateController = PhotoViewScaleStateController();
    super.initState();
  }

  void onControllerState(PhotoViewControllerValue value) {
    setState(() {
      calls += 1;
    });
  }

  @override
  void dispose() {
    controller.dispose();
    scaleStateController.dispose();
    super.dispose();
  }
  Future<Uint8List> _capturePng() async {
    try {
      print('inside');
      setState(() {
        captureClicked=true;
      });
      RenderRepaintBoundary boundary =
      _globalKey.currentContext.findRenderObject();
      ui.Image image = await boundary.toImage(pixelRatio: 3.0);



      ByteData byteData =
      await image.toByteData(format: ui.ImageByteFormat.png);
      var pngBytes = byteData.buffer.asUint8List();
      var bs64 = base64Encode(pngBytes);
      print(pngBytes);
      Navigator.pop(context, pngBytes);
      /*
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ImageViewer(pngBytes),
        ),
      );*/
      print('Base 64'+bs64);
      setState(() {});
      return pngBytes;
    } catch (e) {
      print(e);
    }
  }

  Future<Uint8List> _capturePngAndSave() async {
    try {
      setState(() {
        captureClicked=true;
      });

      print('inside');
      RenderRepaintBoundary boundary =
      _globalKey.currentContext.findRenderObject();
      ui.Image image = await boundary.toImage(pixelRatio: 3.0);



      ByteData byteData =
      await image.toByteData(format: ui.ImageByteFormat.png);
      var pngBytes = byteData.buffer.asUint8List();
      var bs64 = base64Encode(pngBytes);
      print(pngBytes);
      await ImageGallerySaver.saveImage(pngBytes);
      Navigator.pop(context, pngBytes);
      /*
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ImageViewer(pngBytes),
        ),
      );*/
      print('Base 64'+bs64);
      setState(() {});
      return pngBytes;
    } catch (e) {
      print(e);
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: captureClicked?loader():Container(
        height: MediaQuery.of(context).size.height,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[

            Flexible(
              flex: 1,
              child: ClipRect(
                child: Stack(
                  children: <Widget>[
                    Positioned.fill(
                      child:
                  RepaintBoundary(
                  key: _globalKey,
                  child:

                      PhotoView(
                        imageProvider:
                        FileImage(image),
                        controller: controller,
                        scaleStateController: scaleStateController,
                        enableRotation: true,
                        initialScale: defScale,
                        minScale: minScale,
                        maxScale: maxScale,

                      ),)
                    ),
                    Positioned(
                      bottom: 0,
                      height: 220,
                      left: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.all(30.0),
                        child: StreamBuilder(
                          stream: controller.outputStateStream,
                          initialData: controller.value,
                          builder: _streamBuild,
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),
          ],
        ),
      ),

    );
  }

  Widget _streamBuild(BuildContext context, AsyncSnapshot snapshot) {
    if (snapshot.hasError || !snapshot.hasData) {
      return Container();
    }
    final PhotoViewControllerValue value = snapshot.data;
    return Column(
      children: <Widget>[
        /*
        Text(
          "Rotation ${value.rotation}",
          style: const TextStyle(color: Colors.white),
        ),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
              activeTrackColor: Colors.orange, thumbColor: Colors.orange),
          child: Slider(
            value: value.rotation.clamp(min, max),
            min: min,
            max: max,
            onChanged: (double newRotation) {
              controller.rotation = newRotation;
            },
          ),
        ),*/
        /*
        Text(
          "Scale ${value.scale}",
          style: const TextStyle(color: Colors.white),
        ),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: Colors.orange,
            thumbColor: Colors.orange,
          ),
          child: Slider(
            value: value.scale.clamp(minScale, maxScale),
            min: minScale,
            max: maxScale,
            onChanged: (double newScale) {
              controller.scale = newScale;
            },
          ),
        ),
        */
        /*
        Text(
          "Zoom",
          style: const TextStyle(color: Colors.white),
        ),*/
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            new FloatingActionButton(
              heroTag: null,
              child: Icon(Icons.check),
              onPressed: _capturePng,
              backgroundColor: Colors.green,
            ),
            SizedBox(width: 20,),
            new FloatingActionButton(
              heroTag: null,
              child: Icon(Icons.clear),
              backgroundColor: Colors.red,
              onPressed: (){
                Navigator.pop(context);
              },
            ),
            SizedBox(width: 20,),
            new FloatingActionButton(
              heroTag: null,
              child: Icon(Icons.save_alt),
              backgroundColor: prefix0.buttoncolor,
              onPressed: _capturePngAndSave,
            ),

          ],
        )

      ],
    );
  }

  loader() {
    return new Container(
      child: Center(
        child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              Image.asset('assets/spinner.gif', height: 50.0, width: 50.0),
            ]),
      ),
    );
  }
}