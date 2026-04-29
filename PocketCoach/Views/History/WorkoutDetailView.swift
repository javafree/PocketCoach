import SwiftUI

struct WorkoutDetailView: View {
    let session: WorkoutSession

    private var formColor: Color {
        session.formScore >= 80 ? .green : session.formScore >= 60 ? .orange : .red
    }

    var body: some View {
        List {
            Section("Summary") {
                LabeledContent("Exercise",   value: "\(session.exercise.emoji) \(session.exercise.rawValue)")
                LabeledContent("Date",       value: session.startedAt.formatted(date: .long, time: .shortened))
                LabeledContent("Duration",   value: formatDuration(session.duration))
                if !session.exercise.isTimeBased {
                    LabeledContent("Reps",   value: "\(session.totalReps)")
                }
            }

            Section("Form") {
                LabeledContent("Score") {
                    Text("\(session.formScore)%")
                        .foregroundStyle(formColor)
                        .bold()
                }
                LabeledContent("Issues Detected", value: "\(session.formIssueCount)")
            }

            Section("Tips for Next Time") {
                ForEach(session.exercise.keyPoints, id: \.self) { point in
                    Label(point, systemImage: "checkmark.circle")
                        .foregroundStyle(.secondary)
                }
            }
        }
        .navigationTitle(session.exercise.rawValue)
        .navigationBarTitleDisplayMode(.inline)
    }

    private func formatDuration(_ duration: TimeInterval) -> String {
        let m = Int(duration) / 60
        let s = Int(duration) % 60
        return m > 0 ? "\(m) min \(s) sec" : "\(s) sec"
    }
}
