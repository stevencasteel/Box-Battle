# src/core/events/typed_events/boss_health_changed_event.gd
## A typed payload for the [constant EventCatalog.BOSS_HEALTH_CHANGED] event.
class_name BossHealthChangedEvent
extends Resource

@export var current_health: int = 0
@export var max_health: int = 0