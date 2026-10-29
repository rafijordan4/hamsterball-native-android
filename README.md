# Hamster Roll Native (prototype)

A small, original Godot 4 3D rolling-ball prototype intended to establish the Android build pipeline. It is **not** a conversion of the original Hamsterball game and does not include the original game's assets or executable.

## Controls
- Touch the on-screen LEFT / RIGHT / FORWARD / BACK buttons.
- On a keyboard, use arrow keys.
- RESET returns the ball to the start.

## Build
GitHub Actions builds a debug APK from `.github/workflows/android.yml` when code is pushed to `main`, or when manually started via Actions > Build Hamster Roll Android APK > Run workflow.

The artifact is named `HamsterRollNative-debug-apk`.

## Important
The original Hamsterball game is copyrighted. Reusing its art, sounds, levels, or other assets in a distributed port requires checking the rights and obtaining permission where necessary. This repository uses generated placeholder geometry and original script code.
