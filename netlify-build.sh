#!/usr/bin/env bash
set -e

# Install Flutter SDK into $HOME/flutter if not present
if [ ! -d "$HOME/flutter" ]; then
  git clone https://github.com/flutter/flutter.git -b stable $HOME/flutter
fi

export PATH="$HOME/flutter/bin:$PATH"

# Force Flutter to download required artifacts
flutter --version
flutter doctor -v

# Get packages and build web
flutter clean
flutter pub cache repair
flutter pub get
flutter build web --release
