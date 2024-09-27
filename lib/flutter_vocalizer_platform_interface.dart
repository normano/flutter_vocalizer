import 'package:flutter_vocalizer/model.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

abstract class FlutterVocalizerPlatform extends PlatformInterface {

  void Function()? onSpeechComplete;

  /// Constructs a FlutterVocalizerPlatform.
  FlutterVocalizerPlatform() : super(token: _token);

  static final Object _token = Object();

  static FlutterVocalizerPlatform _instance =
  _DefaultFlutterVocalizer();

  /// The default instance of [FlutterVocalizerPlatform] to use.
  ///
  /// Defaults to [FlutterVocalizerIOS].
  static FlutterVocalizerPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [FlutterVocalizerPlatform] when
  /// they register themselves.
  static set instance(FlutterVocalizerPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getPlatformVersion();
  Future<String?> requestPersonalVoiceAuthorization();
  Future<void> speak(String text, {double volume = 0.5, double pitch = 1.0, double rate = 0.5});
  Future<void> speakSSML(String ssml, {double volume = 0.5, double pitch = 1.0, double rate = 0.5});
  Future<void> stop(bool immediate);
  Future<void> resume();
  Future<void> pause(bool immediate);
  Future<bool> isSpeaking();
  Future<bool> isPaused();
  Future<bool> isPersonalVoiceSupported();
  Future<List<String>?> getLanguages();
  Future<dynamic> setLanguage(String language);
  Future<List<TTSVoice>?> getVoices();
  Future<dynamic> setVoice(Map<String, String> voice);
  Future<void> clearVoice();
  Future<int?> getMaxSpeechInputLength();
}

class _DefaultFlutterVocalizer extends FlutterVocalizerPlatform {

  @override
  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }

  @override
  Future<String?> requestPersonalVoiceAuthorization() {
    throw UnimplementedError('requestPersonalVoiceAuthorization() has not been implemented.');
  }

  @override
  Future<void> speak(String text, {double volume = 0.5, double pitch = 1.0, double rate = 0.5}) {
    throw UnimplementedError('speak() has not been implemented.');
  }

  @override
  Future<void> speakSSML(String ssml, {double volume = 0.5, double pitch = 1.0, double rate = 0.5}) {
    throw UnimplementedError('speakSSML() has not been implemented.');
  }

  @override
  Future<void> stop(bool immediate) {
    throw UnimplementedError('stop() has not been implemented.');
  }

  @override
  Future<void> resume() {
    throw UnimplementedError('continueSpeaking() has not been implemented.');
  }

  @override
  Future<void> pause(bool immediate) {
    throw UnimplementedError('pauseSpeaking() has not been implemented.');
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
  Future<bool> isPersonalVoiceSupported() async {
    return false;
  }

  @override
  Future<List<String>> getLanguages() {
    throw UnimplementedError();
  }

  @override
  Future<List<TTSVoice>?> getVoices() {
    throw UnimplementedError();
  }

  @override
  Future setLanguage(String language) {
    throw UnimplementedError();
  }

  @override
  Future setVoice(Map<String, String> voice) {
    throw UnimplementedError();
  }

  @override
  Future<void> clearVoice() {
    throw UnimplementedError();
  }

  @override
  Future<int?> getMaxSpeechInputLength() async {
    return null;
  }
}