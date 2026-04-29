import SwiftUI

struct WorkoutView: View {
    let exercise: Exercise
    @StateObject private var vm: WorkoutViewModel
    @Environment(\.dismiss) private var dismiss

    init(exercise: Exercise) {
        self.exercise = exercise
        _vm = StateObject(wrappedValue: WorkoutViewModel(exercise: exercise))
    }

    var body: some View {
        ZStack {
            if vm.isFinished {
                WorkoutSummaryView(session: vm.session) { dismiss() }
            } else {
                cameraScreen
            }
        }
        .ignoresSafeArea()
        .task { await vm.start() }
        .alert("Camera Error", isPresented: .constant(vm.cameraError != nil)) {
            Button("OK") { dismiss() }
        } message: {
            Text(vm.cameraError ?? "")
        }
    }

    private var cameraScreen: some View {
        GeometryReader { geo in
            ZStack {
                // Camera preview
                CameraPreviewView(session: CameraService.shared.session)
                    .ignoresSafeArea()

                // Pose skeleton overlay
                if let joints = vm.jointPositions {
                    PoseOverlayView(joints: joints, size: geo.size)
                        .ignoresSafeArea()
                }

                // Form feedback banner at top
                VStack {
                    Spacer().frame(height: geo.safeAreaInsets.top + 60)
                    withAnimation(.easeInOut(duration: 0.3)) {
                        FormFeedbackBanner(issues: vm.formIssues)
                    }
                    Spacer()
                }

                // HUD
                HUDView(
                    exercise:       exercise,
                    repCount:       vm.repCount,
                    elapsedSeconds: vm.elapsedSeconds,
                    repState:       vm.repState,
                    onStop:         { Task { await vm.stop() } }
                )
            }
        }
    }
}
