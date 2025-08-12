# src/entities/minions/turret.gd
# The main context script for the stationary Turret minion.
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

# Configurable properties
var fire_rate: float = 2.0
var detection_radius: float = 400.0

func _ready():
	add_to_group("enemy")
	t_data = TurretStateData.new()
	
	var circle_shape = CircleShape2D.new()
	circle_shape.radius = detection_radius
	range_detector_shape.shape = circle_shape
	
	health_component.setup(self, {
		"data_resource": t_data,
		"config": CombatDB.config
	})
	health_component.died.connect(die)
	
	player = get_tree().get_first_node_in_group("player")
	
	var states = {
		State.IDLE: load("res://src/entities/minions/states/state_turret_idle.gd").new(self, state_machine, t_data),
		State.ATTACK: load("res://src/entities/minions/states/state_turret_attack.gd").new(self, state_machine, t_data)
	}
	state_machine.setup(states, State.IDLE)
	
	visual.color = Palette.COLOR_TERRAIN_SECONDARY

func die():
	queue_free()

func fire_at_player():
	if not is_instance_valid(player): return
	# THE FIX: Request a projectile from the correct, dedicated pool.
	var shot = ObjectPool.get_instance(&"turret_shots")
	if not shot: return
	shot.direction = (player.global_position - global_position).normalized()
	shot.global_position = global_position
	shot.activate()

func _on_range_detector_body_entered(body):
	if body.is_in_group("player"):
		t_data.is_player_in_range = true

func _on_range_detector_body_exited(body):
	if body.is_in_group("player"):
		t_data.is_player_in_range = false