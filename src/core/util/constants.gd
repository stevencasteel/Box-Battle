# src/core/util/constants.gd
#
# This singleton holds true global constants that are foundational to the
# engine's architecture or core systems.
#
# GUIDELINES FOR USE:
# - DO add values that define fundamental, project-wide numbers that are
#   unlikely to change (e.g., TILE_SIZE).
# - DO add system-level performance values (e.g., NUM_SFX_PLAYERS).
# - DO NOT add any values related to gameplay feel, balance, or tuning.
#   Those belong in a data resource like CombatConfig.tres.
extends Node

# --- Audio ---
# The number of simultaneous sound effects that can be played at once.
const NUM_SFX_PLAYERS = 8

# --- Arena Design ---
# The universal size (width and height) of a single grid tile in the arena.
const TILE_SIZE = 50