import XCTest
@testable import PocketCoach

final class FormAnalyzerTests: XCTestCase {

    // MARK: - Squat

    func test_squat_goodForm_noIssues() {
        let joints = goodSquatJoints()
        let issues = FormAnalyzer.analyze(joints: joints, exercise: .squat)
        XCTAssertTrue(issues.isEmpty, "Expected no issues for good squat, got: \(issues.map(\.message))")
    }

    func test_squat_kneeCaveLeft_detected() {
        var joints = goodSquatJoints()
        // Left knee x > left ankle x by more than threshold
        joints.leftKnee  = CGPoint(x: 0.6, y: 0.5)
        joints.leftAnkle = CGPoint(x: 0.4, y: 0.3)
        let issues = FormAnalyzer.analyze(joints: joints, exercise: .squat)
        XCTAssertTrue(issues.contains { $0.message == FormIssue.kneeCave.message })
    }

    func test_squat_shallowDepth_detected() {
        var joints = goodSquatJoints()
        // Hip higher than knee (in Vision y-up coordinates, larger y = higher)
        joints.leftHip   = CGPoint(x: 0.4, y: 0.8)
        joints.rightHip  = CGPoint(x: 0.6, y: 0.8)
        joints.leftKnee  = CGPoint(x: 0.4, y: 0.5)
        joints.rightKnee = CGPoint(x: 0.6, y: 0.5)
        let issues = FormAnalyzer.analyze(joints: joints, exercise: .squat)
        XCTAssertTrue(issues.contains { $0.message == FormIssue.depthTooShallow.message })
    }

    // MARK: - Push-up

    func test_pushup_goodForm_noIssues() {
        let joints = goodPushupJoints()
        let issues = FormAnalyzer.analyze(joints: joints, exercise: .pushup)
        XCTAssertTrue(issues.isEmpty, "Expected no issues, got: \(issues.map(\.message))")
    }

    func test_pushup_hipSag_detected() {
        var joints = goodPushupJoints()
        // Hip drops below the shoulder-ankle line
        joints.leftHip  = CGPoint(x: 0.5, y: 0.1)
        joints.rightHip = CGPoint(x: 0.5, y: 0.1)
        let issues = FormAnalyzer.analyze(joints: joints, exercise: .pushup)
        XCTAssertTrue(issues.contains { $0.message == FormIssue.hipSag.message || $0.message == FormIssue.hipPike.message })
    }

    // MARK: - Plank

    func test_plank_goodForm_noIssues() {
        let joints = goodPlankJoints()
        let issues = FormAnalyzer.analyze(joints: joints, exercise: .plank)
        XCTAssertTrue(issues.isEmpty, "Expected no issues, got: \(issues.map(\.message))")
    }

    func test_plank_hipSag_detected() {
        var joints = goodPlankJoints()
        joints.leftHip  = CGPoint(x: 0.5, y: 0.2)
        joints.rightHip = CGPoint(x: 0.5, y: 0.2)
        let issues = FormAnalyzer.analyze(joints: joints, exercise: .plank)
        XCTAssertTrue(issues.contains { $0.message == FormIssue.hipSag.message })
    }

    // MARK: - Fixtures

    private func goodSquatJoints() -> JointPositions {
        var j = JointPositions()
        // Good squat at depth: hips at knee level, knees over ankles
        j.leftShoulder  = CGPoint(x: 0.35, y: 0.85)
        j.rightShoulder = CGPoint(x: 0.65, y: 0.85)
        j.leftHip       = CGPoint(x: 0.38, y: 0.55)
        j.rightHip      = CGPoint(x: 0.62, y: 0.55)
        j.leftKnee      = CGPoint(x: 0.38, y: 0.52)  // hip and knee at similar y = at depth
        j.rightKnee     = CGPoint(x: 0.62, y: 0.52)
        j.leftAnkle     = CGPoint(x: 0.38, y: 0.15)
        j.rightAnkle    = CGPoint(x: 0.62, y: 0.15)
        return j
    }

    private func goodPushupJoints() -> JointPositions {
        var j = JointPositions()
        // Straight body in high plank position
        j.leftShoulder  = CGPoint(x: 0.3, y: 0.6)
        j.rightShoulder = CGPoint(x: 0.7, y: 0.6)
        j.leftHip       = CGPoint(x: 0.3, y: 0.5)
        j.rightHip      = CGPoint(x: 0.7, y: 0.5)
        j.leftAnkle     = CGPoint(x: 0.3, y: 0.1)
        j.rightAnkle    = CGPoint(x: 0.7, y: 0.1)
        j.leftElbow     = CGPoint(x: 0.2, y: 0.55)
        j.rightElbow    = CGPoint(x: 0.8, y: 0.55)
        j.nose          = CGPoint(x: 0.5, y: 0.65)
        return j
    }

    private func goodPlankJoints() -> JointPositions {
        var j = JointPositions()
        // Perfectly straight line from shoulder to ankle
        j.leftShoulder  = CGPoint(x: 0.3, y: 0.6)
        j.rightShoulder = CGPoint(x: 0.7, y: 0.6)
        j.leftHip       = CGPoint(x: 0.3, y: 0.5)
        j.rightHip      = CGPoint(x: 0.7, y: 0.5)
        j.leftAnkle     = CGPoint(x: 0.3, y: 0.1)
        j.rightAnkle    = CGPoint(x: 0.7, y: 0.1)
        j.nose          = CGPoint(x: 0.5, y: 0.65)
        return j
    }
}
