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

    while true; do
        # Check for spelling errors in the commit message
        misspelled_words=$(echo "$message" | aspell list)
        if [[ -n "$misspelled_words" ]]; then
            echo "The commit message contains spelling errors: $misspelled_words"
            echo "Options: "
            echo "1. Proceed with the commit message as is."
            echo "2. Enter a new commit message."
            echo "3. Abort."
            read -p "Choose an option (1/2/3): " option
            case $option in
                1)
                    break
                    ;;
                2)
                    read -p "Enter the new commit message: " message
                    ;;
                3)
                    echo "Commit aborted."
                    return
                    ;;
                *)
                    echo "Invalid option. Please try again."
                    ;;
            esac
        else
            echo "Everything is OK with the commit message."
            break
        fi
    done

    read -p "Do you want to add the author (Mikhail Dorokhovich) to the commit message? (yes/no): " add_author
    if [[ "$add_author" =~ ^([yY][eE][sS]|[yY])$ ]]; then
        message="$message - Mikhail Dorokhovich"
    fi

    git commit -m "$prefix$message"
}
