import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:tflite/tflite.dart';
import 'dart:math' as math;

typedef void Callback(List<dynamic> list, int h, int w);

class CameraFeed extends StatefulWidget {
  final List<CameraDescription> cameras;
  final Callback setRecognitions;
  // The cameraFeed Class takes the cameras list and the setRecognitions
  // function as argument
  CameraFeed(this.cameras, this.setRecognitions);

  @override
  _CameraFeedState createState() => new _CameraFeedState();
}

class _CameraFeedState extends State<CameraFeed> {
  late CameraController controller;
  bool isDetecting = false;

  @override
  void initState() {
    super.initState();
    print(widget.cameras);
    if (widget.cameras.length < 1) {
      print('No Cameras Found.');
    } else {
      controller = CameraController(
        widget.cameras[0],
        ResolutionPreset.high,
      );
      controller.initialize().then((_) {
        if (!mounted) {
          return;
        }
        setState(() {});

        controller.startImageStream((CameraImage img) {
          if (!isDetecting) {
            isDetecting = true;
            Tflite.detectObjectOnFrame(
              bytesList: img.planes.map((plane) {
                return plane.bytes;
              }).toList(),
              model: "SSDMobileNet",
              imageHeight: img.height,
              imageWidth: img.width,
              imageMean: 127.5,
              imageStd: 127.5,
              numResultsPerClass: 1,
              threshold: 0.4,
            ).then((recognitions) {
              widget.setRecognitions(recognitions!, img.height, img.width);
              recognitions.forEach((element) {
                if (element['confidenceInClass'] > 0.5 &&
                    element['detectedClass'] == "car")
                  print(element['detectedClass']);
              });
              print(recognitions);
              isDetecting = false;
            });
          }
        });
      });
    }
  }

  Future<void> initializeCameraController() async {
    await controller.initialize();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!controller.value.isInitialized) {
      return Container();
    }
    // return FutureBuilder(
    //     future: initializeCameraController(),
    //     builder: (BuildContext context, snapshot) {
    //       if (snapshot.connectionState == ConnectionState.done) {
    //         controller.startImageStream((CameraImage img) {
    //           if (!isDetecting) {
    //             isDetecting = true;
    //             Tflite.detectObjectOnFrame(
    //               bytesList: img.planes.map((plane) {
    //                 return plane.bytes;
    //               }).toList(),
    //               model: "SSDMobileNet",
    //               imageHeight: img.height,
    //               imageWidth: img.width,
    //               imageMean: 127.5,
    //               imageStd: 127.5,
    //               numResultsPerClass: 1,
    //               threshold: 0.4,
    //             ).then((recognitions) {
    //               widget.setRecognitions(recognitions!, img.height, img.width);
    //               print(recognitions);
    //               isDetecting = false;
    //             });
    //           }
    //         });
    // If the Future is complete, display the preview.
    var tmp = MediaQuery.of(context).size;
    var screenH = math.max(tmp.height, tmp.width);
    var screenW = math.min(tmp.height, tmp.width);
    tmp = controller.value.previewSize!;
    var previewH = math.max(tmp.height, tmp.width);
    var previewW = math.min(tmp.height, tmp.width);
    var screenRatio = screenH / screenW;
    var previewRatio = previewH / previewW;

    return OverflowBox(
      maxHeight:
          screenRatio > previewRatio ? screenH : screenW / previewW * previewH,
      maxWidth:
          screenRatio > previewRatio ? screenH / previewH * previewW : screenW,
      child: CameraPreview(controller),
    );
    //         } else {
    //           return Center(
    //               child:
    //                   CircularProgressIndicator()); // Otherwise, display a loading indicator.
    //         }
    //       });
    // }
  }
}
