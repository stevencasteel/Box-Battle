# src/combat/attack_logic/attack_logic.gd
@tool
## The abstract base class for all boss attack execution logic.
## This implements the Strategy Pattern for boss attacks.
class_name AttackLogic
extends Resource


## Returns the visual information for this attack's telegraph.
## The dictionary should contain: { "size": Vector2, "offset": Vector2 }
## "offset" is the local position relative to the boss.
func get_telegraph_info(_owner: BaseEntity, _pattern: AttackPattern) -> Dictionary:
	# Default to a simple square
	var facing_direction: float = _owner.entity_data.get("facing_direction", 1.0)
	return {
		"size": Vector2(150, 150), "offset": Vector2(facing_direction * 100, 0)
	}


## Prepares and returns the attack action as a Callable.
## This is the core of the Command Pattern implementation.
func execute(_owner: BaseEntity, _pattern: AttackPattern) -> Callable:
	push_warning("AttackLogic.execute() was called but not overridden.")
	return Callable()  # Return an empty, safe callable