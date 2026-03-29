#!/bin/bash
set -e

echo "--- STARTING NETLIFY BUILD ---"

# ✅ Install Flutter in writable directory
if [ ! -d "$HOME/flutter" ]; then
  git clone https://github.com/flutter/flutter.git -b stable $HOME/flutter
fi

export PATH="$HOME/flutter/bin:$PATH"

# ✅ Set correct pub cache (important)
export PUB_CACHE="$HOME/.pub-cache"

flutter doctor

echo "Current directory: $(pwd)"

# Clean everything
flutter clean
rm -rf .dart_tool
rm -rf build

# Install dependencies
flutter pub get

# Debug check
ls $HOME/.pub-cache/hosted/pub.dev | grep graphview || echo "❌ graphview missing"

# Build
flutter build web --release