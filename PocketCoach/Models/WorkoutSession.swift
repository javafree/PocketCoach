import Foundation

struct WorkoutSession: Identifiable, Codable {
    let id: UUID
    let exercise: Exercise
    let startedAt: Date
    var endedAt: Date?
    var totalReps: Int
    var totalDuration: TimeInterval
    var formIssueCount: Int
    var formScore: Int           // 0-100

    var duration: TimeInterval {
        guard let endedAt else { return Date.now.timeIntervalSince(startedAt) }
        return endedAt.timeIntervalSince(startedAt)
    }

    init(exercise: Exercise) {
        self.id            = UUID()
        self.exercise      = exercise
        self.startedAt     = .now
        self.totalReps     = 0
        self.totalDuration = 0
        self.formIssueCount = 0
        self.formScore     = 100
    }
}

struct WorkoutSummary {
    let totalSessions: Int
    let totalReps: Int
    let totalDuration: TimeInterval
    let averageFormScore: Double
    let exerciseBreakdown: [Exercise: Int]   // exercise -> rep count
}
