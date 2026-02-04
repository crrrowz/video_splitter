<h1 align="center">Video Splitter</h1>

<p align="center">
  <a href="README/README_en.md">🇬🇧 English</a> • 
  <a href="README/README_ar.md">🇸🇦 العربية</a>
</p>

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

## 📦 Project Structure

```
video_splitter/
├── lib/
│   ├── main.dart              # App entry point & theme configuration
│   ├── models/
│   │   ├── app_config_loader.dart  # JSON config loader
│   │   └── app_settings.dart       # User settings persistence
│   ├── pages/
│   │   ├── home_page.dart     # Main video processing UI
│   │   ├── loading_page.dart  # Splash/loading screen
│   │   └── settings_page.dart # Settings configuration UI
│   └── processors/
│       ├── video_processor.dart           # Base processor class
│       ├── basic_video_processor.dart     # Core video processing
│       ├── noise_removal_processor.dart   # Audio noise filtering
│       └── background_removal_processor.dart # (Experimental)
├── assets/
│   └── config/
│       └── app_config.json    # App configuration
├── android/                   # Android platform files
├── ios/                       # iOS platform files
├── web/                       # Web platform files
├── windows/                   # Windows platform files
├── linux/                     # Linux platform files
├── macos/                     # macOS platform files
└── pubspec.yaml               # Flutter dependencies
```

---

## 🔧 Dependencies

| Package | Version | Purpose |
|---------|---------|---------|
| `ffmpeg_kit_flutter_new` | ^4.1.0 | Video processing via FFmpeg |
| `image_picker` | ^1.2.0 | Video file selection |
| `shared_preferences` | ^2.2.2 | Settings persistence |
| `path_provider` | ^2.1.1 | File system paths |
| `permission_handler` | ^11.1.0 | Runtime permissions |
| `url_launcher` | ^6.2.1 | External links |
| `yaml` | ^3.1.1 | Pubspec parsing |

---

## 🤝 Contributing

Contributions are welcome! Please read the [Contributing Guidelines](CONTRIBUTING.md) before submitting a PR.

See the [Changelog](CHANGELOG.md) for version history.

---

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

<p align="center">
  <a href="https://drive.google.com/file/d/1MMJR6RDSzG1Ouo8EGtM_XNzvWVj-g0ha/view?usp=sharing" target="_blank">🖥️ Download APK v1.0.0</a>
</p>