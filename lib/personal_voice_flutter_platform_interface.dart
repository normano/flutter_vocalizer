import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'personal_voice_flutter_method_channel.dart';

abstract class PersonalVoiceFlutterPlatform extends PlatformInterface {
  /// Constructs a PersonalVoiceFlutterPlatform.
  PersonalVoiceFlutterPlatform() : super(token: _token);

  static final Object _token = Object();

  static PersonalVoiceFlutterPlatform _instance =
      MethodChannelPersonalVoiceFlutter();

  /// The default instance of [PersonalVoiceFlutterPlatform] to use.
  ///
  /// Defaults to [MethodChannelPersonalVoiceFlutter].
  static PersonalVoiceFlutterPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [PersonalVoiceFlutterPlatform] when
  /// they register themselves.
  static set instance(PersonalVoiceFlutterPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }

  Future<String?> requestPersonalVoiceAuthorization() {
    throw UnimplementedError(
        'requestPersonalVoiceAuthorization() has not been implemented.');
  }

  Future<void> speak(String text, {double volume = 0.5, double pitch = 1.0, double rate = 0.5}) {
    throw UnimplementedError(
        'speak(String sentence) has not been implemented.');
  }

  Future<void> stop() {
    throw UnimplementedError(
        'stop() has not been implemented.');
  }

  Future<void> resume() {
    throw UnimplementedError(
        'continueSpeaking() has not been implemented.');
  }

  Future<void> pause() {
    throw UnimplementedError(
        'pauseSpeaking() has not been implemented.');
  }

  Future<bool> isSpeaking() async {
    return false;
  }

  Future<bool> isPaused() async {
    return false;
  }

  Future<bool> isSupported() async {
    return false;
  }
}
