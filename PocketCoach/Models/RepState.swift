import Foundation

/// Phase of a single repetition, modeled as a state machine.
/// Transitions: ready -> descending -> bottom -> ascending -> ready (rep counted)
enum RepState: Equatable {
    case ready         // starting position, waiting for movement
    case descending    // moving toward the bottom position
    case bottom        // at or past the target depth
    case ascending     // returning to the starting position
}
