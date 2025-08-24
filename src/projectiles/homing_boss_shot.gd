# src/projectiles/homing_boss_shot.gd
class_name HomingBossShot
extends "res://src/projectiles/base_projectile.gd"

# --- Node References ---
@onready var lifetime_timer: Timer = $LifetimeTimer

# --- Exposed config
@export var lifespan: float = 3.0

# --- Private Member Variables ---
var _player_ref: WeakRef
var _active_tween: Tween
var _pending_start_on_screen: bool = false

const FALLBACK_WAIT_SECONDS := 0.05


func _ready() -> void:
	add_to_group(Identifiers.Groups.ENEMY_PROJECTILE)
	visual.color = Palette.COLOR_HAZARD_PRIMARY


func _move(delta: float) -> void:
	if not _player_ref or not _player_ref.get_ref():
		global_position += transform.x * speed * delta
		return

	var player_node: Node = _player_ref.get_ref()
	var direction_to_player: Vector2 = (player_node.global_position - global_position).normalized()
	rotation = lerp_angle(rotation, direction_to_player.angle(), 0.05)
	global_position += transform.x * speed * delta


func activate(p_services: ServiceLocator) -> void:
	super.activate(p_services)

	var player_node: Node = get_tree().get_first_node_in_group(Identifiers.Groups.PLAYER)
	_player_ref = weakref(player_node)

	if is_instance_valid(lifetime_timer):
		lifetime_timer.start(lifespan)

	if is_instance_valid(_active_tween):
		_active_tween.kill()
		_active_tween = null

	visual.scale = Vector2.ONE
	collision_shape.scale = Vector2.ONE

	call_deferred("_maybe_schedule_shrink", lifespan)


func deactivate() -> void:
	if is_instance_valid(_active_tween):
		_active_tween.kill()
		_active_tween = null

	visual.scale = Vector2.ONE
	collision_shape.scale = Vector2.ONE

	_pending_start_on_screen = false
	super.deactivate()


func _maybe_schedule_shrink(p_lifespan: float) -> void:
	if not _is_active:
		return

	await get_tree().process_frame

	if not _is_active:
		return

	if _has_been_on_screen:
		_start_shrink_tween(p_lifespan)
		return

	_pending_start_on_screen = true

	var timer: SceneTreeTimer = get_tree().create_timer(FALLBACK_WAIT_SECONDS)
	await timer.timeout

	if _pending_start_on_screen and _is_active:
		_pending_start_on_screen = false
		_start_shrink_tween(p_lifespan)


func _start_shrink_tween(p_lifespan: float) -> void:
	if not _is_active:
		return

	if is_instance_valid(_active_tween):
		_active_tween.kill()

	_active_tween = create_tween()
	_active_tween.set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_IN_OUT)
	_active_tween.tween_property(visual, "scale", Vector2.ZERO, p_lifespan)
	_active_tween.tween_property(collision_shape, "scale", Vector2.ZERO, p_lifespan)


func _on_lifetime_timer_timeout() -> void:
	if not _is_active:
		return
	if is_instance_valid(_services):
		_services.object_pool.return_instance.call_deferred(self)


func _on_screen_entered() -> void:
	super._on_screen_entered()

	if _pending_start_on_screen:
		_pending_start_on_screen = false
		_start_shrink_tween(lifespan)
