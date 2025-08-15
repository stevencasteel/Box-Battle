# src/arenas/arena_baker_test.gd
# FINAL VERSION: This version adds the baked tiles as direct children of the
# scene root, which guarantees correct ownership and ensures they are saved.
@tool
class_name ArenaBakerTest
extends Node2D

const GridUtilsScript = preload("res://src/core/util/grid_utils.gd")
const PaletteScript = preload("res://src/core/util/palette.gd")
const ConstantsScript = preload("res://src/core/util/constants.gd")

@export var layout: LevelLayout

@export var bake_now: bool = false:
	set(value):
		if value:
			_bake_layout()

func _bake_layout():
	# Clear any previously baked tiles. We iterate backwards to safely remove.
	for i in range(get_child_count() - 1, -1, -1):
		var child = get_child(i)
		# A simple name check is enough to avoid deleting essential nodes if we add them later.
		if child.name.begins_with("BakedTile_"):
			child.queue_free()

	if not is_instance_valid(layout):
		print("ArenaBakerTest: No LevelLayout assigned. Nothing to bake.")
		return
	
	print("Baking level layout...")
	var rows: PackedStringArray = layout.terrain_data
	for y in range(rows.size()):
		var row_string: String = rows[y]
		for x in range(row_string.length()):
			var char_str: String = row_string.substr(x, 1)
			var tile_to_create = true
			var color = Color.WHITE
			var is_oneway = false
			
			match char_str:
				"#": color = PaletteScript.COLOR_TERRAIN_PRIMARY
				"-": color = PaletteScript.COLOR_TERRAIN_SECONDARY; is_oneway = true
				"^": color = PaletteScript.COLOR_HAZARD_PRIMARY
				_: tile_to_create = false

			if tile_to_create:
				var rect = ColorRect.new()
				rect.name = "BakedTile_%d_%d" % [x, y]
				rect.color = color
				
				if is_oneway:
					rect.size = Vector2(ConstantsScript.TILE_SIZE, 10)
					rect.position = Vector2(x * ConstantsScript.TILE_SIZE, y * ConstantsScript.TILE_SIZE + 20)
				else:
					rect.size = Vector2(ConstantsScript.TILE_SIZE, ConstantsScript.TILE_SIZE)
					rect.position = Vector2(x * ConstantsScript.TILE_SIZE, y * ConstantsScript.TILE_SIZE)
				
				# THE DEFINITIVE FIX: Add the new node as a direct child of the scene root.
				# The editor will handle ownership automatically and correctly.
				add_child(rect)
				
				# We also explicitly tell the editor that this node should be saved.
				rect.owner = self

	print("Baking complete.")
