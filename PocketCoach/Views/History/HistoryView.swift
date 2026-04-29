import SwiftUI
import Charts

struct HistoryView: View {
    @StateObject private var vm = HistoryViewModel()

    var body: some View {
        NavigationStack {
            Group {
                if vm.isLoading {
                    ProgressView()
                } else if vm.sessions.isEmpty {
                    emptyState
                } else {
                    content
                }
            }
            .navigationTitle("History")
            .task { await vm.load() }
        }
    }

    private var content: some View {
        ScrollView {
            VStack(spacing: 20) {
                summarySection
                weeklyChart
                sessionList
            }
            .padding(.top)
        }
    }

    private var summarySection: some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
            SummaryTile(label: "Sessions", value: "\(vm.summary?.totalSessions ?? 0)", icon: "figure.strengthtraining.functional", color: .orange)
            SummaryTile(label: "Total Reps", value: "\(vm.summary?.totalReps ?? 0)",   icon: "arrow.up.arrow.down",                color: .blue)
            SummaryTile(label: "Streak",     value: "\(vm.currentStreak)d",            icon: "flame.fill",                        color: .red)
        }
        .padding(.horizontal)
    }

    private var weeklyChart: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Reps This Week")
                .font(.headline)
                .padding(.horizontal)

            Chart(vm.weeklyRepData, id: \.day) { item in
                BarMark(x: .value("Day", item.day), y: .value("Reps", item.reps))
                    .foregroundStyle(Color.orange.gradient)
                    .cornerRadius(6)
            }
            .frame(height: 160)
            .padding(.horizontal)
            .accessibilityLabel("Bar chart showing reps per day this week")
        }
        .padding(.vertical)
        .background(Color(.secondarySystemBackground), in: RoundedRectangle(cornerRadius: 16))
        .padding(.horizontal)
    }

    private var sessionList: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("Recent Sessions")
                .font(.headline)
                .padding(.horizontal)
                .padding(.bottom, 8)

            ForEach(vm.recentSessions) { session in
                NavigationLink(destination: WorkoutDetailView(session: session)) {
                    SessionRow(session: session)
                }
                Divider().padding(.leading, 70)
            }
        }
        .background(Color(.secondarySystemBackground), in: RoundedRectangle(cornerRadius: 16))
        .padding(.horizontal)
        .padding(.bottom)
    }

    private var emptyState: some View {
        VStack(spacing: 16) {
            Image(systemName: "figure.strengthtraining.functional")
                .font(.system(size: 56))
                .foregroundStyle(.tertiary)
            Text("No Workouts Yet")
                .font(.title2.bold())
            Text("Complete your first workout to see your history here.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
        }
    }
}

private struct SummaryTile: View {
    let label: String
    let value: String
    let icon:  String
    let color: Color

    var body: some View {
        VStack(spacing: 6) {
            Image(systemName: icon).foregroundStyle(color).font(.title3)
            Text(value).font(.title3.bold())
            Text(label).font(.caption).foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 14)
        .background(color.opacity(0.1), in: RoundedRectangle(cornerRadius: 12))
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(label): \(value)")
    }
}

private struct SessionRow: View {
    let session: WorkoutSession

    var body: some View {
        HStack(spacing: 14) {
            Text(session.exercise.emoji)
                .font(.title2)
                .frame(width: 44, height: 44)
                .background(Color.orange.opacity(0.12), in: RoundedRectangle(cornerRadius: 10))

            VStack(alignment: .leading, spacing: 3) {
                Text(session.exercise.rawValue).font(.subheadline.bold())
                Text(session.startedAt.formatted(date: .abbreviated, time: .shortened))
                    .font(.caption).foregroundStyle(.secondary)
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 3) {
                if !session.exercise.isTimeBased {
                    Text("\(session.totalReps) reps").font(.subheadline.bold())
                }
                Text("Form: \(session.formScore)%")
                    .font(.caption)
                    .foregroundStyle(session.formScore >= 80 ? .green : .orange)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .foregroundStyle(.primary)
    }
}
