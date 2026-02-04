# Contributing to Video Splitter

Thank you for your interest in contributing to Video Splitter! This document provides guidelines for contributing to the project.

---

## 🚀 Getting Started

### Prerequisites

- Flutter SDK ^3.9.2 or higher
- Dart SDK (included with Flutter)
- Android Studio or VS Code with Flutter extensions
- Git

### Setup

1. Fork the repository
2. Clone your fork:
   ```bash
   git clone https://github.com/YOUR_USERNAME/Video_Splitter.git
   ```
3. Add upstream remote:
   ```bash
   git remote add upstream https://github.com/crrrowz/Video_Splitter.git
   ```
4. Install dependencies:
   ```bash
   flutter pub get
   ```

---

## 📁 Project Structure

```
lib/
├── main.dart              # App entry point
├── models/                # Data models & configuration
│   ├── app_config_loader.dart
│   └── app_settings.dart
├── pages/                 # UI screens
│   ├── home_page.dart
│   ├── loading_page.dart
│   └── settings_page.dart
└── processors/            # Video processing logic
    ├── video_processor.dart        # Base class
    ├── basic_video_processor.dart
    ├── noise_removal_processor.dart
    └── background_removal_processor.dart
```

---

## 🔧 Development Workflow

### Branching Strategy

- `main` - Stable release branch
- `develop` - Integration branch for features
- `feature/*` - Feature branches
- `fix/*` - Bug fix branches

### Making Changes

1. Create a feature branch:
   ```bash
   git checkout -b feature/your-feature-name
   ```

2. Make your changes following the code style guidelines

3. Test your changes:
   ```bash
   flutter analyze
   flutter test
   ```

4. Commit with meaningful messages:
   ```bash
   git commit -m "feat: add video preview before processing"
   ```

5. Push and create a Pull Request

---

## 📝 Code Style Guidelines

### Dart/Flutter

- Follow [Effective Dart](https://dart.dev/guides/language/effective-dart) guidelines
- Use `flutter analyze` to check for issues
- Document public APIs with `///` doc comments
- Keep functions focused and under 50 lines when possible

### Naming Conventions

| Type | Convention | Example |
|------|------------|---------|
| Classes | PascalCase | `VideoProcessor` |
| Functions/Methods | camelCase | `buildCommand()` |
| Variables | camelCase | `segmentTime` |
| Constants | camelCase | `defaultSpeed` |
| Files | snake_case | `video_processor.dart` |

### Commit Messages

Use [Conventional Commits](https://www.conventionalcommits.org/):

- `feat:` - New feature
- `fix:` - Bug fix
- `docs:` - Documentation changes
- `refactor:` - Code refactoring
- `test:` - Adding tests
- `chore:` - Maintenance tasks

---

## 🧪 Testing

### Running Tests

```bash
# Run all tests
flutter test

# Run specific test file
flutter test test/widget_test.dart

# Run with coverage
flutter test --coverage
```

### Writing Tests

- Place tests in the `test/` directory
- Mirror the `lib/` structure for test files
- Name test files with `_test.dart` suffix

---

## 🐛 Reporting Issues

When reporting bugs, please include:

1. **Description**: Clear description of the issue
2. **Steps to Reproduce**: Numbered steps to reproduce
3. **Expected Behavior**: What should happen
4. **Actual Behavior**: What actually happens
5. **Environment**: Flutter version, OS, device
6. **Logs**: Relevant error messages or stack traces

---

## 📋 Pull Request Checklist

Before submitting a PR, ensure:

- [ ] Code follows project style guidelines
- [ ] `flutter analyze` passes with no issues
- [ ] All existing tests pass
- [ ] New features include tests
- [ ] Documentation is updated if needed
- [ ] CHANGELOG.md is updated for notable changes
- [ ] Commit messages follow conventional commits

---

## 🎯 Areas for Contribution

### High Priority

- [ ] Complete Background Removal processor implementation
- [ ] Add unit tests for video processors
- [ ] Add integration tests for processing pipeline

### Medium Priority

- [ ] Batch video processing feature
- [ ] Custom output directory selection
- [ ] Video preview before processing
- [ ] Progress notification for long operations

### Low Priority

- [ ] Localization (additional languages)
- [ ] Accessibility improvements
- [ ] Performance optimizations

---

## 📄 License

By contributing, you agree that your contributions will be licensed under the MIT License.

---

## 💬 Questions?

Feel free to open an issue for any questions or discussions about contributions.
