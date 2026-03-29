#!/bin/bash
set -e

# Install Flutter
git clone https://github.com/flutter/flutter.git -b stable $HOME/flutter || true
export PATH="$HOME/flutter/bin:$PATH"

flutter doctor

# VERY IMPORTANT: ensure correct directory
# Using $NETLIFY_BUILD_BASE which is usually set by Netlify
cd $NETLIFY_BUILD_BASE || cd .

# Clean old state (critical fix)
flutter clean

# Get dependencies properly
flutter pub get

# Verify package exists (debug step)
ls $HOME/.pub-cache/hosted/pub.dev | grep graphview || echo "graphview missing"

# Build web - explicitly using release for production
flutter build web --release