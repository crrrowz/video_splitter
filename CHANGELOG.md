# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

---

## [1.0.0] - 2026-02-04

### Added

- **Video Splitting**: Split videos into segments based on configurable duration
- **Speed Adjustment**: Change playback speed (0.25x to 4.0x)
- **Grayscale Filter**: Apply grayscale video filter
- **Audio Removal**: Remove audio track from videos
- **Noise Removal Processor**: Audio filtering with highpass/lowpass filters and silence removal
- **Hardware Acceleration**: Support for libx264/h264 encoding
- **Dynamic Theming**: Automatic light/dark mode based on system settings
- **Dynamic App Icon**: App icon changes with system theme (Android)
- **Settings Persistence**: User preferences saved via SharedPreferences
- **Cross-Platform Support**: Android, iOS, Windows, macOS, Linux, Web (limited)
- **App Configuration**: External JSON config for app settings and feature flags

### Experimental

- **Background Removal Processor**: Initial implementation (disabled by default, not production-ready)

---

## [Unreleased]

### Planned

- Complete Background Removal implementation
- Unit tests for video processors
- Batch video processing
- Custom output directory selection
- Video preview before processing
