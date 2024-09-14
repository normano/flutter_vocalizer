import Flutter
import Foundation
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

    private func isSupported() -> Bool {
      return isPersonalVoiceFeatureSupported();
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
// Function to check for supported device models on iOS
func isSupportedDeviceOnIOS() -> Bool {
    let modelIdentifier = getDeviceModelIdentifier()

    // Check for iPhone 12 or later
    if modelIdentifier.hasPrefix("iPhone") {
        if let modelNumber = Int(modelIdentifier.split(separator: ",")[0].dropFirst(6)) {
            return modelNumber >= 13 // iPhone 12 has identifier iPhone13,1 and up
        }
    }

    // Check for iPad Air 5th gen or later, iPad Pro 11-inch 3rd gen or later, iPad Pro 12.9-inch 5th gen or later
    if modelIdentifier == "iPad13,16" || modelIdentifier == "iPad13,17" || // iPad Air 5th gen
       modelIdentifier.hasPrefix("iPad8,") && Int(modelIdentifier.split(separator: ",")[1])! >= 11 || // iPad Pro 11-inch 3rd gen
       modelIdentifier.hasPrefix("iPad8,") && Int(modelIdentifier.split(separator: ",")[1])! >= 9 { // iPad Pro 12.9-inch 5th gen
        return true
    }

    return false
}

// Function to check for supported device models on macOS
func isSupportedDeviceOnMac() -> Bool {
    #if targetEnvironment(macCatalyst)
    if ProcessInfo.processInfo.isiOSAppOnMac || ProcessInfo.processInfo.isMacCatalystApp {
        if let arch = NXGetLocalArchInfo()?.pointee.cputype, arch == CPU_TYPE_ARM64 {
            return true // Mac with Apple Silicon
        }
    }
    #endif

    return false
}

// Helper function to get device model identifier (e.g., "iPhone13,1" for iPhone 12)
func getDeviceModelIdentifier() -> String {
    var systemInfo = utsname()
    uname(&systemInfo)
    return String(bytes: Data(bytes: &systemInfo.machine, count: Int(_SYS_NAMELEN)), encoding: .ascii)!.trimmingCharacters(in: .controlCharacters)
}

// Main function to check if the device supports the required features
func isPersonalVoiceFeatureSupported() -> Bool {
    if #available(iOS 17, *) {
        return isSupportedDeviceOnIOS()
    } else if #available(macOS 14, *) {
        return isSupportedDeviceOnMac()
    }
    return false
}