# src/entities/player/player.gd
@tool
class_name Player
extends BaseEntity

# --- Signals ---
signal health_changed(current_health, max_health)
signal died

# --- Enums ---
enum State {MOVE, JUMP, FALL, DASH, WALL_SLIDE, ATTACK, HURT, HEAL}

# --- Constants ---
const ACTION_ALLOWED_STATES = [State.MOVE, State.FALL, State.JUMP, State.WALL_SLIDE]
const CLOSE_RANGE_THRESHOLD = 75.0
const CombatUtilsScript = preload(AssetPaths.SCRIPT_COMBAT_UTILS)

# --- Editor Properties ---
@export var damage_shake_effect: ScreenShakeEffect
@export var hit_spark_effect: VFXEffect
@export var hit_flash_effect: ShaderEffect

# --- Node References ---
@onready var visual_sprite: ColorRect = $ColorRect
@onready var hurtbox: Area2D = $Hurtbox
@onready var healing_timer: Timer = $HealingTimer
@onready var melee_hitbox: Area2D = $MeleeHitbox
@onready var pogo_hitbox: Area2D = $PogoHitbox

# --- Data ---
var entity_data: PlayerStateData

# --- Godot Lifecycle Methods ---

func _ready() -> void:
	super._ready()
	if Engine.is_editor_hint(): return

	add_to_group(Identifiers.Groups.PLAYER)
	_initialize_and_setup_components()
	_connect_signals()

	visual_sprite.color = Palette.COLOR_PLAYER
	resource_component.on_damage_dealt()
	entity_data.determination_counter = 0

func _physics_process(delta: float) -> void:
	_update_timers(delta)

# --- Public Methods ---

func teardown() -> void:
	if is_instance_valid(health_component):
		if health_component.health_changed.is_connected(_on_health_component_health_changed):
			health_component.health_changed.disconnect(_on_health_component_health_changed)
		if health_component.died.is_connected(_on_health_component_died):
			health_component.died.disconnect(_on_health_component_died)
		if health_component.took_damage.is_connected(_on_health_component_took_damage):
			health_component.took_damage.disconnect(_on_health_component_took_damage)
	if is_instance_valid(combat_component):
		if combat_component.damage_dealt.is_connected(resource_component.on_damage_dealt):
			combat_component.damage_dealt.disconnect(resource_component.on_damage_dealt)
		if combat_component.pogo_bounce_requested.is_connected(_on_pogo_bounce_requested):
			combat_component.pogo_bounce_requested.disconnect(_on_pogo_bounce_requested)
	
	super.teardown()
	entity_data = null

func enable_melee_hitbox(is_enabled: bool, is_up_attack: bool = false) -> void:
	var shape_node: CollisionShape2D = melee_hitbox.get_node("CollisionShape2D")
	if is_enabled:
		if is_up_attack:
			shape_node.shape = preload("res://src/entities/player/data/upward_attack_shape.tres")
			shape_node.position = Vector2(0, -40)
		else:
			shape_node.shape = preload("res://src/entities/player/data/forward_attack_shape.tres")
			shape_node.position = Vector2(entity_data.facing_direction * 60, 0)
	shape_node.disabled = not is_enabled

func enable_pogo_hitbox(is_enabled: bool) -> void:
	var shape_node: CollisionShape2D = pogo_hitbox.get_node("CollisionShape2D")
	shape_node.position = Vector2(0, 40)
	shape_node.disabled = not is_enabled

# --- Private Methods ---

func _initialize_and_setup_components() -> void:
	entity_data = PlayerStateData.new()
	entity_data.config = CombatDB.config
	
	var shared_deps := {
		"data_resource": entity_data,
		"config": entity_data.config,
		"health_component": health_component,
	}
	
	var states = {
		State.MOVE: load("res://src/entities/player/states/state_move.gd").new(self, state_machine, entity_data),
		State.FALL: load("res://src/entities/player/states/state_fall.gd").new(self, state_machine, entity_data),
		State.JUMP: load("res://src/entities/player/states/state_jump.gd").new(self, state_machine, entity_data),
		State.DASH: load("res://src/entities/player/states/state_dash.gd").new(self, state_machine, entity_data),
		State.WALL_SLIDE: load("res://src/entities/player/states/state_wall_slide.gd").new(self, state_machine, entity_data),
		State.ATTACK: load("res://src/entities/player/states/state_attack.gd").new(self, state_machine, entity_data),
		State.HURT: load("res://src/entities/player/states/state_hurt.gd").new(self, state_machine, entity_data),
		State.HEAL: load("res://src/entities/player/states/state_heal.gd").new(self, state_machine, entity_data),
	}
	
	var per_component_deps := {
		state_machine: {"states": states, "initial_state_key": State.FALL},
		input_component: {"state_machine": state_machine},
		ability_component: {"state_machine": state_machine, "input_component": input_component},
		fx_component: {"visual_node": visual_sprite, "hit_flash_effect": hit_flash_effect}
	}
	
	setup_components(shared_deps, per_component_deps)


