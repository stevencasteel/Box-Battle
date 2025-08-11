# src/entities/boss/states/state_boss_attack.gd
# This state is now fully data-driven. It reads an AttackPattern resource
# to determine how to telegraph and execute an attack.
extends BaseState
class_name BossStateAttack

const TelegraphScene = preload(AssetPaths.SCENE_TELEGRAPH_COMPONENT)

var current_pattern: AttackPattern
# This variable will hold a correctly-typed reference to the boss.
var boss: BaseBoss

func enter(msg := {}):
	# THE FIX: Cast the generic `owner` to the specific `BaseBoss` type.
	self.boss = owner as BaseBoss
	if not boss:
		push_error("BossStateAttack: Owner is not a BaseBoss. Aborting.")
		state_machine.change_state(owner.State.COOLDOWN)
		return

	if not msg.has("pattern"):
		push_error("BossStateAttack: No 'pattern' provided in enter message. Aborting attack.")
		state_machine.change_state(boss.State.COOLDOWN)
		return
	
	current_pattern = msg.get("pattern")
	_start_telegraph()

func _start_telegraph() -> void:
	var telegraph = TelegraphScene.instantiate()
	boss.add_child(telegraph)
	
	var telegraph_duration = current_pattern.telegraph_duration
	var telegraph_position = boss.global_position + Vector2(state_data.facing_direction * 100, 0)
	var telegraph_size = Vector2(150, 150)
	var telegraph_color = Palette.COLOR_HAZARD_PRIMARY
	
	telegraph.start_telegraph(telegraph_duration, telegraph_size, telegraph_position, telegraph_color)
	await telegraph.telegraph_finished
	
	_execute_attack()

func _execute_attack():
	match current_pattern.attack_id:
		&"single_shot":
			boss.fire_shot_at_player()
		&"volley_shot":
			match boss.phases_remaining:
				3: # Phase 1
					boss.fire_volley(1)
				2: # Phase 2
					boss.fire_volley(3)
				1: # Phase 3
					boss.fire_volley(5)

	boss.cooldown_timer.wait_time = current_pattern.cooldown
	state_machine.change_state(boss.State.COOLDOWN)
