# src/entities/player/player.gd
@tool
class_name Player
extends BaseEntity

# --- Signals ---
signal health_changed(current_health, max_health)
signal died

# --- Constants ---
const ACTION_ALLOWED_STATES = [
	&"move",
	&"fall",
	&"jump",
	&"wall_slide"
]

# --- Editor Properties ---
@export_group("Juice & Feedback")
@export var hit_flash_effect: ShaderEffect
@export var damage_shake_effect: ScreenShakeEffect
@export var hit_spark_effect: VFXEffect
@export var dissolve_effect: ShaderEffect
@export_group("State Scripts")
@export var state_move_script: Script
@export var state_jump_script: Script
@export var state_fall_script: Script
@export var state_dash_script: Script
@export var state_wall_slide_script: Script
@export var state_attack_script: Script
@export var state_hurt_script: Script
@export var state_heal_script: Script
@export var state_pogo_script: Script

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
	if Engine.is_editor_hint():
		return

	add_to_group(Identifiers.Groups.PLAYER)
	EntityBuilder.build(self)

	visual_sprite.color = Palette.COLOR_PLAYER
	entity_data.healing_charges = 0
	get_component(PlayerResourceComponent).on_damage_dealt()
	entity_data.determination_counter = 0


func _physics_process(delta: float) -> void:
	if _is_dead:
		return
	_update_timers(delta)


# --- Public Methods ---
func teardown() -> void:
	var hc: HealthComponent = get_component(HealthComponent)
	if is_instance_valid(hc):
		if hc.health_changed.is_connected(_on_health_component_health_changed):
			hc.health_changed.disconnect(_on_health_component_health_changed)
		if hc.died.is_connected(_on_health_component_died):
			hc.died.disconnect(_on_health_component_died)

	var cc: CombatComponent = get_component(CombatComponent)
	if is_instance_valid(cc):
		var rc: PlayerResourceComponent = get_component(PlayerResourceComponent)
		if is_instance_valid(rc) and cc.damage_dealt.is_connected(rc.on_damage_dealt):
			cc.damage_dealt.disconnect(rc.on_damage_dealt)
		if cc.pogo_bounce_requested.is_connected(_on_pogo_bounce_requested):
			cc.pogo_bounce_requested.disconnect(_on_pogo_bounce_requested)

	var sm: BaseStateMachine = get_component(BaseStateMachine)
	if is_instance_valid(sm):
		if sm.melee_hitbox_toggled.is_connected(_enable_melee_hitbox):
			sm.melee_hitbox_toggled.disconnect(_enable_melee_hitbox)
		if sm.pogo_hitbox_toggled.is_connected(_enable_pogo_hitbox):
			sm.pogo_hitbox_toggled.disconnect(_enable_pogo_hitbox)

	if is_instance_valid(healing_timer):
		if healing_timer.timeout.is_connected(_on_healing_timer_timeout):
			healing_timer.timeout.disconnect(_on_healing_timer_timeout)

	super.teardown()
	entity_data = null


# --- Private Methods ---
func _die() -> void:
	if _is_dead:
		return
	_is_dead = true

	collision_layer = 0
	collision_mask = 0
	set_physics_process(false)

	var sm: BaseStateMachine = get_component(BaseStateMachine)
	if is_instance_valid(sm):
		sm.teardown()

	var fc: FXComponent = get_component(FXComponent)
	if is_instance_valid(dissolve_effect) and is_instance_valid(fc):
		var tween: Tween = fc.play_effect(dissolve_effect, {}, {"preserve_final_state": false})
		if is_instance_valid(tween):
			await tween.finished

	died.emit()


func _enable_melee_hitbox(is_enabled: bool, is_up_attack: bool = false) -> void:
	var shape_node: CollisionShape2D = melee_hitbox.get_node("CollisionShape2D")
	if is_enabled:
		if is_up_attack:
			shape_node.shape = entity_data.config.player_upward_attack_shape
			shape_node.position = Vector2(0, -40)
		else:
			shape_node.shape = entity_data.config.player_forward_attack_shape
			shape_node.position = Vector2(entity_data.facing_direction * 60, 0)
	shape_node.set_deferred("disabled", not is_enabled)


