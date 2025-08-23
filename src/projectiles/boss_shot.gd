# res://src/projectiles/boss_shot.gd
class_name BossShot
extends "res://src/projectiles/base_projectile.gd"


func _ready() -> void:
	visual.color = Palette.COLOR_HAZARD_PRIMARY
	add_to_group(Identifiers.Groups.ENEMY_PROJECTILE)


# --- Overridden Signal Handlers ---


func _on_body_entered(_body: Node) -> void:
	if not _is_active:
		return
	# This projectile is destroyed by solid world geometry.
	if is_instance_valid(_services):
		_services.object_pool.return_instance.call_deferred(self)


func _on_area_entered(area: Area2D) -> void:
	if not _is_active:
		return
	# Standard collision for player hurtbox, etc.
	_handle_collision(area)
