import Vision
import CoreMedia

enum PoseDetectionError: LocalizedError {
    case processingFailed(underlying: Error)
    case noPoseFound

    var errorDescription: String? {
        switch self {
        case .processingFailed(let e): return "Pose detection failed: \(e.localizedDescription)"
        case .noPoseFound:             return "No person detected in frame."
        }
    }
}

/// Runs VNDetectHumanBodyPoseRequest on a CMSampleBuffer.
/// Reuses a single request object across frames for efficiency.
enum PoseDetectionService {

    private static let request = VNDetectHumanBodyPoseRequest()

    /// Returns joint positions from the most prominent person in the frame.
    /// Returns nil if no person is detected (not an error — just no subject).
    static func detect(in buffer: CMSampleBuffer) throws -> JointPositions? {
        let handler = VNImageRequestHandler(cmSampleBuffer: buffer, options: [:])
        do {
            try handler.perform([request])
        } catch {
            throw PoseDetectionError.processingFailed(underlying: error)
        }

        guard let observation = request.results?.first else { return nil }
        let positions = observation.jointPositions()
        return positions.isEmpty ? nil : positions
    }
}
