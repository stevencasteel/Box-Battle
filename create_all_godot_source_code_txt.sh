#!/bin/sh
# This script finds all relevant project text files and combines them into a single context txt file,
# complete with a descriptive header and directory tree structure.
#   Typing this in terminal makes it so you can run the shell script
# chmod +x create_all_godot_source_code_txt.sh
#   Then paste this in terminal from the root directory 
# ./create_all_godot_source_code_txt.sh


OUTPUT_FILE="all_godot_source_code.txt"

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
  -name "project.godot" -o \
  -name "*.txt" \
\) \
-not -path "./assets/*" \
-not -path "./.git/*" \
-not -path "./.godot/*" \
-not -name "$OUTPUT_FILE" \
-not -name "*.uid" \
-not -name "*.import" \
-print0 | xargs -0 -I {} sh -c '
  echo "=====================================";
  echo "FILE: {}";
  echo "=====================================";
  cat {};
  echo "\n";
' >> "$OUTPUT_FILE"

echo "all_godot_source_code.txt '$OUTPUT_FILE' created successfully."