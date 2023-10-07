import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'personal_voice_flutter_platform_interface.dart';

/// An implementation of [PersonalVoiceFlutterPlatform] that uses method channels.
class MethodChannelPersonalVoiceFlutter extends PersonalVoiceFlutterPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('personal_voice_flutter');

  @override
  Future<String?> getPlatformVersion() async {
    final version = await methodChannel.invokeMethod<String>('getPlatformVersion');
    return version;
  }
}
