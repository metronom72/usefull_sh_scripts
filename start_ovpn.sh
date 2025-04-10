#!/bin/bash

# Enable proper globbing
shopt -s nullglob

# Use VPN_PROFILE_DIR from environment or fail if not set
if [ -z "$VPN_PROFILE_DIR" ]; then
  echo "❌ Environment variable VPN_PROFILE_DIR is not set."
  echo "Please set it before running this script."
  exit 1
fi

# Folder with .ovpn profiles
PROFILE_DIR="$VPN_PROFILE_DIR"

# Get all full paths to .ovpn files
full_paths=("$PROFILE_DIR"/*.ovpn)

# Check if any profiles exist
if [ ${#full_paths[@]} -eq 0 ]; then
  echo "No .ovpn files found in $PROFILE_DIR"
  exit 1
fi

# Extract just filenames
file_names=()
for path in "${full_paths[@]}"; do
  file_names+=("$(basename "$path")")
done

# Display prompt with only filenames
echo "Available VPN profiles:"
select file in "${file_names[@]}"; do
  if [[ -n "$file" ]]; then
    selected_path="$PROFILE_DIR/$file"
    echo "You selected: $selected_path"

    echo "Importing profile..."
    import_output=$(openvpn3 config-import --config "$selected_path" 2>&1)
    config_path=$(echo "$import_output" | grep -oE '/net/openvpn/v3/configuration/[^ ]+')

    if [[ -z "$config_path" ]]; then
      echo "❌ Failed to import configuration."
      echo "$import_output"
      exit 1
    fi

    echo "✅ Configuration imported at $config_path"
    echo "Starting VPN session..."

    session_output=$(openvpn3 session-start --config "$selected_path" 2>&1)
    session_path=$(echo "$session_output" | grep -oE '/net/openvpn/v3/sessions/[^ ]+')

    if echo "$session_output" | grep -q "User authentication failed"; then
      echo "❌ User authentication failed."
      echo "If your profile requires web login, you may need to open a browser."
      exit 1
    elif [[ -n "$session_path" ]]; then
      echo "✅ VPN started successfully!"
      echo "Session path: $session_path"
    else
      echo "⚠ Unknown issue starting VPN."
      echo "$session_output"
    fi

    break
  else
    echo "Invalid selection. Try again."
  fi
done
