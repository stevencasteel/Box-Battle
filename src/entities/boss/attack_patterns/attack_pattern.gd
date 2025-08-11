# src/entities/boss/attack_patterns/attack_pattern.gd
#
# A data resource that defines the properties of a single boss attack.
# This allows for designing and tuning attacks directly in the editor.
class_name AttackPattern
extends Resource

# The unique identifier for this attack, used by the state machine to
# determine which logic to execute.
@export var attack_id: StringName = &""

# The duration in seconds that the attack's warning visual is displayed.
@export var telegraph_duration: float = 0.5

# The duration in seconds that the attack is active.
# (More useful for continuous attacks like beams, but good to have).
@export var attack_duration: float = 0.1

# The time in seconds after this attack completes before the boss can
# start the telegraph for a new attack.
@export var cooldown: float = 1.5
