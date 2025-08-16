# src/entities/boss/states/state_boss_attack.gd
## Handles the telegraph and execution of the boss's attacks.
class_name BossStateAttack
extends BaseState

# --- Constants ---
const TelegraphScene = preload(AssetPaths.SCENE_TELEGRAPH_COMPONENT)

# --- Private Member Variables ---
var _current_pattern: AttackPattern
var _boss: BaseBoss

# --- State Lifecycle ---

func enter(msg := {}) -> void:
	self._boss = owner as BaseBoss
	if not _boss:
		push_error("BossStateAttack: Owner is not a BaseBoss. Aborting.")
		state_machine.change_state(_boss.State.COOLDOWN)
		return

	if not msg.has("pattern"):
		push_error("BossStateAttack: No 'pattern' provided. Aborting.")
		state_machine.change_state(_boss.State.COOLDOWN)
		return

	_current_pattern = msg.get("pattern")
	_start_telegraph()

# --- Private Methods ---

func _start_telegraph() -> void:
	var telegraph = TelegraphScene.instantiate()
	_boss.add_child(telegraph)

	var telegraph_duration: float = _current_pattern.telegraph_duration
	var telegraph_position: Vector2
	var telegraph_size: Vector2
	var telegraph_color: Color = Palette.COLOR_HAZARD_PRIMARY

	match _current_pattern.attack_id:
		&"lunge":
			var lunge_width = 800
			telegraph_size = Vector2(lunge_width, 60) # A thin rectangle
			var x_offset = (lunge_width / 2.0) + (_boss.get_node("CollisionShape2D").shape.size.x / 2.0)
			telegraph_position = _boss.global_position + Vector2(state_data.facing_direction * x_offset, 0)
		_: # Default case for projectile attacks
			telegraph_size = Vector2(150, 150)
			telegraph_position = _boss.global_position + Vector2(state_data.facing_direction * 100, 0)

	telegraph.start_telegraph(telegraph_duration, telegraph_size, telegraph_position, telegraph_color)
	await telegraph.telegraph_finished

	_execute_attack()

func _execute_attack() -> void:
	if _current_pattern.attack_id == &"lunge":
		state_machine.change_state(_boss.State.LUNGE, {"pattern": _current_pattern})
		return

	match _current_pattern.attack_id:
		&"single_shot":
			_boss.fire_shot_at_player()
		&"volley_shot":
			match _boss.phases_remaining:
				3: _boss.fire_volley(1)
				2: _boss.fire_volley(3)
				1: _boss.fire_volley(5)

	_boss.cooldown_timer.wait_time = _current_pattern.cooldown
	state_machine.change_state(_boss.State.COOLDOWN)
