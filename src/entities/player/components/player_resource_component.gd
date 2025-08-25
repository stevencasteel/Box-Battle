# src/entities/player/components/player_resource_component.gd
@tool
## Manages the player's resource economy (Determination and Healing).
class_name PlayerResourceComponent
extends IComponent

# --- Member Variables ---
var owner_node: BaseEntity
var p_data: PlayerStateData
var _event_bus: EventBus

# --- Public Methods ---
func setup(p_owner: Node, p_dependencies: Dictionary = {}) -> void:
	self.owner_node = p_owner as BaseEntity
	self.p_data = p_dependencies.get("data_resource")
	
	self._event_bus = p_dependencies.get("event_bus")
	assert(is_instance_valid(_event_bus), "PlayerResourceComponent requires an EventBus.")


func teardown() -> void:
	owner_node = null
	p_data = null
	_event_bus = null


## Called when the player successfully deals damage to an enemy.
func on_damage_dealt() -> void:
	if p_data.healing_charges >= p_data.config.player_max_healing_charges:
		return

	p_data.determination_counter += 1
	if p_data.determination_counter >= p_data.config.player_determination_per_charge:
		p_data.determination_counter = 0
		p_data.healing_charges += 1
		_emit_healing_charges_changed_event()


## Consumes one healing charge.
func consume_healing_charge() -> void:
	if p_data.healing_charges > 0:
		p_data.healing_charges -= 1
		_emit_healing_charges_changed_event()


# --- Private Methods ---
func _emit_healing_charges_changed_event() -> void:
	var ev = PlayerHealingChargesChangedEvent.new()
	ev.current_charges = p_data.healing_charges
	_event_bus.emit(EventCatalog.PLAYER_HEALING_CHARGES_CHANGED, ev)
