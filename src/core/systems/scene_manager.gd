# src/core/systems/scene_manager.gd
# A centralized singleton for handling all scene transitions.
extends Node

func _switch_to_scene(path: String) -> void:
	ObjectPool.reset()
	Sequencer.cancel_all()
	get_tree().call_deferred("change_scene_to_file", path)

# --- Public API ---

func go_to_scene(path: String) -> void:
	_switch_to_scene(path)

func go_to_title_screen() -> void:
	go_to_scene(AssetPaths.SCENE_TITLE_SCREEN)

func start_game(encounter_path: String) -> void:
	# THE FIX: Assign to the correctly named variable.
	GameManager.state.current_encounter_path = encounter_path
	go_to_scene(AssetPaths.SCENE_LOADING_SCREEN)

func go_to_game_over() -> void:
	go_to_scene(AssetPaths.SCENE_GAME_OVER_SCREEN)

func go_to_victory() -> void:
	go_to_scene(AssetPaths.SCENE_VICTORY_SCREEN)