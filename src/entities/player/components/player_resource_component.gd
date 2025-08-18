# src/entities/player/components/player_resource_component.gd
@tool
## Manages the player's resource economy (Determination and Healing).
class_name PlayerResourceComponent
extends IComponent

# --- Member Variables ---
var owner_node: Player
var p_data: PlayerStateData

# --- Public Methods ---

func setup(p_owner: Node, p_dependencies: Dictionary = {}) -> void:
	self.owner_node = p_owner as Player
	self.p_data = p_dependencies.get("data_resource")

func teardown() -> void:
	owner_node = null
	p_data = null

func on_damage_dealt() -> void:
	if p_data.healing_charges >= p_data.config.player_max_healing_charges: return

	p_data.determination_counter += 1
	if p_data.determination_counter >= p_data.config.player_determination_per_charge:
		p_data.determination_counter = 0
		p_data.healing_charges += 1
		_emit_healing_charges_changed_event()

# --- Private Methods ---

func _emit_healing_charges_changed_event() -> void:
	var ev = PlayerHealingChargesChangedEvent.new()
	ev.current_charges = p_data.healing_charges
	EventBus.emit(EventCatalog.PLAYER_HEALING_CHARGES_CHANGED, ev)