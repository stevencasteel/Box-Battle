# src/combat/attack_logic/projectile_logic.gd
@tool
## Concrete AttackLogic for firing one or more projectiles.
class_name ProjectileLogic
extends AttackLogic


func get_telegraph_info(owner: BaseEntity, _pattern: AttackPattern) -> Dictionary:
	var facing_direction: float = owner.entity_data.facing_direction if "facing_direction" in owner.entity_data else 1.0
	return {"size": Vector2(150, 150), "offset": Vector2(facing_direction * 100, 0)}


func execute(owner: BaseEntity, pattern: AttackPattern) -> Callable:
	if pattern.projectile_count <= 1:
		return owner.fire_shot_at_player.bind()
	else:
		return owner.fire_volley.bind(pattern.projectile_count, pattern.volley_delay)
