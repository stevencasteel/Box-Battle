# res://src/projectiles/turret_shot.gd
class_name TurretShot
extends "res://src/projectiles/base_projectile.gd"


func _ready() -> void:
	add_to_group(Identifiers.Groups.ENEMY_PROJECTILE)
	visual.color = Palette.COLOR_UI_ACCENT_PRIMARY