func _connect_signals() -> void:
	melee_hitbox.body_entered.connect(_on_melee_hitbox_body_entered)
	pogo_hitbox.body_entered.connect(_on_pogo_hitbox_body_entered)
	melee_hitbox.area_entered.connect(_on_hitbox_area_entered)
	pogo_hitbox.area_entered.connect(_on_hitbox_area_entered)
	hurtbox.area_entered.connect(_on_hurtbox_area_entered)
	health_component.health_changed.connect(_on_health_component_health_changed)
	health_component.died.connect(_on_health_component_died)
	health_component.took_damage.connect(_on_health_component_took_damage)
	combat_component.damage_dealt.connect(resource_component.on_damage_dealt)
	combat_component.pogo_bounce_requested.connect(_on_pogo_bounce_requested)

func _update_timers(delta: float) -> void:
	entity_data.coyote_timer = max(0.0, entity_data.coyote_timer - delta)
	entity_data.wall_coyote_timer = max(0.0, entity_data.wall_coyote_timer - delta)
	entity_data.dash_cooldown_timer = max(0.0, entity_data.dash_cooldown_timer - delta)
	entity_data.dash_duration_timer = max(0.0, entity_data.dash_duration_timer - delta)
	entity_data.attack_duration_timer = max(0.0, entity_data.attack_duration_timer - delta)
	entity_data.attack_cooldown_timer = max(0.0, entity_data.attack_cooldown_timer - delta)
	entity_data.knockback_timer = max(0.0, entity_data.knockback_timer - delta)
	entity_data.pogo_fall_prevention_timer = max(0.0, entity_data.pogo_fall_prevention_timer - delta)
	if entity_data.is_charging and input_component.buffer.get("attack_pressed"):
		entity_data.charge_timer += delta

# --- Signal Handlers ---
func _on_melee_hitbox_body_entered(body: Node) -> void:
	var target_id = body.get_instance_id()
	if entity_data.hit_targets_this_swing.has(target_id): return
	entity_data.hit_targets_this_swing[target_id] = true
	var damageable = CombatUtilsScript.find_damageable(body)
	if is_instance_valid(damageable):
		var damage_info = DamageInfo.new()
		damage_info.source_node = self
		var distance = self.global_position.distance_to(body.global_position)
		var is_close_range = distance <= CLOSE_RANGE_THRESHOLD
		damage_info.amount = 5 if is_close_range else 1
		damage_info.impact_position = body.global_position
		damage_info.impact_normal = (body.global_position - global_position).normalized()
		var damage_result = damageable.apply_damage(damage_info)
		if damage_result.was_damaged:
			resource_component.on_damage_dealt()
			if is_close_range:
				FXManager.request_hit_stop(entity_data.config.player_melee_close_range_hit_stop_duration)
func _on_pogo_hitbox_body_entered(body: Node) -> void:
	combat_component.trigger_pogo(body)
func _on_hitbox_area_entered(area: Area2D) -> void:
	if area.is_in_group(Identifiers.Groups.ENEMY_PROJECTILE):
		if entity_data.is_pogo_attack:
			combat_component.trigger_pogo(area)
		else:
			ObjectPool.return_instance.call_deferred(area)
func _on_hurtbox_area_entered(area: Area2D) -> void:
	if health_component.is_invincible(): return
	if area.is_in_group(Identifiers.Groups.ENEMY_PROJECTILE):
		var damage_info = DamageInfo.new()
		damage_info.amount = 1
		damage_info.source_node = area
		damage_info.impact_position = global_position
		damage_info.impact_normal = (global_position - area.global_position).normalized()
		var damage_result = health_component.apply_damage(damage_info)
		
		if not is_instance_valid(entity_data): return
		
		if damage_result.was_damaged and entity_data.health > 0:
			self.velocity = damage_result.knockback_velocity
			state_machine.change_state(State.HURT)
		ObjectPool.return_instance.call_deferred(area)
func _on_healing_timer_timeout() -> void:
	if state_machine.current_state == state_machine.states[State.HEAL]:
		entity_data.health += 1; entity_data.healing_charges -= 1
		_on_health_component_health_changed(entity_data.health, entity_data.max_health)
		resource_component.on_damage_dealt()
		state_machine.change_state(State.MOVE)
func _on_health_component_health_changed(current: int, max_val: int) -> void:
	var ev = PlayerHealthChangedEvent.new()
	ev.current_health = current
	ev.max_health = max_val
	EventBus.emit(EventCatalog.PLAYER_HEALTH_CHANGED, ev)
	health_changed.emit(current, max_val)
func _on_health_component_died() -> void:
	died.emit()
func _on_health_component_took_damage(damage_info: DamageInfo, _damage_result: DamageResult) -> void:
	if is_instance_valid(damage_shake_effect):
		FXManager.request_screen_shake(damage_shake_effect)
	FXManager.request_hit_stop(entity_data.config.player_damage_taken_hit_stop_duration)
	if is_instance_valid(hit_spark_effect):
		FXManager.play_vfx(hit_spark_effect, damage_info.impact_position, damage_info.impact_normal)
func _on_pogo_bounce_requested() -> void:
	velocity.y = -entity_data.config.player_pogo_force
	position.y -= 1
	entity_data.can_dash = true
	entity_data.air_jumps_left = entity_data.config.player_max_air_jumps
	state_machine.change_state(State.FALL)
func _cancel_heal() -> void:
	if healing_timer.is_stopped(): return
	healing_timer.stop()
