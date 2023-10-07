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
  String _platformVersion = 'Unknown';
  final _personalVoiceFlutterPlugin = PersonalVoiceFlutter();

  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    String platformVersion;
    // Platform messages may fail, so we use a try/catch PlatformException.
    // We also handle the message potentially returning null.
    try {
      platformVersion =
          await _personalVoiceFlutterPlugin.getPlatformVersion() ??
              'Unknown platform version';
    } on PlatformException {
      platformVersion = 'Failed to get platform version.';
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    setState(() {
      _platformVersion = platformVersion;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Center(
          child: Column(
            children: [
              Text('Running on: $_platformVersion\n'),
              ElevatedButton(
                  onPressed: askPermission,
                  child: const Text("Get Permission")),
              ElevatedButton(onPressed: speak, child: const Text("Speak")),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> speak() async {
    try {
      var result = await _personalVoiceFlutterPlugin.speak(
          "The Langstroth hive revolutionized beekeeping. Lorenzo Langstroth noticed that the hives beekeepers used at the time were just empty boxes with a lid. When beekeepers would lift the lid to harvest honey they would damage and break the comb that the bees had worked so hard to make. Langstroth noticed that the bees would leave 3/8 of an inch of space in between each section of comb they had built (also known as bee space). Langstroth then designed wood frames that could be lifted out of the hive and inspected individually. This allowed for beekeepers to manipulate, remove, replace and inspect frames for diseases without disturbing the entire hive. A Langstroth hive can either be 8 or 10 frames but all hives and frames have the same standard dimensions if you wish to build your own.");
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
}
