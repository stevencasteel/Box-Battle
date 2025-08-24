# src/core/util/service_locator.gd
## A central, autoloaded singleton that provides clean, type-safe access
## to all other core systems (services). This avoids passing around messy
## dictionaries for dependency injection.
extends Node

# --- Constants ---
const COMBAT_CONFIG = preload("res://src/data/combat_config.tres")

# --- Service References ---
var fx_manager: IFXManager
@onready var object_pool: ObjectPool = get_node("/root/ObjectPool")
@onready var event_bus: EventBus = get_node("/root/EventBus")
@onready var sequencer: Sequencer = get_node("/root/Sequencer")
@onready var combat_utils: CombatUtils = get_node("/root/CombatUtils")
@onready var grid_utils: GridUtils = get_node("/root/GridUtils")

# --- Public Properties ---
var combat_config: CombatConfig = COMBAT_CONFIG


func _ready() -> void:
	# Instantiate and register the adapter for the FXManager.
	# Components will now depend on the IFXManager interface, not the global singleton.
	fx_manager = FXManagerAdapter.new()
	add_child(fx_manager)
