# src/projectiles/player_shot.gd
## A projectile fired by the player. Implements the [IPoolable] interface.
class_name PlayerShot
extends Area2D

# --- Constants ---
const CombatUtilsScript = preload(AssetPaths.SCRIPT_COMBAT_UTILS)

# --- Node References ---
@onready var collision_shape: CollisionShape2D = $CollisionShape2D

# --- Member Variables ---
var direction: Vector2 = Vector2.RIGHT
var speed: float = 1000.0
var damage: int = 2
var _object_pool: ObjectPool  # Dependency

# --- Godot Lifecycle Methods ---


func _ready() -> void:
	$ColorRect.color = Palette.COLOR_PLAYER_PROJECTILE


func _physics_process(delta: float) -> void:
	global_position += direction * speed * delta


# --- Public Methods (IPoolable Contract) ---


## Activates the projectile, making it visible and interactive.
func activate(p_dependencies: Dictionary = {}) -> void:
	self._object_pool = p_dependencies.get("object_pool")
	assert(is_instance_valid(_object_pool), "PlayerShot requires an ObjectPool dependency.")

	visible = true
	process_mode = PROCESS_MODE_INHERIT
	collision_shape.disabled = false


## Deactivates the projectile, preparing it to be returned to the ObjectPool.
func deactivate() -> void:
	visible = false
	process_mode = PROCESS_MODE_DISABLED
	collision_shape.disabled = true
	_object_pool = null  # Clear reference


# --- Signal Handlers ---


func _on_body_entered(body: Node) -> void:
	if process_mode == PROCESS_MODE_DISABLED:
		return

	var damageable = CombatUtilsScript.find_damageable(body)
	if is_instance_valid(damageable):
		var damage_info = DamageInfo.new()
		damage_info.amount = damage
		damage_info.source_node = self
		damage_info.impact_position = global_position
		damage_info.impact_normal = -direction
		damageable.apply_damage(damage_info)

	_object_pool.return_instance.call_deferred(self)


func _on_area_entered(area: Area2D) -> void:
	if process_mode == PROCESS_MODE_DISABLED:
		return

	if area.is_in_group(Identifiers.Groups.ENEMY_PROJECTILE):
		_object_pool.return_instance.call_deferred(area)
	_object_pool.return_instance.call_deferred(self)


func _on_screen_exited() -> void:
	if process_mode == PROCESS_MODE_DISABLED:
		return
	_object_pool.return_instance.call_deferred(self)
