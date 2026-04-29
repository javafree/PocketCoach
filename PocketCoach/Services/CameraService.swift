import AVFoundation
import UIKit

enum CameraError: LocalizedError {
    case permissionDenied
    case deviceUnavailable
    case configurationFailed(underlying: Error)

    var errorDescription: String? {
        switch self {
        case .permissionDenied:            return "Camera access denied. Enable it in Settings."
        case .deviceUnavailable:           return "No camera found on this device."
        case .configurationFailed(let e):  return "Camera setup failed: \(e.localizedDescription)"
        }
    }
}

/// Manages the AVCaptureSession and delivers video frames as an AsyncStream.
actor CameraService {
    static let shared = CameraService()

    let session = AVCaptureSession()
    private var frameStream: AsyncStream<CMSampleBuffer>?
    private var continuation: AsyncStream<CMSampleBuffer>.Continuation?
    private let outputDelegate = FrameOutputDelegate()

    private init() {}

    // MARK: - Public API

    var frames: AsyncStream<CMSampleBuffer> {
        get async {
            let stream = AsyncStream<CMSampleBuffer> { continuation in
                self.continuation = continuation
                outputDelegate.onFrame = { [weak self] buffer in
                    Task { await self?.deliver(buffer) }
                }
            }
            return stream
        }
    }

    func start() async throws {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized: break
        case .notDetermined:
            let granted = await AVCaptureDevice.requestAccess(for: .video)
            if !granted { throw CameraError.permissionDenied }
        default:
            throw CameraError.permissionDenied
        }

        guard let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .front)
                ?? AVCaptureDevice.default(for: .video) else {
            throw CameraError.deviceUnavailable
        }

        do {
            session.beginConfiguration()
            session.sessionPreset = .high

            let input = try AVCaptureDeviceInput(device: device)
            if session.canAddInput(input) { session.addInput(input) }

            let output = AVCaptureVideoDataOutput()
            output.videoSettings = [kCVPixelBufferPixelFormatTypeKey as String: kCVPixelFormatType_32BGRA]
            output.alwaysDiscardsLateVideoFrames = true
            let queue = DispatchQueue(label: "com.pocketcoach.camera", qos: .userInitiated)
            output.setSampleBufferDelegate(outputDelegate, queue: queue)
            if session.canAddOutput(output) { session.addOutput(output) }

            // Portrait orientation
            output.connection(with: .video)?.videoRotationAngle = 90

            session.commitConfiguration()
        } catch {
            throw CameraError.configurationFailed(underlying: error)
        }

        session.startRunning()
    }

    func stop() {
        session.stopRunning()
        continuation?.finish()
        continuation = nil
    }

    // MARK: - Private

    private func deliver(_ buffer: CMSampleBuffer) {
        continuation?.yield(buffer)
    }
}

// MARK: - Frame Delegate

private final class FrameOutputDelegate: NSObject, AVCaptureVideoDataOutputSampleBufferDelegate {
    var onFrame: ((CMSampleBuffer) -> Void)?

    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        onFrame?(sampleBuffer)
    }
}
