import Foundation

actor WorkoutHistoryService {
    static let shared = WorkoutHistoryService()

    private let fileURL: URL = {
        let docs = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        return docs.appendingPathComponent("workout_history.json")
    }()

    private init() {}

    func load() throws -> [WorkoutSession] {
        guard FileManager.default.fileExists(atPath: fileURL.path) else { return [] }
        let data = try Data(contentsOf: fileURL)
        return try JSONDecoder().decode([WorkoutSession].self, from: data)
    }

    func save(_ sessions: [WorkoutSession]) throws {
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        let data = try encoder.encode(sessions)
        try data.write(to: fileURL, options: .atomicWrite)
    }

    func append(_ session: WorkoutSession) throws {
        var all = (try? load()) ?? []
        all.append(session)
        // Keep last 365 sessions max
        if all.count > 365 { all = Array(all.suffix(365)) }
        try save(all)
    }

    func summary() throws -> WorkoutSummary {
        let sessions = try load()
        let totalReps     = sessions.reduce(0) { $0 + $1.totalReps }
        let totalDuration = sessions.reduce(0) { $0 + $1.duration }
        let avgForm       = sessions.isEmpty ? 0.0 : Double(sessions.reduce(0) { $0 + $1.formScore }) / Double(sessions.count)

        var breakdown: [Exercise: Int] = [:]
        for session in sessions {
            breakdown[session.exercise, default: 0] += session.totalReps
        }

        return WorkoutSummary(
            totalSessions:     sessions.count,
            totalReps:         totalReps,
            totalDuration:     totalDuration,
            averageFormScore:  avgForm,
            exerciseBreakdown: breakdown
        )
    }
}
