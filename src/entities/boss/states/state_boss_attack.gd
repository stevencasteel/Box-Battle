# src/entities/boss/states/state_boss_attack.gd
# This state is now fully data-driven. It reads an AttackPattern resource
# to determine how to telegraph and execute an attack.
extends BaseState
class_name BossStateAttack

const TelegraphScene = preload(AssetPaths.SCENE_TELEGRAPH_COMPONENT)

# The AttackPattern is now passed into the state via the enter message.
var current_pattern: AttackPattern

func enter(msg := {}):
	if not msg.has("pattern"):
		push_error("BossStateAttack: No 'pattern' provided in enter message. Aborting attack.")
		state_machine.change_state(owner.State.COOLDOWN)
		return
	
	current_pattern = msg.get("pattern")
	
	# Start the telegraph process.
	_start_telegraph()

# This is an async function because it must wait for the telegraph to finish.
func _start_telegraph() -> void:
	# Create an instance of our reusable telegraph component.
	var telegraph = TelegraphScene.instantiate()
	owner.add_child(telegraph)
	
	# Configure the telegraph using data from the AttackPattern resource.
	var telegraph_duration = current_pattern.telegraph_duration
	var telegraph_position = owner.global_position + Vector2(state_data.facing_direction * 100, 0)
	var telegraph_size = Vector2(150, 150)
	var telegraph_color = Palette.COLOR_HAZARD_PRIMARY
	
	# Wait for the telegraph's "finished" signal before proceeding.
	# CORRECTED: Explicitly name the 'duration' parameter.
	telegraph.start_telegraph(telegraph_duration, telegraph_size, telegraph_position, telegraph_color)
	await telegraph.telegraph_finished
	
	# Once the telegraph is done, execute the actual attack.
	_execute_attack()

func _execute_attack():
	# Use the attack_id from the pattern to choose the correct logic.
	match current_pattern.attack_id:
		&"single_shot":
			owner.fire_shot_at_player()
		&"volley_shot":
			var tween = owner.get_tree().create_tween()
			tween.tween_callback(owner.fire_shot_at_player)
			tween.tween_interval(0.2)
			tween.tween_callback(owner.fire_shot_at_player)
			tween.tween_interval(0.2)
			tween.tween_callback(owner.fire_shot_at_player)
	
	# Set the cooldown timer using the value from the pattern.
	owner.cooldown_timer.wait_time = current_pattern.cooldown
	state_machine.change_state(owner.State.COOLDOWN)
