# src/api/global_preloader.gd
## A central autoload script whose sole purpose is to preload all interface
## and critical base class scripts in the project. This ensures their 'class_name'
## is registered with Godot's ScriptServer before any other script tries to use them,
## resolving parse order errors.
extends Node


func _ready() -> void:
	# Preload all interfaces and critical base classes to register them globally.
	preload("res://src/api/interfaces/IComponent.gd")
	preload("res://src/api/interfaces/IDamageable.gd")
	preload("res://src/api/interfaces/IPoolable.gd")
	preload("res://src/api/interfaces/ISceneController.gd")
	preload("res://src/entities/base_entity.gd")
