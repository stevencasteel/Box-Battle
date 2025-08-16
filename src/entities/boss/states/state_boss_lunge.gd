# src/entities/boss/states/state_boss_lunge.gd
## Executes a high-speed, invulnerable dash attack across the arena.
extends BaseState
class_name BossStateLunge

# --- Constants ---
const LUNGE_SPEED = 1200.0

# --- Private Member Variables ---
var _boss: BaseBoss
var _lunge_duration: float

# --- State Lifecycle ---

func enter(msg := {}) -> void:
	self._boss = owner as BaseBoss
	if not _boss: return

	var pattern: AttackPattern = msg.get("pattern")
	if pattern:
		_lunge_duration = pattern.attack_duration
	else:
		_lunge_duration = 0.5 # Default fallback

	_boss.armor_component.activate()
	_boss.velocity = Vector2(state_data.facing_direction * LUNGE_SPEED, 0)

func process_physics(delta: float) -> void:
	_lunge_duration -= delta
	if _lunge_duration <= 0:
		_boss.armor_component.deactivate()
		state_machine.change_state(_boss.State.COOLDOWN)
