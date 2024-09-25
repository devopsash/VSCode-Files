#!/bin/bash

# Define the strings to check for working
working=("string1" "string2" "string3")

# Define the strings to check for not working
notworking=("string4" "string5")

# Input to verify
input=$1

# Function to check for working strings
check_working() {
    for str in "${working[@]}"; do
        if [[ "$input" == *"$str"* ]]; then
            echo "Working: $str found"
        else
            echo "Working: $str not found"
            return 1
        fi
    done
    return 0
}

# Function to check for not working strings
check_notworking() {
    for str in "${notworking[@]}"; do
        if [[ "$input" == *"$str"* ]]; then
            echo "Not Working: $str found"
            return 1
        else
            echo "Not Working: $str not found"
        fi
    done
    return 0
}

# Run the checks
check_working && check_notworking

# If both checks passed
if [[ $? -eq 0 ]]; then
    echo "Input passed all checks."
else
    echo "Input failed checks."
fi
