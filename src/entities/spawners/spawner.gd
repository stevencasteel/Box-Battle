# src/entities/spawners/spawner.gd
## A generic, reusable spawner for instantiating scenes at runtime.
##
## Manages a timer, tracks the number of active instances it has spawned,
## and ensures dependencies are injected into the newly created nodes.
class_name Spawner
extends Node2D

@export_group("Configuration")
## The scene that this spawner will instantiate.
@export var scene_to_spawn: PackedScene
## The delay in seconds between spawn attempts.
@export_range(0.1, 60.0, 0.1) var spawn_delay: float = 10.0
## The maximum number of active instances this spawner can manage at once.
@export_range(1, 10, 1) var max_spawned_instances: int = 1
## If true, the spawner will begin its timer as soon as it enters the scene.
@export var autostart: bool = true
## If true, the spawner will create its first instance immediately.
@export var spawn_on_start: bool = true

# --- Node References ---
@onready var timer: Timer = $Timer

# --- Private Member Variables ---
var _spawned_instances: Array[Node] = []
var _services: ServiceLocator

# --- Godot Lifecycle Methods ---


func _ready() -> void:
	set_process(false)
	set_physics_process(false)
	
	if not Engine.is_editor_hint():
		_services = get_node("/root/ServiceLocator")
		assert(is_instance_valid(_services), "Spawner could not find ServiceLocator.")
		
		timer.wait_time = spawn_delay
		
		if spawn_on_start:
			_spawn_instance()
		
		if autostart:
			timer.start()


# --- Private Methods ---


func _spawn_instance() -> void:
	if not is_instance_valid(scene_to_spawn):
		push_warning("Spawner has no valid 'scene_to_spawn' configured.")
		return
	
	_spawned_instances = _spawned_instances.filter(
		func(instance): return is_instance_valid(instance)
	)

	if _spawned_instances.size() >= max_spawned_instances:
		return

	var new_instance: Node = scene_to_spawn.instantiate()
	
	if new_instance is BaseEntity:
		new_instance.inject_dependencies(_services)

	# Use call_deferred to prevent modifying the scene tree during _ready().
	get_parent().call_deferred("add_child", new_instance)
	if new_instance is Node2D:
		new_instance.global_position = self.global_position

	_spawned_instances.append(new_instance)


# --- Signal Handlers ---


func _on_timer_timeout() -> void:
	_spawn_instance()
