#!/usr/bin/env bash
# ---------------------------------------------------------
# Netlify Build Script for Flutter Web - SIMPLIFIED VERSION
# Based on Netlify's official recommendations
# ---------------------------------------------------------
set -euo pipefail

echo "========================================="
echo "FLUTTER WEB BUILD STARTING"
echo "========================================="
echo "Current directory: $(pwd)"
echo "Contents: $(ls -la)"
echo "========================================="

# Install Flutter SDK
echo "Installing Flutter SDK..."
git clone https://github.com/flutter/flutter.git --depth 1 -b stable flutter-sdk
export PATH="$PWD/flutter-sdk/bin:$PATH"

# Verify Flutter installation
echo "Flutter version:"
flutter --version

# Enable web support and precache web artifacts
echo "Enabling Flutter web support..."
flutter config --enable-web
flutter precache --web

# Get dependencies
echo "Getting dependencies..."
flutter pub get

# Build for web
echo "Building for web..."
flutter build web --release

echo "========================================="
echo "BUILD COMPLETED SUCCESSFULLY"
echo "Output directory: build/web"
echo "========================================="
