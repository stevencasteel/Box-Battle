# src/projectiles/base_projectile.gd
class_name BaseProjectile
extends Area2D

# --- Node References ---
@onready var collision_shape: CollisionShape2D = $CollisionShape2D
@onready var visual: ColorRect = $ColorRect

# --- Public Properties ---
@export var speed: float = 400.0
@export var damage: int = 1
var direction: Vector2 = Vector2.RIGHT

# --- Private Member Variables ---
var _services: ServiceLocator
var _is_active: bool = false
var _has_been_on_screen: bool = false

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


func activate(p_services: ServiceLocator) -> void:
	self._services = p_services
	assert(is_instance_valid(_services), "%s requires a ServiceLocator dependency." % [self.get_class()])
	
	_has_been_on_screen = false
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
	_services = null


# --- Centralized Collision & Cleanup ---


func _handle_collision(target: Node) -> void:
	var damageable = _services.combat_utils.find_damageable(target)
	if is_instance_valid(damageable):
		var damage_info := DamageInfo.new()
		damage_info.amount = damage
		damage_info.source_node = self
		damage_info.impact_position = global_position
		damage_info.impact_normal = -direction.normalized() if not direction.is_zero_approx() else Vector2.ZERO
		damageable.apply_damage(damage_info)

	if is_instance_valid(_services):
		_services.object_pool.return_instance.call_deferred(self)


# --- Signal Handlers ---


func _on_body_entered(body: Node) -> void:
	if not _is_active:
		return
	_handle_collision(body)


func _on_area_entered(area: Area2D) -> void:
	if not _is_active:
		return
	_handle_collision(area)


func _on_screen_entered() -> void:
	_has_been_on_screen = true


func _on_screen_exited() -> void:
	if not _is_active:
		return
	
	if not _has_been_on_screen:
		return
		
	if is_instance_valid(_services):
		_services.object_pool.return_instance.call_deferred(self)
