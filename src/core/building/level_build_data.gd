# src/core/building/level_build_data.gd
@tool
## A custom Resource that acts as a data container for a parsed level.
##
## It holds all the necessary information for the [ArenaBuilder] to construct
## the level, including tile positions and entity spawn points.
class_name LevelBuildData
extends Resource


# --- Inner Classes ---
## A simple data container for a single minion spawn.
class MinionSpawnData:
	extends RefCounted
	var scene: PackedScene
	var position: Vector2

	func _init(p_scene: PackedScene, p_pos: Vector2) -> void:
		scene = p_scene
		position = p_pos


# --- Member Variables ---
var terrain_tiles: Array[Vector2] = []
var oneway_platforms: Array[Vector2] = []
var hazard_tiles: Array[Vector2] = []
var background_tiles: Array[Vector2i] = []
var player_spawn_pos: Vector2 = Vector2.ZERO
var boss_spawn_pos: Vector2 = Vector2.ZERO
var encounter_data_resource: EncounterData = null
var dimensions_tiles: Vector2i = Vector2i.ZERO
var minion_spawns: Array[MinionSpawnData] = []
