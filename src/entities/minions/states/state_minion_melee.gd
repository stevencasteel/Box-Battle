# src/entities/minions/states/state_minion_melee.gd
## A state that triggers a minion's melee attack.
class_name MinionStateMelee
extends BaseState

# --- Constants ---
const LancerPokeData = preload("res://src/data/combat/attacks/lancer_poke.tres")

# --- Private Member Variables ---
var _melee_component: MeleeComponent
var _minion: Minion


func enter(_msg := {}) -> void:
	self._minion = owner as Minion
	_minion.velocity = Vector2.ZERO
	_melee_component = _minion.get_component(MeleeComponent)
	
	if not is_instance_valid(_melee_component):
		push_error("MinionStateMelee requires a MeleeComponent on the owner. Aborting.")
		state_machine.change_state(Identifiers.MinionStates.IDLE)
		return
	
	_melee_component.attack_finished.connect(_on_attack_finished, CONNECT_ONE_SHOT)
	_melee_component.perform_attack(LancerPokeData)


func exit() -> void:
	if is_instance_valid(_melee_component) and _melee_component.attack_finished.is_connected(_on_attack_finished):
		_melee_component.attack_finished.disconnect(_on_attack_finished)


func process_physics(_delta: float) -> void:
	# If the player leaves the melee zone during the attack, immediately go back to patrolling.
	if not state_data.is_player_in_melee_range:
		state_machine.change_state("patrol")
		return


# --- Signal Handlers ---
func _on_attack_finished() -> void:
	if state_machine.current_state == self:
		var attack_data = _melee_component._current_attack_data
		if is_instance_valid(attack_data) and is_instance_valid(_minion.attack_timer):
			_minion.attack_timer.wait_time = 2.0 
			_minion.attack_timer.start()
		
		# Go directly back to patrolling, which is the default active state.
		state_machine.change_state("patrol")