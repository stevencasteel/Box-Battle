# src/scenes/game/game.gd
#
# This script orchestrates the setup of an arena battle. It now also manages
# the overall game flow by listening for signals and events.
extends Node

var player_node: Node = null
var boss_node: Node = null

# --- NEW: Subscription Tokens ---
var _pause_token: int
var _resume_token: int


func _ready():
	# --- NEW: Subscribe to game state events ---
	_pause_token = EventBus.on(EventCatalog.GAME_PAUSED, _on_game_paused)
	_resume_token = EventBus.on(EventCatalog.GAME_RESUMED, _on_game_resumed)

	# MODIFIED: Access the state object on GameManager
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
	# Connect to the boss 'died' signal AFTER the intro sequence has spawned it.
	# We can get the node reference again just in case it wasn't ready before.
	var final_boss_node = get_tree().get_first_node_in_group("enemy")
	if is_instance_valid(final_boss_node):
		final_boss_node.died.connect(_on_boss_died)

func _exit_tree():
	# CRITICAL: Unsubscribe from all events to prevent memory leaks.
	EventBus.off(_pause_token)
	EventBus.off(_resume_token)
	# Unpause the game when this scene is exited.
	get_tree().paused = false


# --- Signal & Event Handlers ---

func _on_player_died():
	print("Game Manager: Player death detected. Initiating Game Over.")
	get_tree().call_deferred("change_scene_to_file", AssetPaths.SCENE_GAME_OVER_SCREEN)

func _on_boss_died():
	print("Game Manager: Boss death detected. Initiating Victory.")
	get_tree().call_deferred("change_scene_to_file", AssetPaths.SCENE_VICTORY_SCREEN)

# --- NEW: Pause Handlers ---
func _on_game_paused(_payload):
	print("Game Scene: Pausing tree.")
	get_tree().paused = true

func _on_game_resumed(_payload):
	print("Game Scene: Resuming tree.")
	get_tree().paused = false