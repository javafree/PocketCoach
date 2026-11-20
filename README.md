# PocketCoach

A real-time exercise form analyzer for iOS.

Point your front camera at yourself doing squats, push-ups, or planks. PocketCoach uses the Vision framework to detect your body joints at up to 30fps, draws a skeleton overlay, counts your reps, and tells you when your form breaks — all on-device with no backend.

---

## Demo

| Home | Active Workout | Form Feedback | History |
|:----:|:--------------:|:-------------:|:-------:|
| ![Home](docs/screenshots/home.png) | ![Workout](docs/screenshots/workout.png) | ![Form](docs/screenshots/form.png) | ![History](docs/screenshots/history.png) |

---

## Features

- **Real-time pose estimation**: `VNDetectHumanBodyPoseRequest` tracks 19 body joints at up to 30fps.
- **Skeleton overlay**: orange stick figure drawn on the live camera feed using SwiftUI `Canvas`.
- **Rep counting**: state machine tracks descent, depth, and ascent for squats and push-ups.
- **Form analysis**: geometric rule engine checks joint angles and relative positions each frame.
- **Spoken cues**: `AVSpeechSynthesizer` announces rep counts and corrective cues so you can work out without looking at the screen.
- **Form score**: 0-100 score calculated from issue frequency relative to reps completed.
- **HealthKit integration**: writes an `HKWorkout` to Apple Health after each session.
- **Workout history**: every session logged locally with rep count, duration, and form score.
- **Weekly chart**: Swift Charts bar chart showing reps per day for the past 7 days.
- **WidgetKit widget**: streak counter and today's session count on the Home Screen.
- **Accessibility**: all UI elements have VoiceOver labels; audio cues make the workout screen usable eyes-free.

### Supported Exercises

| Exercise | Detection method | Form checks |
|----------|-----------------|-------------|
| Squat | Knee angle state machine | Knee cave, forward lean, depth |
| Push-up | Elbow angle state machine | Hip sag, hip pike, elbow flare, head drop |
| Plank | Time-based | Hip sag, hip pike, head drop |

---

## Architecture

```
Camera Frame (CMSampleBuffer)
        |
        v
PoseDetectionService  <-- VNDetectHumanBodyPoseRequest (reused per frame)
        |
        v
JointPositions        <-- 19 normalized body joints, Vision coordinates
        |
   +----+----+
   |         |
   v         v
FormAnalyzer  RepCounter     <-- pure functions / state machine
   |         |
   v         v
WorkoutViewModel              <-- @MainActor, @Published state
        |
        v
CameraPreviewView + PoseOverlayView + HUDView  <-- SwiftUI
```

Vision coordinates have their origin at bottom-left. SwiftUI Canvas has it at top-left. The coordinate flip happens only at render time in `PoseOverlayView`.

Full architecture documentation: [docs/ARCHITECTURE.md](docs/ARCHITECTURE.md)

---

## Tech Stack

| Area | Technology |
|------|-----------|
| UI | SwiftUI (iOS 17) |
| UIKit interop | `UIViewRepresentable` for camera preview |
| Charts | Swift Charts |
| Pose estimation | Vision (`VNDetectHumanBodyPoseRequest`) |
| Camera | AVFoundation (`AVCaptureSession`, `AVCaptureVideoDataOutput`) |
| Audio cues | `AVSpeechSynthesizer` |
| Health | HealthKit (`HKWorkout`) |
| Persistence | JSON + `FileManager` |
| Concurrency | Swift actors, `@MainActor`, `AsyncStream` |
| Widget | WidgetKit |
| Testing | XCTest (pure unit tests, no camera dependency) |
| Project config | XcodeGen (`project.yml`) |

---

## Project Structure

