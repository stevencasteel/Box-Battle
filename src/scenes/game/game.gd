# src/scenes/game/game.gd
## The main game scene controller.
##
## Responsible for asynchronously building the level, spawning the player and
## boss, managing the game camera, and handling the victory/defeat sequences.
## It also manages the developer debug overlay.
extends Node

# --- Node References ---
@onready var camera: Camera2D = $Camera2D

# --- Private Member Variables ---
var _player_node: Node = null
var _level_container: Node = null
var _debug_overlay: CanvasLayer = null
var _boss_died_token: int = 0
var _death_sequence_handle: SequenceHandle

# --- Godot Lifecycle Methods ---

func _ready() -> void:
	_boss_died_token = EventBus.on(EventCatalog.BOSS_DIED, _on_boss_died)

	# Asynchronously build the level from the data stored in GameManager.
	if is_instance_valid(GameManager.state.prebuilt_level):
		_level_container = GameManager.state.prebuilt_level
		GameManager.state.prebuilt_level = null
	else:
		_level_container = await ArenaBuilder.build_level_async()

	if is_instance_valid(_level_container):
		add_child(_level_container)
		await get_tree().process_frame # Wait for nodes to be added to tree

		var build_data: LevelBuildData = _level_container.get_meta("build_data")
		if build_data:
			CameraManager.center_camera_on_arena(camera, build_data.dimensions_tiles)
			await get_tree().process_frame # Wait for camera to position

			var terrain_builder = TerrainBuilder.new()
			terrain_builder.fill_viewport(_level_container, build_data, camera)

	_player_node = get_tree().get_first_node_in_group(Identifiers.Groups.PLAYER)
	if is_instance_valid(_player_node):
		_player_node.died.connect(_on_player_died)

	# Instance and manage the debug overlay.
	_debug_overlay = load(AssetPaths.SCENE_DEBUG_OVERLAY).instantiate()
	add_child(_debug_overlay)
	_debug_overlay.visible = false

func _unhandled_input(_event: InputEvent) -> void:
	if Input.is_action_just_pressed("debug_toggle"):
		if is_instance_valid(_debug_overlay):
			_debug_overlay.visible = not _debug_overlay.visible

func _exit_tree() -> void:
	EventBus.off(_boss_died_token)
	if is_instance_valid(_death_sequence_handle):
		_death_sequence_handle.cancel()
	# Ensure the game is unpaused when leaving the scene.
	get_tree().paused = false

# --- Private Methods ---

## Deactivates all active minions in the scene.
func _deactivate_all_minions() -> void:
	var minions = get_tree().get_nodes_in_group(Identifiers.Groups.ENEMY)
	for minion in minions:
		# Check for the deactivate method to safely handle different enemy types.
		if minion.has_method("deactivate"):
			minion.deactivate()

# --- Signal Handlers ---

func _on_player_died() -> void:
	SceneManager.go_to_game_over()

func _on_boss_died(payload: Dictionary) -> void:
	if is_instance_valid(_player_node): _player_node.set_physics_process(false)
	var boss_node = payload.get("boss_node")

	_deactivate_all_minions()

	# Create and run a cinematic sequence before the victory screen.
	var wait_step_1 = WaitStep.new(); wait_step_1.duration = 1.0
	var wait_step_2 = WaitStep.new(); wait_step_2.duration = 1.5
	var death_sequence: Array[SequenceStep] = [wait_step_1, wait_step_2]

	_death_sequence_handle = Sequencer.run_sequence(death_sequence)
	await _death_sequence_handle.finished

	if is_instance_valid(boss_node): boss_node.queue_free()

	# Only transition if the sequence wasn't cancelled by leaving the scene.
	if is_instance_valid(_death_sequence_handle):
		SceneManager.go_to_victory()
