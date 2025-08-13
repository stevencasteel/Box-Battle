# src/core/systems/scene_manager.gd
#
# A centralized singleton for handling all scene transitions. It now
# cleans up both the ObjectPool and the Sequencer for a clean slate.
extends Node

# The core, private function that handles the actual scene change.
func _switch_to_scene(path: String) -> void:
	# THE FIX: Clean up all active projectiles AND cancel all running sequences.
	ObjectPool.reset()
	Sequencer.cancel_all()
	get_tree().call_deferred("change_scene_to_file", path)


# --- Public API ---

func go_to_title_screen() -> void:
	_switch_to_scene(AssetPaths.SCENE_TITLE_SCREEN)

func start_game(encounter_path: String) -> void:
	GameManager.state.current_encounter_script_path = encounter_path
	_switch_to_scene(AssetPaths.SCENE_LOADING_SCREEN)

func go_to_game_over() -> void:
	_switch_to_scene(AssetPaths.SCENE_GAME_OVER_SCREEN)

func go_to_victory() -> void:
	_switch_to_scene(AssetPaths.SCENE_VICTORY_SCREEN)

# A generic function for simple menu navigation.
func go_to_scene(path: String) -> void:
	_switch_to_scene(path)