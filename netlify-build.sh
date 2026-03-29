#!/bin/bash
set -e

echo "--- STARTING NETLIFY BUILD ---"

# Install Flutter
git clone https://github.com/flutter/flutter.git -b stable /opt/flutter || true
export PATH="/opt/flutter/bin:$PATH"

# 🔥 FORCE correct pub cache path for Netlify
export PUB_CACHE=/opt/buildhome/.pub-cache

flutter doctor

echo "Current directory: $(pwd)"

# Clean EVERYTHING (important)
flutter clean
rm -rf .dart_tool
rm -rf build

# 🔥 FORCE reinstall dependencies
flutter pub get

# DEBUG (real path)
echo "Checking PUB_CACHE..."
ls /opt/buildhome/.pub-cache/hosted/pub.dev | grep graphview || echo "❌ graphview still missing"

# Build with --dart-define for production environment variables
echo "--- BUILDING WEB ---"
flutter build web --release \
  --dart-define=SUPABASE_URL=$SUPABASE_URL \
  --dart-define=SUPABASE_ANON_KEY=$SUPABASE_ANON_KEY

echo "--- BUILD COMPLETE ---"