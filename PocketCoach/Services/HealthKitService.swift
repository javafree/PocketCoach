import HealthKit
import Foundation

enum HealthKitError: LocalizedError {
    case notAvailable
    case authorizationDenied
    case saveFailed(underlying: Error)

    var errorDescription: String? {
        switch self {
        case .notAvailable:           return "HealthKit is not available on this device."
        case .authorizationDenied:    return "HealthKit access denied."
        case .saveFailed(let e):      return "Failed to save workout: \(e.localizedDescription)"
        }
    }
}

actor HealthKitService {
    static let shared = HealthKitService()
    private let store = HKHealthStore()
    private var isAuthorized = false

    private init() {}

    func requestAuthorization() async throws {
        guard HKHealthStore.isHealthDataAvailable() else { throw HealthKitError.notAvailable }
        let types: Set<HKSampleType> = [HKObjectType.workoutType()]
        try await store.requestAuthorization(toShare: types, read: [])
        isAuthorized = true
    }

    func save(session: WorkoutSession) async throws {
        guard HKHealthStore.isHealthDataAvailable() else { return }

        let activityType: HKWorkoutActivityType = {
            switch session.exercise {
            case .squat, .pushup: return .functionalStrengthTraining
            case .plank:          return .coreTraining
            }
        }()

        guard let start = session.endedAt.map({ _ in session.startedAt }),
              let end   = session.endedAt else { return }

        let workout = HKWorkout(
            activityType: activityType,
            start:        start,
            end:          end,
            duration:     session.duration,
            totalEnergyBurned: nil,
            totalDistance: nil,
            metadata: [
                HKMetadataKeyWorkoutBrandName: "PocketCoach",
                "totalReps": session.totalReps,
                "formScore": session.formScore
            ]
        )

        do {
            try await store.save(workout)
        } catch {
            throw HealthKitError.saveFailed(underlying: error)
        }
    }
}
