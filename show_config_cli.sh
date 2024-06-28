#!/bin/bash

# Source internal configuration
[ -r ~/.bashrc.d/internal_config.sh ] && . ~/.bashrc.d/internal_config.sh

# Function to check if a file is excluded
is_excluded() {
    local file=$1
    for excluded in "${BASHRC_INTERNAL_EXCLUDED_FILES[@]}"; do
        if [[ "$(basename "$file")" == "$excluded" ]]; then
            return 0
        fi
    done
    return 1
}

# Function to retrieve and format data from all scripts in .bashrc.d
get_config_data() {
    local config_data=""
    for file in ~/.bashrc.d/*.sh; do
        # Exclude the configuration GUI files
        if ! is_excluded "$file"; then
            config_data+="### $(basename "$file") ###\n"
            while IFS= read -r line; do
                # Print the line if it matches a variable, function, or alias definition
                if [[ $line =~ ^export || $line =~ ^function || $line =~ ^alias ]]; then
                    config_data+="$line\n"
                fi
                # Print the following comment line if it exists (function explanation)
                if [[ $line =~ ^function ]]; then
                    read -r next_line
                    if [[ $next_line =~ ^# ]]; then
                        config_data+="$next_line\n"
                    else
                        config_data+="$next_line\n" # Print next line and move back pointer if not a comment
                    fi
                fi
            done < "$file"
            config_data+="\n"
        fi
    done
    echo -e "$config_data"
}

# Collect all data
config_data=$(get_config_data)

# Create a temporary file for the dialog box
temp_file=$(mktemp)

# Populate the temp file with the collected data
echo "$config_data" > "$temp_file"

# Display the collected data in a dialog box and ensure terminal state is restored
dialog --clear --textbox "$temp_file" 0 0

# Clean up
rm "$temp_file"

# Ensure terminal colors are reset
tput sgr0
clear
