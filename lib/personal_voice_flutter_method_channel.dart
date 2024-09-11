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
    final version =
        await methodChannel.invokeMethod<String>('getPlatformVersion');
    return version;
  }

  @override
  Future<String?> requestPersonalVoiceAuthorization() async {
    final result = await methodChannel
        .invokeMethod<String>('requestPersonalVoiceAuthorization');
    return result;
  }

  @override
  Future<void> speak(String text, {double volume = 0.5, double pitch = 1.0, double rate = 0.5}) async {
    await methodChannel.invokeMethod(
      'speak',
      {
        'text': text,
        'volume': volume,
        'pitch': pitch,
        'rate': rate,
      }
    );
  }

  @override
  Future<void> stop() async {
    await methodChannel.invokeMethod('stop');
  }

  @override
  Future<void> resume() async {
    await methodChannel.invokeMethod('resume');
  }

  @override
  Future<void> pause() async {
    await methodChannel.invokeMethod('pause');
  }

  @override
  Future<bool> isSpeaking() async {
    return await methodChannel.invokeMethod('isSpeaking');
  }

  @override
  Future<bool> isPaused() async {
    return await methodChannel.invokeMethod('isPaused');
  }

  @override
  Future<bool> isSupported() async {
    final bool isSupported = await methodChannel.invokeMethod('isSupported');
    return isSupported;
  }
}
