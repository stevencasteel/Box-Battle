# src/entities/boss/states/state_boss_attack.gd
# This state executes an attack and immediately transitions to Cooldown.
extends "res://src/entities/boss/states/state_boss_base.gd"
class_name BossStateAttack

func enter(_msg := {}) -> void:
	var attack_keys = boss.AttackPattern.keys()
	var chosen_attack_name = attack_keys[randi() % attack_keys.size()]
	boss.current_attack = boss.AttackPattern[chosen_attack_name]
	print("Boss chose attack: ", chosen_attack_name)
	
	match boss.current_attack:
		boss.AttackPattern.SINGLE_SHOT:
			boss.fire_shot_at_player()
		boss.AttackPattern.VOLLEY_SHOT:
			var tween = boss.get_tree().create_tween()
			tween.tween_callback(boss.fire_shot_at_player)
			tween.tween_interval(0.2)
			tween.tween_callback(boss.fire_shot_at_player)
			tween.tween_interval(0.2)
			tween.tween_callback(boss.fire_shot_at_player)
			
	boss.change_state(boss.State.COOLDOWN)

func process_physics(_delta: float) -> void:
	# This state is instantaneous, so it does nothing in the physics process.
	pass
