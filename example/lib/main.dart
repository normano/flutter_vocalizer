import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_vocalizer/flutter_vocalizer.dart';

var scaffoldKey = GlobalKey();
const ssmlText =
    '<speak>Welcome to <prosody volume="x-loud" pitch="high">Flutter Vocalizer</prosody>, a <emphasis level="moderate">fun</emphasis> way to integrate text-to-speech with <prosody rate="fast">SSML</prosody> support!</speak>';

const plainTextStory =
    'Once upon a time, in a land far, far away, there was a mighty king who ruled with wisdom and courage. '
    'The people of his kingdom prospered under his reign. But one day, a great storm loomed over the kingdom, '
    'and the skies darkened. The king, undaunted, called upon his bravest knights to face the storm. '
    'Together, they ventured into the depths of the forest, where the winds howled and trees creaked... '
    'They fought with all their might, and at last, the storm was defeated. The kingdom was saved, and the people cheered!';

const ssmlStory ="""
<speak>
  <prosody rate="medium" pitch="+2%">Once upon a time,</prosody> 
  <break time="500ms"/> in a land far, far away, <prosody pitch="medium">there lived a mighty king</prosody>. 
  He ruled with <emphasis level="moderate">great wisdom</emphasis> and courage.

  <break time="300ms"/>
  The people <prosody rate="slow">loved him</prosody> dearly, for under his reign, the kingdom thrived.

  <break time="400ms"/>
  But one fateful day, a storm began to brew in the distance. 
  <break time="500ms"/> The skies grew <prosody pitch="-2%" rate="slow">dark</prosody>, and the winds began to howl.

  <break time="300ms"/>
  The king gathered his <emphasis level="moderate">bravest knights</emphasis>, and together, they set out on a journey into the heart of the forest. 
  As they ventured deeper, <prosody pitch="-3%">the storm raged on</prosody>, <break time="500ms"/> but the king <prosody pitch="+1%">remained fearless</prosody>.

  <break time="400ms"/>
  After many trials, the storm was finally <emphasis level="moderate">vanquished</emphasis>. 
  The kingdom was saved, and the people rejoiced <prosody pitch="+2%">with joy and relief</prosody>.

  <break time="400ms"/>
  And so, the king returned home, knowing that his people would forever remember his bravery.
</speak>
""";

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with SingleTickerProviderStateMixin {
  TextEditingController _textController = TextEditingController(
    text: 'The Langstroth hive revolutionized beekeeping. Lorenzo Langstroth noticed that the hives beekeepers used at the time were just empty boxes with a lid. When beekeepers would lift the lid to harvest honey they would damage and break the comb that the bees had worked so hard to make. Langstroth noticed that the bees would leave 3/8 of an inch of space in between each section of comb they had built (also known as bee space). Langstroth then designed wood frames that could be lifted out of the hive and inspected individually. This allowed for beekeepers to manipulate, remove, replace and inspect frames for diseases without disturbing the entire hive. A Langstroth hive can either be 8 or 10 frames but all hives and frames have the same standard dimensions if you wish to build your own.', // Set the initial text
  );
  String _textFieldValue = '';
  final _flutterVocalizerPlugin = FlutterVocalizer();
  late TabController _tabController;

  List<String> _languages = [];
  List<Map<String, String>> _voices = [];
  String? _selectedLanguage;
  Map<String, String>? _selectedVoice;
  bool isPlaying = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadLanguages();
    _flutterVocalizerPlugin.setOnSpeechComplete(onCompleteFn);
  }

  void onCompleteFn() {
    setState(() {
      isPlaying = false;
    });
  }

  Future<void> _loadLanguages() async {
    var languages = await _flutterVocalizerPlugin.getLanguages();
    setState(() {
      _languages = languages ?? [];
      _selectedLanguage = _languages.isNotEmpty ? _languages[0] : null;

      if(_selectedLanguage != null) {
        refreshVoices();
      }
    });
  }

  Future<void> refreshVoices() async {
    var voices = await _flutterVocalizerPlugin.getVoices();
    setState(() {
      _voices = voices?.where((voice) {
        return voice["locale"] == _selectedLanguage;
      }).toList() ?? [];
      _selectedVoice = _voices.isNotEmpty ? _voices[0] : null;
    });
  }

  Widget _buildLanguageDropdown() {
    return DropdownButton<String>(
      value: _selectedLanguage,
      items: _languages.map<DropdownMenuItem<String>>((language) {
        return DropdownMenuItem<String>(
          value: language,
          child: Text(language),
        );
      }).toList(),
      onChanged: (value) {
        setState(() {
          _selectedLanguage = value!;
        });
        _flutterVocalizerPlugin.setLanguage(value!);
        refreshVoices();
      },
    );
  }

  Widget _buildVoiceDropdown() {
    return DropdownButton<Map<String, String>>(
      value: _selectedVoice,
      items: _voices.map<DropdownMenuItem<Map<String, String>>>((voice) {
        return DropdownMenuItem<Map<String, String>>(
          value: voice,
          child: Text(voice['name'] ?? ''),
        );
      }).toList(),
      onChanged: (value) {
        setState(() {
          _selectedVoice = value!;
        });
        _flutterVocalizerPlugin.setVoice(value!);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        key: scaffoldKey,
        appBar: AppBar(
          title: const Text('Flutter Vocalizer'),
          bottom: TabBar(
            controller: _tabController,
            tabs: const [
              Tab(text: 'Text Input'),
              Tab(text: 'SSML Example'),
              Tab(text: 'Plain Text Story'), // New Tab for plain text story
              Tab(text: 'SSML Story'), // SSML Story Tab
            ],
          ),
        ),
        body: Column(
          children: [
            Wrap(
              alignment: WrapAlignment.center,
              spacing: 24,
              children: [
                _buildLanguageDropdown(),
                _buildVoiceDropdown(),
                ElevatedButton(
                  onPressed: askPermission,
                  child: const Text("Get Personal Voice Permission"),
                ),
                if(isPlaying) ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white
                  ),
                  onPressed: stop,
                  child: const Text("Stop"),
                ),
              ],
            ),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  // Text Input and Speak Button
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      children: [
                        FutureBuilder(
                            future: _flutterVocalizerPlugin.isPersonalVoiceSupported(),
                            builder: (context, snapshot) {
                              if (snapshot.hasData) {
                                return Text("IS SUPPORTED = ${snapshot.data!}");
                              }
                              return const Text("IS SUPPORTED = ?????");
                            }),
                        const Text(
                            'Note: The phone must not be on silent for speech to play and you must have created a personal voice \n'),
                        Expanded(
                          child: SingleChildScrollView(
                            child: TextField(
                              controller: _textController,
                              maxLines: null,
                              decoration: const InputDecoration(
                                labelText: 'Enter Text',
                              ),
                            ),
                          )
                        ),
                        ElevatedButton(
                          onPressed: speak,
                          child: const Text("Speak"),
                        ),
                      ],
                    ),
                  ),
                  // SSML Example
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Text(
                          'SSML Example:',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 10),
                        const Text(
                          'This will demonstrate a random SSML text spoken:',
                          style: TextStyle(fontSize: 16),
                        ),
                        const SizedBox(height: 10),
                        const Text(
                          ssmlText,
                          style: TextStyle(fontSize: 14),
                        ),
                        const SizedBox(height: 10),
                        ElevatedButton(
                          onPressed: speakSSML,
                          child: const Text("Speak SSML"),
                        ),
                      ],
                    ),
                  ),
                  // Plain Text Story (No SSML)
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Text(
                          'Plain Text Story:',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 10),
                        const Text(
                          'This is the same story without SSML, which will be spoken using the regular speak function.',
                          style: TextStyle(fontSize: 16),
                        ),
                        const SizedBox(height: 10),
                        const Text(
                          plainTextStory,
                          style: TextStyle(fontSize: 14),
                        ),
                        const SizedBox(height: 10),
                        ElevatedButton(
                          onPressed: speakPlainTextStory,
                          child: const Text("Speak Plain Text Story"),
                        ),
                      ],
                    ),
                  ),
                  // SSML Story
                  Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        children: [
                          const Expanded(
                            child: SingleChildScrollView(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  Text(
                                    'SSML Story:',
                                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                  ),
                                  SizedBox(height: 10),
                                  Text(
                                    'This is an advanced SSML story showcasing different SSML tags like pauses, emphasis, pitch, and more.',
                                    style: TextStyle(fontSize: 16),
                                  ),
                                  SizedBox(height: 10),
                                  Text(
                                    ssmlStory,
                                    style: TextStyle(fontSize: 14),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
                          ElevatedButton(
                            onPressed: speakSSMLStory,
                            child: const Text("Speak SSML Story"),
                          ),
                        ],
                      )
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Future<void> stop() async {
    await _flutterVocalizerPlugin.stop();
    setState(() {
      isPlaying = false;
    });
  }

  Future<void> speak() async {
    setState(() {
      _textFieldValue = _textController.text;
    });
    try {
      await _flutterVocalizerPlugin.stop();
      await _flutterVocalizerPlugin.speak(_textFieldValue);
      setState(() {
        isPlaying = true;
      });
    } on PlatformException {
      print("error");
    }
  }

  Future<void> speakSSML() async {
    try {
      await _flutterVocalizerPlugin.stop();
      await _flutterVocalizerPlugin.speakSSML(ssmlText);
      setState(() {
        isPlaying = true;
      });
    } on PlatformException {
      print("Error in SSML speech synthesis");
    }
  }

  Future<void> speakPlainTextStory() async {
     try {
       await _flutterVocalizerPlugin.stop();
      await _flutterVocalizerPlugin.speak(plainTextStory);
       setState(() {
         isPlaying = true;
       });
    } on PlatformException {
      print("Error in plain text speech synthesis");
    }
  }

  Future<void> speakSSMLStory() async {
    try {
      await _flutterVocalizerPlugin.stop();
      await _flutterVocalizerPlugin.speakSSML(ssmlStory);
      setState(() {
        isPlaying = true;
      });
    } on PlatformException {
      print("Error in SSML story speech synthesis");
    }
  }

  Future<void> askPermission() async {
    String result = "";
    // Platform messages may fail, so we use a try/catch PlatformException.
    // We also handle the message potentially returning null.
    try {
      result = await _flutterVocalizerPlugin.requestPersonalVoiceAuthorization() ?? 'Unknown result';
      var context = scaffoldKey.currentContext;
      if(context != null) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(result)));
      }
    } on PlatformException {
      result = 'Failed to get permission.';
    }
  }

  @override
  void dispose() {
    _textController.dispose();
    _tabController.dispose();
    super.dispose();
  }
}
