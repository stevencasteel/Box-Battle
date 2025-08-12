# src/arenas/arena_00_encounter.gd
# This encounter file now defines a list of spawnable minions.
extends Node

const LAYOUT_SCRIPT_PATH = "res://src/arenas/arena_00_layout.gd"

# --- BOSS DATA ---
const BOSS_SCENE = preload(AssetPaths.SCENE_BASE_BOSS)
const BOSS_SPAWN_MARKER = "&"

# --- PLAYER DATA ---
const PLAYER_SPAWN_MARKER = "@"

# --- MINION DATA ---
const MINION_SPAWNS = {
	"T": AssetPaths.SCENE_TURRET
}