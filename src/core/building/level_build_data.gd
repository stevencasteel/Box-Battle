# src/core/builders/level_build_data.gd
#
# A custom Resource script that acts as a data container.
class_name LevelBuildData
extends Resource

var terrain_tiles: Array[Vector2] = []
var oneway_platforms: Array[Vector2] = []
var hazard_tiles: Array[Vector2] = []
var background_tiles: Array[Vector2i] = [] # New: stores grid positions
var player_spawn_pos: Vector2 = Vector2.ZERO
var boss_spawn_pos: Vector2 = Vector2.ZERO
var encounter_script_object: Object = null
var dimensions_tiles: Vector2i = Vector2i.ZERO