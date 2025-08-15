# src/data/layouts/level_layout.gd
# A custom Resource that holds the terrain data for a single arena.
# This moves level design out of scripts and into data files.
class_name LevelLayout
extends Resource

@export var terrain_data: PackedStringArray = []
