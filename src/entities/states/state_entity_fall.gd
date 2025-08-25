# src/entities/states/state_entity_fall.gd
## A generic, shared state for any BaseEntity that is airborne and affected by gravity.
class_name StateEntityFall
extends BaseState

var _entity: BaseEntity


func enter(_msg := {}) -> void:
	self._entity = owner as BaseEntity


func process_physics(delta: float) -> void:
	if not is_instance_valid(_entity):
		return

	# Apply gravity
	var gravity: float = _entity._services.combat_config.gravity
	_entity.velocity.y += gravity * delta
	
	# Apply horizontal friction/drag
	_entity.velocity.x = move_toward(_entity.velocity.x, 0, 100 * delta)

	# Check for landing
	if _entity.is_on_floor():
		var idle_state_key = Identifiers.MinionStates.IDLE
		if _entity is BaseBoss:
			idle_state_key = Identifiers.BossStates.IDLE
		
		state_machine.change_state(idle_state_key)
