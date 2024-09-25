# Flutter Vocalizer

Vocalizer is a flutter plugin for TTS support for iOS and Android.
- Native Device TTS
- SSML Support
- Personal Voice (iOS 17+)

## Usage

Check example project for usage details.

### Personal Voice
You must first create a personal voice on your iPhone under 
Settings->Accessibility->Speech->Personal Voice

After you've created a personal voice you must make sure that
your phone is not in silent mode in order to hear the voice.

**Personal Voice Example**
```dart
import 'package:flutter_vocalizer/flutter_vocalizer.dart';

void main() async {
  var flutterVocalizer = FlutterVocalizer();
  
  var isSupported = await flutterVocalizer.isPersonalVoiceSupported();
  if(isSupported) {
    final permission =
    await flutterVocalizer.requestPersonalVoiceAuthorization();

    if (permission == "authorized") {
      await flutterVocalizer.speak("A sentence using my voice!");
    }
  }
}
```

## Known Issues

### iOS (Carry overs from ancestor project)
- Phone must not be in silent mode. 
- Crashes on iOS 17.0 to 17.0.2
- The phone must not be set to silent or the personal voice will not play.