import SwiftUI

/// Heads-up display overlaid on the camera: rep counter, timer, and rep state indicator.
struct HUDView: View {
    let exercise: Exercise
    let repCount: Int
    let elapsedSeconds: Int
    let repState: RepState
    let onStop: () -> Void

    var body: some View {
        VStack {
            // Top bar
            HStack {
                Button(action: onStop) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.title2)
                        .foregroundStyle(.white.opacity(0.8))
                        .symbolRenderingMode(.hierarchical)
                }
                .accessibilityLabel("End workout")

                Spacer()

                Text(timeString)
                    .font(.system(.subheadline, design: .monospaced).bold())
                    .foregroundStyle(.white)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(.ultraThinMaterial, in: Capsule())
            }
            .padding(.horizontal)
            .padding(.top, 8)

            Spacer()

            // Bottom: rep count or plank timer
            VStack(spacing: 8) {
                if exercise.isTimeBased {
                    Text(timeString)
                        .font(.system(size: 72, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)
                        .accessibilityLabel("Elapsed time: \(timeString)")
                } else {
                    Text("\(repCount)")
                        .font(.system(size: 88, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)
                        .contentTransition(.numericText())
                        .accessibilityLabel("\(repCount) reps")

                    RepStateIndicator(state: repState)
                }
            }
            .padding(.bottom, 40)
            .frame(maxWidth: .infinity)
            .background(
                LinearGradient(
                    colors: [.clear, .black.opacity(0.6)],
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
        }
    }

    private var timeString: String {
        let m = elapsedSeconds / 60
        let s = elapsedSeconds % 60
        return String(format: "%d:%02d", m, s)
    }
}

private struct RepStateIndicator: View {
    let state: RepState

    var body: some View {
        HStack(spacing: 8) {
            ForEach([RepState.ready, .descending, .bottom, .ascending], id: \.self) { s in
                Circle()
                    .fill(s == state ? Color.orange : Color.white.opacity(0.3))
                    .frame(width: 8, height: 8)
                    .animation(.easeInOut(duration: 0.2), value: state)
            }
        }
        .accessibilityLabel("Phase: \(stateLabel)")
        .accessibilityHidden(false)
    }

    private var stateLabel: String {
        switch state {
        case .ready:      return "Ready"
        case .descending: return "Going down"
        case .bottom:     return "Bottom"
        case .ascending:  return "Coming up"
        }
    }
}

extension RepState: Hashable {}
