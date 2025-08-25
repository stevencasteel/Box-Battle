# src/entities/boss/data/boss_behavior.gd
@tool
## A data resource that defines a boss's complete combat behavior.
##
## This encapsulates phase health thresholds and the specific attack patterns
## used in each phase, allowing for the creation of varied boss types without
## changing the core BaseBoss scene or script.
class_name BossBehavior
extends Resource

@export_group("Phase Configuration")
@export_range(0.0, 1.0, 0.01) var phase_2_threshold: float = 0.7
@export_range(0.0, 1.0, 0.01) var phase_3_threshold: float = 0.4

@export_group("Attack Patterns")
## The StringName key for the ObjectPool where this boss's projectiles are stored.
@export var projectile_pool_key: StringName = &"boss_shots"
@export var phase_1_patterns: Array[AttackPattern] = []
@export var phase_2_patterns: Array[AttackPattern] = []
@export var phase_3_patterns: Array[AttackPattern] = []