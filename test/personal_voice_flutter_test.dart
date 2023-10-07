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
