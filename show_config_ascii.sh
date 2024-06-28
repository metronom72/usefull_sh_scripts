#!/bin/bash

# Source internal configuration
[ -r ~/.bashrc.d/internal_config.sh ] && . ~/.bashrc.d/internal_config.sh

# Function to check if a file should be excluded
is_excluded() {
    local file=$1
    for excluded in "${BASHRC_INTERNAL_EXCLUDED_FILES[@]}"; do
        if [[ "$(basename "$file")" == "$excluded" ]]; then
            return 0
        fi
    done
    return 1
}

# Function to print ASCII table headers with color
print_section_header() {
    local section_name=$1
    echo -e "\e[1;34m=== $section_name ===\e[0m"
}

# Function to print ASCII table rows with alternating colors
print_table_row() {
    local item_name=$1
    local item_value=$2
    local color_code=$3

    echo -e "\e[${color_code}m$item_name\e[0m \t $item_value"
}

# Function to retrieve data from scripts in .bashrc.d
get_section_data() {
    local section_name=$1
    local section_files=(~/.bashrc.d/"$section_name".sh)
    local section_data=""

    if [ ${#section_files[@]} -eq 0 ]; then
        echo -e "No files found for $section_name"
        return
    fi

    for file in "${section_files[@]}"; do
        if ! is_excluded "$file"; then
            while IFS= read -r line; do
                if [[ $line =~ ^export || $line =~ ^function || $line =~ ^alias ]]; then
                    section_data+="$line\n"
                fi
                if [[ $line =~ ^function ]]; then
                    read -r next_line
                    if [[ $next_line =~ ^# ]]; then
                        section_data+="$next_line\n"
                    else
                        section_data+="$next_line\n" # Print next line and move back pointer if not a comment
                    fi
                fi
            done < "$file"
        fi
    done

    echo -e "$section_data"
}

# Display data from .bashrc.d in ASCII table format
clear  # Clear the terminal before displaying

# Get unique section names from file names
section_names=()
for file_path in ~/.bashrc.d/*; do
    file_name=$(basename "$file_path")
    section_name="${file_name%.*}"  # Remove extension to get section name
    if [[ ! " ${section_names[@]} " =~ " ${section_name} " ]]; then
        section_names+=("$section_name")
    fi
done

# Display data for each section
for section_name in "${section_names[@]}"; do
    print_section_header "$section_name"
    section_data=$(get_section_data "$section_name")
    if [ -n "$section_data" ]; then
        echo -e "$section_data" | while IFS= read -r line; do
            print_table_row "$line" "" "36"  # Adjust color code as needed
        done
    fi
done

# Ensure terminal colors are reset
tput sgr0
