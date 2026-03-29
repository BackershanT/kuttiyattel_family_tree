#!/usr/bin/env bash
# ---------------------------------------------------------
# Netlify Build Script for Flutter Web - ROBUST VERSION
# Fixes corrupted pub-cache issues
# ---------------------------------------------------------
set -euo pipefail

echo "========================================="
echo "FLUTTER WEB BUILD STARTING"
echo "========================================="
echo "Working directory: $(pwd)"
echo "========================================="

# Install Flutter SDK
echo ">>> Installing Flutter SDK..."
git clone https://github.com/flutter/flutter.git --depth 1 -b stable flutter-sdk
export PATH="$PWD/flutter-sdk/bin:$PATH"

echo ">>> Flutter version:"
flutter --version

# Enable web support
echo ">>> Enabling Flutter web support..."
flutter config --enable-web

# CRITICAL FIX: Clear pub cache BEFORE any package operations
echo ">>> FIXING PUB CACHE - Removing corrupted packages..."
rm -rf $HOME/.pub-cache
mkdir -p $HOME/.pub-cache/hosted/pub.dev

# Precache web artifacts (after cache clear)
echo ">>> Precaching web artifacts..."
flutter precache --web

# Get dependencies with explicit retry
echo ">>> Installing dependencies (first attempt)..."
if ! flutter pub get; then
  echo ">>> First attempt failed, retrying..."
  rm -rf $HOME/.pub-cache/hosted/pub.dev/graphview-*
  flutter pub get
fi

# CRITICAL: Verify graphview was installed correctly
echo ">>> Verifying graphview installation..."
GRAPHVIEW_DIR=$(find $HOME/.pub-cache -name "graphview-1.5.1" -type d | head -1)
if [ -z "$GRAPHVIEW_DIR" ]; then
  echo "ERROR: graphview 1.5.1 not found in pub cache!"
  echo "Available graphview versions:"
  find $HOME/.pub-cache -name "graphview-*" -type d || echo "None found"
  exit 1
fi

echo ">>> Graphview found at: $GRAPHVIEW_DIR"
echo ">>> Checking for graphview.dart file..."
if [ ! -f "$GRAPHVIEW_DIR/lib/graphview.dart" ]; then
  echo "ERROR: graphview.dart file missing! Package is corrupted."
  echo "Files in graphview package:"
  ls -la "$GRAPHVIEW_DIR/" || true
  exit 1
fi
echo "✓ graphview.dart exists and is readable"

# Build for web
echo ">>> Building for web..."
flutter build web --release

echo "========================================="
echo "BUILD COMPLETED SUCCESSFULLY"
echo "Output directory: build/web"
echo "========================================="
