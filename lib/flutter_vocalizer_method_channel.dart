import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_vocalizer/model.dart';

import 'flutter_vocalizer_platform_interface.dart';

/// An implementation of [FlutterVocalizerPlatform] that uses method channels.
class FlutterVocalizerMethodChannel extends FlutterVocalizerPlatform {

  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('flutter_vocalizer');

  FlutterVocalizerMethodChannel() {
    methodChannel.setMethodCallHandler(_methodCallHandler);
  }

  Future<void> _methodCallHandler(MethodCall call) async {
    switch (call.method) {
      case 'onSpeechCompleted':
        if(onSpeechComplete != null) {
          onSpeechComplete!();
        }
        break;
      default:
        // print('Unknown method ${call.method}');
    }
  }

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
  Future<void> speakSSML(String ssml, {double volume = 0.5, double pitch = 1.0, double rate = 0.5}) async {

    await methodChannel.invokeMethod(
      'speakSSML',
      {
        "ssml": ssml,
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
  Future<bool> isPersonalVoiceSupported() async {
    final bool isSupported = await methodChannel.invokeMethod('isPersonalVoiceSupported');
    return isSupported;
  }

  @override
  Future<List<String>?> getLanguages() async {
    final List<String>? languages = await methodChannel.invokeListMethod('getLanguages');
    return languages;
  }

  @override
  Future<dynamic> setLanguage(String language) async {
    return await methodChannel.invokeMethod('setLanguage', language);
  }

  @override
  Future<List<TTSVoice>?> getVoices() async {
    final voices = (await methodChannel.invokeListMethod<Map<Object?, Object?>>(
      'getVoices'
    ))?.map((voice) => TTSVoice.fromMap(voice)).toList() ?? [];
    return voices;
  }

  @override
  Future<dynamic> setVoice(Map<String, String> voice) async {
    return await methodChannel.invokeMethod('setVoice', voice);
  }

  @override
  Future<void> clearVoice() async {
    await methodChannel.invokeMethod('clearVoice');
  }

  @override
  Future<int?> getMaxSpeechInputLength() async {
    return await methodChannel.invokeMethod<int?>('getMaxSpeechInputLength');
  }
}
