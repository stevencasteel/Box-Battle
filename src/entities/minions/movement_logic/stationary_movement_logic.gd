# src/entities/minions/movement_logic/stationary_movement_logic.gd
@tool
## A concrete movement strategy where the minion does not move at all.
class_name StationaryMovementLogic
extends MovementLogic


## Returns zero velocity, effectively keeping the minion stationary.
func execute(_delta: float, _minion: Minion, _state_data: MinionStateData) -> Vector2:
	return Vector2.ZERO
