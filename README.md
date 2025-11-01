# MathFacts

A Flutter application for learning math facts through active retrieval practice.

## Features

- Practice addition and subtraction facts (0-10)
- Spaced repetition for optimal learning
- Progress tracking and mastery levels
- Cross-platform support (Web, Android, iOS, Windows, macOS, Linux)
- Persistent storage of learning progress

## Quick Start

### Prerequisites
- Flutter SDK 3.24.0 or higher
- Dart SDK (included with Flutter)

See [quick-setup.md](quick-setup.md) for detailed installation instructions.

### Install Dependencies
```bash
flutter pub get
```

### Run the App
```bash
# Web
flutter run -d chrome

# Android
flutter run -d android

# Windows
flutter run -d windows
```

## Development

### Before Committing

**Always run pre-commit checks** to ensure code quality:

```powershell
# Windows
.\scripts\pre-commit-checks.ps1

# Mac/Linux
./scripts/pre-commit-checks.sh
```

This runs:
- ✅ Code formatting check
- ✅ Static code analysis
- ✅ All tests

### Quick Commands
```bash
# Format code
dart format .

# Analyze code
flutter analyze

# Run tests
flutter test

# Run with coverage
flutter test --coverage
```

See [CONTRIBUTING.md](CONTRIBUTING.md) for complete development workflow and best practices.

## Project Structure

```
lib/
├── main.dart              # App entry point and main screens
├── storage_interface.dart # Platform-agnostic storage interface
├── storage_mobile.dart    # Mobile storage implementation
├── storage_web.dart       # Web storage implementation
└── core/
    └── constants/         # App-wide constants

test/
├── unit/                  # Unit tests
├── widget/               # Widget tests
└── integration/          # Integration tests
```

## Testing

```bash
# Run all tests
flutter test

# Run specific test file
flutter test test/widget_test.dart

# Run with coverage
flutter test --coverage
```

## Resources

- [Flutter Documentation](https://docs.flutter.dev/)
- [Dart Style Guide](https://dart.dev/guides/language/effective-dart/style)
- [Project Setup Guide](quick-setup.md)
- [Contributing Guidelines](CONTRIBUTING.md)
