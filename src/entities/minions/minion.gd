# src/entities/minions/minion.gd
@tool
## A generic minion enemy, whose behavior is defined by a MinionBehavior resource.
class_name Minion
extends BaseEntity

# --- Constants ---
const HIT_FLASH_EFFECT = preload("res://src/data/effects/entity_hit_flash_effect.tres")

# --- Editor Configuration ---
@export_group("Core Configuration")
@export var behavior: MinionBehavior
@export_group("Juice & Feedback")
@export var hit_spark_effect: VFXEffect
@export var dissolve_effect: ShaderEffect

# --- Node References ---
@onready var visual: Polygon2D = $Visual
@onready var attack_timer: Timer = $AttackTimer
@onready var range_detector_shape: CollisionShape2D = $RangeDetector/CollisionShape2D

# --- Public Member Variables ---
var entity_data: MinionStateData

# --- Private Member Variables ---
var _player: CharacterBody2D
var _is_dead: bool = false

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
	_initialize_and_setup_components()
	_connect_signals()

	_player = get_tree().get_first_node_in_group(Identifiers.Groups.PLAYER)


func _physics_process(_delta: float) -> void:
	if not _is_dead:
		move_and_slide()


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


func deactivate() -> void:
	var sm: BaseStateMachine = get_component(BaseStateMachine)
	if is_instance_valid(sm):
		sm.teardown()
	if is_instance_valid(attack_timer):
		attack_timer.stop()

	set_physics_process(false)
	$RangeDetector.monitoring = false


# --- Private Methods ---


func _fire_at_player() -> void:
	if not is_instance_valid(_player):
		return

	var pool_key: StringName = entity_data.behavior.projectile_pool_key
	var shot: Node = _services.object_pool.get_instance(pool_key)
	if not is_instance_valid(shot):
		push_error("Minion failed to get projectile from pool: '%s'" % pool_key)
		return

	# Look towards player before firing
	var dir_to_player: float = _player.global_position.x - global_position.x
	if not is_zero_approx(dir_to_player):
		entity_data.facing_direction = sign(dir_to_player)

	shot.direction = (self._player.global_position - self.global_position).normalized()
	shot.global_position = self.global_position
	shot.activate(_services)


func _die() -> void:
	if _is_dead:
		return
	_is_dead = true

	collision_layer = 0
	collision_mask = 0
	deactivate()

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
	# THE FIX: Provide the services to the shared state data.
	entity_data.services = _services


func _initialize_and_setup_components() -> void:
	var circle_shape := CircleShape2D.new()
	circle_shape.radius = entity_data.behavior.detection_radius
	range_detector_shape.shape = circle_shape

	var hc: HealthComponent = get_component(HealthComponent)
	var sm: BaseStateMachine = get_component(BaseStateMachine)
	var fc: FXComponent = get_component(FXComponent)

	var shared_deps := {
		"data_resource": entity_data,
		"config": _services.combat_config
	}

	var states: Dictionary = {
		Identifiers.MinionStates.IDLE:
		load("res://src/entities/minions/states/state_minion_idle.gd").new(self, sm, entity_data),
		Identifiers.MinionStates.ATTACK:
		load("res://src/entities/minions/states/state_minion_attack.gd").new(self, sm, entity_data)
	}

	var per_component_deps := {
		sm: {"states": states, "initial_state_key": Identifiers.MinionStates.IDLE},
		fc: {"visual_node": visual, "hit_effect": HIT_FLASH_EFFECT},
		hc: {"hit_spark_effect": hit_spark_effect}
	}

	setup_components(shared_deps, per_component_deps)


func _connect_signals() -> void:
	var hc: HealthComponent = get_component(HealthComponent)
	hc.died.connect(_on_health_component_died)


# --- Signal Handlers ---


func _on_range_detector_body_entered(body: Node) -> void:
	if not entity_data:
		return
	if body.is_in_group(Identifiers.Groups.PLAYER):
		entity_data.is_player_in_range = true


func _on_range_detector_body_exited(body: Node) -> void:
	if not entity_data:
		return
	if body.is_in_group(Identifiers.Groups.PLAYER):
		entity_data.is_player_in_range = false


func _on_health_component_died() -> void:
	_die()
