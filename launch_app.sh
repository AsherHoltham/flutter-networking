#!/bin/bash

# Find an available port by asking the OS directly (commonly reliable method)
find_open_port() {
  local used_ports candidate_port
  # Extract used ports from netstat output (macOS friendly)
  used_ports=$(netstat -anv | grep LISTEN | awk '{print $4}' | rev | cut -d. -f1 | rev | sort -u)
  
  # Compare the dynamic port range against used ports and randomly pick one using awk
  candidate_port=$(comm -23 <(seq 49152 65535 | sort) <(echo "$used_ports") | \
    awk 'BEGIN {srand()} {line[NR]=$0} END {if (NR>0) print line[int(rand()*NR)+1]}')
  
  echo "$candidate_port"
}

open_server() {
  flutter run --dart-define=APP_PORT="$APP_PORT" --target=networks_projects/lib/server.dart -d macos
}

open_user() {
  flutter run --target=lib/client.dart -d macos
}

# Set the open port to an environment variable
export APP_PORT=$(find_open_port)
echo "✅ Found open port: $APP_PORT"

cd networks_projects

# Run the server in the background
open_server &
# Wait a few seconds to allow the server to start up
sleep 5

# Launch two instances of the user client concurrently
open_user &
open_user &

# Wait for all background processes to complete
wait

echo "All processes have finished."