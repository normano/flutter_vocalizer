package com.excsn.flutter_vocalizer

import android.os.Bundle;
import androidx.annotation.NonNull;

import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result

/** FlutterVocalizerPlugin */
class FlutterVocalizerPlugin: FlutterPlugin, MethodCallHandler {

  private lateinit var channel : MethodChannel
  private lateinit var ttsManager: TTSManager

  override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
    channel = MethodChannel(flutterPluginBinding.getBinaryMessenger(), "flutter_vocalizer")
    channel.setMethodCallHandler(this)
    ttsManager = TTSManager(flutterPluginBinding.getApplicationContext(), channel)
  }

  override fun onMethodCall(call: MethodCall, result: Result) {
    when (call.method) {
      "speak" -> {
        val text: String? = call.argument("text")
        val rate: Float = (call.argument("rate") ?: 0.5).toFloat() * 2.0f
        val volume: Float = (call.argument("volume") as? Double)?.toFloat() ?: 1.0f
        val pitch: Float = (call.argument("pitch") as? Double)?.toFloat() ?: 1.0f

        if(text != null) {
          ttsManager.speak(text, volume, rate, pitch)
          result.success(1)
        } else {
          result.success(0)
        }
      }

      "speakSSML" -> {
        val ssmlText: String? = call.argument("ssml")
        val rate: Float = (call.argument("rate") ?: 0.5).toFloat() * 2.0f
        val volume: Float = (call.argument("volume") as? Double)?.toFloat() ?: 1.0f
        val pitch: Float = (call.argument("pitch") as? Double)?.toFloat() ?: 1.0f

        if(ssmlText != null) {
          ttsManager.speakSSML(ssmlText, volume, rate, pitch)
          result.success(1)
        } else {
          result.success(0)
        }
      }

      "pause" -> {
        ttsManager.pause()
        result.success(null)
      }

      "resume" -> {
        ttsManager.resume()
        result.success(null)
      }

      "stop" -> {
        ttsManager.stop()
        result.success(null)
      }

      "isSpeaking" -> {
        result.success(ttsManager.isSpeaking())
      }

      "isPaused" -> {
        result.success(ttsManager.isPaused())
      }

      "getLanguages" -> {
        result.success(ttsManager.getLanguages())
      }

      "setLanguage" -> {
        val language: String = call.arguments.toString()
        result.success(ttsManager.setLanguage(language))
      }

      "getVoices" -> {
        result.success(ttsManager.getVoices())
      }

      "setVoice" -> {
        val voice: HashMap<String, String>? = call.arguments()
        result.success(ttsManager.setVoice(voice))
      }

      "clearVoice" -> {
        ttsManager.clearVoice()
        result.success(true)
      }

      "requestPersonalVoiceAuthorization" -> {
        result.error("UNSUPPORTED", "Personal Voice Is not Available", null)
      }

      "isPersonalVoiceSupported" -> {
        result.success(false)
      }

      "getMaxSpeechInputLength" -> {
        val res = ttsManager.maxSpeechInputLength
        result.success(res)
      }

      "getPlatformVersion" -> {
        result.success("Android ${android.os.Build.VERSION.RELEASE}")
      }

      else -> result.notImplemented()
    }
  }

  override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
    channel.setMethodCallHandler(null)
    ttsManager.shutdown()
  }
}
