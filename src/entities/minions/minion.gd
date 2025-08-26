# src/entities/minions/minion.gd
@tool
## A generic minion enemy, whose behavior is defined by a MinionBehavior resource.
class_name Minion
extends BaseEntity

# --- Editor Configuration ---
@export_group("Core Configuration")
@export var behavior: MinionBehavior
@export_group("Juice & Feedback")
@export var hit_flash_effect: ShaderEffect
@export var hit_spark_effect: VFXEffect
@export var dissolve_effect: ShaderEffect

# --- Node References ---
@onready var visual: Polygon2D = $Visual
@onready var attack_timer: Timer = $AttackTimer
@onready var range_detector_shape: CollisionShape2D = $RangeDetector/CollisionShape2D

# --- Public Member Variables ---
var entity_data: MinionStateData

# --- Godot Lifecycle Methods ---
func _get_configuration_warnings() -> PackedStringArray:
	var warnings := PackedStringArray()
	if not archetype:
		warnings.append("This node requires an EntityArchetype resource.")
	if not behavior:
		warnings.append("This node requires a MinionBehavior resource to function.")
	return warnings


func _ready() -> void:
	super._ready()
	if Engine.is_editor_hint():
		return

	_initialize_data()
	EntityBuilder.build(self)


func _physics_process(delta: float) -> void:
	if _is_dead or not is_instance_valid(entity_data):
		return
	
	if not is_on_floor():
		velocity.y += entity_data.services.combat_config.gravity * delta
		
	move_and_slide()

	if entity_data.behavior.is_anchored:
		velocity = Vector2.ZERO


func _notification(what: int) -> void:
	if what == NOTIFICATION_PREDELETE:
		teardown()


# --- Public Methods ---
func teardown() -> void:
	var hc: HealthComponent = get_component(HealthComponent)
	if is_instance_valid(hc):
		if hc.died.is_connected(_on_health_component_died):
			hc.died.disconnect(_on_health_component_died)

	super.teardown()
	entity_data = null


## A public method for states to request the minion updates its facing direction.
func update_player_tracking() -> void:
	_update_player_tracking()


func deactivate() -> void:
	var sm: BaseStateMachine = get_component(BaseStateMachine)
	if is_instance_valid(sm):
		sm.teardown()
	if is_instance_valid(attack_timer):
		attack_timer.stop()

	set_physics_process(false)
	$RangeDetector.monitoring = false


# --- Private Methods ---
func _die() -> void:
	if _is_dead:
		return
	_is_dead = true

	collision_layer = 0
	collision_mask = 0
	deactivate()

	if is_instance_valid(_active_attack_tween):
		_active_attack_tween.kill()

	var fc: FXComponent = get_component(FXComponent)
	var death_tween: Tween = fc.play_effect(dissolve_effect)
	if is_instance_valid(death_tween):
		await death_tween.finished

	if is_instance_valid(self):
		queue_free()


func _initialize_data() -> void:
	add_to_group(Identifiers.Groups.ENEMY)
	visual.color = Palette.COLOR_TERRAIN_SECONDARY
	entity_data = MinionStateData.new()
	assert(is_instance_valid(_services), "Minion requires a ServiceLocator.")

	assert(is_instance_valid(behavior), "Minion requires a valid MinionBehavior resource.")
	entity_data.behavior = behavior
	entity_data.max_health = behavior.max_health
	entity_data.projectile_pool_key = behavior.projectile_pool_key
	entity_data.services = _services


func _update_player_tracking() -> void:
	if not is_instance_valid(_player):
		return

	var dir_to_player: float = _player.global_position.x - global_position.x
	if not is_zero_approx(dir_to_player):
		entity_data.facing_direction = sign(dir_to_player)


# --- Signal Handlers ---
func _on_range_detector_body_entered(body: Node) -> void:
	if is_instance_valid(entity_data) and body is Player:
		entity_data.is_player_in_range = true


func _on_range_detector_body_exited(body: Node) -> void:
	if is_instance_valid(entity_data) and body is Player:
		entity_data.is_player_in_range = false


func _on_melee_range_detector_body_entered(body: Node) -> void:
	if is_instance_valid(entity_data) and body is Player:
		entity_data.is_player_in_melee_range = true


func _on_melee_range_detector_body_exited(body: Node) -> void:
	if is_instance_valid(entity_data) and body is Player:
		entity_data.is_player_in_melee_range = false


func _on_health_component_died() -> void:
	_die()
