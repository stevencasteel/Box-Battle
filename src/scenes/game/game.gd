# src/scenes/game/game.gd
# CORRECTED: Uses Identifiers constants for group checks.
extends Node

var player_node: Node = null
var level_container: Node = null
@onready var camera: Camera2D = $Camera2D
var _boss_died_token: int = 0
var _death_sequence_handle: SequenceHandle

func _ready():
	_boss_died_token = EventBus.on(EventCatalog.BOSS_DIED, _on_boss_died)
	if GameManager.state.prebuilt_level:
		level_container = GameManager.state.prebuilt_level
		GameManager.state.prebuilt_level = null
	else:
		level_container = await ArenaBuilder.build_level_async()
	
	if is_instance_valid(level_container):
		add_child(level_container)
		await get_tree().process_frame
		var build_data: LevelBuildData = level_container.get_meta("build_data")
		if build_data:
			CameraManager.center_camera_on_arena(camera, build_data.dimensions_tiles)
			await get_tree().process_frame
			var terrain_builder = TerrainBuilder.new()
			terrain_builder.fill_viewport(level_container, build_data, camera)

	player_node = get_tree().get_first_node_in_group(Identifiers.Groups.PLAYER)
	if is_instance_valid(player_node):
		player_node.died.connect(_on_player_died)

func _exit_tree():
	EventBus.off(_boss_died_token)
	if is_instance_valid(_death_sequence_handle):
		_death_sequence_handle.cancel()
	get_tree().paused = false

func _on_player_died():
	SceneManager.go_to_game_over()

func _on_boss_died(payload: Dictionary):
	if is_instance_valid(player_node): player_node.set_physics_process(false)
	var boss_node = payload.get("boss_node")

	_deactivate_all_minions()

	var wait_step_1 = WaitStep.new(); wait_step_1.duration = 1.0
	var wait_step_2 = WaitStep.new(); wait_step_2.duration = 1.5
	var death_sequence: Array[SequenceStep] = [wait_step_1, wait_step_2]
	
	_death_sequence_handle = Sequencer.run_sequence(death_sequence)
	await _death_sequence_handle.finished
	
	if is_instance_valid(boss_node): boss_node.queue_free()
	
	if is_instance_valid(_death_sequence_handle):
		SceneManager.go_to_victory()

func _deactivate_all_minions():
	var minions = get_tree().get_nodes_in_group(Identifiers.Groups.ENEMY)
	for minion in minions:
		if minion.has_method("deactivate"):
			minion.deactivate()