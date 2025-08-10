# src/scenes/game/game.gd
# This script orchestrates the setup of an arena battle and game flow.
extends Node

var player_node: Node = null
var boss_node: Node = null

func _ready():
	if GameManager.state.prebuilt_level:
		add_child(GameManager.state.prebuilt_level)
		GameManager.state.prebuilt_level = null
		await get_tree().process_frame
	elif not GameManager.state.current_encounter_script_path.is_empty():
		var level_container = await ArenaBuilder.build_level_async()
		add_child(level_container)
		await get_tree().process_frame
	else:
		print("ERROR: Game scene loaded without a pre-built level or encounter path. Returning to title.")
		# MODIFIED: Use the new SceneManager.
		SceneManager.go_to_title_screen()
		return

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
	print("Game Manager: Player death detected. Initiating Game Over.")
	# MODIFIED: Use the new SceneManager.
	SceneManager.go_to_game_over()

func _on_boss_died():
	print("Game Manager: Boss death detected. Initiating Victory.")
	# MODIFIED: Use the new SceneManager.
	SceneManager.go_to_victory()
