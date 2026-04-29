import Foundation

/// A specific form problem detected in a single frame.
struct FormIssue: Identifiable, Equatable {
    let id = UUID()
    let severity: Severity
    let message: String
    let cue: String         // short corrective audio cue

    enum Severity: Int, Comparable {
        case warning  = 1   // suboptimal but not dangerous
        case error    = 2   // should stop and correct

        static func < (lhs: Severity, rhs: Severity) -> Bool { lhs.rawValue < rhs.rawValue }
    }
}

// MARK: - Predefined issues

extension FormIssue {
    static let kneeCave        = FormIssue(severity: .error,   message: "Knees caving inward",       cue: "Push knees out")
    static let depthTooShallow = FormIssue(severity: .warning, message: "Squat not deep enough",     cue: "Go deeper")
    static let forwardLean     = FormIssue(severity: .warning, message: "Excessive forward lean",    cue: "Chest up")
    static let hipSag          = FormIssue(severity: .error,   message: "Hips sagging",              cue: "Engage your core")
    static let hipPike         = FormIssue(severity: .warning, message: "Hips too high",             cue: "Lower your hips")
    static let headDrop        = FormIssue(severity: .warning, message: "Head dropping forward",     cue: "Keep head neutral")
    static let elbowFlare      = FormIssue(severity: .warning, message: "Elbows flaring out",        cue: "Tuck elbows in")
    static let incompleteRange = FormIssue(severity: .warning, message: "Incomplete range of motion", cue: "Full range of motion")
}
