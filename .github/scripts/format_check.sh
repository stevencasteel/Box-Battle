#!/bin/bash
# .github/scripts/format_check.sh
# A CI script to check if all GDScript files are correctly formatted.

echo "--- Checking GDScript Formatting ---"
gdformat --check src/

# Capture the exit code of the gdformat command
EXIT_CODE=$?

if [ $EXIT_CODE -ne 0 ]; then
    echo "Formatting check FAILED: Run 'gdformat src/' locally to fix."
    exit 1
else
    echo "Formatting check PASSED: All files are correctly formatted."
    exit 0
fi
