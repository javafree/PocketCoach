import SwiftUI

/// Draws a stick-figure skeleton over the camera preview using the detected joint positions.
/// Vision coordinates (origin bottom-left) are flipped to SwiftUI coordinates (origin top-left).
struct PoseOverlayView: View {
    let joints: JointPositions
    let size:   CGSize

    var body: some View {
        Canvas { context, _ in
            drawSkeleton(in: context)
        }
        .allowsHitTesting(false)
        .accessibilityHidden(true)
    }

    // MARK: - Skeleton Drawing

    private func drawSkeleton(in context: GraphicsContext) {
        let lineStyle = GraphicsContext.StrokeStyle(lineWidth: 3, lineCap: .round)
        let color     = Color.orange.opacity(0.85)

        // Torso
        drawBone(context, from: joints.leftShoulder,  to: joints.rightShoulder, color: color, style: lineStyle)
        drawBone(context, from: joints.leftHip,       to: joints.rightHip,      color: color, style: lineStyle)
        drawBone(context, from: joints.leftShoulder,  to: joints.leftHip,       color: color, style: lineStyle)
        drawBone(context, from: joints.rightShoulder, to: joints.rightHip,      color: color, style: lineStyle)

        // Left arm
        drawBone(context, from: joints.leftShoulder,  to: joints.leftElbow,  color: color, style: lineStyle)
        drawBone(context, from: joints.leftElbow,     to: joints.leftWrist,  color: color, style: lineStyle)

        // Right arm
        drawBone(context, from: joints.rightShoulder, to: joints.rightElbow, color: color, style: lineStyle)
        drawBone(context, from: joints.rightElbow,    to: joints.rightWrist, color: color, style: lineStyle)

        // Left leg
        drawBone(context, from: joints.leftHip,   to: joints.leftKnee,   color: color, style: lineStyle)
        drawBone(context, from: joints.leftKnee,  to: joints.leftAnkle,  color: color, style: lineStyle)

        // Right leg
        drawBone(context, from: joints.rightHip,  to: joints.rightKnee,  color: color, style: lineStyle)
        drawBone(context, from: joints.rightKnee, to: joints.rightAnkle, color: color, style: lineStyle)

        // Head
        drawBone(context, from: joints.neck, to: joints.nose, color: color, style: lineStyle)

        // Joint dots
        let jointPoints: [CGPoint?] = [
            joints.nose, joints.leftShoulder, joints.rightShoulder,
            joints.leftElbow, joints.rightElbow, joints.leftWrist, joints.rightWrist,
            joints.leftHip, joints.rightHip, joints.leftKnee, joints.rightKnee,
            joints.leftAnkle, joints.rightAnkle
        ]

        for point in jointPoints.compactMap({ $0 }) {
            let screen = toScreen(point)
            let rect   = CGRect(x: screen.x - 5, y: screen.y - 5, width: 10, height: 10)
            context.fill(Circle().path(in: rect), with: .color(.white))
            context.stroke(Circle().path(in: rect), with: .color(.orange), lineWidth: 2)
        }
    }

    private func drawBone(_ context: GraphicsContext, from a: CGPoint?, to b: CGPoint?, color: Color, style: GraphicsContext.StrokeStyle) {
        guard let a, let b else { return }
        var path = Path()
        path.move(to: toScreen(a))
        path.addLine(to: toScreen(b))
        context.stroke(path, with: .color(color), style: style)
    }

    /// Converts Vision normalized coordinates to SwiftUI view coordinates.
    /// Vision: origin bottom-left. SwiftUI: origin top-left. Y axis is flipped.
    private func toScreen(_ point: CGPoint) -> CGPoint {
        CGPoint(x: point.x * size.width, y: (1 - point.y) * size.height)
    }
}
