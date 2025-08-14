#!/bin/bash
git config --global --add safe.directory '*'
curl -fsSL https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_3.27.1-stable.tar.xz | tar xJ
export PATH="$PATH:`pwd`/flutter/bin"
flutter config --no-analytics
flutter pub get