#!/usr/bin/env bash
# ---------------------------------------------------------
# Netlify Build Script for Flutter Web - NUCLEAR OPTION
# Destroys ALL caches to force 100% fresh download
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

# NUCLEAR OPTION: Destroy ALL caches
echo ">>> DESTROYING ALL CACHES..."
rm -rf $HOME/.pub-cache
rm -rf flutter-sdk/.pub-cache || true
rm -rf .dart_tool || true

echo ">>> Cleaning project..."
flutter clean

echo ">>> Creating fresh pub cache..."
mkdir -p $HOME/.pub-cache/hosted/pub.dev

# Fetch dependencies with retry logic
echo ">>> Fetching dependencies FRESH from pub.dev (attempt 1/3)..."
for i in 1 2 3; do
  if flutter pub get; then
    echo ">>> Dependencies fetched successfully on attempt $i"
    break
  elif [ $i -eq 3 ]; then
    echo ">>> ERROR: Failed to fetch dependencies after 3 attempts"
    exit 1
  else
    echo ">>> Attempt $i failed, retrying..."
    rm -rf $HOME/.pub-cache/hosted/pub.dev/graphview-*
  fi
done

# Verify graphview installation
echo ">>> Verifying graphview package..."
GRAPHVIEW_LIB=$(find $HOME/.pub-cache -path "*/graphview-*/lib/graphview.dart" | head -1)
if [ -z "$GRAPHVIEW_LIB" ]; then
  echo "ERROR: graphview.dart not found anywhere in pub cache!"
  echo "Searching for graphview packages..."
  find $HOME/.pub-cache -name "graphview*" -type d || echo "None found"
  exit 1
fi

echo ">>> Found graphview.dart at: $GRAPHVIEW_LIB"
echo ">>> Listing lib directory contents:"
ls -la "$(dirname "$GRAPHVIEW_LIB")/"

# Build for web
echo ">>> Building for web..."
flutter build web --release

echo "========================================="
echo "BUILD COMPLETED SUCCESSFULLY"
echo "Output directory: build/web"
echo "========================================="
