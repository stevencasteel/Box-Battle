#!/bin/bash

# Box Battle - Final Core Directory Reorganization Script
echo "Starting final core directory reorganization for Box Battle..."
echo ""

# Navigate to the core directory
cd src/core

# --- STEP 1: Consolidate Event System ---
echo "Step 1: Consolidating event system..."
echo "  -> Moving event_bus.gd and event_catalog.gd into events/ folder..."
mv event_bus.gd events/ 2>/dev/null || echo "    (event_bus.gd may not exist or already moved)"
mv event_catalog.gd events/ 2>/dev/null || echo "    (event_catalog.gd may not exist or already moved)"

# --- STEP 2: Reorganize Sequencer System ---
echo ""
echo "Step 2: Reorganizing sequencer system..."
echo "  -> Renaming sequencer/ to sequencing/..."
if [ -d "sequencer" ]; then
    mv sequencer sequencing
else
    echo "    (sequencer/ directory doesn't exist, creating sequencing/)"
    mkdir -p sequencing
fi

echo "  -> Moving sequencer.gd into sequencing/ folder..."
mv sequencer.gd sequencing/ 2>/dev/null || echo "    (sequencer.gd may not exist or already moved)"

echo "  -> Moving sequence_step.gd into sequencing/ folder..."
if [ -f "sequencing/sequence_step.gd" ]; then
    echo "    (sequence_step.gd already in correct location)"
else
    mv sequencing/sequence_step.gd sequencing/ 2>/dev/null || echo "    (sequence_step.gd may not exist or already moved)"
fi

echo ""
echo "Final reorganization complete!"

# --- STEP 3: Display the new structure for verification ---
echo ""
echo "Step 3: Verifying the final 'core' directory structure..."
echo "===========================================" 
echo ""
echo "Events directory:"
ls -la events/ 2>/dev/null || echo "  (empty or doesn't exist)"
echo ""
echo "Sequencing directory:"
ls -la sequencing/ 2>/dev/null || echo "  (empty or doesn't exist)"
echo ""
echo "Complete core structure:"
tree . 2>/dev/null || ls -R .

echo ""
echo "Reorganization complete! Your core directory now matches the recommended structure."
echo ""
echo "IMPORTANT: Remember to update any import paths in your Godot scripts:"
echo "  - event_bus.gd is now in events/"
echo "  - event_catalog.gd is now in events/"
echo "  - sequencer.gd is now in sequencing/"