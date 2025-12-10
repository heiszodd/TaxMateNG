#!/bin/bash
# Exit on error
set -e

# Install Flutter (stable channel)
git clone https://github.com/flutter/flutter.git -b stable --depth 1 $HOME/flutter
export PATH="$HOME/flutter/bin:$PATH"

# Get dependencies and build web
flutter pub get
flutter build web --release
