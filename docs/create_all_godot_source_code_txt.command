#!/bin/bash

# Get the directory where this script is located
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"

# Change to the parent directory (BOX BATTLE root)
cd "$SCRIPT_DIR/.."

# Define the output file path
OUTPUT_FILE="docs/all_godot_source_code.txt"

echo "🎮 BOX BATTLE Source Code Generator"
echo "=================================="
echo "Working directory: $(pwd)"
echo "Output file: $OUTPUT_FILE"
echo ""

# Step 1: Create the file and write the header
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

echo "📁 Collecting project files..."

# Step 3: Find all the project files and append them to the file
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

echo "✅ Success! File created: $OUTPUT_FILE"
echo ""
echo "📄 You can now find your combined source code at:"
echo "   $(pwd)/$OUTPUT_FILE"
echo ""
echo "Press any key to close this window..."
read -n 1 -s