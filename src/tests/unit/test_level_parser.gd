# src/tests/unit/test_level_parser.gd
extends GutTest

# --- Constants ---
const LevelParser = preload("res://src/core/building/level_parser.gd")
const TestEncounterData = preload("res://src/tests/data/test_encounter.tres")

# --- Test Internals ---
var _parser: LevelParser
var _build_data: LevelBuildData

# --- Test Lifecycle ---

func before_all():
	_parser = LevelParser.new()
	_build_data = _parser.parse_level_data(TestEncounterData)

# --- The Tests ---

func test_parses_correct_dimensions():
	assert_eq(_build_data.dimensions_tiles, Vector2i(5, 3), "Grid dimensions should be parsed correctly.")

func test_parses_terrain_and_platform_tiles():
	assert_eq(_build_data.terrain_tiles.size(), 11, "Should parse 11 solid wall tiles ('#').")
	assert_eq(_build_data.oneway_platforms.size(), 1, "Should parse 1 one-way platform tile ('-').")
	assert_eq(_build_data.hazard_tiles.size(), 1, "Should parse 1 hazard tile ('^').")

func test_parses_spawn_positions():
	# Use grid_to_world to verify the expected pixel coordinates
	var expected_player_pos = GridUtils.grid_to_world(Vector2i(1, 1))
	var expected_boss_pos = GridUtils.grid_to_world(Vector2i(3, 1))
	
	assert_eq(_build_data.player_spawn_pos, expected_player_pos, "Player spawn position should be parsed correctly.")
	assert_eq(_build_data.boss_spawn_pos, expected_boss_pos, "Boss spawn position should be parsed correctly.")

func test_parses_background_tiles():
	# The parser correctly identifies '.', '@', and '&' as background tiles for rendering.
	assert_eq(_build_data.background_tiles.size(), 3, "Should correctly identify all non-terrain/entity tiles as background.")