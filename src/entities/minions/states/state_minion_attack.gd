# src/entities/minions/states/state_minion_attack.gd
## A generic state that handles the telegraph and execution of a minion's attack.
class_name MinionStateAttack
extends BaseState

# --- Constants ---
const TelegraphScene = preload(AssetPaths.SCENE_TELEGRAPH_COMPONENT)

# --- Private Member Variables ---
var _minion: Minion
var _current_pattern: AttackPattern


func enter(msg := {}) -> void:
	self._minion = owner as Minion
	if not is_instance_valid(_minion):
		state_machine.change_state(Identifiers.MinionStates.IDLE)
		return

	if not msg.has("pattern") or not msg.pattern is AttackPattern:
		push_error("MinionStateAttack: No valid 'pattern' provided. Aborting.")
		state_machine.change_state(Identifiers.MinionStates.IDLE)
		return

	_current_pattern = msg.get("pattern")
	_start_telegraph_and_attack()


func _start_telegraph_and_attack() -> void:
	if not is_instance_valid(_current_pattern.logic):
		push_warning("Minion's AttackPattern is missing its 'logic' resource.")
		state_machine.change_state(Identifiers.MinionStates.IDLE)
		return

	var telegraph := TelegraphScene.instantiate()
	_minion.add_child(telegraph)

	var telegraph_info: Dictionary = _current_pattern.logic.get_telegraph_info(_minion, _current_pattern)
	var telegraph_size: Vector2 = telegraph_info.get("size", Vector2.ONE * 100)
	var relative_offset: Vector2 = telegraph_info.get("offset", Vector2.ZERO)

	var directional_offset := Vector2(
		relative_offset.x * _minion.entity_data.facing_direction, relative_offset.y
	)
	var telegraph_position: Vector2 = _minion.global_position + directional_offset

	telegraph.start_telegraph(
		_current_pattern.telegraph_duration,
		telegraph_size,
		telegraph_position,
		Palette.COLOR_HAZARD_PRIMARY
	)
	await telegraph.telegraph_finished

	if not is_instance_valid(_minion):
		return

	var attack_command: Callable = _current_pattern.logic.execute(_minion, _current_pattern)
	if attack_command.is_valid():
		attack_command.call()

	if state_machine.current_state == self:
		_minion.attack_timer.wait_time = _current_pattern.cooldown
		_minion.attack_timer.start()
		state_machine.change_state(Identifiers.MinionStates.IDLE)