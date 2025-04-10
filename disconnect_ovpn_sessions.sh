#!/bin/bash

# List and disconnect all active OpenVPN 3 sessions

# Get all active session paths
sessions=$(openvpn3 sessions-list | grep -oE '/net/openvpn/v3/sessions/[^\ ]+')

if [[ -z "$sessions" ]]; then
  echo "No active VPN sessions found."
  exit 0
fi

echo "Disconnecting all active VPN sessions..."

# Loop through each session and disconnect it
while read -r session; do
  if [[ -n "$session" ]]; then
    echo "Disconnecting: $session"
    openvpn3 session-manage --session-path "$session" --disconnect
  fi
done <<< "$sessions"

echo "✅ All sessions disconnected."
