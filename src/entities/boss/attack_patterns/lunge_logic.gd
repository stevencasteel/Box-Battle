# src/entities/boss/attack_patterns/lunge_logic.gd
@tool
## Concrete AttackLogic for executing a high-speed, invulnerable dash.
class_name LungeLogic
extends AttackLogic


func get_telegraph_info(owner: BaseBoss, _pattern: AttackPattern) -> Dictionary:
	var lunge_width = 800.0
	var owner_width = owner.get_node("CollisionShape2D").shape.size.x
	var x_offset = (lunge_width / 2.0) + (owner_width / 2.0)

	return {"size": Vector2(lunge_width, 60), "offset": Vector2(x_offset, 0)}


func execute(owner: BaseBoss, pattern: AttackPattern) -> Callable:
	var lunge_params = {"pattern": pattern}
	return owner.state_machine.change_state.bind(owner.State.LUNGE, lunge_params)
