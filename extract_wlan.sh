#!/bin/bash

# Check if input file is given
if [ "$#" -ne 1 ]; then
    echo "Usage: $0 <input_file>"
    exit 1
fi

INPUT_FILE="$1"
OUTPUT_FILE="output.txt"

# Check if file exists
if [ ! -f "$INPUT_FILE" ]; then
    echo "Error: File does not exist."
    exit 1
fi

# Clear output file
> "$OUTPUT_FILE"

# Read file line by line
while IFS= read -r line
do
    case "$line" in
        *frame.time*|*WLAN.fc.type*|*WLAN.fc.subtype*)
            echo "$line" >> "$OUTPUT_FILE"
            ;;
    esac
done < "$INPUT_FILE"

echo "Extraction completed."
echo "Output saved in $OUTPUT_FILE"
 
