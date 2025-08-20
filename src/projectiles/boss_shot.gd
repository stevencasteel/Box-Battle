# src/projectiles/boss_shot.gd
## A projectile fired by the boss. Implements the [IPoolable] interface.
class_name BossShot
extends Area2D

# --- Constants ---
const CombatUtilsScript = preload(AssetPaths.SCRIPT_COMBAT_UTILS)

# --- Node References ---
@onready var collision_shape: CollisionShape2D = $CollisionShape2D

# --- Member Variables ---
var direction: Vector2 = Vector2.LEFT
var speed: float = 400.0
var damage: int = 1

# --- Godot Lifecycle Methods ---

func _ready() -> void:
	$ColorRect.color = Palette.COLOR_HAZARD_PRIMARY
	add_to_group(Identifiers.Groups.ENEMY_PROJECTILE)

func _physics_process(delta: float) -> void:
	global_position += direction * speed * delta

# --- Public Methods (IPoolable Contract) ---

## Activates the projectile, making it visible and interactive.
func activate() -> void:
	visible = true
	process_mode = PROCESS_MODE_INHERIT
	collision_shape.disabled = false

## Deactivates the projectile, preparing it to be returned to the ObjectPool.
func deactivate() -> void:
	visible = false
	process_mode = PROCESS_MODE_DISABLED
	collision_shape.disabled = true

# --- Signal Handlers ---

func _on_body_entered(_body: Node) -> void:
	# This handles collision with the solid world.
	ObjectPool.return_instance.call_deferred(self)

func _on_area_entered(area: Area2D) -> void:
	# This handles collision with the Player's Hurtbox.
	var damageable = CombatUtilsScript.find_damageable(area)
	if is_instance_valid(damageable):
		var damage_info = DamageInfo.new()
		damage_info.amount = damage
		damage_info.source_node = self
		damage_info.impact_position = global_position
		damage_info.impact_normal = -direction
		damageable.apply_damage(damage_info)

	ObjectPool.return_instance.call_deferred(self)

func _on_screen_exited() -> void:
	ObjectPool.return_instance.call_deferred(self)