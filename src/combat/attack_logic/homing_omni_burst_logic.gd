# src/combat/attack_logic/homing_omni_burst_logic.gd
@tool
## Concrete AttackLogic for a complex, multi-projectile homing attack.
class_name HomingOmniBurstLogic
extends AttackLogic

@export var projectile_count: int = 30


func get_telegraph_info(_owner: BaseEntity, _pattern: AttackPattern) -> Dictionary:
	return {"size": Vector2(600, 600), "offset": Vector2.ZERO}


func execute(owner: BaseEntity, _pattern: AttackPattern) -> Callable:
	return Callable(self, "_fire_omni_burst").bind(owner)


# --- Private Helper for Execution ---
func _fire_omni_burst(owner: BaseEntity) -> void:
	if not is_instance_valid(owner):
		return

	var object_pool: IObjectPool = owner._services.object_pool
	var angle_step = TAU / projectile_count
	for i in range(projectile_count):
		var shot: HomingBossShot = object_pool.get_instance(Identifiers.Pools.HOMING_BOSS_SHOTS)
		if not is_instance_valid(shot):
			continue

		shot.damage = owner.entity_data.config.homing_shot_damage
		shot.speed = owner.entity_data.config.homing_shot_speed
		shot.lifespan = owner.entity_data.config.homing_shot_lifespan

		var angle = i * angle_step
		shot.rotation = angle
		shot.global_position = owner.global_position
		shot.activate(owner._services)