# src/entities/boss/attack_patterns/homing_omni_burst_logic.gd
@tool
## Concrete AttackLogic for a complex, multi-projectile homing attack.
class_name HomingOmniBurstLogic
extends AttackLogic

@export var projectile_count: int = 30


func get_telegraph_info(_owner: BaseBoss, _pattern: AttackPattern) -> Dictionary:
	return {"size": Vector2(600, 600), "offset": Vector2.ZERO}


func execute(owner: BaseBoss, _pattern: AttackPattern) -> Callable:
	return Callable(self, "_fire_omni_burst").bind(owner)


# --- Private Helper for Execution ---
func _fire_omni_burst(owner: BaseBoss) -> void:
	if not is_instance_valid(owner):
		return

	print("Executing Homing Omni Burst!")

	var object_pool: ObjectPool = owner._services.object_pool
	var angle_step = TAU / projectile_count
	for i in range(projectile_count):
		var shot: HomingBossShot = object_pool.get_instance(Identifiers.Pools.HOMING_BOSS_SHOTS)
		if not is_instance_valid(shot):
			continue

		# Configure the projectile from the central config
		shot.damage = owner.entity_data.config.homing_shot_damage
		shot.speed = owner.entity_data.config.homing_shot_speed
		shot.lifespan = owner.entity_data.config.homing_shot_lifespan

		var angle = i * angle_step
		shot.rotation = angle
		shot.global_position = owner.global_position
		# THE FIX: Pass the ServiceLocator from the owner entity.
		shot.activate(owner._services)
