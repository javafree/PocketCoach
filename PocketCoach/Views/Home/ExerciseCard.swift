import SwiftUI

struct ExerciseCard: View {
    let exercise: Exercise
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 16) {
                Text(exercise.emoji)
                    .font(.system(size: 40))
                    .frame(width: 60, height: 60)
                    .background(Color.orange.opacity(0.12), in: RoundedRectangle(cornerRadius: 14))

                VStack(alignment: .leading, spacing: 4) {
                    Text(exercise.rawValue)
                        .font(.headline)
                        .foregroundStyle(.primary)
                    Text(exercise.description)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .lineLimit(2)
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .foregroundStyle(.tertiary)
                    .font(.subheadline)
            }
            .padding(16)
            .background(Color(.secondarySystemBackground), in: RoundedRectangle(cornerRadius: 18))
        }
        .buttonStyle(.plain)
        .accessibilityLabel("\(exercise.rawValue). \(exercise.description)")
        .accessibilityAddTraits(.isButton)
    }
}
