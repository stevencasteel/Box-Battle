# src/api/interfaces.gd
## A central autoload script whose sole purpose is to preload all interface
## scripts in the project. This ensures their 'class_name' is registered
## with Godot's ScriptServer before any other script tries to use them,
## resolving parse order errors.
extends Node

func _ready() -> void:
	# Preload all interfaces to register their class_names globally.
	# We don't need to store them in variables, just ensure they are loaded.
	preload("res://src/api/interfaces/IComponent.gd")
	preload("res://src/api/interfaces/IDamageable.gd")
	preload("res://src/api/interfaces/IPoolable.gd")
	preload("res://src/api/interfaces/ISceneController.gd")