```
PocketCoach/
├── project.yml
├── PocketCoach/
│   ├── App/
│   │   └── PocketCoachApp.swift     # Entry point, TabView
│   ├── Models/
│   │   ├── Exercise.swift           # Enum with metadata and key points
│   │   ├── JointPositions.swift     # 19-joint struct, midpoint helpers
│   │   ├── RepState.swift           # State machine phases
│   │   ├── FormIssue.swift          # Issue type with severity and audio cue
│   │   └── WorkoutSession.swift     # Persisted session record
│   ├── Services/
│   │   ├── CameraService.swift      # actor, AVCaptureSession + AsyncStream
│   │   ├── PoseDetectionService.swift  # VNDetectHumanBodyPoseRequest wrapper
│   │   ├── FormAnalyzer.swift       # Pure geometric rule engine
│   │   ├── RepCounter.swift         # State machine, one instance per session
│   │   ├── WorkoutHistoryService.swift  # actor, JSON persistence
│   │   ├── HealthKitService.swift   # actor, HKWorkout write
│   │   └── AudioCueService.swift    # actor, AVSpeechSynthesizer
│   ├── ViewModels/
│   │   ├── WorkoutViewModel.swift   # Pipeline orchestration
│   │   └── HistoryViewModel.swift   # History aggregation and chart data
│   ├── Views/
│   │   ├── Home/       HomeView, ExerciseCard
│   │   ├── Workout/    WorkoutView, CameraPreviewView, PoseOverlayView,
│   │   │               HUDView, FormFeedbackBanner, WorkoutSummaryView
│   │   └── History/    HistoryView, WorkoutDetailView
│   └── Extensions/
│       ├── CGPoint+Geometry.swift                    # angle(), distance(), clamped()
│       └── VNHumanBodyPoseObservation+Joints.swift   # jointPositions() convenience
│
├── PocketCoachWidget/
│   └── PocketCoachWidget.swift      # Streak + today's sessions
│
├── PocketCoachTests/
│   ├── RepCounterTests.swift        # 12 tests: state machine transitions
│   ├── FormAnalyzerTests.swift      # 6 tests: good form and specific issues
│   └── CGPointGeometryTests.swift   # 11 tests: angle, distance, clamped
│
└── docs/
    ├── ARCHITECTURE.md
    └── SETUP.md
```

---

## Rep State Machine

```
   +-------+
   | ready |<-------------------------------+
   +---+---+                                |
       | angle drops below threshold        |
       v                                    |
+------------+                              |
| descending |                              |
+-----+------+                              |
      | reaches depth                       |
      v                                     |
   +--------+                               |
   | bottom |                               |
   +---+----+                               |
       | angle starts increasing            |
       v                                    |
  +-----------+   angle above threshold     |
  | ascending |------> count++ ----------->+
  +-----------+
```

Implemented in `RepCounter.swift` as a pure state machine. The `FormAnalyzer` is separate — it runs the same joint positions through geometric rules independently of the rep count logic.

---

## Geometry Primitives

```swift
// CGPoint+Geometry.swift
func angle(to a: CGPoint, and b: CGPoint) -> Double
func distance(to other: CGPoint) -> Double
func bearing(to other: CGPoint) -> Double
```

`angle(to:and:)` computes the angle at `self` using the dot product formula. Used for knee angle in squats, elbow angle in push-ups, and body alignment in planks.

---

## Tests

```bash
cmd+U in Xcode
# or
xcodebuild test -scheme PocketCoach -destination 'platform=iOS Simulator,name=iPhone 16'
```

29 tests across three files. No camera, no HealthKit, no network — runs on any Simulator.

**RepCounterTests** (12 tests): full state machine coverage for squats and push-ups, including multi-rep sequences, reset behavior, and return values.

**FormAnalyzerTests** (6 tests): good-form baseline (no issues expected) plus specific issue detection for knee cave, shallow depth, hip sag, and plank misalignment.

**CGPointGeometryTests** (11 tests): 90, 180, 0, and 45 degree angle cases; symmetry; coincident points; distance triangle; clamped boundary conditions.

---

## Getting Started

The generated Xcode project is included in the repository. Clone the repo and open it directly:

```bash
git clone https://github.com/javafree/PocketCoach
cd PocketCoach
open PocketCoach.xcodeproj
```

To regenerate the project after changing `project.yml`, install XcodeGen and run `xcodegen generate`:

```bash
brew install xcodegen
xcodegen generate --spec project.yml
```

A physical iPhone is required for workout sessions. The iOS Simulator has no camera.

---

## What I Would Add Next

- **More exercises**: lunges, pull-ups, deadlifts — the state machine and form analyzer extend naturally
- **Sets and reps targets**: let the user set a target (3 sets of 10) before starting
- **Historical form trends**: track whether form score improves over time per exercise
- **Rep tempo analysis**: use response time between state transitions to flag reps that are too fast
- **Apple Watch companion**: send rep counts to the watch face during a session

---

## License

MIT
