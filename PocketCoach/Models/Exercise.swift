import Foundation

enum Exercise: String, CaseIterable, Codable, Identifiable {
    case squat   = "Squat"
    case pushup  = "Push-up"
    case plank   = "Plank"

    var id: String { rawValue }

    var isTimeBased: Bool { self == .plank }

    var emoji: String {
        switch self {
        case .squat:  return "🦵"
        case .pushup: return "💪"
        case .plank:  return "🧘"
        }
    }

    var description: String {
        switch self {
        case .squat:
            return "Stand with feet shoulder-width apart. Lower until thighs are parallel to the floor, then drive back up."
        case .pushup:
            return "Start in a high plank. Lower your chest to the floor keeping your body straight, then push back up."
        case .plank:
            return "Hold a forearm plank with a straight line from head to heels. Keep your core tight throughout."
        }
    }

    var keyPoints: [String] {
        switch self {
        case .squat:
            return ["Knees track over toes", "Chest stays upright", "Hips below knees at depth", "Drive through heels"]
        case .pushup:
            return ["Body forms a straight line", "Elbows at 45 degrees", "Full range of motion", "No sagging hips"]
        case .plank:
            return ["Neutral spine", "Hips level", "Core engaged", "No hip pike or sag"]
        }
    }
}
