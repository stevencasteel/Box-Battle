# src/data/layouts/level_layout.gd
@tool
## A custom Resource that holds the terrain data for a level.
##
## Includes a custom configuration warning to ensure that all rows in the
## terrain data array have the same length for valid parsing.
class_name LevelLayout
extends Resource

# --- Editor Properties ---
@export var terrain_data: Array[String] = []:
	set(value):
		terrain_data = value
		# Tell the editor to refresh its property list, which re-runs the warning check.
		notify_property_list_changed()

# --- Godot Lifecycle Methods ---


func _get_configuration_warnings() -> PackedStringArray:
	var warnings = PackedStringArray()
	if terrain_data.is_empty():
		warnings.append("Terrain Data is empty. The level will be blank.")
		return warnings

	var first_row_length = -1
	if not terrain_data[0].is_empty():
		first_row_length = terrain_data[0].length()
	else:  # Handle case where the first row is empty
		warnings.append("The first row of terrain data cannot be empty.")
		return warnings

	for i in range(1, terrain_data.size()):
		if terrain_data[i].length() != first_row_length:
			var msg = "Row %d (length %d) has a different length than the first row (length %d)."
			warnings.append(msg % [i + 1, terrain_data[i].length(), first_row_length])
			break  # Only show the first error found

	return warnings