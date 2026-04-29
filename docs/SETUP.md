# Setup Guide

## Requirements

| Tool | Version |
|------|---------|
| Xcode | 15.0+ |
| iOS Deployment Target | 17.0+ |
| XcodeGen | 2.40+ |
| Physical iPhone | Recommended (camera required for full functionality) |

The iOS Simulator does not have a camera. You can run the app in the Simulator but workout sessions will not start. All other screens (Home, History, widget preview) work in the Simulator.

## 1. Install XcodeGen

```bash
brew install xcodegen
```

## 2. Generate the Xcode project

```bash
cd PocketCoach
xcodegen generate
open PocketCoach.xcodeproj
```

## 3. Set your bundle ID

In `project.yml`, replace `com.yourname` with your reverse-domain identifier. Re-run `xcodegen generate`.

## 4. Enable HealthKit

In the Apple Developer portal, enable the HealthKit capability for your App ID. In Xcode's Signing & Capabilities tab, add HealthKit to the PocketCoach target.

## 5. Run tests

```
cmd+U in Xcode
```

All tests are pure unit tests with no camera or HealthKit dependencies. Run on any Simulator.

## 6. Run on device

Connect an iPhone, select it as the destination, and press Run. Accept the camera and HealthKit permission prompts on first launch.

---

## Troubleshooting

**Workout screen shows black + "Camera Error"**
The front camera is unavailable or permission was denied. Go to Settings > Privacy > Camera > PocketCoach and enable access.

**Pose overlay not appearing**
Make sure you are well-lit and your full body is visible in the frame. Vision requires a minimum confidence threshold (0.3) per joint. Poor lighting or partial occlusion will suppress low-confidence joints.

**HealthKit save failing silently**
The HealthKit entitlement must be configured in both the Developer portal and Xcode. The app logs workout data locally regardless — HealthKit failure is non-fatal.

**Simulator crash on workout start**
Expected. The simulator has no camera. Use a physical device for workout sessions.
