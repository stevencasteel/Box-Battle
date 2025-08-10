#!/bin/bash

# Box Battle - Phase 2 Refactoring Script
echo "Starting Phase 2 refactoring..."
echo ""

# --- STEP 1: Create new directories and placeholder files ---
echo "Step 1: Creating new directories and documentation..."
mkdir -p src/tests
mkdir -p src/core/data/config
mkdir -p src/core/events/typed_events

touch src/core/README.md
touch src/core/DEPRECATION.md
touch src/entities/README.md
touch docs/DEPRECATION.md
echo "Done."
echo ""

# --- STEP 2: Standardize filename casing for Config.gd ---
echo "Step 2: Standardizing filename casing..."
if [ -f "src/core/data/Config.gd" ]; then
    mv src/core/data/Config.gd src/core/data/config.gd
    echo "  -> Renamed Config.gd to config.gd"
else
    echo "  -> config.gd already renamed."
fi
echo "Done."
echo ""

# --- STEP 3: Move files to their new locations ---
echo "Step 3: Moving files into new subdirectories..."

# Move config and settings scripts
mv src/core/data/config.gd src/core/data/config/ 2>/dev/null
mv src/core/data/settings.gd src/core/data/config/ 2>/dev/null
echo "  -> Moved config and settings files to src/core/data/config/"

# Move typed event resources
mv src/core/events/boss_health_changed_event.gd src/core/events/typed_events/ 2>/dev/null
mv src/core/events/player_healing_charges_changed_event.gd src/core/events/typed_events/ 2>/dev/null
mv src/core/events/player_health_changed_event.gd src/core/events/typed_events/ 2>/dev/null
echo "  -> Moved typed event files to src/core/events/typed_events/"

echo "File moves complete."
echo ""

# --- STEP 4: Clean up empty old directory ---
echo "Step 4: Cleaning up..."
rmdir src/core/data 2>/dev/null || echo "  (Old 'data' directory was not empty or did not exist, skipping.)"
echo "Done."
echo ""

# --- STEP 5: Verification ---
echo "Step 5: Verifying final project structure..."
tree src/core
echo ""
echo "Phase 2 refactoring script finished!"
echo "IMPORTANT: The 'project.godot' file must be updated next to reflect the new paths."