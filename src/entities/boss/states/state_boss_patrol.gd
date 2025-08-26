# src/entities/boss/states/state_boss_patrol.gd
## A simple state for moving the boss back and forth between attacks.
extends BaseState
class_name BossStatePatrol

const QuickSwipeData = preload("res://src/data/combat/attacks/boss_quick_swipe.tres")

func enter(_msg := {}) -> void:
	owner.patrol_timer.start()


func process_physics(_delta: float) -> void:
	# High-priority check: if player gets too close, interrupt patrol to attack.
	if state_data.is_player_in_close_range and owner.cooldown_timer.is_stopped():
		state_machine.change_state("melee", {"attack_data": QuickSwipeData})
		return
		
	owner.velocity.x = state_data.facing_direction * state_data.config.boss_patrol_speed
