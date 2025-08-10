# src/scenes/game/game.gd
#
# This script orchestrates the setup of an arena battle. It now also manages
# the overall game flow by listening for signals.
extends Node

var player_node: Node = null
var boss_node: Node = null

# REMOVED: No longer need subscription tokens as we are not using the EventBus here.

func _ready():
	# REMOVED: The game scene no longer subscribes to pause events.
	# Pause logic will be handled differently if implemented later.

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
		get_tree().change_scene_to_file(AssetPaths.SCENE_TITLE_SCREEN)
		return

	player_node = get_tree().get_first_node_in_group("player")
	boss_node = get_tree().get_first_node_in_group("enemy")

	if is_instance_valid(player_node):
		player_node.died.connect(_on_player_died)
	
	var final_boss_node = get_tree().get_first_node_in_group("enemy")
	if is_instance_valid(final_boss_node):
		final_boss_node.died.connect(_on_boss_died)

func _exit_tree():
	# Unpause the game when this scene is exited. This is a safeguard.
	get_tree().paused = false


# --- Signal Handlers ---

func _on_player_died():
	print("Game Manager: Player death detected. Initiating Game Over.")
	get_tree().call_deferred("change_scene_to_file", AssetPaths.SCENE_GAME_OVER_SCREEN)

func _on_boss_died():
	print("Game Manager: Boss death detected. Initiating Victory.")
	get_tree().call_deferred("change_scene_to_file", AssetPaths.SCENE_VICTORY_SCREEN)
