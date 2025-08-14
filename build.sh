#!/bin/bash
git config --global --add safe.directory '*'
export PATH="$PATH:`pwd`/flutter/bin"
flutter build web --release --dart-define=SUPABASE_URL=$SUPABASE_URL --dart-define=SUPABASE_ANON_KEY=$SUPABASE_ANON_KEY