import Foundation

/// Normalized joint positions from a single Vision pose observation.
/// Coordinates are in Vision space: origin at bottom-left, x/y in [0, 1].
struct JointPositions: Sendable {
    var nose:           CGPoint?
    var leftEye:        CGPoint?
    var rightEye:       CGPoint?
    var leftEar:        CGPoint?
    var rightEar:       CGPoint?
    var leftShoulder:   CGPoint?
    var rightShoulder:  CGPoint?
    var leftElbow:      CGPoint?
    var rightElbow:     CGPoint?
    var leftWrist:      CGPoint?
    var rightWrist:     CGPoint?
    var leftHip:        CGPoint?
    var rightHip:       CGPoint?
    var leftKnee:       CGPoint?
    var rightKnee:      CGPoint?
    var leftAnkle:      CGPoint?
    var rightAnkle:     CGPoint?
    var neck:           CGPoint?
    var root:           CGPoint?

    var isEmpty: Bool {
        [leftShoulder, rightShoulder, leftHip, rightHip, leftKnee, rightKnee]
            .compactMap { $0 }.isEmpty
    }

    // Midpoints for bilateral symmetry calculations
    var midShoulder: CGPoint? { midpoint(leftShoulder, rightShoulder) }
    var midHip:      CGPoint? { midpoint(leftHip,      rightHip)      }
    var midKnee:     CGPoint? { midpoint(leftKnee,     rightKnee)     }
    var midAnkle:    CGPoint? { midpoint(leftAnkle,    rightAnkle)    }

    private func midpoint(_ a: CGPoint?, _ b: CGPoint?) -> CGPoint? {
        guard let a, let b else { return nil }
        return CGPoint(x: (a.x + b.x) / 2, y: (a.y + b.y) / 2)
    }
}
