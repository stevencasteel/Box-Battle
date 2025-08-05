# src/arenas/arena_00_encounter.gd
#
# This file defines the dynamic entities and patterns for Arena 00.
# It acts as a "level script" or "director" for the fight.
extends Node

# --- BOSS DATA ---
# Preload the boss scene using the safe path from our singleton.
const BOSS_SCENE = preload(AssetPaths.SCENE_BASE_BOSS)
# The character in the layout that marks the boss's spawn point.
const BOSS_SPAWN_MARKER = "&"

# --- PLAYER DATA ---
const PLAYER_SPAWN_MARKER = "@"