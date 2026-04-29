# Architecture

## Overview

PocketCoach runs a real-time computer vision pipeline on every camera frame at up to 30fps. The architecture is layered so that each concern is isolated and independently testable.

```
Camera Frame (CMSampleBuffer)
        |
        v
PoseDetectionService        <-- Vision framework (VNDetectHumanBodyPoseRequest)
        |
        v
JointPositions              <-- normalized coordinates, Vision space
        |
   +----+----+
   |         |
   v         v
FormAnalyzer  RepCounter    <-- pure functions / state machine, no I/O
   |         |
   v         v
WorkoutViewModel            <-- @MainActor, drives UI updates
        |
        v
SwiftUI Views               <-- CameraPreviewView, PoseOverlayView, HUDView
```

---

## Coordinate Systems

Vision returns joint positions in a normalized coordinate space:
- Origin at **bottom-left**
- x and y both in [0, 1]

SwiftUI Canvas has its origin at **top-left**. The `PoseOverlayView` converts between the two:

```swift
func toScreen(_ point: CGPoint) -> CGPoint {
    CGPoint(x: point.x * size.width, y: (1 - point.y) * size.height)
}
```

All form analysis and rep counting runs in Vision coordinate space. The conversion only happens at render time.

---

## Layers

### Models (pure value types)

| Type | Purpose |
|------|---------|
| `Exercise` | Enum of supported exercises with metadata |
| `JointPositions` | All 19 body joint positions for one frame |
| `RepState` | State machine phase: ready, descending, bottom, ascending |
| `FormIssue` | A detected form problem with severity and corrective cue |
| `WorkoutSession` | Persisted record of a completed workout |

### Services

| Service | Type | Responsibility |
|---------|------|----------------|
| `CameraService` | `actor` | Manages `AVCaptureSession`, delivers frames via `AsyncStream` |
| `PoseDetectionService` | `enum` | Runs `VNDetectHumanBodyPoseRequest` per frame |
| `FormAnalyzer` | `enum` | Geometric rule engine, one function per exercise |
| `RepCounter` | `final class` | State machine tracking rep phases and count |
| `WorkoutHistoryService` | `actor` | JSON persistence to Documents directory |
| `HealthKitService` | `actor` | Writes `HKWorkout` to Apple Health after each session |
| `AudioCueService` | `actor` | Spoken rep counts and form corrections via AVSpeechSynthesizer |

### ViewModels

`WorkoutViewModel` (@MainActor): orchestrates the pipeline for an active session. Processes each camera frame, updates published state, coordinates between services.

`HistoryViewModel` (@MainActor): loads past sessions and computes weekly chart data and streak.

### Views

```
RootView (TabView)
├── HomeView
│   └── WorkoutView (fullScreenCover)
│       ├── CameraPreviewView    (UIViewRepresentable)
│       ├── PoseOverlayView      (Canvas, skeleton drawing)
│       ├── FormFeedbackBanner   (top overlay)
│       ├── HUDView              (rep count, timer, phase dots)
│       └── WorkoutSummaryView   (post-session)
└── HistoryView
    ├── SummaryTiles
    ├── Weekly bar chart (Swift Charts)
    └── WorkoutDetailView
```

---

## AVFoundation + Vision Pipeline

```
AVCaptureSession
    └── AVCaptureVideoDataOutput
            └── FrameOutputDelegate (NSObject, runs on camera queue)
                    └── CameraService.deliver() (actor hop)
                            └── AsyncStream<CMSampleBuffer>
                                    └── WorkoutViewModel.processFrame()
                                            └── PoseDetectionService.detect()
                                                    └── VNDetectHumanBodyPoseRequest
```

Key decisions:
- `VNDetectHumanBodyPoseRequest` is created once and reused across frames (cheaper than per-frame allocation)
- `alwaysDiscardsLateVideoFrames = true` on the output so the pipeline never backs up
- Frame processing is async but UI updates are always dispatched to `@MainActor`

---

## Rep State Machine

```
       +-------+
       | ready |<--------------------------+
       +---+---+                           |
           | knee/elbow angle drops        |
           v                               |
    +------------+                         |
    | descending |                         |
    +-----+------+                         |
          | reaches depth threshold        |
          v                               |
       +--------+                         |
       | bottom |                         |
       +---+----+                         |
           | angle starts increasing      |
           v                               |
      +-----------+   angle > threshold   |
      | ascending |---------------------->+ count++
      +-----------+
```

Angle thresholds (degrees):

| Exercise | Descending | Bottom | Back to Ready |
|----------|-----------|--------|---------------|
| Squat (knee) | < 155 | < 95 | > 155 |
| Push-up (elbow) | < 155 | < 90 | > 155 |

---

## Form Analysis

`FormAnalyzer` is a pure enum with one static function per exercise. Each function takes `JointPositions` and returns `[FormIssue]`. No state, no side effects — straightforward to unit test.

Rules use two geometric primitives from `CGPoint+Geometry.swift`:
- `angle(to:and:)` — angle in degrees at a vertex
- `distance(to:)` — Euclidean distance between points

Example (knee cave detection):
```swift
if let leftKnee  = joints.leftKnee,
   let leftAnkle = joints.leftAnkle,
   leftKnee.x > leftAnkle.x + 0.04 {
    issues.append(.kneeCave)
}
```

---

## Concurrency

- `CameraService` is a Swift `actor`. Frame delivery crosses an actor boundary via `AsyncStream`.
- `PoseDetectionService` and `FormAnalyzer` are `enum` namespaces with pure functions — called from any context.
- `RepCounter` is a `final class` owned exclusively by `WorkoutViewModel` on `@MainActor`.
- All UI mutations happen through `WorkoutViewModel`'s `@Published` properties on `@MainActor`.
- `HealthKitService` and `WorkoutHistoryService` are actors — awaited after the session ends.

---

## Accessibility

- All interactive elements have explicit `accessibilityLabel` values
- `PoseOverlayView` (Canvas) is marked `accessibilityHidden(true)` — decorative
- `AudioCueService` speaks rep counts and form cues so the app is usable without looking at the screen
- Rep state dots in `HUDView` have an `accessibilityLabel` describing the current phase
- Portrait-only orientation is enforced — the form analysis geometry assumes vertical body orientation
