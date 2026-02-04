<h1 align="center">Video Splitter</h1>

<table style="width:100%; border-collapse: collapse;">
<tr>
<td style="width:40%; text-align:center; vertical-align:middle;">
  <img src="https://github.com/crrrowz/Video_Splitter/blob/main/README/app.png?raw=true" width="300" />
</td>
<td style="width:60%; vertical-align:middle; padding:10px; text-align:left;">
Video Splitter is a cross-platform Flutter application designed for advanced video processing. It allows users to split videos into segments, adjust playback speed, apply filters like grayscale, remove audio, and perform audio noise reduction. It features a staged processing pipeline, hardware acceleration support, and dynamic theme switching.
</td>
</tr>
</table>

---

## ✨ Main Features

- **Video Splitting**: Split long videos into smaller segments based on a configurable duration.
- **Speed Adjustment**: Change the video playback speed (faster or slower).
- **Audio Noise Removal**: Automatically detect and remove silent or noisy audio segments using highpass/lowpass filters and configurable thresholds.
- **Audio & Video Filters**: Apply grayscale filter or remove the audio track entirely.
- **Hardware Acceleration**: Utilizes hardware-accelerated encoding (libx264/h264) for faster video re-encoding.
- **Staged Processing**: Applies processing in a defined pipeline (Noise Removal → Basic Processing).
- **Dynamic Theming**: App automatically switches between light and dark mode based on system settings.
- **Settings Persistence**: User preferences are saved locally and restored on app restart.
- **Dynamic App Icon**: App icon changes based on system theme (light/dark).

> **Note**: Background Removal is currently **experimental** and disabled by default. It does not produce output in the current version.

---

## 🏗️ Architecture

### Processing Pipeline

```
┌─────────────────┐     ┌─────────────────────┐     ┌──────────────────┐
│  Video Input    │ ──► │  NoiseRemovalProc   │ ──► │ BasicVideoProc   │ ──► Output
└─────────────────┘     └─────────────────────┘     └──────────────────┘
                         (if enabled)
```

### Core Components

| Component | File | Description |
|-----------|------|-------------|
| `VideoProcessor` | `video_processor.dart` | Abstract base class with FFmpeg execution logic |
| `BasicVideoProcessor` | `basic_video_processor.dart` | Handles splitting, speed, filters, audio removal |
| `NoiseRemovalProcessor` | `noise_removal_processor.dart` | Audio filtering with highpass/lowpass + silence removal |
| `AppSettings` | `app_settings.dart` | Persisted user settings via SharedPreferences |
| `AppConfig` | `app_config_loader.dart` | Loads configuration from `app_config.json` |

---

## ⚙️ Setup Guide

### Prerequisites

- Flutter SDK (^3.9.2 or higher)
- Android Studio / Xcode (for mobile builds)

### Installation

1. **Clone Repository**

```bash
git clone https://github.com/crrrowz/Video_Splitter.git
```

2. **Install Dependencies**

```bash
cd Video_Splitter
flutter pub get
```

3. **Run the Application**

```bash
flutter run
```

---

## 📱 Supported Platforms

| Platform | Status |
|----------|--------|
| Android  | ✅ Fully Supported |
| iOS      | ✅ Supported |
| Windows  | ✅ Supported |
| macOS    | ✅ Supported |
| Linux    | ✅ Supported |
| Web      | ⚠️ Limited (FFmpeg constraints) |

---

## 🔒 Privacy

- **No data collection**: All processing happens locally on-device.
- **No analytics**: No third-party tracking or analytics.
- **Local storage only**: Settings and output files are stored on the device.

---

## 📄 License

MIT License - See [LICENSE](../LICENSE) for details.