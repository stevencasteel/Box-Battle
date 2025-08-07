# src/scenes/game/game.gd
#
# This script orchestrates the setup of an arena battle. It now also manages
# the overall game flow by listening for signals from the player and boss.
extends Node

var player_node: Node = null
var boss_node: Node = null

func _ready():
	if GameManager.prebuilt_level:
		add_child(GameManager.prebuilt_level)
		GameManager.prebuilt_level = null
		await get_tree().process_frame
	elif not GameManager.current_encounter_script_path.is_empty():
		var level_container = await ArenaBuilder.build_level_async()
		add_child(level_container)
		await get_tree().process_frame
	else:
		print("ERROR: Game scene loaded without a pre-built level or encounter path. Returning to title.")
		get_tree().change_scene_to_file(AssetPaths.SCENE_TITLE_SCREEN)
		return
	
	player_node = get_tree().get_first_node_in_group("player")
	boss_node = get_tree().get_first_node_in_group("enemy")

	# --- LOGIC & WIRING FIX ---
	# Ensure the correct signals are connected to the correct handler functions.
	if is_instance_valid(player_node):
		player_node.died.connect(_on_player_died)
	if is_instance_valid(boss_node):
		boss_node.died.connect(_on_boss_died)

# --- Signal Handlers for Game Flow ---

func _on_player_died():
	print("Game Manager: Player death detected. Initiating Game Over.")
	get_tree().change_scene_to_file(AssetPaths.SCENE_GAME_OVER_SCREEN)

func _on_boss_died():
	print("Game Manager: Boss death detected. Initiating Victory.")
	get_tree().change_scene_to_file(AssetPaths.SCENE_VICTORY_SCREEN)


func _exit_tree():
	# CRITICAL: Unpause the game when this scene is exited.
	get_tree().paused = false
