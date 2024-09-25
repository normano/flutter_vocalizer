/// {@template tts_voice}
/// Represents a wapper around Android's Voice class and
/// Swift's AVSpeechSynthesisVoice class.
///
/// It exposes basic information about the underlying classes like the name,
/// locale and gender of the synthetic voice.
///
/// {@endtemplate}
class TTSVoice {

  final String name;
  final String locale;
  final String quality;
  final String identifier;
  final bool isPersonalVoice;
  final TTSVoiceGender gender;
  
  /// {@macro tts_voice}
  const TTSVoice({
    required this.name,
    required this.locale,
    required this.quality,
    required this.identifier,
    required this.isPersonalVoice,
    required this.gender,
  });

  TTSVoice.fromMap(Map map)
      : name = map['name']!.toString(),
        locale = map['locale']!.toString(),
        quality = map['quality']!.toString(),
        identifier = map['identifier']!.toString(),
        isPersonalVoice = map['isPersonalVoice']!.toString() == "true",
        gender = TTSVoiceGenderFromString.fromString(
          map['gender']!.toString(),
        );

  Map<String, String> asVoiceMap() => {
    'name': name,
    'locale': locale,
  };
}

enum TTSVoiceGender {
  male,
  female,
  unknown,
}

extension TTSVoiceGenderFromString on TTSVoiceGender {
  static TTSVoiceGender fromString(String value) {
    switch (value) {
      case "female":
        return TTSVoiceGender.female;

      case "male":
        return TTSVoiceGender.male;

      default:
        return TTSVoiceGender.unknown;
    }
  }

  bool get isMale => this == TTSVoiceGender.male;
  bool get isFemale => this == TTSVoiceGender.female;
  bool get isUnknownGender => this == TTSVoiceGender.unknown;
}