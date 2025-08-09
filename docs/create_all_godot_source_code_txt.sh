#!/bin/sh
# This script finds all relevant project text files and combines them into a single context txt file,
# complete with a descriptive header and directory tree structure.
#
# USAGE INSTRUCTIONS:
# 1. Right-click on your PROJECT ROOT folder (Box Battle) → "New Terminal at Folder"
# 2. One time step → Make the script executable by typing:
#    chmod +x docs/create_all_godot_source_code_txt.sh
# 3. Run the script by typing:
#    ./docs/create_all_godot_source_code_txt.sh

OUTPUT_FILE="docs/all_godot_source_code.txt"

# Step 1: Create the file and write the header. The '>' overwrites the old file.
echo "+---------------------------------+" > "$OUTPUT_FILE"
echo "|       B O X  B A T T L E        |" >> "$OUTPUT_FILE"
echo "|  Godot Project Source Context   |" >> "$OUTPUT_FILE"
echo "+---------------------------------+" >> "$OUTPUT_FILE"
echo "Generated on: $(date)" >> "$OUTPUT_FILE"
echo "" >> "$OUTPUT_FILE"

# Step 2: Add directory tree structure
echo "=====================================" >> "$OUTPUT_FILE"
echo "PROJECT DIRECTORY STRUCTURE:" >> "$OUTPUT_FILE"
echo "=====================================" >> "$OUTPUT_FILE"
if command -v tree >/dev/null 2>&1; then
    # Use tree command if available (excludes common non-essential directories and files)
    tree -I 'assets|.git|.godot|.tmp|*.uid|*.import' >> "$OUTPUT_FILE"
else
    # Fallback to find command if tree is not available
    echo "Note: 'tree' command not found, using find as fallback" >> "$OUTPUT_FILE"
    echo "" >> "$OUTPUT_FILE"
    find . -type d \
        -not -path "./assets*" \
        -not -path "./.git*" \
        -not -path "./.godot*" \
        -not -path "./.tmp*" \
        | sed 's|[^/]*/|  |g; s|  \([^/]*\)$|-- \1/|' >> "$OUTPUT_FILE"
fi
echo "" >> "$OUTPUT_FILE"
echo "" >> "$OUTPUT_FILE"

# Step 3: Find all the project files and append '>>' them to the file we just created.
find . -type f \( \
  -name "*.gd" -o \
  -name "*.tscn" -o \
  -name "*.md" -o \
  -name "*.tres" -o \
  -name "*.gdshader" -o \
  -name "*.json" -o \
  -name "*.csv" -o \
  -name "project.godot" -o \
  -name "*.txt" \
\) \
-not -path "./assets/*" \
-not -path "./.git/*" \
-not -path "./.godot/*" \
-not -path "./$OUTPUT_FILE" \
-not -name "*.uid" \
-not -name "*.import" \
-exec sh -c '
  echo "====================================="
  echo "FILE: $1"
  echo "====================================="
  cat "$1"
  echo ""
  echo ""
' _ {} \; >> "$OUTPUT_FILE"

echo "all_godot_source_code.txt '$OUTPUT_FILE' created successfully."