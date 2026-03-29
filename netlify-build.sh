#!/bin/bash
# ---------------------------------------------------------
# Netlify Build Script for Flutter Web
# ---------------------------------------------------------
set -e # Exit on any error
set -x # Print commands for debugging

echo "--- Starting Flutter Build Process ---"

# 1. Setup absolute paths
PROJECT_DIR=$(pwd)
FLUTTER_SDK_DIR="$PROJECT_DIR/flutter_sdk"
# Set explicit PUB_CACHE to ensure consistent package location
export PUB_CACHE="$HOME/.pub-cache"
export PATH="$FLUTTER_SDK_DIR/bin:$PATH"

# 2. Install or Use Cached Flutter SDK
if [ ! -d "$FLUTTER_SDK_DIR" ]; then
  echo "Flutter SDK not found in cache. Cloning..."
  git clone https://github.com/flutter/flutter.git -b stable --depth 1 "$FLUTTER_SDK_DIR"
else
  echo "Using cached Flutter SDK."
  # Optional: Update the SDK if needed, but keeping it stable is faster
  # cd "$FLUTTER_SDK_DIR" && git pull && cd "$PROJECT_DIR"
fi

# 3. Disable Analytics and show version
flutter config --no-analytics
flutter --version

# 4. Get Dependencies
echo "Installing dependencies..."
flutter pub get

# 4.5. Verify graphview package is installed
echo "--- Verifying graphview package installation ---"
if [ -d "$PUB_CACHE/hosted/pub.dev/graphview-1.5.1" ]; then
  echo "✓ graphview 1.5.1 found in pub.dev cache"
elif [ -d "$PUB_CACHE/hosted/pub.dartlang.org/graphview-1.5.1" ]; then
  echo "✓ graphview 1.5.1 found in pub.dartlang.org cache"
else
  echo "⚠ Warning: graphview directory not found, but flutter pub get succeeded"
  echo "Listing PUB_CACHE contents:"
  ls -la "$PUB_CACHE/hosted/" 2>/dev/null || echo "No hosted directory yet"
fi

# 5. Build Web for Release
echo "Running Flutter Web Build..."
# Note: CanvasKit is the default for premium look, but if it fails, try --web-renderer html
# Adding --no-wasm-dry-run as dependencies have incompatibilities currently
flutter build web --release \
  --no-wasm-dry-run \
  --dart-define=SUPABASE_URL="$SUPABASE_URL" \
  --dart-define=SUPABASE_ANON_KEY="$SUPABASE_ANON_KEY"

echo "--- Build Finished Successfully ---"
