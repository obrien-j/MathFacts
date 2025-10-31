# Android Mobile Development Setup Guide

This guide will help you set up a complete Android development environment in VS Code for creating the MathFacts mobile app.

## 1. Required Software Installation

### Java Development Kit (JDK)
- **Install JDK 17** (recommended for current Android development)
- Download options:
  - [Oracle JDK](https://www.oracle.com/java/technologies/javase/jdk17-archive-downloads.html)
  - [OpenJDK (Adoptium)](https://adoptium.net/)
- Verify installation: `java -version` in terminal

### Android Studio
- **Download and install** [Android Studio](https://developer.android.com/studio)
- During installation, ensure these components are included:
  - Android SDK
  - Android SDK Platform-Tools
  - Android Virtual Device (AVD)
  - Android SDK Build-Tools
- **Note**: You don't need to use Android Studio as your IDE, but it provides essential SDK tools

## 2. Environment Variables Setup

After installing Android Studio, set up these environment variables:

### Windows Environment Variables
1. Open **System Properties** → **Advanced** → **Environment Variables**
2. Add these system variables:

**ANDROID_HOME**
```
C:\Users\[YourUsername]\AppData\Local\Android\Sdk
```

**Add to PATH variable:**
```
%ANDROID_HOME%\platform-tools
%ANDROID_HOME%\tools
%ANDROID_HOME%\tools\bin
%ANDROID_HOME%\emulator
```

### Verify Setup
Open a new PowerShell window and run:
```powershell
adb --version
emulator -list-avds
```

## 3. VS Code Extensions

Install these essential extensions for Android development:

### Core Extensions
- **Flutter** (`dart-code.flutter`) - Flutter support and debugger
- **Dart** (`dart-code.dart-code`) - Dart language support
- **React Native Tools** (`msjsdiag.vscode-react-native`) - React Native debugging
- **Language Support for Java** (`redhat.java`) - Java development
- **Debugger for Java** (`vscjava.vscode-java-debug`) - Java debugging
- **Maven for Java** (`vscjava.vscode-maven`) - Maven project management
- **Test Runner for Java** (`vscjava.vscode-java-test`) - Java testing

### Additional Helpful Extensions
- **ES7+ React/Redux/React-Native snippets** (`dsznajder.es7-react-js-snippets`)
- **Android iOS Emulator** (`diemasmichiels.emulate`) - Easy emulator launching
- **Flutter Widget Snippets** (`alexisvt.flutter-snippets`)
- **Awesome Flutter Snippets** (`nash.awesome-flutter-snippets`)

## 4. Development Framework Options

### Option 1: Flutter (Recommended for MathFacts App) ⭐
**Pros:**
- Cross-platform (Android + iOS with single codebase)
- Excellent for educational apps with custom UI
- Great performance and smooth animations
- Large community and Google support
- Perfect for interactive math games

**Setup:**
1. Install Flutter SDK from [flutter.dev](https://flutter.dev/docs/get-started/install/windows)
2. Add Flutter to PATH: `C:\flutter\bin`
3. Run `flutter doctor` to verify setup
4. Create project: `flutter create mathfacts`

## 5. Creating Your First Project

### For Flutter (Recommended):
```powershell
# Navigate to your development directory
cd c:\Users\johnobrien\dev\MathFacts

# Create Flutter project
flutter create . --project-name mathfacts

# Check that everything works
flutter doctor

# Run on emulator or device
flutter run
```

## 6. Setting Up Android Emulator

### Create Virtual Device:
1. Open Android Studio
2. Go to **Tools** → **AVD Manager**
3. Click **Create Virtual Device**
4. Choose a device (e.g., Pixel 4)
5. Select a system image (API 30+ recommended)
6. Click **Finish**

### Test Emulator:
```powershell
# List available emulators
emulator -list-avds

# Start emulator
emulator -avd [EmulatorName]
```

## 7. Verification Checklist

Before starting development, verify:

- [ ] JDK 17 installed and in PATH
- [ ] Android Studio installed with SDK components
- [ ] Environment variables (ANDROID_HOME, PATH) configured
- [ ] VS Code with required extensions installed
- [ ] Flutter SDK installed (if using Flutter)
- [ ] Node.js installed (if using React Native)
- [ ] Android emulator created and working
- [ ] `adb devices` shows your emulator/device
- [ ] `flutter doctor` shows no issues (if using Flutter)

## 8. Recommended Project Structure for MathFacts App

### Flutter Structure:
```
mathfacts/
├── lib/
│   ├── main.dart
│   ├── screens/
│   │   ├── home_screen.dart
│   │   ├── game_screen.dart
│   │   └── settings_screen.dart
│   ├── widgets/
│   │   ├── math_problem.dart
│   │   └── score_display.dart
│   ├── models/
│   │   └── math_problem.dart
│   └── services/
│       └── game_logic.dart
├── assets/
│   ├── images/
│   └── sounds/
├── test/
└── pubspec.yaml
```

## 9. Next Steps

1. **Choose your framework** (Flutter recommended for MathFacts)
2. **Install all required software**
3. **Set up environment variables**
4. **Create and test a simple "Hello World" app**
5. **Start building your math facts game features**

## 10. Troubleshooting

### Common Issues:

**Flutter Doctor Issues:**
- Run `flutter doctor` and follow the suggestions
- Ensure all licenses are accepted: `flutter doctor --android-licenses`

**Emulator Won't Start:**
- Check if Hyper-V is disabled (for Intel HAXM)
- Ensure hardware acceleration is enabled in BIOS
- Try creating a new AVD with different API level

**Build Failures:**
- Clean project: `flutter clean` or `cd android && ./gradlew clean`
- Check Android SDK licenses: `flutter doctor --android-licenses`

**PATH Issues:**
- Restart VS Code/PowerShell after setting environment variables
- Verify paths are correct: `echo $env:ANDROID_HOME`

## 11. Useful Commands

### Flutter:
```powershell
flutter doctor              # Check setup
flutter devices             # List connected devices
flutter run                 # Run app
flutter build apk           # Build APK
flutter clean               # Clean project
```

### React Native:
```powershell
npx react-native doctor     # Check setup
npx react-native run-android # Run on Android
npx react-native start      # Start Metro bundler
```

### Android:
```powershell
adb devices                  # List connected devices
adb install app.apk          # Install APK
adb logcat                   # View device logs
```

---

**Happy coding! 🚀 Your MathFacts app development environment is ready to go!**