import 'dart:io';

import 'package:flutter_vocalizer/flutter_vocalizer_method_channel.dart';
import 'package:flutter_vocalizer/model.dart';

import 'flutter_vocalizer_platform_interface.dart';

class FlutterVocalizer {

  static bool isInit = false;
  late final FlutterVocalizerPlatform _platformInstance;

  FlutterVocalizer() {

    if(Platform.isIOS || Platform.isMacOS || Platform.isAndroid) {

      if(!isInit) {
        FlutterVocalizerPlatform.instance = FlutterVocalizerMethodChannel();
        isInit = true;
      }
    }
    _platformInstance = FlutterVocalizerPlatform.instance;
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

  Future<void> speakSSML(String ssml, {double volume = 0.5, double pitch = 1.0, double rate = 0.5}) async {
    return _platformInstance.speakSSML(ssml);
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

  Future<bool> isPersonalVoiceSupported() {
    return _platformInstance.isPersonalVoiceSupported();
  }

  Future<List<String>?> getLanguages() {
    return _platformInstance.getLanguages();
  }

  Future<dynamic> setLanguage(String language) {
    return _platformInstance.setLanguage(language);
  }

  Future<List<TTSVoice>?> getVoices() {
    return _platformInstance.getVoices();
  }

  Future<dynamic> setVoice(TTSVoice voice) {
    return _platformInstance.setVoice(voice.asVoiceMap());
  }

  Future<void> resetVoice() {
    return _platformInstance.clearVoice();
  }

  Future<int?> getMaxSpeechInputLength() {
    return _platformInstance.getMaxSpeechInputLength();
  }

  void setOnSpeechComplete(void Function()? onCompleteFn) {
    _platformInstance.onSpeechComplete = onCompleteFn;
  }
}
