# src/core/util/service_locator.gd
## A central, autoloaded singleton that provides clean, type-safe access
## to all other core systems (services). This avoids passing around messy
## dictionaries for dependency injection.
extends Node

# --- Service References ---
# These are populated by the engine at startup based on the autoload order.
@onready var object_pool: ObjectPool = get_node("/root/ObjectPool")
@onready var fx_manager: FXManager = get_node("/root/FXManager")
@onready var event_bus: EventBus = get_node("/root/EventBus")
@onready var sequencer: Sequencer = get_node("/root/Sequencer")
@onready var combat_utils: CombatUtils = get_node("/root/CombatUtils")