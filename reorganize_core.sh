#!/bin/bash

# Box Battle - Core Directory Reorganization Script
echo "Starting core directory reorganization for Box Battle..."
echo ""

# Navigate to the core directory
cd src/core

# --- STEP 1: Create the new directory structure ---
echo "Step 1: Creating new directory structure..."
mkdir -p systems
mkdir -p building
mkdir -p util
mkdir -p data
echo "  -> Created: systems/, building/, util/, data/"

# --- STEP 2: Move files to appropriate directories ---
echo ""
echo "Step 2: Moving files to new locations..."

# Move the global system managers
echo "  -> Moving system managers..."
mv audio_manager.gd* cursor_manager.gd* game_manager.gd* object_pool.gd* systems/ 2>/dev/null || echo "    (Some system files may not exist or already moved)"

# Consolidate the arena builder and its sub-folder into the new 'building' folder
echo "  -> Consolidating building system..."
mv arena_builder.gd* building/ 2>/dev/null || echo "    (arena_builder files may not exist or already moved)"
if [ -d "builders" ]; then
    mv builders/* building/ 2>/dev/null || echo "    (builders directory may be empty or not exist)"
    rmdir builders 2>/dev/null || echo "    (builders directory may not be empty)"
fi

# Move the utility files
echo "  -> Moving utility files..."
mv asset_paths.gd* util/ 2>/dev/null || echo "    (asset_paths files may not exist or already moved)"

# Move configuration and constants to appropriate places
echo "  -> Moving configuration files..."
mv Config.gd* settings.gd* data/ 2>/dev/null || echo "    (Config files may not exist or already moved)"
mv constants.gd* palette.gd* physics_layers.gd* util/ 2>/dev/null || echo "    (Constant files may not exist or already moved)"

# Keep event system files in main core directory for now (they're core infrastructure)
echo "  -> Keeping event system in core/ (event_bus, event_catalog, events/)"

# Keep sequencer in core/ as it's core game infrastructure
echo "  -> Keeping sequencer in core/ (core game infrastructure)"

echo ""
echo "File reorganization complete!"

# --- STEP 3: Display the new structure for verification ---
echo ""
echo "Step 3: Verifying the new 'core' directory structure..."
echo "===========================================" 
ls -la
echo ""
echo "Systems directory:"
ls -la systems/ 2>/dev/null || echo "  (empty or doesn't exist)"
echo ""
echo "Building directory:"
ls -la building/ 2>/dev/null || echo "  (empty or doesn't exist)"
echo ""
echo "Util directory:"
ls -la util/ 2>/dev/null || echo "  (empty or doesn't exist)"
echo ""
echo "Data directory:"
ls -la data/ 2>/dev/null || echo "  (empty or doesn't exist)"

echo ""
echo "Reorganization complete! Your core directory is now better organized."
echo "Remember to update any import paths in your Godot scripts that reference these moved files."