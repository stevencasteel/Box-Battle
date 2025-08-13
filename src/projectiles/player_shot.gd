# src/projectiles/player_shot.gd
# CORRECTED: Uses the correct static function call syntax.
extends Area2D

const CombatUtilsScript = preload(AssetPaths.SCRIPT_COMBAT_UTILS)

@onready var collision_shape: CollisionShape2D = $CollisionShape2D

var direction = Vector2.RIGHT
var speed = 1000.0
var damage = 2

func _ready():
	$ColorRect.color = Palette.COLOR_PLAYER_PROJECTILE

func activate():
	process_mode = PROCESS_MODE_INHERIT
	collision_shape.disabled = false

func deactivate():
	process_mode = PROCESS_MODE_DISABLED
	collision_shape.disabled = true
	global_position = Vector2(-1000, -1000)

func _physics_process(delta):
	global_position += direction * speed * delta

func _on_body_entered(body: Node) -> void:
	var damageable = CombatUtilsScript.find_damageable(body) # CORRECTED CALL
	if is_instance_valid(damageable):
		var damage_info = DamageInfo.new()
		damage_info.amount = damage
		damage_info.source_node = self
		damageable.apply_damage(damage_info)
	
	ObjectPool.return_instance(self)

func _on_area_entered(area: Area2D) -> void:
	if area.is_in_group("enemy_projectile"):
		ObjectPool.return_instance(area)
	ObjectPool.return_instance(self)

func _on_screen_exited():
	ObjectPool.return_instance(self)
