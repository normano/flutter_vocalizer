import Flutter
import UIKit
import AVFoundation

public class PersonalVoiceFlutterPlugin: NSObject, FlutterPlugin, AVSpeechSynthesizerDelegate {
    
    let synthesizer = AVSpeechSynthesizer()
    var channel: FlutterMethodChannel?

    override init() {
      super.init()
      synthesizer.delegate = self
    }

    public static func register(with registrar: FlutterPluginRegistrar) {
      let channel = FlutterMethodChannel(name: "personal_voice_flutter", binaryMessenger: registrar.messenger())
      let instance = PersonalVoiceFlutterPlugin()
      instance.channel = channel
      registrar.addMethodCallDelegate(instance, channel: channel)
    }
    
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
//    NSLog("Received method call: \(call.method)")
//            NSLog("Arguments: \(String(describing: call.arguments))")
//
//            if let args = call.arguments as? [String: Any] {
//                for (key, value) in args {
//                    NSLog("Argument Key: \(key), Value: \(value), Type: \(type(of: value))")
//                }
//            } else {
//                NSLog("Arguments are not a dictionary")
//            }

        switch call.method {
        case "getPlatformVersion":
            result("iOS " + UIDevice.current.systemVersion)
        case "requestPersonalVoiceAuthorization":
            requestPersonalVoiceAuthorization(result: result)
        case "speak":
          if let args = call.arguments as? [String: Any] {
            let text = args["text"] as! String
            let volume = (args["volume"] as? NSNumber)?.floatValue ?? 0.5
            let pitch = (args["pitch"] as? NSNumber)?.floatValue ?? 1.0
            let rate = (args["rate"] as? NSNumber)?.floatValue ?? AVSpeechUtteranceDefaultSpeechRate
            speak(sentence: text, volume: volume, pitch: pitch, rate: rate)
            result(nil)
          }
          result(nil)
        case "stop":
          stop()
          result(nil)
        case "resume":
          resume()
          result(nil)
        case "pause":
          pause()
          result(nil)
        case "isSpeaking":
          result(self.synthesizer.isSpeaking)
        case "isPaused":
          result(self.synthesizer.isPaused)
        case "isSupported":
            result(isSupported())
        default:
          result(FlutterMethodNotImplemented)
        }
    }

    private func isSupported() -> Bool {

      if #available(iOS 17.0, *) {
        return true
      }

      return false
    }
    
    private func speak(sentence:String, volume: Float, pitch: Float, rate: Float) {
        if #available(iOS 17.0, *) {
          stop();
          let personalVoices = AVSpeechSynthesisVoice.speechVoices().filter { $0.voiceTraits.contains(.isPersonalVoice) }
          if let voice = personalVoices.first {
            let utterance = AVSpeechUtterance(string: sentence)
            utterance.voice = voice
            utterance.volume = volume
            utterance.pitchMultiplier = pitch
            utterance.rate = rate
            self.synthesizer.speak(utterance)
          }
        }
    }

    private func resume() {
        if #available(iOS 17.0, *) {
          if(self.synthesizer.isSpeaking || !self.synthesizer.isPaused) {
            return
          }
          self.synthesizer.continueSpeaking()
        }
    }

    private func pause() {
        if #available(iOS 17.0, *) {
          if(!self.synthesizer.isSpeaking || self.synthesizer.isPaused) {
            return
          }
          self.synthesizer.pauseSpeaking(at: .immediate)
        }
    }

    private func stop() {
        if #available(iOS 17.0, *) {
          if(!self.synthesizer.isSpeaking) {
            return
          }
          self.synthesizer.stopSpeaking(at: .immediate)
        }
    }
    
    private func requestPersonalVoiceAuthorization(result: @escaping FlutterResult) {
        if #available(iOS 17.0, *) {
            AVSpeechSynthesizer.requestPersonalVoiceAuthorization() { status in
                switch status {
                case .notDetermined:
                    result("notDetermined")
                case .denied:
                    result("denied")
                    /**
                     Personal voices are unsupported on this device.
                     */
                case .unsupported:
                    result("unsupported")
                    /**
                     The user granted your app's request to use personal voices.
                     */
                case .authorized:
                    result("authorized")
                default:
                    print("Default")
                }
            }
        } else {
            result("Must use iOS 17 or higher to use personal voice")
        }
    }

    // Delegate method to notify when speech is finished
    public func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
      channel?.invokeMethod("onSpeechCompleted", arguments: nil)
    }
}