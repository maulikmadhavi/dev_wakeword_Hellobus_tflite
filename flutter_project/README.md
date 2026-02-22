# Hellobus Wakeword — Flutter Web Demo

A Flutter web UI that visualises real-time wakeword detection scores for the Hellobus speech recognition system. The UI simulates the inference pipeline that runs on-device via TensorFlow Lite.

## Requirements

| Tool | Version |
|------|---------|
| Flutter | 3.41.2 (stable) |
| Dart | 3.11.0 |
| Browser | Chrome / Edge (web target) |

No Android SDK, Java, or native toolchain is required for the web build.

## Setup

```bash
# Install dependencies
flutter pub get

# Enable web (one-time)
flutter config --enable-web
flutter create . --platforms web
```

## Build

**Development server with hot reload:**
```bash
flutter run -d web-server --web-hostname 0.0.0.0 --web-port 8080
```

**Production build:**
```bash
flutter build web --release
# Output: build/web/
```

**Serve the production build:**
```bash
cd build/web
python3 -m http.server 8080 --bind 0.0.0.0
# Open: http://<your-ip>:8080
```

> On WSL2, use `hostname -I` to get your IP and open it in the Windows browser.

## Architecture

```
lib/
└── main.dart
    ├── HellobusApp            # Root MaterialApp, theme config
    └── WakewordScreen         # Main screen (StatefulWidget)
        ├── _buildMicButton        # Animated pulsing mic button
        ├── _buildDetectedWord     # Animated detected wakeword badge
        ├── _buildScoreBars        # Per-wakeword confidence bars
        └── _buildModelInfoCard    # Static model metadata display
```

### State Flow

```
User taps mic
    → _toggleListening()
        → setState: _isListening = true
        → _startSimulation()
            → Timer (300ms) fires repeatedly
                → generates simulated scores
                → setState: _scores, _detectedWord, _confidence
                → UI rebuilds: score bars + detected word badge
User taps mic again
    → _simulationTimer.cancel()
    → setState: _isListening = false, scores reset to 0
```

### Simulation vs Real Inference

The web build uses a random score simulator to mimic TFLite output. To target Android, replace `_startSimulation()` with:

1. **`record`** package — stream PCM16 audio at 16kHz from microphone
2. **`tflite_flutter`** package — run `retrained_graph.tflite` on 800ms audio frames
3. Feed softmax output directly into `setState(_scores = ...)`

The UI requires no changes — it consumes `_scores: List<double>` regardless of source.

### Wakewords

| Index | Label | Displayed |
|-------|-------|-----------|
| 0 | `_silence_` | No |
| 1 | `_unknown_` | No |
| 2 | `hellobus` | Yes |
| 3 | `busagent` | Yes |
| 4 | `okbus` | Yes |
| 5 | `okagent` | Yes |

Detection threshold: **75% confidence**.
