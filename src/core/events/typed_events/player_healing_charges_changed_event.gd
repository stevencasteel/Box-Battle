# src/core/events/typed_events/player_healing_charges_changed_event.gd
## A typed payload for the [constant EventCatalog.PLAYER_HEALING_CHARGES_CHANGED] event.
class_name PlayerHealingChargesChangedEvent
extends Resource

@export var current_charges: int = 0