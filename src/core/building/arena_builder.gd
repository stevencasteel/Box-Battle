# src/core/building/arena_builder.gd
#
# This singleton is a high-level "Coordinator". It owns the logic for directing
# the encounter to ensure Callables remain valid throughout sequences.
extends Node

var _current_build_data: LevelBuildData
var _current_level_container: Node
var _intro_sequence_handle: SequenceHandle

func build_level_async() -> Node:
	# Clean up any previous encounter's state.
	if is_instance_valid(_intro_sequence_handle) and _intro_sequence_handle.is_running:
		_intro_sequence_handle.cancel()
	_intro_sequence_handle = null
	
	_current_level_container = Node.new()
	_current_level_container.name = "LevelContainer"

	var encounter_path: String = GameManager.state.current_encounter_script_path
	if encounter_path.is_empty():
		push_error("ArenaBuilder: No encounter script specified.")
		return _current_level_container
		
	var encounter_script: Script = load(encounter_path)
	if not is_instance_valid(encounter_script):
		push_error("ArenaBuilder: Failed to load encounter script at: %s" % encounter_path)
		return _current_level_container
		
	var parser = LevelParser.new()
	_current_build_data = parser.parse_level_data(encounter_script)
	
	await get_tree().process_frame

	var terrain_builder = TerrainBuilder.new()
	await terrain_builder.build_terrain_async(_current_level_container, _current_build_data, get_tree())

	# ArenaBuilder now directly calls the spawning logic.
	await _spawn_player_async()
	await _spawn_hud_async()
	_intro_sequence_handle = _run_intro_sequence()

	await get_tree().process_frame
	
	return _current_level_container

# --- Encounter Director Logic (now part of ArenaBuilder) ---

func _spawn_player_async() -> void:
	var player_instance = load(AssetPaths.SCENE_PLAYER).instantiate()
	player_instance.global_position = _current_build_data.player_spawn_pos
	_current_level_container.add_child(player_instance)
	await get_tree().process_frame

func _spawn_boss_async() -> Node:
	var boss_scene: PackedScene = _current_build_data.encounter_script_object.BOSS_SCENE
	if not boss_scene:
		push_error("ArenaBuilder: Could not find BOSS_SCENE in encounter script.")
		return null

	var boss_instance = boss_scene.instantiate()
	boss_instance.global_position = _current_build_data.boss_spawn_pos
	_current_level_container.add_child(boss_instance)
	await get_tree().process_frame
	return boss_instance

func _spawn_hud_async() -> void:
	var hud_instance = load(AssetPaths.SCENE_GAME_HUD).instantiate()
	_current_level_container.add_child(hud_instance)
	await get_tree().process_frame

func _run_intro_sequence() -> SequenceHandle:
	var wait_step = WaitStep.new()
	wait_step.duration = 0.5
	
	var spawn_boss_step = CallableStep.new()
	spawn_boss_step.callable = Callable(self, "_spawn_boss_async")

	var intro_steps: Array[SequenceStep] = [wait_step, spawn_boss_step]
	
	return Sequencer.run_sequence(intro_steps)