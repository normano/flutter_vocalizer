import AVFoundation
import Flutter

class TTSManager: NSObject, AVSpeechSynthesizerDelegate {
  private var synthesizer: AVSpeechSynthesizer
  private var currentVoice: AVSpeechSynthesisVoice?
  var onSpeechCompletion: (() -> Void)?
  var language: String = AVSpeechSynthesisVoice.currentLanguageCode()
  var languages = Set<String>()

  override init() {
    self.synthesizer = AVSpeechSynthesizer()
    super.init()
    self.synthesizer.delegate = self
    refreshLanguages()
  }

  private func refreshLanguages() {
    self.languages.removeAll()
    for voice in AVSpeechSynthesisVoice.speechVoices() {
      self.languages.insert(voice.language)
    }
  }

  func speak(text: String, volume: Float, pitch: Float, rate: Float) {
    let utterance = AVSpeechUtterance(string: text)
    utterance.volume = volume
    utterance.pitchMultiplier = pitch
    utterance.rate = rate
    utterance.voice = currentVoice ?? AVSpeechSynthesisVoice(language: self.language)
    synthesizer.speak(utterance)
  }

  func speakSSML(ssml: String, volume: Float, pitch: Float, rate: Float) {
    if #available(iOS 16.0, *) {
      if let utterance = AVSpeechUtterance(ssmlRepresentation: ssml) {
        utterance.volume = volume
        utterance.pitchMultiplier = pitch
        utterance.rate = rate
        utterance.voice = currentVoice ?? AVSpeechSynthesisVoice(language: self.language)
        synthesizer.speak(utterance)
      }
    } else {
      self.speak(text: ssml, volume: volume, pitch: pitch, rate: rate)
    }
  }

  func stop() {
    synthesizer.stopSpeaking(at: .immediate)
  }

  func pause() {
    synthesizer.pauseSpeaking(at: .immediate)
  }

  func resume() {
    synthesizer.continueSpeaking()
  }

  var isSpeaking: Bool {
    return synthesizer.isSpeaking
  }

  var isPaused: Bool {
    return synthesizer.isPaused
  }

  func getLanguages(result: FlutterResult) {
    result(Array(self.languages))
  }

  func setLanguage(language: String) -> Int {
    if !(self.languages.contains(where: {$0.range(of: language, options: [.caseInsensitive, .anchored]) != nil})) {
      return 0
    }

    self.language = language
    return 1
  }

  func getVoices(result: FlutterResult) {
    if #available(iOS 9.0, *) {
      var voices: [[String: String]] = []

      for voice in AVSpeechSynthesisVoice.speechVoices() {
        var isPersonalVoice = false

        if #available(iOS 17.0, *) {
          isPersonalVoice = voice.voiceTraits.contains(.isPersonalVoice)
        }

        var voiceDict: [String: String] = [
          "name": voice.name,
          "locale": voice.language,
          "quality": String(describing: voice.quality.rawValue),
          "identifier": voice.identifier,
          "isPersonalVoice": isPersonalVoice ? "true" : "false",
        ]

        if #available(iOS 13.0, *) {
          let gender = voice.gender == AVSpeechSynthesisVoiceGender.female ? "female"
                      : voice.gender == AVSpeechSynthesisVoiceGender.male ? "male" : "unspecified"
          voiceDict["gender"] = gender
        } else {
          voiceDict["gender"] = "unknown"
        }

        voices.append(voiceDict)
      }

      result(voices)
    } else {
      // Fallback for older iOS versions
      getLanguages(result: result)
    }
  }

  func setVoice(voice: [String: String]) -> Int {
    if #available(iOS 9.0, *) {
      if let selectedVoice = AVSpeechSynthesisVoice.speechVoices().first(where: {
          $0.name == voice["name"] && $0.language == voice["locale"]
      }) {
        self.currentVoice = selectedVoice
        return 1 // Success
      } else {
        return 0 // Failure, voice not found
      }
    } else {
      return setLanguage(language: voice["locale"]!)
    }
  }

  func clearVoice() {
    self.currentVoice = nil
  }

  func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
    onSpeechCompletion?()
  }
}
