#!/bin/bash

# Find an available port by asking the OS directly (commonly reliable method)
find_open_port() {
  port=$(comm -23 <(seq 49152 65535 | sort) <(ss -tan | awk '{print $4}' | grep -o '[0-9]*$' | sort -u) | shuf | head -n 1)
  echo "$port"
}

# Set the open port to an environment variable
export APP_PORT=$(find_open_port)

echo "✅ Found open port: $APP_PORT"

# Run your Flutter app (assuming it's configured to read APP_PORT)
cd networks_projects
flutter run --dart-define=APP_PORT="$APP_PORT"