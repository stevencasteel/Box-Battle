# src/core/util/constants.gd
## An autoloaded singleton for true global constants that define the
## project's foundational architecture or core system limits.
##
## GUIDELINE: Only add values here that are fundamental and unlikely to
## ever change. Gameplay tuning values belong in [CombatConfig].
extends Node

# --- Audio ---
## The number of simultaneous sound effects that can be played at once.
const NUM_SFX_PLAYERS = 8

# --- Arena Design ---
## The universal size (width and height) of a single grid tile in pixels.
const TILE_SIZE = 50
