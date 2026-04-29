import Vision

extension VNHumanBodyPoseObservation {

    /// Returns the normalized position of a joint if confidence exceeds the threshold.
    func point(_ jointName: VNHumanBodyPoseObservation.JointName, minConfidence: Float = 0.3) -> CGPoint? {
        guard let point = try? recognizedPoint(jointName),
              point.confidence >= minConfidence else { return nil }
        return point.location
    }

    /// Builds a JointPositions struct from this observation.
    func jointPositions() -> JointPositions {
        JointPositions(
            nose:          point(.nose),
            leftEye:       point(.leftEye),
            rightEye:      point(.rightEye),
            leftEar:       point(.leftEar),
            rightEar:      point(.rightEar),
            leftShoulder:  point(.leftShoulder),
            rightShoulder: point(.rightShoulder),
            leftElbow:     point(.leftElbow),
            rightElbow:    point(.rightElbow),
            leftWrist:     point(.leftWrist),
            rightWrist:    point(.rightWrist),
            leftHip:       point(.leftHip),
            rightHip:      point(.rightHip),
            leftKnee:      point(.leftKnee),
            rightKnee:     point(.rightKnee),
            leftAnkle:     point(.leftAnkle),
            rightAnkle:    point(.rightAnkle),
            neck:          point(.neck),
            root:          point(.root)
        )
    }
}
