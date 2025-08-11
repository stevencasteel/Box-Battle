# src/scenes/game/game.gd
# The game scene now correctly awaits the death cinematic sequence.
extends Node

var player_node: Node = null
var level_container: Node = null
@onready var camera: Camera2D = $Camera2D
var _boss_died_token: int = 0

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

	player_node = get_tree().get_first_node_in_group("player")
	if is_instance_valid(player_node):
		player_node.died.connect(_on_player_died)

func _exit_tree():
	EventBus.off(_boss_died_token)
	get_tree().paused = false

func _on_player_died():
	SceneManager.go_to_game_over()

func _on_boss_died(payload: Dictionary):
	if is_instance_valid(player_node): player_node.set_physics_process(false)
	var boss_node = payload.get("boss_node")

	var wait_step_1 = WaitStep.new(); wait_step_1.duration = 1.0
	var wait_step_2 = WaitStep.new(); wait_step_2.duration = 1.5
	var death_sequence: Array[SequenceStep] = [wait_step_1, wait_step_2]
	
	# THE FIX: Get the handle and await its `finished` signal.
	var handle = Sequencer.run_sequence(death_sequence)
	await handle.finished
	
	if is_instance_valid(boss_node): boss_node.queue_free()
	SceneManager.go_to_victory()
