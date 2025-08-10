# src/core/constants.gd
#
# This singleton now only holds true global constants that are not meant for
# gameplay tuning, such as UI layout numbers or asset counts. All gameplay
# values have been moved to combat_config.json.
extends Node

# --- Audio ---
const NUM_SFX_PLAYERS = 8 # The number of sound effects that can play at once.

# --- Arena Design ---
const TILE_SIZE = 50