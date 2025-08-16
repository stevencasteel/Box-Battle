# src/entities/boss/attack_patterns/attack_pattern.gd
@tool
## A data resource that defines the properties of a single boss attack.
##
## This allows for designing and tuning attacks directly in the editor instead
## of hard-coding values in scripts.
class_name AttackPattern
extends Resource

# --- Editor Properties ---
## A unique identifier used by the StateMachine to select attack logic.
@export var attack_id: StringName = &""
## The duration in seconds that the attack's warning visual is displayed.
@export var telegraph_duration: float = 0.5
## The duration in seconds that the attack itself is active.
@export var attack_duration: float = 0.1
## The time in seconds after this attack before the boss can start another.
@export var cooldown: float = 1.5