# Pre-commit checks script for MathFacts
# This script runs the same checks that GitHub Actions will run

Write-Host "🔍 Running pre-commit checks..." -ForegroundColor Cyan
Write-Host ""

$failed = $false

# 1. Check formatting
Write-Host "📝 Checking code formatting..." -ForegroundColor Yellow
dart format --output=none --set-exit-if-changed .
if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ Formatting check failed. Run 'dart format .' to fix." -ForegroundColor Red
    $failed = $true
} else {
    Write-Host "✅ Formatting check passed" -ForegroundColor Green
}
Write-Host ""

# 2. Analyze code
Write-Host "🔬 Analyzing code..." -ForegroundColor Yellow
flutter analyze
if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ Code analysis failed. Fix the issues above." -ForegroundColor Red
    $failed = $true
} else {
    Write-Host "✅ Code analysis passed" -ForegroundColor Green
}
Write-Host ""

# 3. Run tests
Write-Host "🧪 Running tests..." -ForegroundColor Yellow
flutter test
if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ Tests failed. Fix the failing tests." -ForegroundColor Red
    $failed = $true
} else {
    Write-Host "✅ All tests passed" -ForegroundColor Green
}
Write-Host ""

# Summary
if ($failed) {
    Write-Host "❌ Pre-commit checks FAILED. Please fix the issues above before committing." -ForegroundColor Red
    exit 1
} else {
    Write-Host "✅ All pre-commit checks PASSED! Safe to commit and push." -ForegroundColor Green
    exit 0
}
