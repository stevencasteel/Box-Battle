#!/bin/bash

# This script creates the final planning documents for our refactoring effort.
# It should be run from the root directory of the project.

set -e # Exit immediately if any command fails

# --- Configuration ---
AUDIT_DIR="docs/sprint_0_audit"

# --- Script Start ---
echo "Creating refactoring planning documents..."

# Check if the audit directory exists
if [ ! -d "$AUDIT_DIR" ]; then
    echo "Error: Audit directory '$AUDIT_DIR' not found. Please run the first script again."
    exit 1
fi

# Create the placeholder files
touch "$AUDIT_DIR/ARCH-001_Refactoring_Principles.md"
touch "$AUDIT_DIR/ARCH-002_Acceptance_Criteria.md"

echo "  -> Created Refactoring_Principles.md"
echo "  -> Created Acceptance_Criteria.md"

echo "----------------------------------------"
echo "Refactoring planning placeholders created successfully."
