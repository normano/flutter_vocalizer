package com.excsn.flutter_vocalizer

import android.content.Context
import android.os.Build
import android.os.Bundle
import android.speech.tts.TextToSpeech
import android.speech.tts.UtteranceProgressListener
import android.speech.tts.Voice
import android.util.Log
import io.flutter.plugin.common.MethodChannel

import java.io.StringReader
import java.util.*

import org.xmlpull.v1.XmlPullParser
import org.xmlpull.v1.XmlPullParserFactory

class TTSManager(
  private val context: Context,
  private val methodChannel: MethodChannel
) : TextToSpeech.OnInitListener {
  private var tts: TextToSpeech
  private var actionQueue: TTSActionQueue
  private val tag = "TTS"
  private val defaultPause = 500L;

  val mainHandler = android.os.Handler(context.mainLooper)
  val maxSpeechInputLength: Int = TextToSpeech.getMaxSpeechInputLength()

  var currentLanguage: Locale = Locale.getDefault()
  var currentVoice: String? = null

  init {
    this.tts = TextToSpeech(context, this)
    this.actionQueue = TTSActionQueue(tts)
  }

  override fun onInit(status: Int) {
    if (status == TextToSpeech.SUCCESS) {
      val result = tts.setLanguage(Locale.US)  // Default language to US English
      if (result == TextToSpeech.LANG_MISSING_DATA || result == TextToSpeech.LANG_NOT_SUPPORTED) {
        Log.e("TTSManager", "Language not supported!")
      }
      setTTSListeners()
      Log.i("TTSManager", "Initialized successfully")
    } else {
      Log.e("TTSManager", "Initialization failed!")
    }
  }

  private fun setTTSListeners() {
    tts.setOnUtteranceProgressListener(object : UtteranceProgressListener() {
      override fun onStart(utteranceId: String?) {
        mainHandler.post {
          methodChannel.invokeMethod("onSpeechStart", utteranceId)
        }
      }

      override fun onDone(utteranceId: String?) {
        mainHandler.post {
          actionQueue.playNextAction()
          if (!actionQueue.hasPendingActions()) {
            methodChannel.invokeMethod("onSpeechCompleted", utteranceId)
          }
        }
      }

      override fun onError(utteranceId: String?) {
        mainHandler.post {
          methodChannel.invokeMethod("onSpeechError", utteranceId)
        }
      }
    })
  }

  fun clearVoice() {
    tts.voice = tts.defaultVoice
  }

  fun speak(text: String, volume: Float, rate: Float, pitch: Float) {
    if (text.length > maxSpeechInputLength) {
      val textChunks = splitTextByNaturalBoundaries(text, maxSpeechInputLength)
      for (chunk in textChunks) {
        submitSpeakAction(chunk, volume, rate, pitch);
      }
    } else {
      submitSpeakAction(text, volume, rate, pitch);
    }

    actionQueue.startQueue()
  }

  fun speakSSML(ssml: String, volume: Float, rate: Float, pitch: Float) {
    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
      speak(ssml, volume, rate, pitch);
    } else {
      parseSSMLAndQueueActions(actionQueue, ssml, volume, rate, pitch)
    }
    actionQueue.startQueue()
  }

  fun stop() {
    actionQueue.stopQueue()
  }

  fun pause() {
    actionQueue.pauseQueue()
  }

  fun resume() {
    actionQueue.resumeQueue()
  }

  fun shutdown() {
    Log.e("TTSManager", "Shutting down")
    tts.shutdown()
  }

  fun isSpeaking(): Boolean {
    return tts.isSpeaking ?: false
  }

  fun isPaused(): Boolean {
    return actionQueue.isPaused()
  }

  fun getLanguages(): List<String> {
    val locales = mutableListOf<String>()
    try {
      if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
        // While this method was introduced in API level 21, it seems that it
        // has not been implemented in the speech service side until API Level 23.
        for (locale in tts.availableLanguages) {
          locales.add(locale.toLanguageTag())
        }
      } else {
        for (locale in Locale.getAvailableLocales()) {
          if (locale.variant.isEmpty() && isLanguageAvailable(locale)) {
            locales.add(locale.toLanguageTag())
          }
        }
      }
    } catch (e: MissingResourceException) {
      Log.d(tag, "getLanguages: " + e.message)
    } catch (e: NullPointerException) {
      Log.d(tag, "getLanguages: " + e.message)
    }

    return locales;
  }

  fun setLanguage(language: String?): Int {
    if (language != null) {
      currentLanguage = Locale(language)

      if(tts != null) {
        tts.language = currentLanguage
        return 1
      }
    }

    return 0
  }

  fun getVoices(): List<Map<String, String>> {
    val voices = mutableListOf<Map<String, String>>()
    try {
      val availableVoices: Set<Voice> = tts.voices ?: emptySet()
      for (voice in availableVoices) {
        val voiceMap = mutableMapOf<String, String>()
        voiceMap["name"] = voice.name
        voiceMap["locale"] = voice.locale.toLanguageTag()
        voiceMap["quality"] = voice.quality.toString()
        voiceMap["identifier"] = voice.name
        voiceMap["gender"] = "unknown"
        voiceMap["isPersonalVoice"] = "false"

        voices.add(voiceMap)
      }
    } catch (e: NullPointerException) {
      Log.d(tag, "getVoices: " + e.message)
    }

    return voices
  }

  fun setVoice(voice: Map<String, String>?): Int {

    if (voice != null) {
      for (ttsVoice in tts.voices) {
        if (
          ttsVoice.name == voice["name"] &&
          ttsVoice.locale.toLanguageTag() == voice["locale"]
        ) {
          tts.voice = ttsVoice
          return 1
        }
      }
    }

    Log.d(tag, "Voice name not found: $voice")
    return 0
  }

  fun isLanguageAvailable(locale: Locale?): Boolean {
    return tts.isLanguageAvailable(locale) >= TextToSpeech.LANG_AVAILABLE
  }

  private fun submitSpeakAction(text: String, volume: Float, rate: Float, pitch: Float) {
    var id = "utteranceID_${System.currentTimeMillis()}";
    actionQueue.addAction {
      var bundle = Bundle();
      bundle.putFloat(TextToSpeech.Engine.KEY_PARAM_VOLUME, volume)

      tts.setSpeechRate(rate)
      tts.setPitch(pitch)
      tts.speak(text, TextToSpeech.QUEUE_FLUSH, bundle, id)
    }
  }

  private fun parseSSMLAndQueueActions(actionQueue: TTSActionQueue, ssml: String, volume: Float, rate: Float, pitch: Float) {
    try {
      val parser: XmlPullParser = XmlPullParserFactory.newInstance().newPullParser()
      parser.setInput(StringReader(ssml))

      var currentRate = rate;
      var currentPitch = pitch;
      var currentVolume = volume;
      var eventType: Int = parser.getEventType()

      while (eventType != XmlPullParser.END_DOCUMENT) {
        val tagName: String = parser.getName()

        when (eventType) {
          XmlPullParser.START_TAG -> if ("prosody".equals(tagName)) {
            val newRate: String? = parser.getAttributeValue(null, "rate")
            val newPitch: String? = parser.getAttributeValue(null, "pitch")
            val newVolume: String? = parser.getAttributeValue(null, "volume")

            if (rate != null) {
              currentRate = convertRate(newRate, currentRate)
            }

            if (pitch != null) {
              currentPitch = convertPitch(newPitch, currentPitch);
            }

            if (pitch != null) {
              currentVolume = convertVolume(newVolume, currentVolume);
            }
          } else if ("break".equals(tagName)) {
            val time: String = parser.getAttributeValue(null, "time")
            val strength = parser.getAttributeValue(null, "strength")
            if (time != null) {
              val pauseTime = convertToPauseDuration(time, strength)
              actionQueue.addAction { tts.playSilentUtterance(pauseTime, TextToSpeech.QUEUE_ADD, null) }
            }
          } else if ("p".equals(tagName) || "s".equals(tagName)) {
            // default pause for sentences or paragraphs
            actionQueue.addAction { tts.playSilentUtterance(defaultPause, TextToSpeech.QUEUE_ADD, null) }
          } else if ("emphasis".equals(tagName)) {
            val level = parser.getAttributeValue(null, "level")
            val convertedValues = convertEmphasis(level, currentRate, currentPitch)
            currentRate = convertedValues[0];
            currentPitch = convertedValues[1];
          }

          XmlPullParser.TEXT -> {
            val text: String = parser.getText()
            submitSpeakAction(text, volume, currentRate, currentPitch)
          }

          XmlPullParser.END_TAG -> {
            val tagName = parser.name
            if ("emphasis".equals(tagName)) {
              currentPitch = pitch
            } else if ("prosody".equals(tagName)) {
              currentPitch = pitch
              currentRate = rate
              currentVolume = volume
            }
          }
        }
        eventType = parser.next()
      }
    } catch (e: Exception) {
      e.printStackTrace()
    }
  }

  private fun splitTextByNaturalBoundaries(text: String, maxSpeechLength: Int): List<String> {
    val chunks = mutableListOf<String>()
    var currentChunk = StringBuilder()

    val sentences = text.split(Regex("(?<=\\.|!|\\?)\\s"))  // Split by sentence-ending punctuation

    for (sentence in sentences) {
      // If adding the current sentence exceeds the max length, start a new chunk
      if (currentChunk.length + sentence.length > maxSpeechLength) {
        chunks.add(currentChunk.toString().trim())
        currentChunk = StringBuilder()
      }

      currentChunk.append(sentence).append(" ")
    }

    // Add the last chunk if any remaining text exists
    if (currentChunk.isNotEmpty()) {
      chunks.add(currentChunk.toString().trim())
    }

    return chunks
  }

  fun convertToPauseDuration(time: String?, strength: String?): Long {
    // Convert 'time' if it exists, otherwise use 'strength'
    return when {
      time != null -> {
        // Remove "ms" if present and parse the time to Long
        parseTimeToMillis(time)
      }
      strength != null -> {
        // Use predefined durations based on 'strength'
        when (strength) {
          "none" -> 0L
          "x-weak" -> 100L  // Very short pause
          "weak" -> 200L
          "medium" -> 500L   // Medium pause (default)
          "strong" -> 800L
          "x-strong" -> 1000L // Long pause
          else -> 500L       // Default to medium pause if unrecognized
        }
      }
      else -> 500L // Default to a medium pause if neither 'time' nor 'strength' is provided
    }
  }

  fun convertEmphasis(level: String?, currentRate: Float, currentPitch: Float): List<Float> {
    var newRate = currentRate
    var newPitch = currentPitch
    when (level) {
      "strong" -> {
        newRate *= 1.1f // Slightly increase rate
        newPitch *= 1.2f // Increase pitch for emphasis
      }
      "moderate" -> {
        newRate *= 1.05f
        newPitch *= 1.1f
      }
      "reduced" -> {
        newRate *= 0.95f
        newPitch *= 0.9f
      }
      else -> {
        // no change for other levels
      }
    }

    return listOf(newRate, newPitch);
  }

  private fun convertPitch(pitch: String?, baselinePitch: Float): Float {
    return when (pitch) {
      null -> baselinePitch
      "x-low" -> baselinePitch * 0.5f
      "low" -> baselinePitch * 0.75f
      "medium" -> baselinePitch * 1.0f
      "high" -> baselinePitch * 1.5f
      "x-high" -> baselinePitch * 2.0f
      else -> {
        // For relative values like "+20%" or "-10%"
        if (pitch.contains("%")) {
          val value = pitch.replace("%", "").toFloatOrNull()
          value?.let {
            if (pitch.startsWith("+")) baselinePitch * (1.0f + it / 100) else baselinePitch * (1.0f - it / 100)
          } ?: baselinePitch // If parsing fails, return the baseline
        } else {
          baselinePitch // Default pitch
        }
      }
    }
  }

  // Convert rate values from SSML to Android's TTS values
  private fun convertRate(rate: String?, baselineRate: Float): Float {
    return when (rate) {
      null -> baselineRate
      "x-slow" -> baselineRate * 0.5f
      "slow" -> baselineRate * 0.75f
      "medium" -> baselineRate * 1.0f
      "fast" -> baselineRate * 1.5f
      "x-fast" -> baselineRate * 2.0f
      else -> {
        // For relative values like "+50%" or "-25%"
        if (rate.contains("%")) {
          val value = rate.replace("%", "").toFloatOrNull()
          value?.let {
            if (rate.startsWith("+")) baselineRate * (1.0f + it / 100) else baselineRate * (1.0f - it / 100)
          } ?: baselineRate
        } else {
          baselineRate // Default rate
        }
      }
    }
  }

  // Convert volume values from SSML to Android's TTS values
  private fun convertVolume(volume: String?, baselineVolume: Float): Float {
    return when (volume) {
      null -> baselineVolume
      "silent" -> 0.0f
      "x-soft" -> baselineVolume * 0.25f
      "soft" -> baselineVolume * 0.5f
      "medium" -> baselineVolume * 1.0f
      "loud" -> baselineVolume * 1.5f
      "x-loud" -> baselineVolume * 2.0f
      else -> {
        // For relative values like "+20%" or "-10%"
        if (volume.contains("%")) {
          val value = volume.replace("%", "").toFloatOrNull()
          value?.let {
            if (volume.startsWith("+")) baselineVolume * (1.0f + it / 100) else baselineVolume * (1.0f - it / 100)
          } ?: baselineVolume
        } else {
          baselineVolume // Default volume
        }
      }
    }
  }

  private fun parseTimeToMillis(time: String): Long {
    return if (time.endsWith("ms")) {
      time.replace("ms", "").toLong()
    } else if (time.endsWith("s")) {
      time.replace("s", "").toLong() * 1000
    } else {
      0
    }
  }
}