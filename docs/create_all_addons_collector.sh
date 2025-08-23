#!/bin/bash
# Get the directory where this script is located
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
# Change to the parent directory (BOX BATTLE root)
cd "$SCRIPT_DIR/.."
# Define the output file path
OUTPUT_FILE="docs/all_addons_source_code.txt"
echo "🔌 BOX BATTLE Addons Source Code Generator"
echo "=========================================="
echo "Working directory: $(pwd)"
echo "Output file: $OUTPUT_FILE"
echo ""
# Step 1: Create the file and write the header
echo "+---------------------------------+" > "$OUTPUT_FILE"
echo "|       B O X  B A T T L E        |" >> "$OUTPUT_FILE"
echo "|   Addons Source Code Context    |" >> "$OUTPUT_FILE"
echo "+---------------------------------+" >> "$OUTPUT_FILE"
echo "Generated on: $(date)" >> "$OUTPUT_FILE"
echo "" >> "$OUTPUT_FILE"
# Step 2: Add addons directory tree structure
echo "=====================================" >> "$OUTPUT_FILE"
echo "ADDONS DIRECTORY STRUCTURE:" >> "$OUTPUT_FILE"
echo "=====================================" >> "$OUTPUT_FILE"
if [ -d "./addons" ]; then
    if command -v tree >/dev/null 2>&1; then
        # Use tree command if available, focusing only on addons directory
        tree addons -I '*.uid|*.import' >> "$OUTPUT_FILE"
    else
        # Fallback to find command if tree is not available
        echo "Note: 'tree' command not found, using find as fallback" >> "$OUTPUT_FILE"
        echo "" >> "$OUTPUT_FILE"
        find ./addons -type d | sed 's|[^/]*/|  |g; s|  \([^/]*\)$|-- \1/|' >> "$OUTPUT_FILE"
    fi
else
    echo "No addons directory found in project." >> "$OUTPUT_FILE"
fi
echo "" >> "$OUTPUT_FILE"
echo "" >> "$OUTPUT_FILE"
# Step 3: Find all addon files and append them to the file
if [ -d "./addons" ]; then
    echo "🔌 Collecting addon files..."
    find ./addons -type f \( \
      -name "*.gd" -o \
      -name "*.tscn" -o \
      -name "*.md" -o \
      -name "*.tres" -o \
      -name "*.gdshader" -o \
      -name "*.json" -o \
      -name "*.csv" -o \
      -name "*.txt" -o \
      -name "*.cfg" -o \
      -name "plugin.cfg" -o \
      -name "*.glsl" -o \
      -name "*.hlsl" -o \
      -name "*.cs" \
    \) \
    -not -name "*.uid" \
    -not -name "*.import" \
    -exec sh -c '
      echo "====================================="
      echo "ADDON FILE: $1"
      echo "====================================="
      cat "$1"
      echo ""
      echo ""
    ' _ {} \; >> "$OUTPUT_FILE"
    echo "✅ Success! Addons file created: $OUTPUT_FILE"
else
    echo "No addons directory found. Creating empty addons documentation." >> "$OUTPUT_FILE"
    echo "⚠️  Warning: No addons directory found in project."
fi
echo ""
echo "📄 You can now find your addons source code at:"
echo "   $(pwd)/$OUTPUT_FILE"
echo ""
echo "Press any key to close this window..."
read -n 1 -s