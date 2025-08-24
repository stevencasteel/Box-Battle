# src/entities/minions/movement_logic/movement_logic.gd
@tool
## The abstract base class for all minion movement strategies.
## Defines the contract for how a minion's velocity is calculated each frame.
class_name MovementLogic
extends Resource

## Calculates and returns the minion's velocity for the current physics frame.
## This is the core method to be implemented by all concrete movement strategies.
## @param delta: The time elapsed since the last physics frame.
## @param minion: A reference to the Minion node executing this logic.
## @param state_data: The shared state data resource for the minion.
## @return: The calculated velocity vector for the current frame.
func execute(_delta: float, _minion: Minion, _state_data: MinionStateData) -> Vector2:
	push_warning("MovementLogic.execute() was called but not overridden by the implementer.")
	return Vector2.ZERO
