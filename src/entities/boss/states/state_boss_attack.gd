# src/entities/boss/states/state_boss_attack.gd
# This state executes an attack and immediately transitions to Cooldown.
extends BaseState
class_name BossStateAttack

func enter(_msg := {}):
	var attack_keys = owner.AttackPattern.keys()
	var chosen_attack_name = attack_keys[randi() % attack_keys.size()]
	
	state_data.current_attack = owner.AttackPattern[chosen_attack_name]
	
	match state_data.current_attack:
		owner.AttackPattern.SINGLE_SHOT:
			owner.fire_shot_at_player()
		owner.AttackPattern.VOLLEY_SHOT:
			var tween = owner.get_tree().create_tween()
			tween.tween_callback(owner.fire_shot_at_player)
			tween.tween_interval(0.2)
			tween.tween_callback(owner.fire_shot_at_player)
			tween.tween_interval(0.2)
			tween.tween_callback(owner.fire_shot_at_player)
			
	state_machine.change_state(owner.State.COOLDOWN)

func process_physics(_delta: float):
	# This state is instantaneous, so it does nothing in the physics process.
	pass
