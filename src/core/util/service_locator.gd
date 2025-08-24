# src/core/util/service_locator.gd
## A central, autoloaded singleton that provides clean, type-safe access
## to all other core systems (services). This avoids passing around messy
## dictionaries for dependency injection.
extends Node

# --- Constants ---
const COMBAT_CONFIG = preload("res://src/data/combat_config.tres")

# --- Service References ---
@onready var fx_manager: IFXManager = get_node("/root/FXManagerAdapter")
@onready var object_pool: IObjectPool = get_node("/root/ObjectPoolAdapter")
@onready var event_bus: EventBus = get_node("/root/EventBus")
@onready var sequencer: Sequencer = get_node("/root/Sequencer")
@onready var combat_utils: CombatUtils = get_node("/root/CombatUtils")
@onready var grid_utils: GridUtils = get_node("/root/GridUtils")

# --- Public Properties ---
var combat_config: CombatConfig = COMBAT_CONFIG
