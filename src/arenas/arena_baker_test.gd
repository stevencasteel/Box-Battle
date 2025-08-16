# src/arenas/arena_baker_test.gd
@tool
## An editor tool to "bake" a [LevelLayout] resource into a scene of nodes.
##
## This provides a WYSIWYG preview of a data-driven level layout directly in
## the Godot editor, validating the workflow for designer-friendly tools.
class_name ArenaBakerTest
extends Node2D

# --- Constants ---
const GridUtilsScript = preload("res://src/core/util/grid_utils.gd")
const PaletteScript = preload("res://src/core/util/palette.gd")
const ConstantsScript = preload("res://src/core/util/constants.gd")

# --- Editor Properties ---
@export var layout: LevelLayout

@export var bake_now: bool = false:
	set(value):
		if value:
			_bake_layout()

# --- Private Methods ---

func _bake_layout() -> void:
	# Clear any previously baked tiles by iterating backwards to safely remove.
	for i in range(get_child_count() - 1, -1, -1):
		var child = get_child(i)
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
			var should_create_tile = true
			var color = Color.WHITE
			var is_oneway = false

			match char_str:
				"#": color = PaletteScript.COLOR_TERRAIN_PRIMARY
				"-": color = PaletteScript.COLOR_TERRAIN_SECONDARY; is_oneway = true
				"^": color = PaletteScript.COLOR_HAZARD_PRIMARY
				_: should_create_tile = false

			if should_create_tile:
				var rect = ColorRect.new()
				rect.name = "BakedTile_%d_%d" % [x, y]
				rect.color = color

				if is_oneway:
					rect.size = Vector2(ConstantsScript.TILE_SIZE, 10)
					rect.position = Vector2(x * ConstantsScript.TILE_SIZE, y * ConstantsScript.TILE_SIZE + 20)
				else:
					rect.size = Vector2(ConstantsScript.TILE_SIZE, ConstantsScript.TILE_SIZE)
					rect.position = Vector2(x * ConstantsScript.TILE_SIZE, y * ConstantsScript.TILE_SIZE)

				add_child(rect)
				# Set the owner to ensure the node is saved with the scene.
				rect.owner = self

	print("Baking complete.")
