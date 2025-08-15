# src/core/builders/level_build_data.gd
# A custom Resource script that acts as a data container.
class_name LevelBuildData
extends Resource

class MinionSpawnData extends RefCounted:
	var scene: PackedScene
	var position: Vector2
	func _init(p_scene: PackedScene, p_pos: Vector2):
		scene = p_scene
		position = p_pos

var terrain_tiles: Array[Vector2] = []
var oneway_platforms: Array[Vector2] = []
var hazard_tiles: Array[Vector2] = []
var background_tiles: Array[Vector2i] = []
var player_spawn_pos: Vector2 = Vector2.ZERO
var boss_spawn_pos: Vector2 = Vector2.ZERO
# THE FIX: Renamed to accurately reflect that it holds an EncounterData resource.
var encounter_data_resource: EncounterData = null
var dimensions_tiles: Vector2i = Vector2i.ZERO
var minion_spawns: Array[MinionSpawnData] = []