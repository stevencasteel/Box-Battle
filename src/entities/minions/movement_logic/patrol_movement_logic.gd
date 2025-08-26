# src/entities/minions/movement_logic/patrol_movement_logic.gd
@tool
## A concrete movement strategy where the minion moves back and forth,
## reversing direction when it hits a wall.
class_name PatrolMovementLogic
extends MovementLogic

## Moves the minion horizontally, applying gravity, and reverses on wall collision.
func execute(delta: float, minion: Minion, state_data: MinionStateData) -> Vector2:
	var new_velocity := minion.velocity

	# This logic is now responsible for applying gravity to itself.
	if not minion.is_on_floor():
		new_velocity.y += state_data.services.combat_config.gravity * delta
	
	if minion.is_on_wall():
		state_data.facing_direction *= -1.0

	new_velocity.x = state_data.facing_direction * state_data.services.combat_config.boss_patrol_speed
	return new_velocity