package com.excsn.flutter_vocalizer

import android.content.Context
import android.os.Build
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

  fun speak(text: String) {
    if (text.length > maxSpeechInputLength) {
      val textChunks = splitTextByNaturalBoundaries(text, maxSpeechInputLength)
      for (chunk in textChunks) {
        var id = "utteranceID_${System.currentTimeMillis()}";
        actionQueue.addAction {
          tts.speak(chunk, TextToSpeech.QUEUE_FLUSH, null, id)
        }
      }
    } else {
      var id = "utteranceID_${System.currentTimeMillis()}";
      actionQueue.addAction {
        tts.speak(text, TextToSpeech.QUEUE_FLUSH, null, id)
      }
    }

    actionQueue.startQueue()
  }

  fun speakSSML(ssml: String) {
    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
      speak(ssml);
    } else {
      parseSSMLAndQueueActions(ssml, actionQueue)
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

  private fun parseSSMLAndQueueActions(ssml: String, actionQueue: TTSActionQueue) {
    try {
      val parser: XmlPullParser = XmlPullParserFactory.newInstance().newPullParser()
      parser.setInput(StringReader(ssml))

      var eventType: Int = parser.getEventType()
      while (eventType != XmlPullParser.END_DOCUMENT) {
        val tagName: String = parser.getName()

        when (eventType) {
          XmlPullParser.START_TAG -> if ("prosody".equals(tagName)) {
            val rate: String = parser.getAttributeValue(null, "rate")
            val pitch: String = parser.getAttributeValue(null, "pitch")
            if (rate != null) {
              actionQueue.addAction { tts.setSpeechRate(convertRate(rate)) }
            }
            if (pitch != null) {
              actionQueue.addAction { tts.setPitch(convertPitch(pitch)) }
            }
          } else if ("break".equals(tagName)) {
            val time: String = parser.getAttributeValue(null, "time")
            if (time != null) {
              val pauseTime = parseTimeToMillis(time)
              actionQueue.addAction { tts.playSilentUtterance(pauseTime, TextToSpeech.QUEUE_ADD, null) }
            }
          } else if ("emphasis".equals(tagName)) {
            actionQueue.addAction { tts.setPitch(1.3f) } // Emphasis
          }

          XmlPullParser.TEXT -> {
            val text: String = parser.getText()
            actionQueue.addAction { tts.speak(text, TextToSpeech.QUEUE_ADD, null, "utteranceID") }
          }

          XmlPullParser.END_TAG -> if ("emphasis".equals(tagName)) {
            actionQueue.addAction { tts.setPitch(1.0f) } // Reset pitch
          }
        }
        eventType = parser.next()
      }
    } catch (e: Exception) {
      e.printStackTrace()
    }
  }

  private fun convertRate(rate: String): Float {
    return when (rate) {
      "fast" -> 1.5f
      "slow" -> 0.75f
      else -> 1.0f
    }
  }

  private fun convertPitch(pitch: String): Float {
    return when (pitch) {
      "high" -> 1.5f
      "low" -> 0.75f
      else -> 1.0f
    }
  }

  private fun parseTimeToMillis(time: String): Long {
    return if (time.endsWith("ms")) {
      time.replace("ms", "").toLong()
    } else if (time.endsWith("s")) {
      time.replace("s", "").toLong() * 1000
    } else {
      500 // Default pause of 500ms
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
}