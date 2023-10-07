import Flutter
import UIKit
import AVFoundation

public class PersonalVoiceFlutterPlugin: NSObject, FlutterPlugin {
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
        default:
            result(FlutterMethodNotImplemented)
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
