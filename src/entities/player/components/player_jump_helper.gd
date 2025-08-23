# src/entities/player/components/player_jump_helper.gd
## A stateless helper class that centralizes all jump-related logic for the Player.
## Its single responsibility is to determine if a jump can occur and what kind of
## jump it is, based on the player's current state.
class_name PlayerJumpHelper
extends RefCounted

# --- Public Methods ---


## Checks all possible jump conditions in a prioritized order and executes one if valid.
## Returns true if a jump was successfully initiated, false otherwise.
static func try_jump(owner: Player, p_data: PlayerStateData) -> bool:
	var physics: PlayerPhysicsComponent = owner.get_component(PlayerPhysicsComponent)
	var sm: BaseStateMachine = owner.get_component(BaseStateMachine)

	if not is_instance_valid(physics) or not is_instance_valid(sm):
		return false

	# 1. Wall Jump (Highest Priority)
	if p_data.wall_coyote_timer > 0:
		physics.perform_wall_jump()
		sm.change_state(Identifiers.PlayerStates.JUMP)
		return true

	# 2. Ground Jump (includes coyote time)
	if p_data.coyote_timer > 0:
		sm.change_state(Identifiers.PlayerStates.JUMP)
		return true

	# 3. Air Jump
	if p_data.air_jumps_left > 0:
		sm.change_state(Identifiers.PlayerStates.JUMP, {"is_air_jump": true})
		return true

	return false


## Checks if the player is attempting to drop through a one-way platform.
## Returns true if the drop was successful, false otherwise.
static func try_platform_drop(owner: Player) -> bool:
	var floor_col = owner.get_last_slide_collision()
	if not floor_col:
		return false

	var floor_collider = floor_col.get_collider()
	if (
		is_instance_valid(floor_collider)
		and floor_collider.is_in_group(Identifiers.Groups.ONEWAY_PLATFORMS)
	):
		owner.position.y += 2 # Nudge the player down to clear the platform
		owner.get_component(BaseStateMachine).change_state(Identifiers.PlayerStates.FALL)
		return true

	return false