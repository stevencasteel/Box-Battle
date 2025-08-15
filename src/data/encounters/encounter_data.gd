# src/data/encounters/encounter_data.gd
# A custom Resource that defines a complete encounter or stage.
# REFACTORED: Now uses @export_group for a clean Inspector UI.
class_name EncounterData
extends Resource

@export_group("Layout")
@export var level_layout: LevelLayout
@export var player_spawn_marker: String = "@"

@export_group("Boss")
@export var boss_scene: PackedScene
@export var boss_spawn_marker: String = "&"

@export_group("Minions")
# The key is the character marker in the layout file (e.g., "T").
# The value is the PackedScene for that minion.
@export var minion_spawns: Dictionary = {}