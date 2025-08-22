# src/entities/minions/turret.gd
@tool
## A stationary enemy that detects and fires projectiles at the player.
class_name Turret
extends BaseEntity

# --- Enums ---
enum State { IDLE, ATTACK }

# --- Constants ---
const COMBAT_CONFIG = preload("res://src/data/combat_config.tres")
const HIT_FLASH_EFFECT = preload("res://src/data/effects/entity_hit_flash_effect.tres")

# --- Editor Configuration ---
@export var hit_spark_effect: VFXEffect
@export var dissolve_effect: ShaderEffect

# --- Node References ---
@onready var visual: Polygon2D = $Visual
@onready var attack_timer: Timer = $AttackTimer
@onready var range_detector_shape: CollisionShape2D = $RangeDetector/CollisionShape2D

# --- Public Member Variables ---
var entity_data: TurretStateData

# --- Private Member Variables ---
var _player: CharacterBody2D
var _object_pool: ObjectPool  # Dependency
var _fx_manager: Node  # Dependency
var _is_dead: bool = false

# --- Godot Lifecycle Methods ---


func _ready() -> void:
	super._ready()
	if Engine.is_editor_hint():
		return

	_initialize_data()
	_initialize_and_setup_components()
	_connect_signals()

	_player = get_tree().get_first_node_in_group(Identifiers.Groups.PLAYER)


func _notification(what: int) -> void:
	if what == NOTIFICATION_PREDELETE:
		teardown()


# --- Public Methods ---


func teardown() -> void:
	if is_instance_valid(health_component):
		if health_component.died.is_connected(_on_health_component_died):
			health_component.died.disconnect(_on_health_component_died)

	super.teardown()
	entity_data = null


func deactivate() -> void:
	if is_instance_valid(state_machine):
		state_machine.teardown()
	if is_instance_valid(attack_timer):
		attack_timer.stop()

	set_physics_process(false)
	$RangeDetector.monitoring = false


# --- Private Methods ---


func _fire_at_player() -> void:
	if not is_instance_valid(_player):
		return

	var shot = _object_pool.get_instance(Identifiers.Pools.TURRET_SHOTS)
	if not is_instance_valid(shot):
		return

	shot.direction = (self._player.global_position - self.global_position).normalized()
	shot.global_position = self.global_position
	shot.activate({"object_pool": _object_pool})


func _die() -> void:
	if _is_dead:
		return
	_is_dead = true

	# THE FIX: Immediately remove from physics and stop all logic.
	collision_layer = 0
	collision_mask = 0
	deactivate()

	var death_tween: Tween = fx_component.play_effect(dissolve_effect)
	if is_instance_valid(death_tween):
		await death_tween.finished

	if is_instance_valid(self):
		queue_free()


func _initialize_data() -> void:
	add_to_group(Identifiers.Groups.ENEMY)
	visual.color = Palette.COLOR_TERRAIN_SECONDARY
	entity_data = TurretStateData.new()
	entity_data.config = COMBAT_CONFIG

	_object_pool = get_injected_dependency("object_pool")
	_fx_manager = get_injected_dependency("fx_manager")
	assert(is_instance_valid(_object_pool), "Turret requires 'object_pool' injected.")
	assert(is_instance_valid(_fx_manager), "Turret requires 'fx_manager' injected.")


func _initialize_and_setup_components() -> void:
	var circle_shape = CircleShape2D.new()
	circle_shape.radius = entity_data.config.turret_detection_radius
	range_detector_shape.shape = circle_shape

	attack_timer.wait_time = entity_data.config.turret_fire_rate

	var shared_deps := {
		"data_resource": entity_data, "config": entity_data.config, "fx_manager": _fx_manager
	}

	var states = {
		State.IDLE:
		load("res://src/entities/minions/states/state_turret_idle.gd").new(
			self, state_machine, entity_data
		),
		State.ATTACK:
		load("res://src/entities/minions/states/state_turret_attack.gd").new(
			self, state_machine, entity_data
		)
	}

	var per_component_deps := {
		state_machine: {"states": states, "initial_state_key": State.IDLE},
		fx_component:
		{
			"visual_node": visual,
			"health_component": health_component,
			"hit_effect": HIT_FLASH_EFFECT
		},
		health_component: {"hit_spark_effect": hit_spark_effect}
	}

	setup_components(shared_deps, per_component_deps)


func _connect_signals() -> void:
	health_component.died.connect(_on_health_component_died)


# --- Signal Handlers ---


func _on_range_detector_body_entered(body: Node) -> void:
	if not entity_data:
		return
	if body.is_in_group(Identifiers.Groups.PLAYER):
		entity_data.is_player_in_range = true


func _on_range_detector_body_exited(body: Node) -> void:
	if not entity_data:
		return
	if body.is_in_group(Identifiers.Groups.PLAYER):
		entity_data.is_player_in_range = false


func _on_health_component_died() -> void:
	_die()
