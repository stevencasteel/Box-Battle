# src/core/events/boss_health_changed_event.gd
# A typed payload for the BOSS_HEALTH_CHANGED event.
extends Resource
class_name BossHealthChangedEvent

@export var current_health: int = 0
@export var max_health: int = 0