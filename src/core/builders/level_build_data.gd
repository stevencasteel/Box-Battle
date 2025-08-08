# src/core/builders/level_build_data.gd
#
# A custom Resource script that acts as a data container. Its only purpose is to
# hold all the parsed information about a level in one clean, portable object.
# This prevents us from having to pass many individual arrays and variables between
# our different builder classes.
class_name LevelBuildData
extends Resource

var terrain_tiles: Array[Vector2] = []
var oneway_platforms: Array[Vector2] = []
var hazard_tiles: Array[Vector2] = []
var player_spawn_pos: Vector2 = Vector2.ZERO
var boss_spawn_pos: Vector2 = Vector2.ZERO
var encounter_script_object: Object = null