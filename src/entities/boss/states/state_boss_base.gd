# src/entities/boss/states/state_boss_base.gd
# Base class / contract for all Boss states.
# Modeled after src/entities/player/states/state_base.gd
class_name BossState

var boss: CharacterBody2D
var b_data: BossStateData # NEW: Reference to the shared state data

# MODIFIED: The constructor now accepts the state data resource.
func _init(boss_node: CharacterBody2D, boss_data: BossStateData) -> void:
	self.boss = boss_node
	self.b_data = boss_data

# Called when this state becomes active.
func enter(_msg := {}) -> void:
	pass

# Called when this state is being replaced by another state.
func exit() -> void:
	pass

# Main per-physics-frame update for the state.
func process_physics(_delta: float) -> void:
	pass

# Optional input handling for state-specific input semantics.
func process_input(_event: InputEvent) -> void:
	pass
