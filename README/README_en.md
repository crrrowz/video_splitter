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

- **Video Splitting**: Split long videos into smaller segments based on a set duration.

- **Speed Adjustment**: Change the video playback speed (faster or slower).

- **Audio Noise Removal**: Automatically detect and remove silent or noisy audio segments using a configurable threshold.

- **Audio & Video Filters**: Apply filters like grayscale or remove the audio track completely.

- **Hardware Acceleration**: Utilizes hardware acceleration (e.g., h264_mediacodec) for faster video re-encoding.

- **Staged Processing**: Applies processing in a defined pipeline (e.g., Noise Removal > Background Removal > Basic Processing).

- **Dynamic Theming**: App automatically switches between light and dark mode based on system settings.

---

## ⚙️ Setup Guide

### 1. Prerequisites

Ensure you have the Flutter SDK installed on your system.

### 2. Clone Repository

Clone the project repository to your local machine (once available).

```bash
git clone <repository_url>
```

### 3. Install Dependencies

Navigate to the project directory and run `flutter pub get` to install all required dependencies.

```bash
cd video_splitter
flutter pub get
```

### 4. Run the Application

Connect a device or start an emulator, then run the app.

```bash
flutter run
```

---