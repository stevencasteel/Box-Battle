# src/projectiles/homing_boss_shot.gd
## A projectile that seeks the player and shrinks over time.
class_name HomingBossShot
extends Area2D

# --- Constants ---
const CombatUtilsScript = preload(AssetPaths.SCRIPT_COMBAT_UTILS)

# --- Editor Properties ---
@export var speed: float = 250.0
@export var damage: int = 1
@export var lifespan: float = 10.0

# --- Node References ---
@onready var collision_shape: CollisionShape2D = %CollisionShape2D
@onready var visual: ColorRect = %ColorRect
@onready var lifetime_timer: Timer = %LifetimeTimer

# --- Private Member Variables ---
var _player_ref: WeakRef
var _active_tween: Tween
var _object_pool: ObjectPool # Dependency

# --- Godot Lifecycle Methods ---

func _ready() -> void:
	add_to_group(Identifiers.Groups.ENEMY_PROJECTILE)
	visual.color = Palette.COLOR_HAZARD_PRIMARY

func _physics_process(delta: float) -> void:
	if not _player_ref or not _player_ref.get_ref():
		global_position += transform.x * speed * delta
		return
	
	var player_node = _player_ref.get_ref()
	var direction_to_player = (player_node.global_position - global_position).normalized()
	
	rotation = lerp_angle(rotation, direction_to_player.angle(), 0.05)
	
	global_position += transform.x * speed * delta

# --- IPoolable Contract ---

func activate(p_dependencies: Dictionary = {}) -> void:
	self._object_pool = p_dependencies.get("object_pool")
	assert(is_instance_valid(_object_pool), "HomingBossShot requires an ObjectPool dependency.")

	visible = true
	process_mode = PROCESS_MODE_INHERIT
	collision_shape.disabled = false
	
	var player_node = get_tree().get_first_node_in_group(Identifiers.Groups.PLAYER)
	_player_ref = weakref(player_node)
	
	lifetime_timer.start(lifespan)
	
	if is_instance_valid(_active_tween):
		_active_tween.kill()
		
	_active_tween = create_tween()
	_active_tween.tween_property(visual, "scale", Vector2.ZERO, lifespan)
	_active_tween.tween_property(collision_shape, "scale", Vector2.ZERO, lifespan)

func deactivate() -> void:
	if is_instance_valid(_active_tween):
		_active_tween.kill()
		_active_tween = null
		
	visible = false
	process_mode = PROCESS_MODE_DISABLED
	collision_shape.disabled = true
	visual.scale = Vector2.ONE
	collision_shape.scale = Vector2.ONE
	_object_pool = null

# --- Signal Handlers ---

func _on_body_entered(_body: Node) -> void:
	if process_mode == PROCESS_MODE_DISABLED: return
	_object_pool.return_instance.call_deferred(self)

func _on_area_entered(area: Area2D) -> void:
	if process_mode == PROCESS_MODE_DISABLED: return
	var damageable = CombatUtilsScript.find_damageable(area)
	if is_instance_valid(damageable):
		var damage_info = DamageInfo.new()
		damage_info.amount = damage
		damage_info.source_node = self
		damage_info.impact_position = global_position
		damage_info.impact_normal = (global_position - area.global_position).normalized()
		damageable.apply_damage(damage_info)
	
	_object_pool.return_instance.call_deferred(self)

func _on_screen_exited() -> void:
	if process_mode == PROCESS_MODE_DISABLED: return
	_object_pool.return_instance.call_deferred(self)

func _on_lifetime_timer_timeout() -> void:
	if process_mode == PROCESS_MODE_DISABLED: return
	_object_pool.return_instance.call_deferred(self)
