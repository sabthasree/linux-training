#!/bin/bash

# -------------------------------
# analyzer.sh
# Demonstrates:
# Recursive function
# Redirection & error handling
# Here document & here string
# Special parameters
# Regular expressions
# getopt argument handling
# -------------------------------

# Log file for errors
ERROR_LOG="errors.log"

# -------------------------------
# Function: Show Help Menu (Here Document)
# -------------------------------
show_help() {
cat << EOF
Usage: $0 [OPTIONS]

Options:
  -d <directory>    Directory to search recursively
  -k <keyword>      Keyword to search
  -f <file>         Search keyword in specific file
  --help            Display this help menu

Examples:
  $0 -d /home/user -k hello
  $0 -f sample.txt -k test
EOF
exit 0
}

# -------------------------------
# Recursive Function to Search Files
# -------------------------------
search_recursive() {
    local dir="$1"
    local keyword="$2"

    for item in "$dir"/*; do
        if [ -f "$item" ]; then
            if grep -q "$keyword" "$item"; then
                echo "Keyword found in: $item"
            fi
        elif [ -d "$item" ]; then
            search_recursive "$item" "$keyword"
        fi
    done
}

# -------------------------------
# Error Logging Function
# -------------------------------
log_error() {
    echo "Error: $1" | tee -a "$ERROR_LOG"
}

# -------------------------------
# Input Validation using Regex
# -------------------------------
validate_keyword() {
    if [[ ! "$1" =~ ^[a-zA-Z0-9_]+$ ]]; then
        log_error "Invalid keyword. Only alphanumeric and underscore allowed."
        exit 1
    fi
}

# -------------------------------
# Parse Arguments using getopt
# -------------------------------
ARGS=$(getopt -o d:k:f: --long help -- "$@")

if [ $? -ne 0 ]; then
    log_error "Invalid arguments."
    exit 1
fi

eval set -- "$ARGS"

while true; do
    case "$1" in
        -d) DIRECTORY="$2"; shift 2 ;;
        -k) KEYWORD="$2"; shift 2 ;;
        -f) FILE="$2"; shift 2 ;;
        --help) show_help ;;
        --) shift; break ;;
        *) log_error "Unknown option."; exit 1 ;;
    esac
done

# -------------------------------
# Special Parameters Usage
# -------------------------------
echo "Script Name: $0"
echo "Number of arguments: $#"
echo "All arguments: $@"

# -------------------------------
# Validate Keyword
# -------------------------------
if [ -z "$KEYWORD" ]; then
    log_error "Keyword cannot be empty."
    exit 1
fi

validate_keyword "$KEYWORD"

# -------------------------------
# If File Option Used (Here String)
# -------------------------------
if [ -n "$FILE" ]; then
    if [ ! -f "$FILE" ]; then
        log_error "File does not exist."
        exit 1
    fi

    while read line; do
        if grep -q "$KEYWORD" <<< "$line"; then
            echo "Match found in file: $FILE"
        fi
    done < "$FILE"

    echo "Exit status of last command: $?"
fi

# -------------------------------
# If Directory Option Used
# -------------------------------
if [ -n "$DIRECTORY" ]; then
    if [ ! -d "$DIRECTORY" ]; then
        log_error "Directory does not exist."
        exit 1
    fi

    search_recursive "$DIRECTORY" "$KEYWORD"
    echo "Exit status of last command: $?"
fi
