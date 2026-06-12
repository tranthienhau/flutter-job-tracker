# Screenshot capture flow

Real captures from the iOS Simulator via an integration-test driver (no mockups).

## Steps

1. Boot the simulator:
   ```bash
   xcrun simctl boot "iPhone 17 Pro Max"
   open -a Simulator
   ```
2. Scaffold the iOS platform folder (if missing) and get dependencies:
   ```bash
   flutter create . --platforms=ios --project-name flutter_job_tracker
   flutter pub get
   ```
3. Drive the screenshot test:
   ```bash
   flutter drive \
     --driver test_driver/integration_test.dart \
     --target integration_test/screenshot_test.dart \
     -d "B4172C2F-DF1D-4269-85FD-CBC4ADC6D393"
   ```
4. Build the demo GIF from the PNGs:
   ```bash
   cd screenshots
   ffmpeg -y -framerate 1 -pattern_type glob -i '*.png' \
     -vf "scale=320:-1:flags=lanczos,split[s0][s1];[s0]palettegen[p];[s1][p]paletteuse" \
     -loop 0 demo.gif
   ```

PNGs + `demo.gif` are written to `screenshots/` and embedded in `README.md`.

## How it works

- `test_driver/integration_test.dart` - `integrationDriver(onScreenshot:)` writes each PNG to `screenshots/<name>.png`.
- `integration_test/screenshot_test.dart` - initializes Hive and opens the `jobs` box so the Riverpod `jobProvider` auto-seeds its sample jobs, then pumps each screen directly inside a `ProviderScope` + `MaterialApp` (avoiding `main()` router init):
  - `01-dashboard` - `DashboardScreen` showing live stats plus urgent and active jobs.
  - `02-jobs-list` - `JobsScreen` showing the filter chips and priority-sorted job cards.
  - `03-job-detail` - `JobDetailScreen(jobId: '1')` showing client info, notes, and status actions.
- Each capture calls `binding.convertFlutterSurfaceToImage()` + `pumpAndSettle()` + `binding.takeScreenshot('NN-name')`.
