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
		state_machine.change_state(Identifiers.BossStates.COOLDOWN)
		return

	if not msg.has("pattern") or not msg.pattern is AttackPattern:
		push_error("BossStateAttack: No valid 'pattern' provided. Aborting.")
		state_machine.change_state(Identifiers.BossStates.COOLDOWN)
		return

	_current_pattern = msg.get("pattern")
	_start_telegraph_and_attack()


# --- Private Methods ---


func _start_telegraph_and_attack() -> void:
	if not is_instance_valid(_current_pattern.logic):
		push_warning("AttackPattern is missing its 'logic' resource.")
		state_machine.change_state(Identifiers.BossStates.COOLDOWN)
		return

	var telegraph = TelegraphScene.instantiate()
	_boss.add_child(telegraph)

	var telegraph_info = _current_pattern.logic.get_telegraph_info(_boss, _current_pattern)
	var telegraph_size = telegraph_info.get("size", Vector2.ONE * 100)
	var relative_offset = telegraph_info.get("offset", Vector2.ZERO)

	var directional_offset = Vector2(
		relative_offset.x * _boss.entity_data.facing_direction, relative_offset.y
	)
	var telegraph_position = _boss.global_position + directional_offset

	telegraph.start_telegraph(
		_current_pattern.telegraph_duration,
		telegraph_size,
		telegraph_position,
		Palette.COLOR_UI_PANEL_BG
	)
	await telegraph.telegraph_finished

	# Use a robust check to ensure the owner wasn't freed during the await.
	if not is_instance_valid(_boss):
		return

	var attack_command: Callable = _current_pattern.logic.execute(_boss, _current_pattern)
	if attack_command.is_valid():
		attack_command.call()

	if state_machine.current_state == self:
		_boss.cooldown_timer.wait_time = _current_pattern.cooldown
		state_machine.change_state(Identifiers.BossStates.COOLDOWN)
