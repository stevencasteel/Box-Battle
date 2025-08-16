# src/projectiles/turret_shot.gd
## A projectile fired by the Turret minion. Implements the [IPoolable] interface.
class_name TurretShot
extends Area2D

# --- Constants ---
const CombatUtilsScript = preload(AssetPaths.SCRIPT_COMBAT_UTILS)

# --- Node References ---
@onready var collision_shape: CollisionShape2D = $CollisionShape2D

# --- Member Variables ---
var direction: Vector2 = Vector2.LEFT
var speed: float = 500.0
var damage: int = 1

# --- Godot Lifecycle Methods ---

func _ready() -> void:
	add_to_group(Identifiers.Groups.ENEMY_PROJECTILE)
	$ColorRect.color = Palette.COLOR_UI_ACCENT_PRIMARY

func _physics_process(delta: float) -> void:
	global_position += direction * speed * delta

# --- Public Methods (IPoolable Contract) ---

## Activates the projectile, making it visible and interactive.
func activate() -> void:
	process_mode = PROCESS_MODE_INHERIT
	collision_shape.disabled = false

## Deactivates the projectile, preparing it to be returned to the ObjectPool.
func deactivate() -> void:
	process_mode = PROCESS_MODE_DISABLED
	collision_shape.disabled = true
	global_position = Vector2(-1000, -1000) # Move to the graveyard

# --- Signal Handlers ---

func _on_body_entered(body: Node) -> void:
	var damageable = CombatUtilsScript.find_damageable(body)
	if is_instance_valid(damageable):
		var damage_info = DamageInfo.new()
		damage_info.amount = damage
		damage_info.source_node = self
		damageable.apply_damage(damage_info)

	ObjectPool.return_instance(self)

func _on_screen_exited() -> void:
	ObjectPool.return_instance(self)