# src/entities/minions/turret.gd
# CORRECTED: Uses Identifiers constants for group checks.
class_name Turret
extends CharacterBody2D

enum State { IDLE, ATTACK }

@onready var visual: Polygon2D = $Visual
@onready var health_component: HealthComponent = $HealthComponent
@onready var state_machine: BaseStateMachine = $StateMachine
@onready var attack_timer: Timer = $AttackTimer
@onready var range_detector_shape: CollisionShape2D = $RangeDetector/CollisionShape2D

var t_data: TurretStateData
var player: CharacterBody2D

var fire_rate: float = 2.0
var detection_radius: float = 400.0

func _ready():
	add_to_group(Identifiers.Groups.ENEMY)
	t_data = TurretStateData.new()
	t_data.config = CombatDB.config
	
	var circle_shape = CircleShape2D.new()
	circle_shape.radius = detection_radius
	range_detector_shape.shape = circle_shape
	
	health_component.setup(self, {
		"data_resource": t_data,
		"config": t_data.config
	})
	
	var states = {
		State.IDLE: load("res://src/entities/minions/states/state_turret_idle.gd").new(self, state_machine, t_data),
		State.ATTACK: load("res://src/entities/minions/states/state_turret_attack.gd").new(self, state_machine, t_data)
	}
	state_machine.setup(self, { "states": states, "initial_state_key": State.IDLE })
	
	health_component.died.connect(die)
	
	player = get_tree().get_first_node_in_group(Identifiers.Groups.PLAYER)
	
	visual.color = Palette.COLOR_TERRAIN_SECONDARY

func _notification(what):
	if what == NOTIFICATION_PREDELETE:
		if is_instance_valid(state_machine): state_machine.teardown()
		if is_instance_valid(health_component): health_component.teardown()
		t_data = null

func die():
	queue_free()

func fire_at_player():
	if not is_instance_valid(player): return
	var shot = ObjectPool.get_instance(Identifiers.Pools.TURRET_SHOTS)
	if not shot: return
	shot.direction = (player.global_position - global_position).normalized()
	shot.global_position = global_position
	shot.activate()

func deactivate():
	if is_instance_valid(state_machine):
		state_machine.teardown()
	if is_instance_valid(attack_timer):
		attack_timer.stop()
	set_physics_process(false)
	$RangeDetector.monitoring = false

func _on_range_detector_body_entered(body):
	if not t_data: return
	if body.is_in_group(Identifiers.Groups.PLAYER):
		t_data.is_player_in_range = true

func _on_range_detector_body_exited(body):
	if not t_data: return
	if body.is_in_group(Identifiers.Groups.PLAYER):
		t_data.is_player_in_range = false
