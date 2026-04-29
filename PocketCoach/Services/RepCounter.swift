import Foundation

/// Rep counter implemented as a state machine.
/// One instance per workout session — reset between sessions.
final class RepCounter {

    private(set) var count: Int = 0
    private(set) var state: RepState = .ready
    private(set) var currentAngle: Double = 0

    // Thresholds vary by exercise
    private let exercise: Exercise

    init(exercise: Exercise) {
        self.exercise = exercise
    }

    func reset() {
        count = 0
        state = .ready
        currentAngle = 0
    }

    /// Feed new joint positions. Returns true if a rep was just completed.
    @discardableResult
    func update(joints: JointPositions) -> Bool {
        switch exercise {
        case .squat:  return updateSquat(joints: joints)
        case .pushup: return updatePushup(joints: joints)
        case .plank:  return false   // plank is time-based, not rep-based
        }
    }

    // MARK: - Squat State Machine
    //
    // ready -> descending (knee angle drops below 155°)
    // descending -> bottom (knee angle drops below 95°)
    // bottom -> ascending (knee angle increases)
    // ascending -> ready (knee angle rises above 155°) -> count rep

    private func updateSquat(joints: JointPositions) -> Bool {
        guard let hip   = joints.midHip,
              let knee  = joints.midKnee,
              let ankle = joints.midAnkle else { return false }

        let angle = knee.angle(to: hip, and: ankle)
        let previousAngle = currentAngle
        currentAngle = angle

        switch state {
        case .ready:
            if angle < 155 { state = .descending }

        case .descending:
            if angle < 95 {
                state = .bottom
            } else if angle > 160 {
                // Stood back up without reaching depth
                state = .ready
            }

        case .bottom:
            if angle > previousAngle + 2 { state = .ascending }

        case .ascending:
            if angle > 155 {
                state = .ready
                count += 1
                return true
            }
            if angle < 95 { state = .bottom }
        }

        return false
    }

    // MARK: - Push-up State Machine
    //
    // ready -> descending (elbow angle drops below 155°)
    // descending -> bottom (elbow angle drops below 90°)
    // bottom -> ascending (elbow angle increases)
    // ascending -> ready (elbow angle rises above 155°) -> count rep

    private func updatePushup(joints: JointPositions) -> Bool {
        // Use the average of both elbows for robustness
        let leftAngle  = elbowAngle(shoulder: joints.leftShoulder,  elbow: joints.leftElbow,  wrist: joints.leftWrist)
        let rightAngle = elbowAngle(shoulder: joints.rightShoulder, elbow: joints.rightElbow, wrist: joints.rightWrist)

        guard let angle = averagedAngle(leftAngle, rightAngle) else { return false }

        let previousAngle = currentAngle
        currentAngle = angle

        switch state {
        case .ready:
            if angle < 155 { state = .descending }

        case .descending:
            if angle < 90 {
                state = .bottom
            } else if angle > 160 {
                state = .ready
            }

        case .bottom:
            if angle > previousAngle + 2 { state = .ascending }

        case .ascending:
            if angle > 155 {
                state = .ready
                count += 1
                return true
            }
            if angle < 90 { state = .bottom }
        }

        return false
    }

    // MARK: - Helpers

    private func elbowAngle(shoulder: CGPoint?, elbow: CGPoint?, wrist: CGPoint?) -> Double? {
        guard let s = shoulder, let e = elbow, let w = wrist else { return nil }
        return e.angle(to: s, and: w)
    }

    private func averagedAngle(_ a: Double?, _ b: Double?) -> Double? {
        switch (a, b) {
        case let (a?, b?): return (a + b) / 2
        case let (a?, nil): return a
        case let (nil, b?): return b
        case (nil, nil): return nil
        }
    }
}
