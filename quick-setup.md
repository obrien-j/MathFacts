# Quick Setup Guide for MathFacts Development

## Step-by-Step Installation (Do these in order)

### 1. Install Java JDK 17 (Required)
1. Go to: https://adoptium.net/
2. Download **JDK 17 LTS** for Windows x64
3. Run the installer (accept all defaults)
4. Restart PowerShell and test: `java -version`

### 2. Install Android Studio (Required)
1. Go to: https://developer.android.com/studio
2. Download Android Studio
3. Run installer and follow setup wizard
4. **Important**: Accept all SDK licenses during setup
5. Create a virtual device when prompted

### 3. Install Flutter SDK
1. Go to: https://flutter.dev/docs/get-started/install/windows
2. Download Flutter SDK (3.x stable)
3. Extract to `C:\flutter` (create this folder)
4. Add `C:\flutter\bin` to your PATH environment variable

### 4. Set Environment Variables
After Android Studio installs:
1. Open **System Properties** → **Environment Variables**
2. Add **ANDROID_HOME**: `C:\Users\johnobrien\AppData\Local\Android\Sdk`
3. Add to **PATH**: 
   - `%ANDROID_HOME%\platform-tools`
   - `%ANDROID_HOME%\tools`
   - `C:\flutter\bin`

### 5. Verify Installation
Open **new** PowerShell window and run:
```powershell
java -version
flutter doctor
adb --version
```

## What to do after installation:
1. Run `flutter doctor` and resolve any issues
2. Run `flutter doctor --android-licenses` and accept all licenses
3. Come back here and we'll create the app!

## Estimated Time
- **Total setup time**: 30-45 minutes (mostly downloading)
- **Active work**: 10-15 minutes

## Alternative: Start with React Native
If you prefer JavaScript/TypeScript and want to get started faster:
1. Install Node.js: https://nodejs.org/ (LTS version)
2. Install React Native CLI: `npm install -g @react-native-community/cli`
3. You'll still need Android Studio for the emulator

## Need Help?
- Check the detailed `setup.md` file for troubleshooting
- Each installer should guide you through the process
- Restart PowerShell after each installation

**After you complete these steps, we'll create your MathFacts app together!**