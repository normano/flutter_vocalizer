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

  override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPluginBinding) {
    channel = MethodChannel(flutterPluginBinding.getBinaryMessenger(), "flutter_vocalizer")
    channel.setMethodCallHandler(this)
    ttsManager = TTSManager(flutterPluginBinding.getApplicationContext(), channel)
  }

  override fun onMethodCall(call: MethodCall, result: Result) {
    when (call.method) {
      "speak" -> {
        val text: String = call.argument("text")
        ttsManager.speak(text)
        result.success(null)
      }

      "speakSSML" -> {
        val ssml: String = call.argument("ssml")
        ttsManager.speakSSML(text)
        result.success(null)
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

      "getPlatformVersion" -> {
        result.success("Android ${android.os.Build.VERSION.RELEASE}")
      }


      "requestPersonalVoiceAuthorization" -> {
        result("unsupported")
      }

      else -> result.notImplemented()
    }
  }

  override fun onDetachedFromEngine(@NonNull binding: FlutterPluginBinding?) {
    channel.setMethodCallHandler(null)
    ttsManager.shutdown()
  }
}
