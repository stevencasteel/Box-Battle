# src/core/building/arena_builder.gd
## An autoload that procedurally constructs the entire level scene.
##
## It parses data from [EncounterData] and [LevelLayout] resources, then uses
## builder sub-systems to spawn the terrain, entities, and UI.
extends Node

# --- Private Member Variables ---
var _current_build_data: LevelBuildData
var _current_level_container: Node
var _intro_sequence_handle: SequenceHandle
var _minion_spawn_counts: Dictionary = {}

# --- Public Methods ---


## Asynchronously builds the entire level and returns the root node.
func build_level_async() -> Node:
	if is_instance_valid(_intro_sequence_handle):
		_intro_sequence_handle.cancel()
	_intro_sequence_handle = null
	_minion_spawn_counts.clear()

	_current_level_container = Node.new()
	_current_level_container.name = "LevelContainer"

	var encounter_path: String = GameManager.state.current_encounter_path
	if encounter_path.is_empty():
		return _current_level_container

	var encounter_data: EncounterData = load(encounter_path)
	if not is_instance_valid(encounter_data):
		push_error("ArenaBuilder: Failed to load EncounterData at path: %s" % encounter_path)
		return _current_level_container

	var parser = LevelParser.new()
	_current_build_data = parser.parse_level_data(encounter_data, ServiceLocator)
	_current_build_data.encounter_data_resource = encounter_data
	_current_level_container.set_meta("build_data", _current_build_data)

	await get_tree().process_frame

	var terrain_builder = TerrainBuilder.new()
	await terrain_builder.build_terrain_async(
		_current_level_container, _current_build_data, get_tree(), ServiceLocator
	)

	await _spawn_player_async()
	await _spawn_hud_async()
	await _spawn_minions_async()

	_intro_sequence_handle = _run_intro_sequence()
	if is_instance_valid(_intro_sequence_handle):
		await _intro_sequence_handle.finished

	await get_tree().process_frame

	return _current_level_container


# --- Private Methods ---


func _spawn_player_async() -> void:
	var instance: BaseEntity = load(AssetPaths.SCENE_PLAYER).instantiate()
	instance.global_position = _current_build_data.player_spawn_pos
	instance.inject_dependencies(ServiceLocator)
	_current_level_container.add_child(instance)
	await get_tree().process_frame


func _spawn_boss_async() -> Node:
	var boss_scene: PackedScene = _current_build_data.encounter_data_resource.boss_scene
	if not boss_scene:
		return null
	var instance: BaseEntity = boss_scene.instantiate()
	instance.global_position = _current_build_data.boss_spawn_pos
	instance.inject_dependencies(ServiceLocator)
	_current_level_container.add_child(instance)
	await get_tree().process_frame
	return instance


func _spawn_hud_async() -> void:
	var instance: CanvasLayer = load(AssetPaths.SCENE_GAME_HUD).instantiate()
	_current_level_container.add_child(instance)
	await get_tree().process_frame


func _spawn_minions_async() -> void:
	for spawn_data in _current_build_data.minion_spawns:
		var instance: Node = spawn_data.scene.instantiate()

		var base_name: String = instance.name
		var current_count: int = _minion_spawn_counts.get(base_name, 0) + 1
		_minion_spawn_counts[base_name] = current_count
		instance.name = "%s_%d" % [base_name, current_count]
		
		if instance is Node2D:
			instance.global_position = spawn_data.position
		
		# THE FIX: Only inject dependencies if the spawned node is an entity.
		if instance is BaseEntity:
			instance.inject_dependencies(ServiceLocator)
			
		_current_level_container.add_child(instance)
		await get_tree().process_frame


func _run_intro_sequence() -> SequenceHandle:
	var wait_step := WaitStep.new()
	wait_step.duration = 0.5
	var spawn_boss_step := CallableStep.new()
	spawn_boss_step.callable = Callable(self, "_spawn_boss_async")
	var intro_steps: Array[SequenceStep] = [wait_step, spawn_boss_step]
	return Sequencer.run_sequence(intro_steps)
