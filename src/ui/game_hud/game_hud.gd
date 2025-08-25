# src/ui/game_hud/game_hud.gd
## Manages the in-game heads-up display.
##
## Subscribes to [EventBus] events to keep the player health, boss health,
## and phase indicators updated in real-time.
extends CanvasLayer

# --- Constants ---
const COMBAT_CONFIG = preload("res://src/data/combat_config.tres")

# --- Node References ---
@onready var player_health_value: Label = %PlayerHealthValue
@onready var player_heal_charges_value: Label = %PlayerHealChargesValue
@onready var boss_health_bar: ProgressBar = %BossHealthBar
@onready var phase_indicators: HBoxContainer = %PhaseIndicators

# --- Private Member Variables ---
# THE FIX: We are now creating ColorRects, not Panels.
var _phase_squares: Array[ColorRect] = []
var _total_phases: int = 3
var _player_health_token: int
var _player_charges_token: int
var _boss_health_token: int
var _boss_phase_token: int
var _boss_died_token: int


# --- Godot Lifecycle Methods ---
func _ready() -> void:
	_subscribe_to_events()
	_initialize_ui_state()


func _exit_tree() -> void:
	_unsubscribe_from_events()


# --- Private Methods ---
func _subscribe_to_events() -> void:
	_player_health_token = EventBus.on(EventCatalog.PLAYER_HEALTH_CHANGED, on_player_health_changed)
	_player_charges_token = EventBus.on(
		EventCatalog.PLAYER_HEALING_CHARGES_CHANGED, on_player_healing_charges_changed
	)
	_boss_health_token = EventBus.on(EventCatalog.BOSS_HEALTH_CHANGED, on_boss_health_changed)
	_boss_phase_token = EventBus.on(EventCatalog.BOSS_PHASE_CHANGED, on_boss_phase_changed)
	_boss_died_token = EventBus.on(EventCatalog.BOSS_DIED, on_boss_died)


func _unsubscribe_from_events() -> void:
	EventBus.off(_player_health_token)
	EventBus.off(_player_charges_token)
	EventBus.off(_boss_health_token)
	EventBus.off(_boss_phase_token)
	EventBus.off(_boss_died_token)


func _initialize_ui_state() -> void:
	var max_health = COMBAT_CONFIG.player_max_health
	player_health_value.text = "%d / %d" % [max_health, max_health]
	player_heal_charges_value.text = "0"

	var health_bar_style = boss_health_bar.get_theme_stylebox("fill").duplicate()
	health_bar_style.bg_color = Palette.COLOR_PLAYER_PROJECTILE
	boss_health_bar.add_theme_stylebox_override("fill", health_bar_style)

	boss_health_bar.max_value = COMBAT_CONFIG.boss_health
	boss_health_bar.value = boss_health_bar.max_value

	phase_indicators.add_theme_constant_override("separation", 5)
	_create_phase_indicators()


func _create_phase_indicators() -> void:
	for i in range(_total_phases):
		# THE FIX: Create a ColorRect instead of a Panel.
		var square = ColorRect.new()
		square.custom_minimum_size = Vector2(40, 40)
		phase_indicators.add_child(square)
		_phase_squares.append(square)
	_update_phase_visuals(_total_phases)


func _update_phase_visuals(phases_remaining: int) -> void:
	for i in range(_phase_squares.size()):
		var square: ColorRect = _phase_squares[i]
		
		# THE FIX: Directly set the color property, bypassing themes entirely.
		if i < phases_remaining:
			square.color = Color.WHITE
		else:
			square.color = Color.BLACK


# --- EventBus Callbacks ---
func on_player_health_changed(payload: PlayerHealthChangedEvent) -> void:
	player_health_value.text = str(payload.current_health) + " / " + str(payload.max_health)


func on_player_healing_charges_changed(payload: PlayerHealingChargesChangedEvent) -> void:
	player_heal_charges_value.text = str(payload.current_charges)


func on_boss_health_changed(payload: BossHealthChangedEvent) -> void:
	boss_health_bar.max_value = payload.max_health
	boss_health_bar.value = payload.current_health


func on_boss_phase_changed(payload: Dictionary) -> void:
	var phases_remaining = payload.get("phases_remaining", 1)
	_update_phase_visuals(phases_remaining)


func on_boss_died(_payload) -> void:
	_update_phase_visuals(0)
