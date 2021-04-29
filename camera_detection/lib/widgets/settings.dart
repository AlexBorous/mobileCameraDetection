import 'package:camera_detection/main.dart';
import 'package:flutter/material.dart';

class Settings extends StatefulWidget {
  @override
  _SettingsState createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
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
    return AlertDialog(
        title: Center(
            child: Text(
          "Settings",
          style: TextStyle(fontSize: 25.0, fontWeight: FontWeight.bold),
        )),
        actions: [
          ElevatedButton(
            child: Text('Close'),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
        insetPadding:
            const EdgeInsets.symmetric(horizontal: 5.0, vertical: 5.0),
        backgroundColor: Colors.blueGrey.shade700,
        content: Container(
          height: MediaQuery.of(context).size.height * 0.5,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "POST url",
                style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontStyle: FontStyle.italic,
                    color: Colors.white70),
              ),
              const SizedBox(
                height: 8.0,
              ),
              Container(
                child: TextField(
                  decoration: InputDecoration(
                      border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.0),
                  )),
                  textAlign: TextAlign.center,
                  controller: _textEditingController,
                  onSubmitted: (str) async {
                    await box.put("url", str);
                    setState(() {
                      url = str;
                    });
                  },
                ),
              ),
              const SizedBox(
                height: 28.0,
              ),
              Text(
                "Delay",
                style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontStyle: FontStyle.italic,
                    color: Colors.white70),
              ),
              const SizedBox(
                height: 8.0,
              ),
              Flexible(
                child: Slider(
                  value: delay.toDouble(),
                  min: 0,
                  max: 10,
                  divisions: 9,
                  onChangeEnd: (double val) async =>
                      await box.put("delay", val.toInt()),
                  onChanged: (double value) {
                    setState(() {
                      delay = value.toInt();
                    });
                  },
                  label: "$delay",
                ),
              ),
              const SizedBox(
                height: 12.0,
              ),
              Flexible(
                child: Text(
                  "Model Minimum Detection Confidence",
                  style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontStyle: FontStyle.italic,
                      color: Colors.white70),
                ),
              ),
              const SizedBox(
                height: 8.0,
              ),
              Flexible(
                child: Slider(
                  value: confidence,
                  divisions: 20,
                  onChangeEnd: (double val) async =>
                      await box.put("confidence", val),
                  onChanged: (double value) {
                    setState(() {
                      confidence = value;
                    });
                  },
                  label: "$confidence",
                ),
              ),
              const SizedBox(
                height: 12.0,
              ),
              Flexible(
                child: Center(
                  child: ElevatedButton(
                    style: ButtonStyle(
                      backgroundColor:
                          MaterialStateProperty.all<Color>(Colors.red),
                    ),
                    child: Text('Reset Image Uploaded Counter'),
                    onPressed: () async {
                      await box.put("imagesUploaded", 0);
                    },
                  ),
                ),
              )
            ],
          ),
        ));
  }
}
