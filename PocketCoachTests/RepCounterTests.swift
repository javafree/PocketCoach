import XCTest
@testable import PocketCoach

final class RepCounterTests: XCTestCase {

    // MARK: - Initial state

    func test_initialCount_isZero() {
        XCTAssertEqual(RepCounter(exercise: .squat).count, 0)
    }

    func test_initialState_isReady() {
        XCTAssertEqual(RepCounter(exercise: .squat).state, .ready)
    }

    // MARK: - Squat state machine

    func test_squat_transitionsToDescending_whenKneeAngleDrops() {
        let counter = RepCounter(exercise: .squat)
        counter.update(joints: squatJoints(kneeAngle: 145))
        XCTAssertEqual(counter.state, .descending)
    }

    func test_squat_transitionsToBottom_atDepth() {
        let counter = RepCounter(exercise: .squat)
        counter.update(joints: squatJoints(kneeAngle: 145))
        counter.update(joints: squatJoints(kneeAngle: 90))
        XCTAssertEqual(counter.state, .bottom)
    }

    func test_squat_transitionsToAscending_afterBottom() {
        let counter = RepCounter(exercise: .squat)
        counter.update(joints: squatJoints(kneeAngle: 145))
        counter.update(joints: squatJoints(kneeAngle: 90))
        counter.update(joints: squatJoints(kneeAngle: 94))  // angle increasing
        XCTAssertEqual(counter.state, .ascending)
    }

    func test_squat_countsRep_onFullCycle() {
        let counter = RepCounter(exercise: .squat)
        simulateSquatRep(counter)
        XCTAssertEqual(counter.count, 1)
    }

    func test_squat_countsMultipleReps() {
        let counter = RepCounter(exercise: .squat)
        simulateSquatRep(counter)
        simulateSquatRep(counter)
        simulateSquatRep(counter)
        XCTAssertEqual(counter.count, 3)
    }

    func test_squat_returnsTrue_whenRepCompleted() {
        let counter = RepCounter(exercise: .squat)
        counter.update(joints: squatJoints(kneeAngle: 145))
        counter.update(joints: squatJoints(kneeAngle: 90))
        counter.update(joints: squatJoints(kneeAngle: 94))
        let result = counter.update(joints: squatJoints(kneeAngle: 160))
        XCTAssertTrue(result)
    }

    func test_squat_returnsFalse_whenNoRepCompleted() {
        let counter = RepCounter(exercise: .squat)
        let result = counter.update(joints: squatJoints(kneeAngle: 170))
        XCTAssertFalse(result)
    }

    // MARK: - Reset

    func test_reset_clearsCountAndState() {
        let counter = RepCounter(exercise: .squat)
        simulateSquatRep(counter)
        counter.reset()
        XCTAssertEqual(counter.count, 0)
        XCTAssertEqual(counter.state, .ready)
    }

    // MARK: - Plank (no reps)

    func test_plank_neverCountsReps() {
        let counter = RepCounter(exercise: .plank)
        counter.update(joints: squatJoints(kneeAngle: 90))
        counter.update(joints: squatJoints(kneeAngle: 160))
        XCTAssertEqual(counter.count, 0)
    }

    // MARK: - Helpers

    private func simulateSquatRep(_ counter: RepCounter) {
        counter.update(joints: squatJoints(kneeAngle: 170))  // standing
        counter.update(joints: squatJoints(kneeAngle: 145))  // descending
        counter.update(joints: squatJoints(kneeAngle: 90))   // bottom
        counter.update(joints: squatJoints(kneeAngle: 94))   // ascending
        counter.update(joints: squatJoints(kneeAngle: 160))  // back up
    }

    /// Builds a minimal JointPositions that produces the requested knee angle.
    /// Places hip above knee, ankle below, adjusting angles geometrically.
    private func squatJoints(kneeAngle: Double) -> JointPositions {
        let knee = CGPoint(x: 0.5, y: 0.5)
        let angleRad = kneeAngle * .pi / 180
        let hip   = CGPoint(x: knee.x,                          y: knee.y + 0.2)
        let ankle = CGPoint(x: knee.x + 0.2 * sin(angleRad),   y: knee.y - 0.2 * cos(angleRad))

        var joints = JointPositions()
        joints.leftHip   = hip;   joints.rightHip   = hip
        joints.leftKnee  = knee;  joints.rightKnee  = knee
        joints.leftAnkle = ankle; joints.rightAnkle = ankle
        return joints
    }
}
