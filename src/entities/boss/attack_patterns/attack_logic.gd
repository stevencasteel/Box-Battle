# src/entities/boss/attack_patterns/attack_logic.gd
@tool
## The abstract base class for all boss attack execution logic.
## This implements the Strategy Pattern for boss attacks.
class_name AttackLogic
extends Resource

## Returns the visual information for this attack's telegraph.
## The dictionary should contain: { "size": Vector2, "offset": Vector2 }
## "offset" is the local position relative to the boss.
func get_telegraph_info(_owner: BaseBoss, _pattern: AttackPattern) -> Dictionary:
	# Default to a simple square
	return {
		"size": Vector2(150, 150),
		"offset": Vector2(_owner.state_data.facing_direction * 100, 0)
	}

## Executes the attack. The core of the Strategy Pattern.
func execute(_owner: BaseBoss, _pattern: AttackPattern) -> void:
	push_warning("AttackLogic.execute() was called but not overridden.")
