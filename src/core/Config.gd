# src/core/Config.gd
#
# An autoloaded singleton responsible for loading all configuration files
# from the res://data/ directory at startup. It provides a simple dot-notation
# getter to access nested configuration values from anywhere in the project.
extends Node

var _config_data: Dictionary = {}

func _ready() -> void:
	_load_all_configs()

# Public getter to retrieve a config value using a dot-separated key.
# Example: Config.get_value("player.physics.speed")
func get_value(key: String, default = null):
	var parts = key.split(".")
	var current_level = _config_data
	for part in parts:
		if current_level is Dictionary and current_level.has(part):
			current_level = current_level[part]
		else:
			push_warning("Config.get_value: Key '%s' not found." % key)
			return default
	return current_level

# --- Internal Functions ---

func _load_all_configs() -> void:
	var dir = DirAccess.open("res://data")
	if not dir:
		push_error("Config: Could not open 'res://data/' directory. Make sure it exists.")
		return

	dir.list_dir_begin()
	var file_name = dir.get_next()
	while file_name != "":
		if not dir.current_is_dir() and file_name.ends_with(".json"):
			_load_and_parse_file("res://data/" + file_name)
		file_name = dir.get_next()

func _load_and_parse_file(file_path: String) -> void:
	var file = FileAccess.open(file_path, FileAccess.READ)
	if not file:
		push_error("Config: Failed to open config file: %s" % file_path)
		return

	var content = file.get_as_text()
	var json = JSON.new()
	var error = json.parse(content)
	if error != OK:
		push_error("Config: Failed to parse JSON in %s. Error: %s at line %d" % [file_path, json.get_error_message(), json.get_error_line()])
		return

	# Merge the data from this file into our main dictionary.
	_config_data.merge(json.data, true)
