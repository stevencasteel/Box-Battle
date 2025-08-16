# src/core/events/typed_events/player_health_changed_event.gd
## A typed payload for the [constant EventCatalog.PLAYER_HEALTH_CHANGED] event.
class_name PlayerHealthChangedEvent
extends Resource

@export var current_health: int = 0
@export var max_health: int = 0