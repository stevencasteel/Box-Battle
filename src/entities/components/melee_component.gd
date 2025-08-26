# src/entities/components/melee_component.gd
@tool
## A generic, data-driven component for executing melee attacks.
##
## This component manages a hitbox Area2D and orchestrates the telegraph,
## attack duration, and damage application based on a provided MeleeAttackData resource.
class_name MeleeComponent
extends IComponent

# --- Signals ---
## Emitted when the attack successfully hits a valid target.
signal hit_confirmed
## Emitted when the full attack sequence (telegraph + duration) is complete.
signal attack_finished

# --- Constants ---
const TelegraphScene = preload(AssetPaths.SCENE_TELEGRAPH_COMPONENT)

# --- Node References ---
@onready var hitbox: Area2D = $Hitbox
@onready var collision_shape: CollisionShape2D = $Hitbox/CollisionShape2D

# --- Private Member Variables ---
var _owner: BaseEntity
var _services: ServiceLocator
var _current_attack_data: MeleeAttackData
var _hit_targets_this_swing: Dictionary = {}
var _is_attacking: bool = false

# --- IComponent Contract ---
func setup(p_owner: Node, p_dependencies: Dictionary = {}) -> void:
	self._owner = p_owner as BaseEntity
	self._services = p_dependencies.get("services")
	assert(is_instance_valid(_owner), "MeleeComponent must be owned by a BaseEntity.")
	assert(is_instance_valid(_services), "MeleeComponent requires a ServiceLocator.")
	
	hitbox.body_entered.connect(_on_hitbox_body_entered)
	hitbox.area_entered.connect(_on_hitbox_area_entered)


func teardown() -> void:
	if is_instance_valid(hitbox):
		if hitbox.body_entered.is_connected(_on_hitbox_body_entered):
			hitbox.body_entered.disconnect(_on_hitbox_body_entered)
		if hitbox.area_entered.is_connected(_on_hitbox_area_entered):
			hitbox.area_entered.disconnect(_on_hitbox_area_entered)
	_owner = null
	_services = null


# --- Public API ---
## The main entry point to start a melee attack sequence.
func perform_attack(attack_data: MeleeAttackData) -> void:
	if _is_attacking or not is_instance_valid(attack_data):
		return

	_is_attacking = true
	_current_attack_data = attack_data
	_hit_targets_this_swing.clear()
	
	_execute_attack_sequence()


# --- Private Logic ---
func _execute_attack_sequence() -> void:
	var facing_direction = _owner.entity_data.facing_direction if "facing_direction" in _owner.entity_data else 1.0
	
	# --- 1. Telegraph Phase ---
	if _current_attack_data.telegraph_duration > 0.0:
		var telegraph := TelegraphScene.instantiate()
		_owner.add_child(telegraph)
		
		var telegraph_size = _current_attack_data.shape.get_rect().size
		var telegraph_offset = _current_attack_data.offset
		var telegraph_position = _owner.global_position + (telegraph_offset * Vector2(facing_direction, 1.0))
		
		telegraph.start_telegraph(
			_current_attack_data.telegraph_duration,
			telegraph_size,
			telegraph_position,
			Palette.COLOR_UI_PANEL_BG
		)
		await telegraph.telegraph_finished
		
		if not is_instance_valid(self):
			return

	# --- 2. Attack Phase ---
	collision_shape.shape = _current_attack_data.shape
	hitbox.position = _current_attack_data.offset * Vector2(facing_direction, 1.0)
	
	hitbox.monitoring = true
	# Use the new dedicated hitbox layer.
	hitbox.collision_layer = PhysicsLayers.HITBOX
	
	if _owner.is_in_group(Identifiers.Groups.PLAYER):
		hitbox.collision_mask = PhysicsLayers.ENEMY | PhysicsLayers.ENEMY_PROJECTILE
	else:
		hitbox.collision_mask = PhysicsLayers.PLAYER_HURTBOX
	
	collision_shape.disabled = false
	
	var timer = get_tree().create_timer(_current_attack_data.duration)
	await timer.timeout
	
	if not is_instance_valid(self):
		return
		
	# --- 3. Cleanup ---
	collision_shape.disabled = true
	hitbox.monitoring = false
	hitbox.collision_layer = 0
	hitbox.collision_mask = 0
	
	_is_attacking = false
	attack_finished.emit()


func _process_hit(collider: Node) -> void:
	var target_id = collider.get_instance_id()
	if _hit_targets_this_swing.has(target_id):
		return

	_hit_targets_this_swing[target_id] = true
	
	var damageable: IDamageable = _services.combat_utils.find_damageable(collider)
	if is_instance_valid(damageable):
		var damage_info := DamageInfo.new()
		damage_info.amount = _current_attack_data.damage_amount
		damage_info.source_node = _owner
		damage_info.impact_position = collider.global_position
		damage_info.impact_normal = (collider.global_position - _owner.global_position).normalized()
		
		var result := damageable.apply_damage(damage_info)
		if result.was_damaged:
			if is_instance_valid(_current_attack_data.hit_spark_effect):
				_services.fx_manager.play_vfx(
					_current_attack_data.hit_spark_effect,
					damage_info.impact_position,
					damage_info.impact_normal
				)
			
			if _current_attack_data.hit_stop_duration > 0.0:
				_services.fx_manager.request_hit_stop(_current_attack_data.hit_stop_duration)
			
			hit_confirmed.emit()


# --- Signal Handlers ---
func _on_hitbox_body_entered(body: Node) -> void:
	_process_hit(body)


func _on_hitbox_area_entered(area: Area2D) -> void:
	_process_hit(area)
