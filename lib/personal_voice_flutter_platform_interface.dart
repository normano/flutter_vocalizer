import 'package:plugin_platform_interface/plugin_platform_interface.dart';

abstract class PersonalVoiceFlutterPlatform extends PlatformInterface {

  void Function()? onSpeechComplete;

  /// Constructs a PersonalVoiceFlutterPlatform.
  PersonalVoiceFlutterPlatform() : super(token: _token);

  static final Object _token = Object();

  static PersonalVoiceFlutterPlatform _instance =
  _DefaultPersonalVoiceFlutter();

  /// The default instance of [PersonalVoiceFlutterPlatform] to use.
  ///
  /// Defaults to [PersonalVoiceFlutterIOS].
  static PersonalVoiceFlutterPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [PersonalVoiceFlutterPlatform] when
  /// they register themselves.
  static set instance(PersonalVoiceFlutterPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getPlatformVersion();
  Future<String?> requestPersonalVoiceAuthorization();
  Future<void> speak(String text, {double volume = 0.5, double pitch = 1.0, double rate = 0.5});
  Future<void> stop();
  Future<void> resume();
  Future<void> pause();
  Future<bool> isSpeaking();
  Future<bool> isPaused();
  Future<bool> isSupported();
}

class _DefaultPersonalVoiceFlutter extends PersonalVoiceFlutterPlatform {

  @override
  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }

  @override
  Future<String?> requestPersonalVoiceAuthorization() {
    throw UnimplementedError(
        'requestPersonalVoiceAuthorization() has not been implemented.');
  }

  @override
  Future<void> speak(String text, {double volume = 0.5, double pitch = 1.0, double rate = 0.5}) {
    throw UnimplementedError(
        'speak(String sentence) has not been implemented.');
  }

  @override
  Future<void> stop() {
    throw UnimplementedError(
        'stop() has not been implemented.');
  }

  @override
  Future<void> resume() {
    throw UnimplementedError(
        'continueSpeaking() has not been implemented.');
  }

  @override
  Future<void> pause() {
    throw UnimplementedError(
        'pauseSpeaking() has not been implemented.');
  }

  @override
  Future<bool> isSpeaking() async {
    return false;
  }

  @override
  Future<bool> isPaused() async {
    return false;
  }

  @override
  Future<bool> isSupported() async {
    return false;
  }
}