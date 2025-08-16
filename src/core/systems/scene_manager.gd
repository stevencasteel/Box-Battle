# src/core/systems/scene_manager.gd
## A centralized singleton for handling all scene transitions.
##
## This provides a robust, single API for navigation and ensures that
## necessary cleanup (like resetting the ObjectPool) happens automatically.
extends Node

# --- Public API ---

## Generic method to transition to any scene by its path.
func go_to_scene(path: String) -> void:
	_switch_to_scene(path)

## Transitions to the main title screen.
func go_to_title_screen() -> void:
	go_to_scene(AssetPaths.SCENE_TITLE_SCREEN)

## Starts a new game with a specific encounter.
func start_game(encounter_path: String) -> void:
	GameManager.state.current_encounter_path = encounter_path
	go_to_scene(AssetPaths.SCENE_LOADING_SCREEN)

## Transitions to the game over screen.
func go_to_game_over() -> void:
	go_to_scene(AssetPaths.SCENE_GAME_OVER_SCREEN)

## Transitions to the victory screen.
func go_to_victory() -> void:
	go_to_scene(AssetPaths.SCENE_VICTORY_SCREEN)

# --- Private Methods ---

## The core scene-switching logic.
func _switch_to_scene(path: String) -> void:
	# Perform necessary cleanup before changing scenes.
	ObjectPool.reset()
	Sequencer.cancel_all()
	get_tree().call_deferred("change_scene_to_file", path)