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
    for file in ~/.bashrc.d/*.sh; do
        # Exclude the configuration GUI files
        if ! is_excluded "$file"; then
            echo "### $(basename "$file") ###"
            while IFS= read -r line; do
                # Print the line if it matches a variable, function, or alias definition
                if [[ $line =~ ^export || $line =~ ^function || $line =~ ^alias ]]; then
                    echo "$line"
                fi
                # Print the following comment line if it exists (function explanation)
                if [[ $line =~ ^function ]]; then
                    read -r next_line
                    if [[ $next_line =~ ^# ]]; then
                        echo "$next_line"
                    else
                        echo "$next_line" >> "$file" # To move the pointer back if not a comment
                    fi
                fi
            done < "$file"
            echo ""
        fi
    done
}

# Collect all data
config_data=$(get_config_data)

# Create a temporary file for the zenity text-info dialog
temp_file=$(mktemp)

# Populate the temp file with the collected data
echo "$config_data" > "$temp_file"

# Display the collected data in a zenity text-info dialog
zenity --text-info --title="Bash Configuration" --filename="$temp_file" --width=800 --height=600

# Clean up
rm "$temp_file"
