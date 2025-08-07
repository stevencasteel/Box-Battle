# src/entities/player/states/state_hurt.gd
# Handles player knockback and invincibility.
extends PlayerState

func enter():
	player.is_charging = false
	player._cancel_heal()
	player.knockback_timer = Constants.KNOCKBACK_DURATION

func process_physics(delta):
	player.velocity.y += Constants.GRAVITY * delta
	
	if player.knockback_timer <= 0:
		player.change_state(player.State.FALL)