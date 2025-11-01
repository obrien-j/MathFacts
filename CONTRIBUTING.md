# Development Workflow

## Before You Commit

**Always run pre-commit checks before committing and pushing to GitHub.** This ensures your code will pass CI/CD checks.

### Quick Check (Recommended)

Run the automated pre-commit script:

**Windows (PowerShell):**
```powershell
.\scripts\pre-commit-checks.ps1
```

**Mac/Linux:**
```bash
chmod +x ./scripts/pre-commit-checks.sh  # First time only
./scripts/pre-commit-checks.sh
```

This script runs the exact same checks that GitHub Actions runs:
1. ✅ Code formatting verification
2. ✅ Static code analysis
3. ✅ Unit/widget tests

### Manual Checks (Alternative)

If you prefer to run checks individually:

```bash
# 1. Check and fix formatting
dart format .

# 2. Analyze code for issues
flutter analyze

# 3. Run all tests
flutter test
```

## CI/CD Pipeline

Our GitHub Actions workflow (`.github/workflows/test.yml`) runs on every push and pull request:

- **Formatting Check**: `dart format --output=none --set-exit-if-changed .`
- **Static Analysis**: `flutter analyze`
- **Tests**: `flutter test`

If any check fails, the GitHub Action will fail and block merging.

## Fixing Common Issues

### Formatting Failures
```bash
# Auto-fix all formatting issues
dart format .

# Check what would change without modifying files
dart format --output=none --set-exit-if-changed .
```

### Analysis Warnings
```bash
# See detailed analysis
flutter analyze

# Common fixes:
# - Add missing imports
# - Remove unused variables
# - Fix type mismatches
```

### Test Failures
```bash
# Run all tests with verbose output
flutter test --verbose

# Run a specific test file
flutter test test/unit/specific_test.dart

# Run tests with coverage
flutter test --coverage
```

## Development Best Practices

### 1. Write Tests First (TDD)
- Write failing test
- Implement feature
- Make test pass
- Refactor

### 2. Keep Code Formatted
- Run `dart format .` frequently
- Configure your IDE to format on save
  - VS Code: Install Dart extension, enable format on save
  - Android Studio: Enable Dart format on save in settings

### 3. Run Checks Frequently
- Before committing
- After making significant changes
- Before creating a pull request

### 4. Fix Issues Immediately
Don't accumulate technical debt:
- Fix formatting issues as they appear
- Address analyzer warnings promptly
- Keep tests passing at all times

## IDE Setup

### VS Code
1. Install "Dart" and "Flutter" extensions
2. Add to `.vscode/settings.json`:
```json
{
  "editor.formatOnSave": true,
  "dart.lineLength": 80,
  "editor.rulers": [80]
}
```

### Android Studio / IntelliJ
1. Go to Settings → Languages & Frameworks → Flutter
2. Enable "Format code on save"
3. Set line length to 80 in Dart settings

## Quick Reference

| Command | Purpose |
|---------|---------|
| `dart format .` | Auto-format all Dart code |
| `flutter analyze` | Run static code analysis |
| `flutter test` | Run all tests |
| `.\scripts\pre-commit-checks.ps1` | Run all checks (Windows) |
| `./scripts/pre-commit-checks.sh` | Run all checks (Mac/Linux) |
| `flutter pub get` | Install/update dependencies |
| `flutter clean` | Clean build artifacts |

## Commit Message Guidelines

Use conventional commits:
```
feat: add new practice mode for multiplication
fix: resolve score persistence issue
docs: update README with setup instructions
test: add tests for MathFact model
refactor: simplify storage interface
style: fix formatting in main.dart
```

## Questions?

- Check our CI/CD pipeline: `.github/workflows/test.yml`
- Review Dart style guide: https://dart.dev/guides/language/effective-dart/style
- See Flutter best practices: https://flutter.dev/docs/development/best-practices
