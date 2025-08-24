# src/entities/minions/data/minion_behavior.gd
@tool
## A data resource that defines a minion's complete combat behavior.
##
## This combines base stats with swappable logic resources for movement and
## attacks, allowing for the creation of varied minion types from a single
## generic Minion scene.
class_name MinionBehavior
extends Resource

@export_group("Stats")
@export_range(1, 100, 1) var max_health: int = 3

@export_group("Movement")
@export var movement_logic: MovementLogic

@export_group("Combat")
# TODO: Implement a swappable AttackLogic system for minions.
@export_range(0.1, 10.0, 0.1) var attack_cooldown: float = 2.0
@export_range(50, 1000, 10) var detection_radius: float = 400.0
@export var projectile_pool_key: StringName = &"turret_shots"
