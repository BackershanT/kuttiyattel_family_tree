#!/bin/bash
# ---------------------------------------------------------
# Netlify Build Script for Flutter Web
# ---------------------------------------------------------
set -e # Exit on any error
set -x # Print commands for debugging

echo "--- Starting Flutter Build Process ---"

# 1. Setup paths
# We use the project directory to store the SDK and cache so Netlify can persist them
PROJECT_DIR=$(pwd)
FLUTTER_SDK_DIR="$PROJECT_DIR/flutter_sdk"
export PUB_CACHE="$PROJECT_DIR/.pub_cache"
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

# 5. Build Web for Release
echo "Running Flutter Web Build..."
# Note: CanvasKit is the default for premium look, but if it fails, try --web-renderer html
flutter build web --release \
  --dart-define=SUPABASE_URL="$SUPABASE_URL" \
  --dart-define=SUPABASE_ANON_KEY="$SUPABASE_ANON_KEY"

echo "--- Build Finished Successfully ---"
