import SwiftUI

struct WorkoutSummaryView: View {
    let session: WorkoutSession
    let onDone: () -> Void

    private var formColor: Color {
        switch session.formScore {
        case 85...100: return .green
        case 60..<85:  return .orange
        default:       return .red
        }
    }

    private var formEmoji: String {
        switch session.formScore {
        case 90...100: return "🏆"
        case 75..<90:  return "⭐"
        case 60..<75:  return "📈"
        default:       return "💪"
        }
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 32) {
                    // Header
                    VStack(spacing: 8) {
                        Text(formEmoji)
                            .font(.system(size: 64))
                        Text("Workout Complete")
                            .font(.title.bold())
                        Text("\(session.exercise.emoji) \(session.exercise.rawValue)")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    .padding(.top, 24)

                    // Stats grid
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 14) {
                        if session.exercise.isTimeBased {
                            StatCard(title: "Hold Time",  value: formatDuration(session.duration), icon: "timer",           color: .blue)
                        } else {
                            StatCard(title: "Reps",       value: "\(session.totalReps)",            icon: "arrow.up.arrow.down", color: .blue)
                        }
                        StatCard(title: "Duration",   value: formatDuration(session.duration),   icon: "clock",            color: .purple)
                        StatCard(title: "Form Score",  value: "\(session.formScore)%",            icon: "checkmark.seal",   color: formColor)
                        StatCard(title: "Form Issues", value: "\(session.formIssueCount)",        icon: "exclamationmark.triangle", color: .orange)
                    }
                    .padding(.horizontal)

                    // Key points reminder
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Key Points")
                            .font(.headline)
                        ForEach(session.exercise.keyPoints, id: \.self) { point in
                            HStack(alignment: .top, spacing: 10) {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundStyle(.green)
                                Text(point)
                                    .font(.subheadline)
                            }
                        }
                    }
                    .padding()
                    .background(Color(.secondarySystemBackground), in: RoundedRectangle(cornerRadius: 16))
                    .padding(.horizontal)

                    Button(action: onDone) {
                        Text("Done")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(.orange, in: RoundedRectangle(cornerRadius: 14))
                            .foregroundStyle(.white)
                    }
                    .padding(.horizontal)
                    .padding(.bottom)
                }
            }
            .navigationBarHidden(true)
        }
        .accessibilityElement(children: .contain)
    }

    private func formatDuration(_ duration: TimeInterval) -> String {
        let m = Int(duration) / 60
        let s = Int(duration) % 60
        return m > 0 ? "\(m)m \(s)s" : "\(s)s"
    }
}

private struct StatCard: View {
    let title: String
    let value: String
    let icon:  String
    let color: Color

    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundStyle(color)
            Text(value)
                .font(.title2.bold())
            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .background(color.opacity(0.1), in: RoundedRectangle(cornerRadius: 14))
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(title): \(value)")
    }
}
