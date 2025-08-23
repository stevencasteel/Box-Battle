# src/projectiles/base_projectile.gd
class_name BaseProjectile
extends Area2D

# --- Constants ---
const CombatUtilsScript = preload(AssetPaths.SCRIPT_COMBAT_UTILS)

# --- Node References ---
@onready var collision_shape: CollisionShape2D = $CollisionShape2D
@onready var visual: ColorRect = $ColorRect

# --- Public Properties ---
@export var speed: float = 400.0
@export var damage: int = 1
var direction: Vector2 = Vector2.RIGHT

# --- Private Member Variables ---
var _object_pool: ObjectPool
var _is_active: bool = false

# --- Godot Lifecycle ---


func _physics_process(delta: float) -> void:
	if not _is_active:
		return
	_move(delta)


# --- Virtual Hooks ---


## Can be overridden by child classes for custom movement (e.g., homing).
func _move(delta: float) -> void:
	global_position += direction * speed * delta


# --- IPoolable Contract ---


func activate(p_dependencies: Dictionary = {}) -> void:
	self._object_pool = p_dependencies.get("object_pool")
	assert(is_instance_valid(_object_pool), "%s requires an ObjectPool dependency." % [self.get_class()])

	visible = true
	_is_active = true
	process_mode = PROCESS_MODE_INHERIT
	if is_instance_valid(collision_shape):
		collision_shape.disabled = false


func deactivate() -> void:
	visible = false
	_is_active = false
	process_mode = PROCESS_MODE_DISABLED
	if is_instance_valid(collision_shape):
		collision_shape.disabled = true
	_object_pool = null


# --- Centralized Collision & Cleanup ---


func _handle_collision(target: Node) -> void:
	# Find a damageable target using the utility script.
	var damageable = CombatUtilsScript.find_damageable(target)
	if is_instance_valid(damageable):
		var damage_info := DamageInfo.new()
		damage_info.amount = damage
		damage_info.source_node = self
		damage_info.impact_position = global_position
		damage_info.impact_normal = -direction.normalized() if not direction.is_zero_approx() else Vector2.ZERO
		damageable.apply_damage(damage_info)

	if is_instance_valid(_object_pool):
		_object_pool.return_instance.call_deferred(self)


# --- Signal Handlers ---


func _on_body_entered(body: Node) -> void:
	if not _is_active:
		return
	_handle_collision(body)


func _on_area_entered(area: Area2D) -> void:
	if not _is_active:
		return
	_handle_collision(area)


func _on_screen_exited() -> void:
	if not _is_active:
		return
	if is_instance_valid(_object_pool):
		_object_pool.return_instance.call_deferred(self)