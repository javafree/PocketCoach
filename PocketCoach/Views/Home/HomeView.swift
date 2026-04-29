import SwiftUI

struct HomeView: View {
    @State private var selectedExercise: Exercise?

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    Text("What are we training today?")
                        .font(.title2.weight(.semibold))
                        .padding(.horizontal)

                    VStack(spacing: 14) {
                        ForEach(Exercise.allCases) { exercise in
                            ExerciseCard(exercise: exercise) {
                                selectedExercise = exercise
                            }
                        }
                    }
                    .padding(.horizontal)
                }
                .padding(.top)
            }
            .navigationTitle("PocketCoach")
            .fullScreenCover(item: $selectedExercise) { exercise in
                WorkoutView(exercise: exercise)
            }
        }
    }
}
