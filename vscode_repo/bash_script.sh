#!/bin/bash

# Define the strings to check for working
working=("string1" "string2" "string3")

# Define the strings to check for not working
notworking=("string4" "string5")

# Input log file
log_file=$1

# Function to check for working strings
check_working() {
    for str in "${working[@]}"; do
        if grep -q "$str" <<< "$log_content"; then
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
        if grep -q "$str" <<< "$log_content"; then
            echo "Not Working: $str found"
            return 1
        else
            echo "Not Working: $str not found"
        fi
    done
    return 0
}

# Get the last 30 lines of the log file
log_content=$(tail -n 30 "$log_file")

# Run the checks
check_working && check_notworking

# If both checks passed
if [[ $? -eq 0 ]]; then
    echo "Log passed all checks."
else
    echo "Log failed checks."
fi
