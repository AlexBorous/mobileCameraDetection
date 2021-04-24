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
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              ButtonTheme(
                minWidth: 160,
                child: ElevatedButton(
                  child: Text("Start Detection"),
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
      applicationName: "Object Detector App",
      applicationLegalese: "By Alex Borousas",
      applicationVersion: "1.0",
      children: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
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
