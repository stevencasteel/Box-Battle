# src/arenas/arena_00_encounter.gd
#
# This file defines the dynamic entities and patterns for Arena 00.
# It acts as a "level script" or "director" for the fight.
extends Node

# --- NEW: DATA-DRIVEN LAYOUT ---
# This constant explicitly defines which layout file this encounter uses.
# The ArenaBuilder will read this path directly, removing any assumptions
# about file naming conventions.
const LAYOUT_SCRIPT_PATH = "res://src/arenas/arena_00_layout.gd"

# --- BOSS DATA ---
const BOSS_SCENE = preload(AssetPaths.SCENE_BASE_BOSS)
const BOSS_SPAWN_MARKER = "&"

# --- PLAYER DATA ---
const PLAYER_SPAWN_MARKER = "@"