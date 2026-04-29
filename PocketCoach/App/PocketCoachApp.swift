import SwiftUI

@main
struct PocketCoachApp: App {
    var body: some Scene {
        WindowGroup {
            RootView()
                .task {
                    try? await HealthKitService.shared.requestAuthorization()
                }
        }
    }
}

struct RootView: View {
    var body: some View {
        TabView {
            HomeView()
                .tabItem { Label("Train", systemImage: "figure.strengthtraining.functional") }
            HistoryView()
                .tabItem { Label("History", systemImage: "chart.bar.fill") }
        }
        .tint(.orange)
    }
}
