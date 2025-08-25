# src/combat/attack_logic/lunge_logic.gd
@tool
## Concrete AttackLogic for executing a high-speed, invulnerable dash.
class_name LungeLogic
extends AttackLogic


func get_telegraph_info(_owner: BaseEntity, _pattern: AttackPattern) -> Dictionary:
	var lunge_width = 800.0
	var owner_width = 60.0
	var x_offset = (lunge_width / 2.0) + (owner_width / 2.0)
	
	# THE FIX: Reduced height from 60 to 50.
	return {"size": Vector2(lunge_width, 50), "offset": Vector2(x_offset, 0)}


func execute(owner: BaseEntity, pattern: AttackPattern) -> Callable:
	var boss_owner := owner as BaseBoss
	if not is_instance_valid(boss_owner):
		push_warning("LungeLogic can only be executed by a BaseBoss.")
		return Callable()

	var lunge_params = {"pattern": pattern}
	var sm: BaseStateMachine = boss_owner.get_component(BaseStateMachine)
	return sm.change_state.bind(Identifiers.BossStates.LUNGE, lunge_params)
