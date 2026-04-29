import Foundation

/// Rule-based form analyzer. Each exercise has its own set of geometric checks.
/// All methods are pure functions: given joint positions, return detected issues.
enum FormAnalyzer {

    static func analyze(joints: JointPositions, exercise: Exercise) -> [FormIssue] {
        switch exercise {
        case .squat:  return analyzeSquat(joints: joints)
        case .pushup: return analyzePushup(joints: joints)
        case .plank:  return analyzePlank(joints: joints)
        }
    }

    // MARK: - Squat

    private static func analyzeSquat(joints: JointPositions) -> [FormIssue] {
        var issues: [FormIssue] = []

        // Check knee cave: knees should be outside or aligned with ankles
        if let leftKnee  = joints.leftKnee,
           let leftAnkle = joints.leftAnkle,
           leftKnee.x > leftAnkle.x + 0.04 {
            issues.append(.kneeCave)
        }
        if let rightKnee  = joints.rightKnee,
           let rightAnkle = joints.rightAnkle,
           rightKnee.x < rightAnkle.x - 0.04 {
            issues.append(.kneeCave)
        }

        // Check forward lean: shoulder should be relatively upright over hip
        if let shoulder = joints.midShoulder,
           let hip      = joints.midHip,
           let knee     = joints.midKnee {
            let trunkAngle = hip.angle(to: shoulder, and: knee)
            if trunkAngle < 50 { issues.append(.forwardLean) }
        }

        // Check squat depth: hip should reach knee level at bottom
        if let hip  = joints.midHip,
           let knee = joints.midKnee {
            // Vision y-axis is bottom-up, so larger y = higher in frame
            if hip.y > knee.y + 0.05 { issues.append(.depthTooShallow) }
        }

        return Array(Set(issues.map { $0.message }).compactMap { msg in issues.first { $0.message == msg } })
    }

    // MARK: - Push-up

    private static func analyzePushup(joints: JointPositions) -> [FormIssue] {
        var issues: [FormIssue] = []

        // Check body alignment: shoulder, hip, ankle should be roughly collinear
        if let shoulder = joints.midShoulder,
           let hip      = joints.midHip,
           let ankle    = joints.midAnkle {
            let bodyAngle = hip.angle(to: shoulder, and: ankle)
            if bodyAngle < 160 {
                if hip.y < shoulder.y && hip.y < ankle.y {
                    issues.append(.hipPike)
                } else {
                    issues.append(.hipSag)
                }
            }
        }

        // Check elbow flare: elbow should not be wider than shoulder by more than threshold
        if let leftShoulder  = joints.leftShoulder,
           let leftElbow     = joints.leftElbow,
           let rightShoulder = joints.rightShoulder,
           let rightElbow    = joints.rightElbow {
            let shoulderWidth = abs(leftShoulder.x - rightShoulder.x)
            let elbowWidth    = abs(leftElbow.x    - rightElbow.x)
            if elbowWidth > shoulderWidth * 1.5 { issues.append(.elbowFlare) }
        }

        // Check head drop: nose should not be below shoulder level
        if let nose     = joints.nose,
           let shoulder = joints.midShoulder,
           nose.y < shoulder.y - 0.05 {
            issues.append(.headDrop)
        }

        return issues
    }

    // MARK: - Plank

    private static func analyzePlank(joints: JointPositions) -> [FormIssue] {
        var issues: [FormIssue] = []

        // Body should be a straight line: shoulder, hip, ankle aligned
        if let shoulder = joints.midShoulder,
           let hip      = joints.midHip,
           let ankle    = joints.midAnkle {
            let bodyAngle = hip.angle(to: shoulder, and: ankle)
            if bodyAngle < 155 {
                // Determine direction of deviation
                let midY = (shoulder.y + ankle.y) / 2
                if hip.y > midY + 0.04 {
                    issues.append(.hipSag)
                } else if hip.y < midY - 0.04 {
                    issues.append(.hipPike)
                }
            }
        }

        // Head should be neutral: nose roughly in line with shoulder bearing
        if let nose      = joints.nose,
           let shoulder  = joints.midShoulder,
           let hip       = joints.midHip {
            let spineAngle = shoulder.angle(to: hip, and: nose)
            if spineAngle < 140 { issues.append(.headDrop) }
        }

        return issues
    }
}
