# src/entities/boss/attack_patterns/homing_omni_burst_logic.gd
@tool
## Concrete AttackLogic for a complex, multi-projectile homing attack.
##
## This script serves as a template for future advanced attack patterns.
## The logic here could be expanded to spawn projectiles that actively seek
## the player. For now, it fires a simple, non-homing circular burst.
class_name HomingOmniBurstLogic
extends AttackLogic

## The number of projectiles to spawn in the burst.
@export var projectile_count: int = 10
## The speed of the projectiles.
@export var projectile_speed: float = 350.0

func get_telegraph_info(owner: BaseBoss, _pattern: AttackPattern) -> Dictionary:
	# A large circular telegraph is appropriate for a burst attack.
	return {
		"size": Vector2(600, 600),
		"offset": Vector2.ZERO # Centered on the boss
	}

func execute(owner: BaseBoss, _pattern: AttackPattern) -> void:
	# --- FUTURE IMPLEMENTATION NOTES ---
	# To make these projectiles "homing", we would need a new projectile scene
	# (e.g., 'HomingBossShot.tscn') with a script that includes a 'target'
	# property. In this 'execute' method, we would get the player node, and
	# for each spawned projectile, set its 'target' to the player. The
	# projectile's own '_physics_process' would then handle adjusting its
	# direction towards the target.
	
	if not is_instance_valid(owner): return
	
	var angle_step = TAU / projectile_count
	for i in range(projectile_count):
		var shot = ObjectPool.get_instance(Identifiers.Pools.BOSS_SHOTS)
		if not is_instance_valid(shot): continue
		
		var angle = i * angle_step
		shot.direction = Vector2.RIGHT.rotated(angle)
		shot.speed = projectile_speed # Use the speed from this logic resource
		shot.global_position = owner.global_position
		shot.activate()