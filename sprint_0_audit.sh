#!/bin/bash

# This script performs an automated audit of the "BOX BATTLE" Godot project
# to gather data for Sprint 0 of our refactoring plan.
# It should be run from the root directory of the project.

set -e # Exit immediately if any command fails

# --- Configuration ---
AUDIT_DIR="docs/sprint_0_audit"
SRC_DIR="src"
PROJECT_FILE="project.godot"

# --- Script Start ---
echo "Starting Sprint 0 Architectural Audit..."

# 1. Create the output directory
echo "Creating audit directory at $AUDIT_DIR..."
mkdir -p "$AUDIT_DIR"

# 2. Map all autoloaded singletons
echo "Mapping singletons from $PROJECT_FILE..."
awk '/\[autoload\]/{flag=1;next} /\[/{flag=0} flag' "$PROJECT_FILE" > "$AUDIT_DIR/singleton_map.txt"
echo "  -> Saved to $AUDIT_DIR/singleton_map.txt"

# 3. Catalog all Config.get_value() calls
echo "Cataloging all Config.get_value() usage in $SRC_DIR..."
grep -r -n "Config.get_value(" "$SRC_DIR" --include='*.gd' > "$AUDIT_DIR/config_usage.txt"
echo "  -> Saved to $AUDIT_DIR/config_usage.txt"

# 4. Inventory all EventBus usage
echo "Inventorying all EventBus.emit() and EventBus.on() usage..."
{
    echo "--- EventCatalog.gd ---"
    cat "$SRC_DIR/core/events/event_catalog.gd"
    echo -e "\n\n--- EventBus.on() Subscriptions ---"
    grep -r -n "EventBus.on(" "$SRC_DIR" --include='*.gd'
    echo -e "\n\n--- EventBus.emit() Emissions ---"
    grep -r -n "EventBus.emit(" "$SRC_DIR" --include='*.gd'
} > "$AUDIT_DIR/event_usage.txt"
echo "  -> Saved to $AUDIT_DIR/event_usage.txt"

# 5. Create placeholders for manual documentation
echo "Creating placeholder files for manual documentation..."
touch "$AUDIT_DIR/ADR.md"
touch "$AUDIT_DIR/state_machine_flow.md"
echo "  -> Created ADR.md and state_machine_flow.md"

echo "----------------------------------------"
echo "Audit complete."
echo "Please review the generated files in the $AUDIT_DIR directory."