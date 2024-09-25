import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_vocalizer/flutter_vocalizer.dart';
import 'package:flutter_vocalizer/flutter_vocalizer_method_channel.dart';
import 'package:flutter_vocalizer/flutter_vocalizer_platform_interface.dart';
import 'package:flutter_vocalizer/model.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockFlutterVocalizerPlatform
    with MockPlatformInterfaceMixin
    implements FlutterVocalizerPlatform {

  @override
  Future<String?> getPlatformVersion() => Future.value('42');

  @override
  Future<String?> requestPersonalVoiceAuthorization() {
    // TODO: implement requestPersonalVoiceAuthorization
    throw UnimplementedError();
  }
  @override
  Future<bool> isPaused() {
    // TODO: implement isPaused
    throw UnimplementedError();
  }

  @override
  Future<bool> isSpeaking() {
    // TODO: implement isSpeaking
    throw UnimplementedError();
  }

  @override
  Future<bool> isPersonalVoiceSupported() {
    // TODO: implement isSupported
    throw UnimplementedError();
  }

  @override
  Future<void> pause() {
    // TODO: implement pause
    throw UnimplementedError();
  }

  @override
  Future<void> resume() {
    // TODO: implement resume
    throw UnimplementedError();
  }

  @override
  Future<void> stop() {
    // TODO: implement stop
    throw UnimplementedError();
  }

  @override
  Future<void> speak(String text, {double volume = 1.0, double pitch = 1.0, double rate = 0.5}) {
    // TODO: implement speak
    throw UnimplementedError();
  }

  @override
  void Function()? onSpeechComplete;

  @override
  Future<void> speakSSML(String ssml, {double volume = 0.5, double pitch = 1.0, double rate = 0.5}) {
    // TODO: implement speakSSML
    throw UnimplementedError();
  }

  @override
  Future<List<String>> getLanguages() {
    // TODO: implement getLanguages
    throw UnimplementedError();
  }

  @override
  Future<List<TTSVoice>?> getVoices() {
    // TODO: implement getVoices
    throw UnimplementedError();
  }

  @override
  Future setLanguage(String language) {
    // TODO: implement setLanguage
    throw UnimplementedError();
  }

  @override
  Future setVoice(Map<String, String> voice) {
    // TODO: implement setVoice
    throw UnimplementedError();
  }

  @override
  Future<int?> getMaxSpeechInputLength() {
    // TODO: implement getMaxSpeechInputLength
    throw UnimplementedError();
  }

  @override
  Future<void> clearVoice() {
    // TODO: implement clearVoice
    throw UnimplementedError();
  }
}

void main() {
  final FlutterVocalizerPlatform initialPlatform = FlutterVocalizerPlatform.instance;

  test('$FlutterVocalizerMethodChannel is the default instance', () {
    expect(initialPlatform, isInstanceOf<FlutterVocalizerMethodChannel>());
  });

  test('getPlatformVersion', () async {
    FlutterVocalizer flutterVocalizerPlugin = FlutterVocalizer();
    MockFlutterVocalizerPlatform fakePlatform = MockFlutterVocalizerPlatform();
    FlutterVocalizerPlatform.instance = fakePlatform;

    expect(await flutterVocalizerPlugin.getPlatformVersion(), '42');
  });
}
