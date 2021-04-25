import 'dart:io';

import 'package:camera_detection/upload_image.dart';
import 'package:flutter/material.dart';

import 'package:camera/camera.dart';
import 'package:hive/hive.dart';
import 'package:tflite/tflite.dart';
import 'dart:math' as math;

typedef void Callback(List<dynamic> list, int h, int w);

class CameraFeed extends StatefulWidget {
  final List<CameraDescription> cameras;
  final Callback setRecognitions;
  final String url;
  CameraFeed(this.cameras, this.setRecognitions, this.url);

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
        controller.lockCaptureOrientation();
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
        ).then((recognitions) {
          widget.setRecognitions(recognitions!, img.height, img.width);
          recognitions.forEach((element) async {
            if (element['confidenceInClass'] > 0.55 &&
                element['detectedClass'] == "car") {
              print(element['detectedClass']);
              await controller.stopImageStream();
              final up = await controller.takePicture();
              print(up.path);
              print(up.name);
              // await Navigator.push(
              //   context,
              //   MaterialPageRoute(
              //     builder: (context) => DisplayPictureScreen(
              //       imagePath: up.path,
              //     ),
              //   ),
              // );
              int? reason = await uploadImage(
                  filepath: up.path, url: widget.url, filename: up.name);
              if (reason == null) return func();
              print(reason);
              if (reason == 200) {
                int imagesUploaded =
                    Hive.box("settings").get("imagesUploaded", defaultValue: 0);
                await Hive.box("settings")
                    .put("imagesUploaded", imagesUploaded + 1);
              }
              await Future.delayed(Duration(seconds: 1));
              func();
              // final image = await convertImagetoPng(img);
              // print(image!.getBytes());

            }
          });
          print(recognitions);
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

class DisplayPictureScreen extends StatelessWidget {
  final String imagePath;

  const DisplayPictureScreen({required this.imagePath});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Display the Picture')),
      // The image is stored as a file on the device. Use the `Image.file`
      // constructor with the given path to display the image.
      body: Image.file(File(imagePath)),
    );
  }
}
