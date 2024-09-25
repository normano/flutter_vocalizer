# flutter_vocalizer

This Flutter plugin provides an API for accessing Personal Voice on iOS.

## Usage

This plugin only works on iOS 17 or later. 

You must first create a personal voice on your iPhone under 
Settings->Accessibility->Speech->Personal Voice

After you've created a personal voice you must make sure that
your phone is not in silent mode in order to hear the voice.


```dart
import 'package:flutter_vocalizer/flutter_vocalizer.dart';

...

final permission =
        await _flutterVocalizerPlugin.requestPersonalVoiceAuthorization();

if(permission == "authorized") {
    await _flutterVocalizerPlugin.speak("A sentence using my voice!");
}
```

## Known Issues

### iOS
- Phone must not be in silent mode. 
- Crashes on iOS 17.0 to 17.0.2
- The phone must not be set to silent or the personal voice will not play.