import 'package:camera/camera.dart';
import 'package:camera_detection/live_camera.dart';
import 'package:flutter/material.dart';

late List<CameraDescription> cameras;
String url = "default URl";
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  cameras = await availableCameras();

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Realtime Detection',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(),
      home: CameraApp(),
    );
  }
}

class CameraApp extends StatefulWidget {
  @override
  _CameraAppState createState() => _CameraAppState();
}

class _CameraAppState extends State<CameraApp> {
  late TextEditingController _textEditingController;
  @override
  void initState() {
    super.initState();

    _textEditingController = TextEditingController(text: url);
  }

  @override
  void dispose() {
    _textEditingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    print(url);

    return Scaffold(
      appBar: AppBar(
        title: Text("Car Detector App"),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.info),
            onPressed: aboutDialog,
          ),
        ],
      ),
      body: Container(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Column(
                    children: [
                      Container(
                        width: 100.0,
                        height: 100.0,
                        margin: EdgeInsets.all(20),
                        padding: EdgeInsets.all(10),
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(100),
                            border: Border.all(width: 2, color: Colors.white)),
                        child: Center(
                          child: Text(
                            "5",
                            style: const TextStyle(fontSize: 40.0),
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 12.0,
                      ),
                      Text("Images upladed"),
                    ],
                  ),
                ],
              ),
              const SizedBox(
                height: 50.0,
              ),
              Container(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      child: Row(
                        children: [
                          Text("Start Detection"),
                          const SizedBox(
                            width: 12.0,
                          ),
                          const Icon(
                            Icons.video_camera_back_outlined,
                            color: Colors.white,
                          ),
                        ],
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => LiveFeed(
                              cameras,
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  aboutDialog() {
    showAboutDialog(
      context: context,
      applicationName: "Car Detector App",
      children: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text("POST url:"),
            const SizedBox(
              width: 20.0,
            ),
            Flexible(
              child: TextField(
                textAlign: TextAlign.center,
                controller: _textEditingController,
                onSubmitted: (str) {
                  url = str;
                },
              ),
            ),
          ],
        ),
      ],
    );
  }
}
