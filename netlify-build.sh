#!/bin/bash

set -e  # STOP on error (important)

# Install Flutter
if [ ! -d "$HOME/flutter" ]; then
  git clone https://github.com/flutter/flutter.git -b stable $HOME/flutter
fi

export PATH="$HOME/flutter/bin:$PATH"

flutter doctor

# Get dependencies
flutter pub get

# Build web
flutter build web