# src/scenes/game/encounter_scene.gd
## The main game scene controller.
##
## Responsible for asynchronously building the level, spawning entities,
## managing the game camera, and handling victory/defeat sequences.
## It also manages the developer debug overlay and target inspection.
class_name EncounterScene
extends ISceneController

# --- Node References ---
@onready var camera: Camera2D = $Camera2D

# --- Private Member Variables ---
var _level_container: Node = null
var _debug_overlay: DebugOverlay = null
var _boss_died_token: int = 0
var _death_sequence_handle: SequenceHandle
var _camera_shaker: CameraShaker = null
const TestConversation = preload("res://src/data/dialogue/test_conversation.tres")

# --- Debug Inspector ---
var _inspectable_entities: Array[Node] = []
var _current_inspect_index: int = 0

# --- Godot Lifecycle Methods ---

func _ready() -> void:
	_boss_died_token = EventBus.on(EventCatalog.BOSS_DIED, _on_boss_died)

	if is_instance_valid(GameManager.state.prebuilt_level):
		_level_container = GameManager.state.prebuilt_level
		GameManager.state.prebuilt_level = null
	else:
		_level_container = await ArenaBuilder.build_level_async()

	if is_instance_valid(_level_container):
		add_child(_level_container)
		await get_tree().process_frame

		var build_data: LevelBuildData = _level_container.get_meta("build_data")
		if build_data:
			CameraManager.center_camera_on_arena(camera, build_data.dimensions_tiles)
			await get_tree().process_frame
			var terrain_builder = TerrainBuilder.new()
			terrain_builder.fill_viewport(_level_container, build_data, camera)

	_initialize_camera_shaker()
	_initialize_debug_inspector()

	var player_node = get_tree().get_first_node_in_group(Identifiers.Groups.PLAYER)
	if is_instance_valid(player_node):
		player_node.died.connect(_on_player_died)

func _unhandled_input(_event: InputEvent) -> void:
	if Input.is_action_just_pressed("debug_toggle_overlay"):
		if is_instance_valid(_debug_overlay):
			_debug_overlay.visible = not _debug_overlay.visible
			
	if Input.is_action_just_pressed("debug_dialogue"):
		# THE FIX: Toggle the dialogue on/off.
		if DialogueManager.is_conversation_active():
			DialogueManager.end_conversation()
		else:
			DialogueManager.start_conversation(TestConversation)
			print("VERIFICATION: Dialogue triggered.")

	if Input.is_action_just_pressed("debug_cycle_target"):
		if is_instance_valid(_debug_overlay) and _debug_overlay.visible:
			_cycle_debug_target()

func _exit_tree() -> void:
	# This is the safety net that catches exits not handled by SceneManager.
	_cleanup_entities()

	EventBus.off(_boss_died_token)
	FXManager.unregister_camera_shaker()
	if is_instance_valid(_death_sequence_handle): _death_sequence_handle.cancel()
	if is_instance_valid(camera): camera.offset = Vector2.ZERO
	get_tree().paused = false

# --- Public Methods (ISceneController Contract) ---

func scene_exiting() -> void:
	_cleanup_entities()

# --- Private Methods ---

func _cleanup_entities() -> void:
	# This centralized function ensures all entities are properly torn down.
	var player_node = get_tree().get_first_node_in_group(Identifiers.Groups.PLAYER)
	if is_instance_valid(player_node) and player_node.has_method("teardown"):
		player_node.teardown()

	var enemy_nodes = get_tree().get_nodes_in_group(Identifiers.Groups.ENEMY)
	for enemy in enemy_nodes:
		if is_instance_valid(enemy) and enemy.has_method("teardown"):
			enemy.teardown()

func _initialize_camera_shaker() -> void:
	var shaker_scene = load("res://src/core/systems/camera_shaker.tscn")
	if shaker_scene:
		_camera_shaker = shaker_scene.instantiate() as CameraShaker
		add_child(_camera_shaker)
		_camera_shaker.target_camera = camera
		FXManager.register_camera_shaker(_camera_shaker)

func _initialize_debug_inspector() -> void:
	_debug_overlay = load(AssetPaths.SCENE_DEBUG_OVERLAY).instantiate()
	add_child(_debug_overlay)
	_debug_overlay.visible = false
	
	_inspectable_entities.append_array(get_tree().get_nodes_in_group(Identifiers.Groups.PLAYER))
	_inspectable_entities.append_array(get_tree().get_nodes_in_group(Identifiers.Groups.ENEMY))
	
	if not _inspectable_entities.is_empty():
		_debug_overlay.set_target(_inspectable_entities[0])

func _cycle_debug_target() -> void:
	_inspectable_entities = _inspectable_entities.filter(func(e): return is_instance_valid(e))

	if _inspectable_entities.is_empty():
		_debug_overlay.set_target(null)
		return

	_current_inspect_index = (_current_inspect_index + 1) % _inspectable_entities.size()
	var new_target = _inspectable_entities[_current_inspect_index]
	_debug_overlay.set_target(new_target)

func _deactivate_all_minions() -> void:
	var minions = get_tree().get_nodes_in_group(Identifiers.Groups.ENEMY)
	for minion in minions:
		if minion.has_method("deactivate"):
			minion.deactivate()

# --- Signal Handlers ---

func _on_player_died() -> void:
	SceneManager.go_to_game_over()

func _on_boss_died(payload: Dictionary) -> void:
	var player_node = get_tree().get_first_node_in_group(Identifiers.Groups.PLAYER)
	if is_instance_valid(player_node): player_node.set_physics_process(false)
	var boss_node = payload.get("boss_node")

	_deactivate_all_minions()
	
	var wait_step = WaitStep.new(); wait_step.duration = 2.0
	var death_sequence: Array[SequenceStep] = [wait_step]

	_death_sequence_handle = Sequencer.run_sequence(death_sequence)
	await _death_sequence_handle.finished

	if is_instance_valid(boss_node):
		boss_node.queue_free()
		
	if is_instance_valid(_death_sequence_handle):
		SceneManager.go_to_victory()