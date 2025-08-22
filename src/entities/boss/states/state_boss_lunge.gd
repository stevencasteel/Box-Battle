# src/entities/boss/states/state_boss_lunge.gd
## Executes a high-speed, invulnerable dash attack across the arena.
extends BaseState
class_name BossStateLunge

# --- Private Member Variables ---
var _boss: BaseBoss
var _lunge_duration: float
var _invincibility_token: int

# --- State Lifecycle ---


func enter(msg := {}) -> void:
	self._boss = owner as BaseBoss
	if not _boss:
		return

	var pattern: AttackPattern = msg.get("pattern")
	_lunge_duration = pattern.attack_duration if pattern else 0.5

	_invincibility_token = _boss.health_component.grant_invincibility(self)
	_boss.velocity = Vector2(state_data.facing_direction * state_data.config.boss_lunge_speed, 0)


func exit() -> void:
	if is_instance_valid(_boss) and is_instance_valid(_boss.health_component):
		_boss.health_component.release_invincibility(_invincibility_token)


func process_physics(delta: float) -> void:
	_lunge_duration -= delta
	if _lunge_duration <= 0:
		state_machine.change_state(_boss.State.COOLDOWN)
