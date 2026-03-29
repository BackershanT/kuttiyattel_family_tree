#!/bin/bash
set -e

echo "--- STARTING NETLIFY BUILD ---"

# Install Flutter
if [ ! -d "$HOME/flutter" ]; then
  git clone https://github.com/flutter/flutter.git -b stable $HOME/flutter
fi
export PATH="$HOME/flutter/bin:$PATH"

flutter doctor

# DO NOT change directory to $NETLIFY_BUILD_BASE! 
# We are already in the repository root where netlify-build.sh is located.
echo "Current directory: $(pwd)"
ls -F

# Clean old state (critical fix)
flutter clean

# Get dependencies properly
flutter pub get

# Verify package exists (debug step)
ls $HOME/.pub-cache/hosted/pub.dev | grep graphview || echo "graphview missing in cache"

# Build web - always use release for production
flutter build web --release