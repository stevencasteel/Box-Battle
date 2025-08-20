# src/entities/boss/attack_patterns/homing_omni_burst_logic.gd
@tool
## Concrete AttackLogic for a complex, multi-projectile homing attack.
class_name HomingOmniBurstLogic
extends AttackLogic

@export var projectile_count: int = 10
@export var projectile_speed: float = 350.0

func get_telegraph_info(owner: BaseBoss, _pattern: AttackPattern) -> Dictionary:
	return { "size": Vector2(600, 600), "offset": Vector2.ZERO }

func execute(owner: BaseBoss, _pattern: AttackPattern) -> Callable:
	return Callable(self, "_fire_omni_burst").bind(owner)

# --- Private Helper for Execution ---
func _fire_omni_burst(owner: BaseBoss) -> void:
	if not is_instance_valid(owner): return
	
	var angle_step = TAU / projectile_count
	for i in range(projectile_count):
		var shot = ObjectPool.get_instance(Identifiers.Pools.BOSS_SHOTS)
		if not is_instance_valid(shot): continue
		
		var angle = i * angle_step
		shot.direction = Vector2.RIGHT.rotated(angle)
		shot.speed = projectile_speed
		shot.global_position = owner.global_position
		shot.activate()


	# --- FUTURE IMPLEMENTATION NOTES ---
	# To make these projectiles "homing", we would need a new projectile scene
	# (e.g., 'HomingBossShot.tscn') with a script that includes a 'target'
	# property. In this 'execute' method, we would get the player node, and
	# for each spawned projectile, set its 'target' to the player. The
	# projectile's own '_physics_process' would then handle adjusting its
	# direction towards the target.
