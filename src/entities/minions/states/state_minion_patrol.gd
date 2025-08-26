# src/entities/minions/states/state_minion_patrol.gd
## The state where a minion actively moves according to its movement logic.
class_name MinionStatePatrol
extends BaseState

var _minion: Minion


func enter(_msg := {}) -> void:
	self._minion = owner as Minion


func process_physics(delta: float) -> void:
	if not is_instance_valid(_minion):
		return

	# --- Priority 1: Melee Interrupt ---
	# If player gets too close, this action takes precedence over everything.
	if state_data.is_player_in_melee_range:
		_minion.velocity = Vector2.ZERO
		_minion.attack_timer.stop() 
		state_machine.change_state("melee")
		return

	# --- Priority 2: Ranged Attack (while continuing to patrol) ---
	if (
		state_data.is_player_in_range
		and _minion.attack_timer.is_stopped()
		and not state_data.behavior.attack_patterns.is_empty()
	):
		_minion.update_player_tracking()
		var pattern: AttackPattern = state_data.behavior.attack_patterns.pick_random()
		_minion.attack_timer.wait_time = pattern.cooldown
		_minion.attack_timer.start()
		
		if is_instance_valid(pattern.logic):
			var attack_command: Callable = pattern.logic.execute(_minion, pattern)
			if attack_command.is_valid():
				attack_command.call()

	# --- Default Action: Always Execute Movement ---
	if is_instance_valid(state_data.behavior.movement_logic):
		var new_velocity: Vector2 = state_data.behavior.movement_logic.execute(
			delta, _minion, state_data
		)
		_minion.velocity = new_velocity
