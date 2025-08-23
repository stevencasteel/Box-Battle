# homing_boss_shot.gd
class_name HomingBossShot
extends "res://src/projectiles/base_projectile.gd"

# --- Node References ---
@onready var lifetime_timer: Timer = $LifetimeTimer

# --- Exposed config (avoid depending on external COMBAT_CONFIG)
@export var lifespan: float = 3.0

# --- Private Member Variables ---
var _player_ref: WeakRef
var _active_tween: Tween

func _ready() -> void:
	add_to_group(Identifiers.Groups.ENEMY_PROJECTILE)
	visual.color = Palette.COLOR_HAZARD_PRIMARY

# Movement override
func _move(delta: float) -> void:
	# If no player, fall back to simple linear motion.
	if not _player_ref or not _player_ref.get_ref():
		global_position += transform.x * speed * delta
		return

	var player_node = _player_ref.get_ref()
	var direction_to_player = (player_node.global_position - global_position).normalized()
	rotation = lerp_angle(rotation, direction_to_player.angle(), 0.05)
	global_position += transform.x * speed * delta

# IPoolable override (call base via super)
func activate(p_dependencies: Dictionary = {}) -> void:
	# Call base activate
	super.activate(p_dependencies)

	# Find player once
	var player_node = get_tree().get_first_node_in_group(Identifiers.Groups.PLAYER)
	_player_ref = weakref(player_node)

	# Configure and start lifespan/tween
	if is_instance_valid(lifetime_timer):
		lifetime_timer.start(lifespan)

	if is_instance_valid(_active_tween):
		_active_tween.kill()

	_active_tween = create_tween()
	_active_tween.tween_property(visual, "scale", Vector2.ZERO, lifespan)
	_active_tween.tween_property(collision_shape, "scale", Vector2.ZERO, lifespan)

func deactivate() -> void:
	# kill tweens and reset visuals before base deactivation
	if is_instance_valid(_active_tween):
		_active_tween.kill()
		_active_tween = null

	visual.scale = Vector2.ONE
	collision_shape.scale = Vector2.ONE

	# Call base deactivate
	super.deactivate()

# Signal: lifetime expired
func _on_lifetime_timer_timeout() -> void:
	if not _is_active:
		return
	if is_instance_valid(_object_pool):
		_object_pool.return_instance.call_deferred(self)
