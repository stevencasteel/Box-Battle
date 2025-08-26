# src/entities/boss/states/state_boss_melee.gd
## A state that triggers a melee attack and waits for it to complete.
class_name BossStateMelee
extends BaseState

# --- Constants ---
const LungeMeleeAttackData = preload("res://src/data/combat/attacks/boss_lunge_melee.tres")

# --- Private Member Variables ---
var _melee_component: MeleeComponent


func enter(msg := {}) -> void:
	owner.velocity = Vector2.ZERO
	_melee_component = owner.get_component(MeleeComponent)
	
	if not is_instance_valid(_melee_component):
		push_error("BossStateMelee requires a MeleeComponent on the owner. Aborting attack.")
		state_machine.change_state(Identifiers.BossStates.COOLDOWN)
		return
	
	# Default to the lunge follow-up, but allow other states to specify a different attack.
	var attack_to_perform = msg.get("attack_data", LungeMeleeAttackData)
	
	_melee_component.attack_finished.connect(_on_attack_finished, CONNECT_ONE_SHOT)
	_melee_component.perform_attack(attack_to_perform)


func exit() -> void:
	if is_instance_valid(_melee_component) and _melee_component.attack_finished.is_connected(_on_attack_finished):
		_melee_component.attack_finished.disconnect(_on_attack_finished)


# --- Signal Handlers ---
func _on_attack_finished() -> void:
	if state_machine.current_state == self:
		# Use the cooldown from the attack we just performed.
		var attack_data = _melee_component._current_attack_data
		if is_instance_valid(attack_data):
			owner.cooldown_timer.wait_time = attack_data.telegraph_duration + attack_data.duration + 0.5
		
		state_machine.change_state(Identifiers.BossStates.COOLDOWN)
