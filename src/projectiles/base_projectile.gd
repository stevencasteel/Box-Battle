# res://src/projectiles/base_projectile.gd
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
var _services: ServiceLocator = null
var _is_active: bool = false
var _has_been_on_screen: bool = false

# --- Godot Lifecycle ---
func _physics_process(delta: float) -> void:
	if not _is_active:
		return
	_move(delta)

# --- Virtual Hooks ---
func _move(delta: float) -> void:
	global_position += direction * speed * delta

# --- IPoolable Contract ---
func activate(p_services: ServiceLocator) -> void:
	_services = p_services
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
	# Ignore AI sensor Areas by name (RangeDetector, MeleeRangeDetector, etc.)
	if target is Area2D:
		var lname := target.name.to_lower()
		if lname.find("range") != -1 or lname.find("detector") != -1:
			return

	# Resolve damageable (uses your ServiceLocator/combat_utils)
	var damageable = null
	if is_instance_valid(_services):
		# services.combat_utils.find_damageable(...) was used previously in your project
		if _services.combat_utils:
			damageable = _services.combat_utils.find_damageable(target)

	if is_instance_valid(damageable):
		var damage_info := DamageInfo.new()
		damage_info.amount = damage
		damage_info.source_node = self
		damage_info.impact_position = global_position
		damage_info.impact_normal = -direction.normalized() if not direction.is_zero_approx() else Vector2.ZERO
		damageable.apply_damage(damage_info)

	# Return to pool safely (deferred to avoid physics callback issues)
	if is_instance_valid(_services) and _services.object_pool:
		_services.object_pool.return_instance.call_deferred(self)

# --- Timer / On-screen handlers (signal targets) ---
func _on_lifetime_timer_timeout() -> void:
	# If you have a Timer node named "LifetimeTimer" in the projectile scene
	# and connected its "timeout" signal here, this will be called even without a member var.
	if not _is_active:
		return
	if is_instance_valid(_services) and _services.object_pool:
		_services.object_pool.return_instance.call_deferred(self)

func _on_screen_entered() -> void:
	_has_been_on_screen = true

func _on_screen_exited() -> void:
	if not _is_active:
		return
	if not _has_been_on_screen:
		return
	if is_instance_valid(_services) and _services.object_pool:
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
