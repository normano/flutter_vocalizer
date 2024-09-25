package com.excsn.flutter_vocalizer

import android.speech.tts.TextToSpeech

import java.util.*

class TTSActionQueue(tts: TextToSpeech) {
  private val actionQueue: Queue<Runnable> = LinkedList()
  private var _isPaused = false
  private var isStopped = false
  private val tts: TextToSpeech = tts

  fun addAction(action: Runnable?) {
    actionQueue.add(action)
  }

  fun startQueue() {
    isStopped = false
    playNextAction()
  }

  fun stopQueue() {
    isStopped = true
    tts.stop() // Stop TTS
    clear()
  }

  fun pauseQueue() {
    _isPaused = true
    tts.stop() // Stop speaking but preserve the queue
  }

  fun resumeQueue() {
    _isPaused = false
    playNextAction()
  }

  fun hasPendingActions(): Boolean {
    return actionQueue.isNotEmpty()
  }

  fun clear() {
    actionQueue.clear()
  }

  fun playNextAction() {
    if (isStopped || actionQueue.isEmpty()) {
      return
    }

    if (!_isPaused && !actionQueue.isEmpty()) {
      val nextAction: Runnable = actionQueue.poll()
      nextAction.run()
    }
  }

  // Hook into TTS UtteranceListener to know when TTS finishes speaking
  fun onUtteranceCompleted() {
    if (!_isPaused && !isStopped) {
      playNextAction()
    }
  }

  fun isPaused(): Boolean {
    return _isPaused
  }
}