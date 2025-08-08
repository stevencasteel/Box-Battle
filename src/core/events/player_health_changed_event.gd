# src/core/events/player_health_changed_event.gd
# A typed payload for the PLAYER_HEALTH_CHANGED event. Using a Resource allows
# for type safety and IDE autocompletion in listener scripts.
extends Resource
class_name PlayerHealthChangedEvent

@export var current_health: int = 0
@export var max_health: int = 0