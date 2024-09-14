import 'dart:io';

import 'package:personal_voice_flutter/personal_voice_flutter_method_channel.dart';

import 'personal_voice_flutter_platform_interface.dart';

class PersonalVoiceFlutter {

  static bool isInit = false;
  late final PersonalVoiceFlutterPlatform _platformInstance;

  PersonalVoiceFlutter() {

    if(Platform.isIOS || Platform.isMacOS) {

      if(!isInit) {
        PersonalVoiceFlutterPlatform.instance = PersonalVoiceFlutterMethodChannel();
        isInit = true;
      }
    }
    _platformInstance = PersonalVoiceFlutterPlatform.instance;
  }

  Future<String?> getPlatformVersion() {
    return _platformInstance.getPlatformVersion();
  }

  Future<String?> requestPersonalVoiceAuthorization() {
    return _platformInstance
        .requestPersonalVoiceAuthorization();
  }

  Future<void> speak(String sentence, {double volume = 0.5, double pitch = 1.0, double rate = 0.5}) {
    return _platformInstance.speak(sentence, volume: volume, pitch: pitch, rate: rate);
  }

  Future<void> stop() {
    return _platformInstance.stop();
  }

  Future<void> pause() {
    return _platformInstance.pause();
  }

  Future<void> resume() {
    return _platformInstance.resume();
  }

  Future<bool> isSpeaking() {
    return _platformInstance.isSpeaking();
  }

  Future<bool> isPaused() {
    return _platformInstance.isPaused();
  }

  Future<bool> isSupported() {
    return _platformInstance.isSupported();
  }

  void setOnSpeechComplete(void Function()? onCompleteFn) {
    _platformInstance.onSpeechComplete = onCompleteFn;
  }
}
