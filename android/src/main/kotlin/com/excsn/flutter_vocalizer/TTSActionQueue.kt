
class TTSActionQueue(tts: TextToSpeech) {
  private val actionQueue: Queue<Runnable> = LinkedList()
  private var isPaused = false
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
    isPaused = true
    tts.stop() // Stop speaking but preserve the queue
  }

  fun resumeQueue() {
    isPaused = false
    playNextAction()
  }

  fun hasPendingActions(): Boolean {
    return actionQueue.isNotEmpty()
  }

  fun clear() {
    actionQueue.clear()
  }

  private fun playNextAction() {
    if (isStopped || actionQueue.isEmpty()) {
      return
    }

    if (!isPaused && !actionQueue.isEmpty()) {
      val nextAction: Runnable = actionQueue.poll()
      nextAction.run()
    }
  }

  // Hook into TTS UtteranceListener to know when TTS finishes speaking
  fun onUtteranceCompleted() {
    if (!isPaused && !isStopped) {
      playNextAction()
    }
  }
}