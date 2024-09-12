import 'package:flutter_test/flutter_test.dart';
import 'package:personal_voice_flutter/personal_voice_flutter.dart';
import 'package:personal_voice_flutter/personal_voice_flutter_platform_interface.dart';
import 'package:personal_voice_flutter/personal_voice_flutter_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockPersonalVoiceFlutterPlatform
    with MockPlatformInterfaceMixin
    implements PersonalVoiceFlutterPlatform {

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
  Future<bool> isSupported() {
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
}

void main() {
  final PersonalVoiceFlutterPlatform initialPlatform = PersonalVoiceFlutterPlatform.instance;

  test('$MethodChannelPersonalVoiceFlutter is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelPersonalVoiceFlutter>());
  });

  test('getPlatformVersion', () async {
    PersonalVoiceFlutter personalVoiceFlutterPlugin = PersonalVoiceFlutter();
    MockPersonalVoiceFlutterPlatform fakePlatform = MockPersonalVoiceFlutterPlatform();
    PersonalVoiceFlutterPlatform.instance = fakePlatform;

    expect(await personalVoiceFlutterPlugin.getPlatformVersion(), '42');
  });
}
