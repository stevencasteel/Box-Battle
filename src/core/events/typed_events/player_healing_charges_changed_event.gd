# src/core/events/player_healing_charges_changed_event.gd
# A typed payload for the PLAYER_HEALING_CHARGES_CHANGED event.
extends Resource
class_name PlayerHealingChargesChangedEvent

@export var current_charges: int = 0