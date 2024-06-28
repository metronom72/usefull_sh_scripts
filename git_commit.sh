#!/bin/bash

function git_commit() {
    local prefixes=("BUILD" "CHORE" "CI" "DOCS" "FEAT" "FIX" "PERF" "REFACTOR" "REVERT" "STYLE" "TEST" "WIP" "NO")

    echo "Choose a prefix:"
    select prefix in "${prefixes[@]}"; do
        if [[ -n "$prefix" ]]; then
            break
        else
            echo "Invalid choice. Please try again."
        fi
    done

    if [ "$prefix" == "NO" ]; then
        prefix=""
    else
        prefix="$prefix: "
    fi

    while true; do
        read -p "Enter the commit message: " message
        if [[ -n "$message" ]]; then
            break
        else
            echo "Error: Commit message cannot be empty. Please enter a valid message."
        fi
    done

    read -p "Do you want to add the author to the commit message? (yes/no): " add_author
    if [[ "$add_author" =~ ^([yY][eE][sS]|[yY])$ ]]; then
        if [ -z "$GIT_AUTHOR" ]; then
            echo "Error: GIT_AUTHOR environment variable is not set."
            return 1
        fi
        message="$message - $GIT_AUTHOR"
    fi

    git commit -m "$prefix$message"
}
