import SwiftUI

/// Displays the most severe form issue at the top of the workout screen.
struct FormFeedbackBanner: View {
    let issues: [FormIssue]

    private var worst: FormIssue? {
        issues.max(by: { $0.severity < $1.severity })
    }

    var body: some View {
        if let issue = worst {
            HStack(spacing: 10) {
                Image(systemName: issue.severity == .error ? "exclamationmark.triangle.fill" : "info.circle.fill")
                    .foregroundStyle(issue.severity == .error ? .red : .yellow)
                Text(issue.message)
                    .font(.subheadline.bold())
                    .foregroundStyle(.white)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(.ultraThinMaterial, in: Capsule())
            .transition(.move(edge: .top).combined(with: .opacity))
            .accessibilityLabel("\(issue.severity == .error ? "Error" : "Warning"): \(issue.message)")
        }
    }
}
