# src/core/building/arena_builder.gd
#
# The ArenaBuilder now correctly awaits the completion of the intro
# sequence, ensuring the boss is spawned before the level is returned.
extends Node

var _current_build_data: LevelBuildData
var _current_level_container: Node
var _intro_sequence_handle: SequenceHandle

func build_level_async() -> Node:
	if is_instance_valid(_intro_sequence_handle): _intro_sequence_handle.cancel()
	_intro_sequence_handle = null
	
	_current_level_container = Node.new(); _current_level_container.name = "LevelContainer"

	var encounter_path: String = GameManager.state.current_encounter_script_path
	if encounter_path.is_empty(): return _current_level_container
		
	var encounter_script: Script = load(encounter_path)
	if not is_instance_valid(encounter_script): return _current_level_container
		
	var parser = LevelParser.new()
	_current_build_data = parser.parse_level_data(encounter_script)
	_current_level_container.set_meta("build_data", _current_build_data)
	
	await get_tree().process_frame

	var terrain_builder = TerrainBuilder.new()
	await terrain_builder.build_terrain_async(_current_level_container, _current_build_data, get_tree())

	await _spawn_player_async()
	await _spawn_hud_async()
	await _spawn_minions_async()
	
	_intro_sequence_handle = _run_intro_sequence()
	# THE FIX: Wait for the intro sequence to fully complete before proceeding.
	# This ensures the boss is spawned before the loading screen transitions away.
	if is_instance_valid(_intro_sequence_handle):
		await _intro_sequence_handle.finished

	await get_tree().process_frame
	
	return _current_level_container

# --- Entity Spawning Logic ---

func _spawn_player_async() -> void:
	var instance = load(AssetPaths.SCENE_PLAYER).instantiate()
	instance.global_position = _current_build_data.player_spawn_pos
	_current_level_container.add_child(instance)
	await get_tree().process_frame

func _spawn_boss_async() -> Node:
	var boss_scene: PackedScene = _current_build_data.encounter_script_object.BOSS_SCENE
	if not boss_scene: return null
	var instance = boss_scene.instantiate()
	instance.global_position = _current_build_data.boss_spawn_pos
	_current_level_container.add_child(instance)
	await get_tree().process_frame
	return instance

func _spawn_hud_async() -> void:
	var instance = load(AssetPaths.SCENE_GAME_HUD).instantiate()
	_current_level_container.add_child(instance)
	await get_tree().process_frame

func _spawn_minions_async() -> void:
	for spawn_data in _current_build_data.minion_spawns:
		var instance = load(spawn_data.scene_path).instantiate()
		instance.global_position = spawn_data.position
		_current_level_container.add_child(instance)
		await get_tree().process_frame

func _run_intro_sequence() -> SequenceHandle:
	var wait_step = WaitStep.new(); wait_step.duration = 0.5
	var spawn_boss_step = CallableStep.new()
	spawn_boss_step.callable = Callable(self, "_spawn_boss_async")
	var intro_steps: Array[SequenceStep] = [wait_step, spawn_boss_step]
	return Sequencer.run_sequence(intro_steps)