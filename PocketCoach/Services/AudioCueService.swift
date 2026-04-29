import AVFoundation

/// Delivers spoken form cues and rep counts using AVSpeechSynthesizer.
/// Audio cues make the app fully usable without looking at the screen.
actor AudioCueService {
    static let shared = AudioCueService()

    private let synthesizer = AVSpeechSynthesizer()
    private var isEnabled = true
    private var lastCueTime: Date = .distantPast
    private let minCueInterval: TimeInterval = 3.0   // avoid repeating the same cue too frequently

    private init() {}

    func setEnabled(_ enabled: Bool) {
        isEnabled = enabled
        if !enabled { synthesizer.stopSpeaking(at: .immediate) }
    }

    func announceRep(_ count: Int) {
        speak("\(count)")
    }

    func announceIssue(_ issue: FormIssue) {
        guard Date.now.timeIntervalSince(lastCueTime) >= minCueInterval else { return }
        speak(issue.cue)
        lastCueTime = .now
    }

    func announceSessionComplete(reps: Int, formScore: Int) {
        speak("Done. \(reps) reps. Form score: \(formScore) percent.")
    }

    func announceStart(exercise: Exercise) {
        speak("\(exercise.rawValue). Starting in 3... 2... 1... Go.")
    }

    // MARK: - Private

    private func speak(_ text: String) {
        guard isEnabled else { return }
        let utterance = AVSpeechUtterance(string: text)
        utterance.rate = AVSpeechUtteranceDefaultSpeechRate * 1.1
        utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
        synthesizer.speak(utterance)
    }
}
