import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:personal_voice_flutter/personal_voice_flutter.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  TextEditingController _textController = TextEditingController(
    text:
        'The Langstroth hive revolutionized beekeeping. Lorenzo Langstroth noticed that the hives beekeepers used at the time were just empty boxes with a lid. When beekeepers would lift the lid to harvest honey they would damage and break the comb that the bees had worked so hard to make. Langstroth noticed that the bees would leave 3/8 of an inch of space in between each section of comb they had built (also known as bee space). Langstroth then designed wood frames that could be lifted out of the hive and inspected individually. This allowed for beekeepers to manipulate, remove, replace and inspect frames for diseases without disturbing the entire hive. A Langstroth hive can either be 8 or 10 frames but all hives and frames have the same standard dimensions if you wish to build your own.', // Set the initial text
  );
  String _textFieldValue = '';
  final _personalVoiceFlutterPlugin = PersonalVoiceFlutter();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Personal Voice Flutter'),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                const Text(
                    'Note: The phone must not be on silent for speech to play and you must have created a personal voice \n'),
                TextField(
                  controller: _textController,
                  maxLines: null,
                  decoration: const InputDecoration(
                    labelText: 'Enter Text',
                  ),
                ),
                ElevatedButton(
                    onPressed: askPermission,
                    child: const Text("Get Permission")),
                ElevatedButton(onPressed: speak, child: const Text("Speak")),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> speak() async {
    setState(() {
      _textFieldValue = _textController.text;
    });
    try {
      await _personalVoiceFlutterPlugin.speak(_textFieldValue);
    } on PlatformException {
      print("error");
    }
  }

  Future<void> askPermission() async {
    String result = "";
    // Platform messages may fail, so we use a try/catch PlatformException.
    // We also handle the message potentially returning null.
    try {
      result = await _personalVoiceFlutterPlugin
              .requestPersonalVoiceAuthorization() ??
          'Unknown result';
      print(result);
    } on PlatformException {
      result = 'Failed to get permission.';
    }
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }
}
