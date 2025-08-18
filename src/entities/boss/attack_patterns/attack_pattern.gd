# src/entities/boss/attack_patterns/attack_pattern.gd
@tool
## A data resource that defines the properties of a single boss attack.
##
## This combines timing data with a swappable "AttackLogic" resource that
## contains the actual execution code for the attack (Strategy Pattern).
class_name AttackPattern
extends Resource

# --- Editor Properties ---
@export var logic: AttackLogic ## The script that defines HOW this attack behaves.
@export var telegraph_duration: float = 0.5
@export var attack_duration: float = 0.1
@export var cooldown: float = 1.5

@export_group("Attack-Specific Data")
# --- ProjectileLogic Data ---
@export var projectile_count: int = 1
@export var volley_delay: float = 0.2