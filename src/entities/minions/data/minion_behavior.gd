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
@export_range(50, 1000, 10) var detection_radius: float = 400.0
# THE FIX: Add the projectile pool key back. This defines WHAT projectile the
# minion fires, while the AttackPattern defines HOW it's fired.
@export var projectile_pool_key: StringName = &"turret_shots"
@export var attack_patterns: Array[AttackPattern] = []