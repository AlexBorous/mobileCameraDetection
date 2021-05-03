import 'package:camera_detection/upload_image.dart';
import 'package:flutter/material.dart';

import 'package:camera/camera.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:hive/hive.dart';
import 'package:tflite/tflite.dart';
import 'dart:math' as math;

typedef void Callback(List<dynamic> list, int h, int w);

class CameraFeed extends StatefulWidget {
  final List<CameraDescription> cameras;
  final Callback setRecognitions;
  final String url;
  final int delay;
  final double confidence;
  CameraFeed(
      {required this.cameras,
      required this.setRecognitions,
      required this.url,
      required this.delay,
      required this.confidence});

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
        func();
      });
    }
  }

  void func() {
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
          numResultsPerClass: 2,
          threshold: 0.1,
        ).then((recognitions) async {
          widget.setRecognitions(recognitions!, img.height, img.width);
          for (var element in recognitions) {
            if (element['confidenceInClass'] > widget.confidence &&
                element['detectedClass'] == "car") {
              await controller.stopImageStream();
              final up = await controller.takePicture();

              String? reason = await uploadImage(
                  filepath: up.path, url: widget.url, filename: up.name);
              if (reason == null)
                break;
              else if (reason == "good") {
                if (!Hive.isBoxOpen("settings")) await Hive.openBox("settings");
                int imagesUploaded =
                    Hive.box("settings").get("imagesUploaded", defaultValue: 0);
                await Hive.box("settings")
                    .put("imagesUploaded", imagesUploaded + 1);
                await Hive.close();
              } else {
                Fluttertoast.showToast(
                    msg: reason,
                    toastLength: Toast.LENGTH_LONG,
                    gravity: ToastGravity.BOTTOM,
                    timeInSecForIosWeb: 1,
                    backgroundColor: Colors.red,
                    textColor: Colors.white,
                    fontSize: 22.0);
              }

              break;
            }
          }
          await Future.delayed(Duration(seconds: widget.delay));

          if (!controller.value.isStreamingImages) func();

          isDetecting = false;
        });
      }
    });
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
  }
}
