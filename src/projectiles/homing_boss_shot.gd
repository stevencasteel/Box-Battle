# src/projectiles/homing_boss_shot.gd
## A projectile that seeks the player and shrinks over time.
class_name HomingBossShot
extends Area2D

# --- Constants ---
const LIFESPAN_SECONDS = 10.0
const CombatUtilsScript = preload(AssetPaths.SCRIPT_COMBAT_UTILS)

# --- Editor Properties ---
@export var speed: float = 250.0
@export var damage: int = 1

# --- Node References ---
@onready var collision_shape: CollisionShape2D = $CollisionShape2D
@onready var visual: ColorRect = $ColorRect
@onready var lifetime_timer: Timer = $LifetimeTimer

# --- Private Member Variables ---
var _player_ref: WeakRef
var _active_tween: Tween # THE FIX: Add a member variable to hold the tween.

# --- Godot Lifecycle Methods ---

func _ready() -> void:
	add_to_group(Identifiers.Groups.ENEMY_PROJECTILE)
	visual.color = Palette.COLOR_HAZARD_PRIMARY

func _physics_process(delta: float) -> void:
	if not _player_ref or not _player_ref.get_ref():
		# If the player is gone, just continue in a straight line.
		global_position += transform.x * speed * delta
		return
	
	var player_node = _player_ref.get_ref()
	var direction_to_player = (player_node.global_position - global_position).normalized()
	
	# Simple rotation towards the player
	rotation = lerp_angle(rotation, direction_to_player.angle(), 0.05)
	
	global_position += transform.x * speed * delta

# --- IPoolable Contract ---

func activate() -> void:
	visible = true
	process_mode = PROCESS_MODE_INHERIT
	collision_shape.disabled = false
	
	var player_node = get_tree().get_first_node_in_group(Identifiers.Groups.PLAYER)
	_player_ref = weakref(player_node)
	
	lifetime_timer.start(LIFESPAN_SECONDS)
	
	# THE FIX: Kill any previous tween before creating a new one.
	if is_instance_valid(_active_tween):
		_active_tween.kill()
		
	_active_tween = create_tween()
	_active_tween.tween_property(visual, "scale", Vector2.ZERO, LIFESPAN_SECONDS)
	_active_tween.tween_property(collision_shape, "scale", Vector2.ZERO, LIFESPAN_SECONDS)

func deactivate() -> void:
	# THE FIX: Kill the tween immediately upon deactivation.
	if is_instance_valid(_active_tween):
		_active_tween.kill()
		_active_tween = null
		
	visible = false
	process_mode = PROCESS_MODE_DISABLED
	collision_shape.disabled = true
	# THE FIX: Reset scale for the next use. This is now guaranteed to stick.
	visual.scale = Vector2.ONE
	collision_shape.scale = Vector2.ONE

# --- Signal Handlers ---

func _on_body_entered(_body: Node) -> void:
	ObjectPool.return_instance.call_deferred(self)

func _on_area_entered(area: Area2D) -> void:
	var damageable = CombatUtilsScript.find_damageable(area)
	if is_instance_valid(damageable):
		var damage_info = DamageInfo.new()
		damage_info.amount = damage
		damage_info.source_node = self
		damage_info.impact_position = global_position
		damage_info.impact_normal = (global_position - area.global_position).normalized()
		damageable.apply_damage(damage_info)
	
	ObjectPool.return_instance.call_deferred(self)

func _on_screen_exited() -> void:
	ObjectPool.return_instance.call_deferred(self)

func _on_lifetime_timer_timeout() -> void:
	ObjectPool.return_instance.call_deferred(self)