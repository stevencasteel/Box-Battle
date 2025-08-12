# src/entities/boss/states/state_boss_attack.gd
# This state now displays a different telegraph shape for the lunge attack
# to clearly communicate the boss's intent to the player.
extends BaseState
class_name BossStateAttack

const TelegraphScene = preload(AssetPaths.SCENE_TELEGRAPH_COMPONENT)

var current_pattern: AttackPattern
var boss: BaseBoss

func enter(msg := {}):
	self.boss = owner as BaseBoss
	if not boss:
		push_error("BossStateAttack: Owner is not a BaseBoss. Aborting.")
		state_machine.change_state(owner.State.COOLDOWN)
		return

	if not msg.has("pattern"):
		push_error("BossStateAttack: No 'pattern' provided. Aborting.")
		state_machine.change_state(boss.State.COOLDOWN)
		return
	
	current_pattern = msg.get("pattern")
	
	_start_telegraph()

func _start_telegraph() -> void:
	var telegraph = TelegraphScene.instantiate()
	boss.add_child(telegraph)
	
	var telegraph_duration = current_pattern.telegraph_duration
	var telegraph_position: Vector2
	var telegraph_size: Vector2
	var telegraph_color = Palette.COLOR_HAZARD_PRIMARY

	# MODIFIED: Choose telegraph shape based on the attack ID.
	match current_pattern.attack_id:
		&"lunge":
			# For a lunge, show a long, thin rectangle covering the lunge path.
			var lunge_width = 800
			telegraph_size = Vector2(lunge_width, 60) # A thin rectangle
			# Position it in front of the boss, centered vertically.
			var x_offset = (lunge_width / 2.0) + (boss.get_node("CollisionShape2D").shape.size.x / 2.0)
			telegraph_position = boss.global_position + Vector2(state_data.facing_direction * x_offset, 0)
		_: # Default case for projectile attacks
			# For projectiles, show a square where the attack will originate.
			telegraph_size = Vector2(150, 150)
			telegraph_position = boss.global_position + Vector2(state_data.facing_direction * 100, 0)

	telegraph.start_telegraph(telegraph_duration, telegraph_size, telegraph_position, telegraph_color)
	await telegraph.telegraph_finished
	
	_execute_attack()

func _execute_attack():
	# If the attack was a lunge, the state change is handled here.
	if current_pattern.attack_id == &"lunge":
		state_machine.change_state(boss.State.LUNGE, {"pattern": current_pattern})
		return

	# Otherwise, execute the projectile attack.
	match current_pattern.attack_id:
		&"single_shot":
			boss.fire_shot_at_player()
		&"volley_shot":
			match boss.phases_remaining:
				3: boss.fire_volley(1)
				2: boss.fire_volley(3)
				1: boss.fire_volley(5)

	boss.cooldown_timer.wait_time = current_pattern.cooldown
	state_machine.change_state(boss.State.COOLDOWN)
