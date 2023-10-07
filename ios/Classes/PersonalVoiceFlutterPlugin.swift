import Flutter
import UIKit
import AVFoundation

public class PersonalVoiceFlutterPlugin: NSObject, FlutterPlugin {
    
    let synthesizer = AVSpeechSynthesizer()
    
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "personal_voice_flutter", binaryMessenger: registrar.messenger())
        let instance = PersonalVoiceFlutterPlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
    }
    
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "getPlatformVersion":
            result("iOS " + UIDevice.current.systemVersion)
        case "requestPersonalVoiceAuthorization":
            requestPersonalVoiceAuthorization(result: result)
        case "speak":
            if let args = call.arguments as? [String: Any],
               let sentence = args["sentence"] as? String {
                // Handle yourString here
                speak(sentence: sentence)
            } else {
                result("Invalid argument")
            }
        default:
            result(FlutterMethodNotImplemented)
        }
    }
    
    private func speak(sentence:String) {
        if #available(iOS 17.0, *) {
            let personalVoices = AVSpeechSynthesisVoice.speechVoices().filter { $0.voiceTraits.contains(.isPersonalVoice) }
            let utterance2 = AVSpeechUtterance(string: sentence)
            if let voice = personalVoices.first {
                utterance2.voice = voice
                self.synthesizer.speak(utterance2)
            }
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
    
}
