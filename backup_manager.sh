

#!/bin/bash

echo "Backup Manager Script started "

# ==========================================
# command line argument and quoting the script must accept three arguments :
# Source directory : A directory containing files to backup
# Backup directory : the destination files will be backed up
# File extension : A specific file extension to filter (eg.txt)
# ==========================================

if [ "$#" -ne 3 ]; then
    echo "Usage: $0 <source_directory> <backup_directory> <file_extension>"
    exit 1
fi

SOURCE_DIR="$1"
BACKUP_DIR="$2"
FILE_EXT="$3"

echo "Source Directory: $SOURCE_DIR"
echo "Backup Directory: $BACKUP_DIR"
echo "File Extension: $FILE_EXT"

# ==========================================
# 2: the script should use globbing to find all files in the source directory matching the provided file extension
# 3: use export to set an environment variable BACKUP_COUNT which tracks the total number of files backed up during the script execution
# ==========================================

export BACKUP_COUNT=0
echo "Matching files:"

for file in "$SOURCE_DIR"/*."$FILE_EXT"
do
    if [ -f "$file" ]; then
        echo "$file"
        BACKUP_COUNT=$((BACKUP_COUNT + 1))
    fi
done

echo "Total files to backup: $BACKUP_COUNT"

# ==========================================
# 4: Store the list of files to be backed up in an array
# Print the names of these files along with their sizes before performing the backup
# ==========================================

echo "Scanning files:"
FILES=()

for file in "$SOURCE_DIR"/*."$FILE_EXT"
do
    if [ -f "$file" ]; then
        FILES+=("$file")
    fi
done

echo "Files to be backed up:"

for file in "${FILES[@]}"
do
    size=$(stat -c%s "$file")
    echo "FILE : $file | Size: $size bytes"
done

# ==========================================
# 5: If the backup directory does not exist, create it
# If creation fails, exit with an error
# If the source directory is empty or contains no files matching the extension, exit with a message
# If the file already exists in the backup directory with the same name, only overwrite if it is older than the source file (compare timestamps)
# ==========================================

if [ ! -d "$SOURCE_DIR" ]; then
    echo "Error: Source directory does not exist."
    exit 1
fi

if [ ! -d "$BACKUP_DIR" ]; then
    mkdir -p "$BACKUP_DIR"
    if [ $? -ne 0 ]; then
        echo "Error: Failed to create backup directory."
        exit 1
    fi
fi

if [ ${#FILES[@]} -eq 0 ]; then
    echo "No matching files found in source directory."
    exit 0
fi

echo "Starting backup..."

TOTAL_SIZE=0
BACKUP_COUNT=0

for file in "${FILES[@]}"
do
    filename=$(basename "$file")
    dest="$BACKUP_DIR/$filename"

    if [ -f "$dest" ]; then
        if [ "$file" -nt "$dest" ]; then
            cp "$file" "$dest"
            echo "Overwritten (newer file): $filename"
        else
            echo "Skipped (backup is newer): $filename"
            continue
        fi
    else
        cp "$file" "$dest"
        echo "Copied: $filename"
    fi

    BACKUP_COUNT=$((BACKUP_COUNT + 1))
    size=$(stat -c%s "$file")
    TOTAL_SIZE=$((TOTAL_SIZE + size))
done

# ==========================================
# 6: Output Report
# After the backup, generate a summary report displaying:
# the total files processed
# total size of files backed up
# the path to the backup directory
# The report should be saved in the backup directory as backup_report.log
# ==========================================

REPORT_FILE="$BACKUP_DIR/backup_report.log"

echo "Generating backup report..."

echo "Backup Summary Report" > "$REPORT_FILE"
echo "----------------------" >> "$REPORT_FILE"
echo "Total files processed: $BACKUP_COUNT" >> "$REPORT_FILE"
echo "Total size backed up: $TOTAL_SIZE bytes" >> "$REPORT_FILE"
echo "Backup directory: $BACKUP_DIR" >> "$REPORT_FILE"

echo "Report saved at: $REPORT_FILE"
echo "Backup completed successfully."
