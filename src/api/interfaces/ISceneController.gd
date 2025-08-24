# src/api/interfaces/ISceneController.gd
## The conceptual "interface" for all main scene controller scripts.
##
## This defines a formal contract for scenes that require explicit cleanup
## logic to be run by the SceneManager before the scene is changed.
class_name ISceneController
extends Node

# --- Virtual Methods ---


## Called by the SceneManager immediately before it changes the scene.
## This function can be async to allow for cleanup animations or sequences.
func scene_exiting() -> void:
	pass