func _enable_pogo_hitbox(is_enabled: bool) -> void:
	var shape_node: CollisionShape2D = pogo_hitbox.get_node("CollisionShape2D")
	shape_node.position = Vector2(0, 40)
	shape_node.set_deferred("disabled", not is_enabled)


func _update_timers(delta: float) -> void:
	if not is_instance_valid(entity_data):
		return

	entity_data.coyote_timer = max(0.0, entity_data.coyote_timer - delta)
	entity_data.wall_coyote_timer = max(0.0, entity_data.wall_coyote_timer - delta)
	entity_data.dash_cooldown_timer = max(0.0, entity_data.dash_cooldown_timer - delta)
	entity_data.dash_duration_timer = max(0.0, entity_data.dash_duration_timer - delta)
	entity_data.attack_duration_timer = max(0.0, entity_data.attack_duration_timer - delta)
	entity_data.attack_cooldown_timer = max(0.0, entity_data.attack_cooldown_timer - delta)
	entity_data.knockback_timer = max(0.0, entity_data.knockback_timer - delta)
	entity_data.pogo_fall_prevention_timer = max(
		0.0, entity_data.pogo_fall_prevention_timer - delta
	)
	var ic: InputComponent = get_component(InputComponent)
	if entity_data.is_charging and is_instance_valid(ic) and ic.buffer.get("attack_pressed"):
		entity_data.charge_timer += delta


# --- Signal Handlers ---
func _on_melee_hitbox_body_entered(body: Node) -> void:
	get_component(CombatComponent).trigger_melee_attack(body)


func _on_pogo_hitbox_body_entered(body: Node) -> void:
	get_component(CombatComponent).trigger_pogo(body)


func _on_hitbox_area_entered(area: Area2D) -> void:
	if area.is_in_group(Identifiers.Groups.ENEMY_PROJECTILE):
		if entity_data.is_pogo_attack:
			get_component(CombatComponent).trigger_pogo(area)
		else:
			_services.object_pool.return_instance.call_deferred(area)


func _on_hurtbox_area_entered(area: Area2D) -> void:
	var hc: HealthComponent = get_component(HealthComponent)
	if hc.is_invincible():
		return
	if area.is_in_group(Identifiers.Groups.ENEMY_PROJECTILE):
		var damage_info = DamageInfo.new()
		damage_info.amount = 1
		damage_info.source_node = area
		damage_info.impact_position = global_position
		damage_info.impact_normal = (global_position - area.global_position).normalized()
		var damage_result = hc.apply_damage(damage_info)

		if not is_instance_valid(entity_data):
			return

		if damage_result.was_damaged and entity_data.health > 0:
			self.velocity = damage_result.knockback_velocity
			get_component(BaseStateMachine).change_state(Identifiers.PlayerStates.HURT)
		_services.object_pool.return_instance.call_deferred(area)


func _on_healing_timer_timeout() -> void:
	var sm: BaseStateMachine = get_component(BaseStateMachine)
	if sm.current_state == sm.states[Identifiers.PlayerStates.HEAL]:
		entity_data.health += 1
		get_component(PlayerResourceComponent).consume_healing_charge()
		_on_health_component_health_changed(entity_data.health, entity_data.max_health)
		sm.change_state(Identifiers.PlayerStates.MOVE)


func _on_health_component_health_changed(current: int, max_val: int) -> void:
	var ev = PlayerHealthChangedEvent.new()
	ev.current_health = current
	ev.max_health = max_val
	_services.event_bus.emit(EventCatalog.PLAYER_HEALTH_CHANGED, ev)
	health_changed.emit(current, max_val)


func _on_health_component_died() -> void:
	_die()


func _on_pogo_bounce_requested() -> void:
	velocity.y = -entity_data.config.player_pogo_force
	position.y -= 1
	entity_data.can_dash = true
	entity_data.air_jumps_left = entity_data.config.player_max_air_jumps
	get_component(BaseStateMachine).change_state(Identifiers.PlayerStates.FALL)


func _cancel_heal() -> void:
	if healing_timer.is_stopped():
		return
	healing_timer.stop()
