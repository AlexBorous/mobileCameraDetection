import 'package:camera/camera.dart';
import 'package:camera_detection/camera.dart';
import 'package:flutter/material.dart';
import 'package:tflite/tflite.dart';

class LiveFeed extends StatefulWidget {
  final List<CameraDescription> cameras;
  final String url;
  LiveFeed(this.cameras, this.url);
  @override
  _LiveFeedState createState() => _LiveFeedState();
}

class _LiveFeedState extends State<LiveFeed> {
  late List<dynamic> _recognitions;
  int _imageHeight = 0;
  int _imageWidth = 0;
  initCameras() async {}
  loadTfModel() async {
    await Tflite.loadModel(
      model: "assets/models/ssd_mobilenet.tflite",
      labels: "assets/models/labels.txt",
    );
  }

  /* 
  The set recognitions function assigns the values of recognitions, imageHeight and width to the variables defined here as callback
  */
  setRecognitions(recognitions, imageHeight, imageWidth) {
    setState(() {
      _recognitions = recognitions;
      _imageHeight = imageHeight;
      _imageWidth = imageWidth;
    });
  }

  @override
  void initState() {
    super.initState();
    loadTfModel();
  }

  @override
  void dispose() {
    Tflite.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: <Widget>[
          CameraFeed(widget.cameras, setRecognitions, widget.url),
        ],
      ),
    );
  }
}
