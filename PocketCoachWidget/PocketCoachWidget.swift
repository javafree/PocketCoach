import WidgetKit
import SwiftUI

struct PocketCoachEntry: TimelineEntry {
    let date: Date
    let streak: Int
    let totalSessionsToday: Int
}

struct PocketCoachProvider: TimelineProvider {
    func placeholder(in context: Context) -> PocketCoachEntry {
        PocketCoachEntry(date: .now, streak: 5, totalSessionsToday: 2)
    }

    func getSnapshot(in context: Context, completion: @escaping (PocketCoachEntry) -> Void) {
        Task { completion(await entry()) }
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<PocketCoachEntry>) -> Void) {
        Task {
            let e = await entry()
            let midnight = Calendar.current.startOfDay(for: Calendar.current.date(byAdding: .day, value: 1, to: .now)!)
            completion(Timeline(entries: [e], policy: .after(midnight)))
        }
    }

    private func entry() async -> PocketCoachEntry {
        let sessions = (try? await WorkoutHistoryService.shared.load()) ?? []
        let calendar = Calendar.current
        let today    = sessions.filter { calendar.isDateInToday($0.startedAt) }.count
        let streak   = computeStreak(sessions: sessions, calendar: calendar)
        return PocketCoachEntry(date: .now, streak: streak, totalSessionsToday: today)
    }

    private func computeStreak(sessions: [WorkoutSession], calendar: Calendar) -> Int {
        let days     = Set(sessions.map { calendar.startOfDay(for: $0.startedAt) }).sorted(by: >)
        var streak   = 0
        var expected = calendar.startOfDay(for: .now)
        for day in days {
            if day == expected {
                streak += 1
                expected = calendar.date(byAdding: .day, value: -1, to: expected)!
            } else { break }
        }
        return streak
    }
}

struct PocketCoachWidgetView: View {
    let entry: PocketCoachEntry
    @Environment(\.widgetFamily) var family

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text("🏋️").font(.title3)
                Text("PocketCoach").font(.caption.bold()).foregroundStyle(.secondary)
            }
            Spacer()

            if entry.streak > 0 {
                HStack(spacing: 4) {
                    Image(systemName: "flame.fill").foregroundStyle(.orange)
                    Text("\(entry.streak) day streak").font(.caption.bold()).foregroundStyle(.orange)
                }
            }

            Text(entry.totalSessionsToday == 0 ? "No sessions today" : "\(entry.totalSessionsToday) session\(entry.totalSessionsToday == 1 ? "" : "s") today")
                .font(.subheadline.bold())
        }
        .padding()
        .containerBackground(.background, for: .widget)
    }
}

@main
struct PocketCoachWidget: Widget {
    let kind = "PocketCoachWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: PocketCoachProvider()) { entry in
            PocketCoachWidgetView(entry: entry)
        }
        .configurationDisplayName("PocketCoach")
        .description("Track your daily workout streak.")
        .supportedFamilies([.systemSmall])
    }
}
