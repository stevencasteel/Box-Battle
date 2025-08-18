# src/entities/minions/turret.gd
@tool
## A stationary enemy that detects and fires projectiles at the player.
##
## This minion uses the standard entity architecture, including a HealthComponent
## and a simple two-state StateMachine (Idle, Attack).
class_name Turret
extends CharacterBody2D

# --- Enums ---
enum State { IDLE, ATTACK }

# --- Editor Configuration ---
@export var fire_rate: float = 2.0
@export var detection_radius: float = 400.0
@export var hit_spark_effect: VFXEffect

# --- Node References ---
@onready var visual: Polygon2D = $Visual
@onready var health_component: HealthComponent = $HealthComponent
@onready var state_machine: BaseStateMachine = $StateMachine
@onready var attack_timer: Timer = $AttackTimer
@onready var range_detector_shape: CollisionShape2D = $RangeDetector/CollisionShape2D

# --- Public Member Variables ---
var entity_data: TurretStateData

# --- Private Member Variables ---
var _player: CharacterBody2D

# --- Godot Lifecycle Methods ---

func _ready() -> void:
	if Engine.is_editor_hint(): return

	_initialize_data()
	_initialize_components()
	_initialize_state_machine()
	_connect_signals()

	_player = get_tree().get_first_node_in_group(Identifiers.Groups.PLAYER)

func _notification(what: int) -> void:
	if what == NOTIFICATION_PREDELETE:
		if is_instance_valid(state_machine): state_machine.teardown()
		if is_instance_valid(health_component): health_component.teardown()
		entity_data = null

# --- Public Methods ---

## Fires a single projectile towards the player.
func fire_at_player() -> void:
	if not is_instance_valid(_player): return

	var shot = ObjectPool.get_instance(Identifiers.Pools.TURRET_SHOTS)
	if not is_instance_valid(shot): return

	shot.direction = (self._player.global_position - self.global_position).normalized()
	shot.global_position = self.global_position
	shot.activate()

## Deactivates the turret, stopping its AI and attacks. Called by GameManager.
func deactivate() -> void:
	if is_instance_valid(state_machine):
		state_machine.teardown()
	if is_instance_valid(attack_timer):
		attack_timer.stop()

	set_physics_process(false)
	$RangeDetector.monitoring = false

## Handles the turret's death.
func die() -> void:
	queue_free()

# --- Private Methods ---

func _initialize_data() -> void:
	add_to_group(Identifiers.Groups.ENEMY)
	visual.color = Palette.COLOR_TERRAIN_SECONDARY
	entity_data = TurretStateData.new()
	entity_data.config = CombatDB.config

func _initialize_components() -> void:
	var circle_shape = CircleShape2D.new()
	circle_shape.radius = detection_radius
	range_detector_shape.shape = circle_shape

	health_component.setup(self, {
		"data_resource": entity_data,
		"config": entity_data.config
	})

func _initialize_state_machine() -> void:
	var states = {
		State.IDLE: load("res://src/entities/minions/states/state_turret_idle.gd").new(self, state_machine, entity_data),
		State.ATTACK: load("res://src/entities/minions/states/state_turret_attack.gd").new(self, state_machine, entity_data)
	}
	state_machine.setup(self, { "states": states, "initial_state_key": State.IDLE })

func _connect_signals() -> void:
	health_component.died.connect(die)
	health_component.took_damage.connect(_on_health_component_took_damage)

# --- Signal Handlers ---

func _on_range_detector_body_entered(body: Node) -> void:
	if not entity_data: return
	if body.is_in_group(Identifiers.Groups.PLAYER):
		entity_data.is_player_in_range = true

func _on_range_detector_body_exited(body: Node) -> void:
	if not entity_data: return
	if body.is_in_group(Identifiers.Groups.PLAYER):
		entity_data.is_player_in_range = false
		
func _on_health_component_took_damage(damage_info: DamageInfo, _damage_result: DamageResult) -> void:
	if is_instance_valid(hit_spark_effect):
		FXManager.play_vfx(hit_spark_effect, damage_info.impact_position, damage_info.impact_normal)
