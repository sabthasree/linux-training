echo "Backup Manager Script started "

#!/bin/bash

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
 
export BACKUP_COUNT=0
echo "Matching files:"

for file in "$SOURCE_DIR"/*"$FILE_EXT"
do
    if [ -f "$file" ]; then
        echo "$file"
      BACKUP_COUNT=$((BACKUP_COUNT + 1))
    fi
done
 
echo "total files to backup: $BACKUP_COUNT"



echo "Scanning files:"
FILES=()
for file in "$SOURCE_DIR"/*"$FILE_EXT"
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
        fi
    else
        cp "$file" "$dest"
        echo "Copied: $filename"
    fi
done


REPORT_FILE="$BACKUP_DIR/backup_report.log"

echo "Generating backup report..."

echo "Backup Summary Report" > "$REPORT_FILE"
echo "----------------------" >> "$REPORT_FILE"
echo "Total files processed: $BACKUP_COUNT" >> "$REPORT_FILE"
echo "Total size backed up: $TOTAL_SIZE bytes" >> "$REPORT_FILE"
echo "Backup directory: $BACKUP_DIR" >> "$REPORT_FILE"

echo "Report saved at: $REPORT_FILE"
echo "Backup completed successfully."
