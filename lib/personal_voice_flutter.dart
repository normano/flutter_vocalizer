import 'personal_voice_flutter_platform_interface.dart';

class PersonalVoiceFlutter {
  Future<String?> getPlatformVersion() {
    return PersonalVoiceFlutterPlatform.instance.getPlatformVersion();
  }

  Future<String?> requestPersonalVoiceAuthorization() {
    return PersonalVoiceFlutterPlatform.instance
        .requestPersonalVoiceAuthorization();
  }

  Future<void> speak(String sentence, {double volume = 0.5, double pitch = 1.0, double rate = 0.5}) {
    return PersonalVoiceFlutterPlatform.instance.speak(sentence, volume: volume, pitch: pitch, rate: rate);
  }

  Future<void> stop() {
    return PersonalVoiceFlutterPlatform.instance.stop();
  }

  Future<void> pause() {
    return PersonalVoiceFlutterPlatform.instance.pause();
  }

  Future<void> resume() {
    return PersonalVoiceFlutterPlatform.instance.resume();
  }

  Future<bool> isSpeaking() {
    return PersonalVoiceFlutterPlatform.instance.isSpeaking();
  }

  Future<bool> isPaused() {
    return PersonalVoiceFlutterPlatform.instance.isPaused();
  }

  Future<bool> isSupported() {
    return PersonalVoiceFlutterPlatform.instance.isSupported();
  }
}
