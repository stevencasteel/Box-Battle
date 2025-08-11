# src/scenes/game/game.gd
# This script orchestrates the setup of an arena battle and game flow.
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
		var build_data: LevelBuildData = level_container.get_meta("build_data")
		if build_data:
			# STEP 1: Center the camera on the arena.
			CameraManager.center_camera_on_arena(camera, build_data.dimensions_tiles)
			
			# STEP 2: Add the level to the scene.
			add_child(level_container)
			await get_tree().process_frame
			
			# STEP 3: Fill the viewport (which is now wider than the arena).
			var terrain_builder = TerrainBuilder.new()
			terrain_builder.fill_viewport(level_container, build_data, camera)

	player_node = get_tree().get_first_node_in_group("player")
	if is_instance_valid(player_node):
		player_node.died.connect(_on_player_died)
	
	var final_boss_node = get_tree().get_first_node_in_group("enemy")
	if is_instance_valid(final_boss_node):
		final_boss_node.died.connect(_on_boss_died)

func _exit_tree():
	EventBus.off(_boss_died_token)
	get_tree().paused = false

# --- Signal & Event Handlers ---

func _on_player_died():
	SceneManager.go_to_game_over()

func _on_boss_died(_payload = null):
	SceneManager.go_to_victory()
