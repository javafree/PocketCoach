import Foundation

@MainActor
final class HistoryViewModel: ObservableObject {
    @Published private(set) var sessions: [WorkoutSession] = []
    @Published private(set) var summary:  WorkoutSummary?
    @Published private(set) var isLoading = false
    @Published var error: String?

    func load() async {
        isLoading = true
        defer { isLoading = false }
        do {
            sessions = try await WorkoutHistoryService.shared.load()
            summary  = try await WorkoutHistoryService.shared.summary()
        } catch {
            self.error = error.localizedDescription
        }
    }

    var recentSessions: [WorkoutSession] {
        Array(sessions.sorted { $0.startedAt > $1.startedAt }.prefix(20))
    }

    var weeklyRepData: [(day: String, reps: Int)] {
        let calendar = Calendar.current
        let today    = calendar.startOfDay(for: .now)
        return (0..<7).reversed().map { offset in
            let day  = calendar.date(byAdding: .day, value: -offset, to: today)!
            let reps = sessions
                .filter { calendar.isDate($0.startedAt, inSameDayAs: day) }
                .reduce(0) { $0 + $1.totalReps }
            let label = offset == 0 ? "Today" : calendar.shortWeekdaySymbols[calendar.component(.weekday, from: day) - 1]
            return (label, reps)
        }
    }

    var currentStreak: Int {
        let calendar = Calendar.current
        let days     = Set(sessions.map { calendar.startOfDay(for: $0.startedAt) }).sorted(by: >)
        var streak   = 0
        var expected = calendar.startOfDay(for: .now)
        for day in days {
            if day == expected {
                streak += 1
                expected = calendar.date(byAdding: .day, value: -1, to: expected)!
            } else {
                break
            }
        }
        return streak
    }
}
