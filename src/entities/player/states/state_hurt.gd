# src/entities/player/states/state_hurt.gd
# Handles player knockback and invincibility.
extends PlayerState

func enter():
	p_data.is_charging = false
	player._cancel_heal()
	# CORRECTED: Use the flat config path: "player_knockback_duration"
	p_data.knockback_timer = CombatDB.config.player_knockback_duration

func process_physics(delta):
	# CORRECTED: Use the flat config path: "gravity"
	player.velocity.y += CombatDB.config.gravity * delta
	
	if p_data.knockback_timer <= 0:
		player.change_state(player.State.FALL)