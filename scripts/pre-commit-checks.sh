#!/bin/bash
# Pre-commit checks script for MathFacts (Unix/Linux/Mac)
# This script runs the same checks that GitHub Actions will run

echo "🔍 Running pre-commit checks..."
echo ""

failed=false

# 1. Check formatting
echo "📝 Checking code formatting..."
dart format --output=none --set-exit-if-changed .
if [ $? -ne 0 ]; then
    echo "❌ Formatting check failed. Run 'dart format .' to fix."
    failed=true
else
    echo "✅ Formatting check passed"
fi
echo ""

# 2. Analyze code
echo "🔬 Analyzing code..."
flutter analyze
if [ $? -ne 0 ]; then
    echo "❌ Code analysis failed. Fix the issues above."
    failed=true
else
    echo "✅ Code analysis passed"
fi
echo ""

# 3. Run tests
echo "🧪 Running tests..."
flutter test
if [ $? -ne 0 ]; then
    echo "❌ Tests failed. Fix the failing tests."
    failed=true
else
    echo "✅ All tests passed"
fi
echo ""

# Summary
if [ "$failed" = true ]; then
    echo "❌ Pre-commit checks FAILED. Please fix the issues above before committing."
    exit 1
else
    echo "✅ All pre-commit checks PASSED! Safe to commit and push."
    exit 0
fi
