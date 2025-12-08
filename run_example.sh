#!/bin/bash

# Script to run the merge example
# Usage: ./run_example.sh

set -e

echo "🎯 Dart AST Smart Merge CLI - Example Runner"
echo ""

# Check if Dart is installed
if ! command -v dart &> /dev/null; then
    echo "❌ Error: Dart SDK not found in PATH"
    echo "   Please install Dart from https://dart.dev/get-dart"
    exit 1
fi

echo "📦 Installing dependencies..."
dart pub get

echo ""
echo "🔍 Running merge example..."
echo ""

dart run bin/main.dart \
  --current-file example/current_file.dart \
  --generated-file example/generated_file.dart \
  --output-file example/merged_output.dart

echo ""
echo "✨ Done! Check example/merged_output.dart to see the result."

