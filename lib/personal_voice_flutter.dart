import 'personal_voice_flutter_platform_interface.dart';

class PersonalVoiceFlutter {
  Future<String?> getPlatformVersion() {
    return PersonalVoiceFlutterPlatform.instance.getPlatformVersion();
  }

  Future<String?> requestPersonalVoiceAuthorization() {
    return PersonalVoiceFlutterPlatform.instance
        .requestPersonalVoiceAuthorization();
  }

  Future<void> speak(String sentence) {
    return PersonalVoiceFlutterPlatform.instance.speak(sentence);
  }
}
