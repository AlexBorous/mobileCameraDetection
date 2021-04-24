import 'dart:io';
import 'dart:typed_data';

import 'package:camera_detection/image_converted.dart';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as t;

import 'package:camera/camera.dart';
import 'package:tflite/tflite.dart';
import 'dart:math' as math;

typedef void Callback(List<dynamic> list, int h, int w);

class CameraFeed extends StatefulWidget {
  final List<CameraDescription> cameras;
  final Callback setRecognitions;

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
          numResultsPerClass: 1,
          threshold: 0.4,
        ).then((recognitions) {
          widget.setRecognitions(recognitions!, img.height, img.width);
          recognitions.forEach((element) async {
            if (element['confidenceInClass'] > 0.5 &&
                element['detectedClass'] == "car") {
              print(element['detectedClass']);
              await controller.stopImageStream();
              final up = await controller.takePicture();
              print(up.readAsBytes());
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => DisplayPictureScreen(
                    imagePath: up.path,
                  ),
                ),
              );
              func();
              // final image = await convertImagetoPng(img);
              // print(image!.getBytes());

            }
          });
          // print(recognitions);
          isDetecting = false;
        });
      }
    });
  }
  // final shift = (0xFF << 24);
  // Future<Image> convertYUV420toImageColor(CameraImage image) async {
  //   try {
  //     final int width = image.width;
  //     final int height = image.height;
  //     final int uvRowStride = image.planes[1].bytesPerRow;
  //     final int? uvPixelStride = image.planes[1].bytesPerPixel;

  //     print("uvRowStride: " + uvRowStride.toString());
  //     print("uvPixelStride: " + uvPixelStride.toString());

  //     // imgLib -> Image package from https://pub.dartlang.org/packages/image
  //     var img = imglib.Image(width, height); // Create Image buffer

  //     // Fill image buffer with plane[0] from YUV420_888
  //     for (int x = 0; x < width; x++) {
  //       for (int y = 0; y < height; y++) {
  //         final int uvIndex =
  //             uvPixelStride * (x / 2).floor() + uvRowStride * (y / 2).floor();
  //         final int index = y * width + x;

  //         final yp = image.planes[0].bytes[index];
  //         final up = image.planes[1].bytes[uvIndex];
  //         final vp = image.planes[2].bytes[uvIndex];
  //         // Calculate pixel color
  //         int r = (yp + vp * 1436 / 1024 - 179).round().clamp(0, 255);
  //         int g = (yp - up * 46549 / 131072 + 44 - vp * 93604 / 131072 + 91)
  //             .round()
  //             .clamp(0, 255);
  //         int b = (yp + up * 1814 / 1024 - 227).round().clamp(0, 255);
  //         // color: 0x FF  FF  FF  FF
  //         //           A   B   G   R
  //         img.data[index] = shift | (b << 16) | (g << 8) | r;
  //       }
  //     }

  //     imglib.PngEncoder pngEncoder = new imglib.PngEncoder(level: 0, filter: 0);
  //     List<int> png = pngEncoder.encodeImage(img);
  //     muteYUVProcessing = false;
  //     return Image.memory(png);
  //   } catch (e) {
  //     print(">>>>>>>>>>>> ERROR:" + e.toString());
  //   }
  //   return null;
  // }

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
