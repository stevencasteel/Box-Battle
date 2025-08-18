# src/entities/boss/attack_patterns/projectile_logic.gd
@tool
## Concrete AttackLogic for firing one or more projectiles.
class_name ProjectileLogic
extends AttackLogic

func get_telegraph_info(_owner: BaseBoss, _pattern: AttackPattern) -> Dictionary:
	return {
		"size": Vector2(150, 150),
		"offset": Vector2(100, 0)
	}

func execute(owner: BaseBoss, pattern: AttackPattern) -> void:
	if pattern.projectile_count <= 1:
		owner.fire_shot_at_player()
	else:
		owner.fire_volley(pattern.projectile_count, pattern.volley_delay)
