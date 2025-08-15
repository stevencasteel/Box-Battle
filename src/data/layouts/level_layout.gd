# src/data/layouts/level_layout.gd
# REVISED: Uses the correct notify_property_list_changed() method for Resources.
@tool
class_name LevelLayout
extends Resource

@export var terrain_data: PackedStringArray = []:
	set(value):
		terrain_data = value
		# THE FIX: This is the correct method for a Resource. It tells the
		# editor's Inspector to refresh, which will then re-run the warning check.
		notify_property_list_changed()

func _get_configuration_warnings() -> PackedStringArray:
	var warnings = PackedStringArray()
	
	if terrain_data.is_empty():
		warnings.append("Terrain Data is empty. The level will be blank.")
		return warnings

	var first_row_length = -1
	if not terrain_data[0].is_empty():
		first_row_length = terrain_data[0].length()
	else:
		for i in range(1, terrain_data.size()):
			if not terrain_data[i].is_empty():
				warnings.append("Row 1 is empty, but Row %d is not. All rows must be the same length." % (i + 1))
				return warnings
		return warnings

	for i in range(1, terrain_data.size()):
		if terrain_data[i].length() != first_row_length:
			warnings.append("Row %d (length %d) has a different length than the first row (length %d). All rows must be the same length." % [i + 1, terrain_data[i].length(), first_row_length])
			break
			
	return warnings
