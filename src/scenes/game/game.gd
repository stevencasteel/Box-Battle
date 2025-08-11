# src/scenes/game/game.gd
# This script orchestrates the setup of an arena battle and game flow.
extends Node

var player_node: Node = null
var boss_node: Node = null
var level_container: Node = null

@onready var camera: Camera2D = $Camera2D

func _ready():
	if GameManager.state.prebuilt_level:
		level_container = GameManager.state.prebuilt_level
		add_child(level_container)
		GameManager.state.prebuilt_level = null
		await get_tree().process_frame
	elif not GameManager.state.current_encounter_script_path.is_empty():
		# This path is now only taken if skipping the loading screen.
		level_container = await ArenaBuilder.build_level_async()
		add_child(level_container)
		await get_tree().process_frame
	else:
		print("ERROR: Game scene loaded without a pre-built level or encounter path.")
		SceneManager.go_to_title_screen()
		return
	
	if is_instance_valid(level_container):
		var build_data: LevelBuildData = level_container.get_meta("build_data")
		if build_data:
			# Step 1: Fit the camera to the logical arena size.
			CameraManager.fit_camera_to_arena(camera, build_data.dimensions_tiles)
			await get_tree().process_frame # Wait a frame for camera zoom to apply.
			
			# Step 2: Fill the visible empty space with background tiles.
			var terrain_builder = TerrainBuilder.new()
			terrain_builder.fill_viewport(level_container, build_data, camera)

	player_node = get_tree().get_first_node_in_group("player")
	boss_node = get_tree().get_first_node_in_group("enemy")

	if is_instance_valid(player_node):
		player_node.died.connect(_on_player_died)
	
	var final_boss_node = get_tree().get_first_node_in_group("enemy")
	if is_instance_valid(final_boss_node):
		final_boss_node.died.connect(_on_boss_died)

func _exit_tree():
	get_tree().paused = false

# --- Signal Handlers ---

func _on_player_died():
	SceneManager.go_to_game_over()

func _on_boss_died():
	SceneManager.go_to_victory()
