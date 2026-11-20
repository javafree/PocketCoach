import Foundation
import Combine
import CoreMedia

@MainActor
final class WorkoutViewModel: ObservableObject {

    // MARK: - Published state

    @Published private(set) var jointPositions: JointPositions?
    @Published private(set) var formIssues:     [FormIssue] = []
    @Published private(set) var repCount:        Int = 0
    @Published private(set) var elapsedSeconds:  Int = 0
    @Published private(set) var repState:        RepState = .ready
    @Published private(set) var isRunning:       Bool = false
    @Published private(set) var isFinished:      Bool = false
    @Published private(set) var session:         WorkoutSession
    @Published var cameraError:                  String?

    // MARK: - Private

    private let exercise: Exercise
    private let repCounter: RepCounter
    private var frameTask: Task<Void, Never>?
    private var timerTask: Task<Void, Never>?
    private var totalFormIssueCount = 0
    private var sessionStartTime: Date = .now

    init(exercise: Exercise) {
        self.exercise   = exercise
        self.repCounter = RepCounter(exercise: exercise)
        self.session    = WorkoutSession(exercise: exercise)
    }

    // MARK: - Lifecycle

    func start() async {
        do {
            try await CameraService.shared.start()
        } catch {
            cameraError = error.localizedDescription
            return
        }

        isRunning = true
        sessionStartTime = .now
        await AudioCueService.shared.announceStart(exercise: exercise)

        startTimer()
        startFrameProcessing()
    }

    func stop() async {
        frameTask?.cancel()
        timerTask?.cancel()
        await CameraService.shared.stop()
        isRunning = false

        let duration  = Date.now.timeIntervalSince(sessionStartTime)
        let formScore = computeFormScore()

        session.endedAt      = .now
        session.totalReps    = repCount
        session.totalDuration = duration
        session.formIssueCount = totalFormIssueCount
        session.formScore    = formScore

        await AudioCueService.shared.announceSessionComplete(reps: repCount, formScore: formScore)

        do {
            try await WorkoutHistoryService.shared.append(session)
            try await HealthKitService.shared.save(session: session)
        } catch {
            // Non-fatal: session data is already in local history
        }

        isFinished = true
    }

    // MARK: - Frame Processing

    private func startFrameProcessing() {
        frameTask = Task {
            let frames = await CameraService.shared.frames
            for await buffer in frames {
                guard !Task.isCancelled else { break }
                processFrame(buffer)
            }
        }
    }

    private func processFrame(_ buffer: CMSampleBuffer) {
        guard let joints = try? PoseDetectionService.detect(in: buffer) else { return }

        let issues = FormAnalyzer.analyze(joints: joints, exercise: exercise)
        let repCompleted = repCounter.update(joints: joints)

        Task { @MainActor in
            self.jointPositions = joints
            self.formIssues     = issues
            self.repState       = self.repCounter.state
            self.repCount       = self.repCounter.count
            self.totalFormIssueCount += issues.count

            if repCompleted {
                await AudioCueService.shared.announceRep(self.repCount)
            }

            if let worst = issues.max(by: { $0.severity < $1.severity }) {
                await AudioCueService.shared.announceIssue(worst)
            }
        }
    }

    // MARK: - Timer

    private func startTimer() {
        timerTask = Task {
            while !Task.isCancelled {
                try? await Task.sleep(for: .seconds(1))
                guard !Task.isCancelled else { break }
                elapsedSeconds += 1
            }
        }
    }

    // MARK: - Form Score
    //
    // Starts at 100, deducts points per form issue detected.
    // Errors cost more than warnings. Clamped to 0-100.

    private func computeFormScore() -> Int {
        guard repCount > 0 || exercise == .plank else { return 100 }
        let denominator = exercise.isTimeBased ? max(elapsedSeconds, 1) : max(repCount, 1)
        let deduction   = Double(totalFormIssueCount) / Double(denominator) * 10
        return max(0, Int((100 - deduction).rounded()))
    }
}
