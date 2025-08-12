# src/entities/boss/states/state_boss_lunge.gd
# This state executes a high-speed, armored lunge attack.
extends BaseState
class_name BossStateLunge

var boss: BaseBoss
var lunge_duration: float
const LUNGE_SPEED = 1200.0

func enter(msg := {}):
	self.boss = owner as BaseBoss
	if not boss: return

	# Get the duration from the AttackPattern resource.
	var pattern = msg.get("pattern")
	if pattern:
		lunge_duration = pattern.attack_duration
	else:
		lunge_duration = 0.5 # Default fallback
	
	# Activate armor and set velocity for the lunge.
	boss.armor_component.activate()
	boss.velocity = Vector2(state_data.facing_direction * LUNGE_SPEED, 0)

func process_physics(delta: float):
	lunge_duration -= delta
	if lunge_duration <= 0:
		# Lunge is over. Deactivate armor and transition to cooldown.
		boss.armor_component.deactivate()
		state_machine.change_state(boss.State.COOLDOWN)
