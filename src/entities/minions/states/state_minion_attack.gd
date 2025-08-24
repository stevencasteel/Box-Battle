# src/entities/minions/states/state_minion_attack.gd
## The state for when the minion is executing its attack.
class_name MinionStateAttack
extends BaseState

var _minion: Minion


func enter(_msg := {}) -> void:
	self._minion = owner as Minion
	if not is_instance_valid(_minion):
		state_machine.change_state(Identifiers.MinionStates.IDLE)
		return
	
	_minion.velocity = Vector2.ZERO
	_minion._fire_at_player()
	_minion.attack_timer.start(state_data.behavior.attack_cooldown)
	
	# This state is now transient; it immediately returns to Idle.
	# The attack timer's cooldown will prevent it from attacking again right away.
	state_machine.change_state(Identifiers.MinionStates.IDLE)