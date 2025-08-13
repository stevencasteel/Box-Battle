# src/ui/game_hud/game_hud.gd
# Manages the in-game heads-up display. Phase indicators are now
# correctly initialized and styled.
extends CanvasLayer

@onready var player_health_value: Label = $PlayerInfo/PlayerHealthHBox/PlayerHealthValue
@onready var player_heal_charges_value: Label = $PlayerInfo/PlayerHealChargesHBox/PlayerHealChargesValue
@onready var boss_health_bar: ProgressBar = $BossHealthBar
@onready var phase_indicators: HBoxContainer = $PhaseIndicators

var _phase_squares: Array[Panel] = []
var _total_phases = 3

var _player_health_token: int
var _player_charges_token: int
var _boss_health_token: int
var _boss_phase_token: int
var _boss_died_token: int

# THE FIX: Pre-create the styles once for efficiency and stability.
var _filled_style: StyleBoxFlat
var _empty_style: StyleBoxFlat

func _ready():
	_player_health_token = EventBus.on(EventCatalog.PLAYER_HEALTH_CHANGED, on_player_health_changed)
	_player_charges_token = EventBus.on(EventCatalog.PLAYER_HEALING_CHARGES_CHANGED, on_player_healing_charges_changed)
	_boss_health_token = EventBus.on(EventCatalog.BOSS_HEALTH_CHANGED, on_boss_health_changed)
	_boss_phase_token = EventBus.on(EventCatalog.BOSS_PHASE_CHANGED, on_boss_phase_changed)
	_boss_died_token = EventBus.on(EventCatalog.BOSS_DIED, on_boss_died)
	
	_create_styles()
	
	var max_health = CombatDB.config.player_max_health
	player_health_value.text = "%d / %d" % [max_health, max_health]
	player_heal_charges_value.text = "0"
	
	var health_bar_style = boss_health_bar.get_theme_stylebox("fill").duplicate()
	health_bar_style.bg_color = Palette.COLOR_PLAYER_PROJECTILE
	boss_health_bar.add_theme_stylebox_override("fill", health_bar_style)
	
	boss_health_bar.max_value = CombatDB.config.boss_health
	boss_health_bar.value = boss_health_bar.max_value
	
	phase_indicators.add_theme_constant_override("separation", 5)
	_create_phase_indicators()

func _exit_tree():
	EventBus.off(_player_health_token)
	EventBus.off(_player_charges_token)
	EventBus.off(_boss_health_token)
	EventBus.off(_boss_phase_token)
	EventBus.off(_boss_died_token)

# THE FIX: Style creation is now in its own function, called once.
func _create_styles():
	_filled_style = StyleBoxFlat.new()
	_filled_style.bg_color = Palette.COLOR_HAZARD_PRIMARY
	_filled_style.border_width_bottom = 3
	_filled_style.border_width_left = 3
	_filled_style.border_width_right = 3
	_filled_style.border_width_top = 3
	_filled_style.border_color = Palette.COLOR_UI_ACCENT_PRIMARY

	_empty_style = _filled_style.duplicate()
	_empty_style.bg_color = Palette.COLOR_BACKGROUND

# THE FIX: This function now correctly calls the update logic to set the initial state.
func _create_phase_indicators():
	for i in range(_total_phases):
		var panel = Panel.new()
		panel.custom_minimum_size = Vector2(40, 40)
		phase_indicators.add_child(panel)
		_phase_squares.append(panel)
	
	# Set the initial visual state to be full.
	_update_phase_visuals(_total_phases)

# --- EventBus Callbacks ---
func on_player_health_changed(payload: PlayerHealthChangedEvent):
	player_health_value.text = str(payload.current_health) + " / " + str(payload.max_health)

func on_player_healing_charges_changed(payload: PlayerHealingChargesChangedEvent):
	player_heal_charges_value.text = str(payload.current_charges)

func on_boss_health_changed(payload: BossHealthChangedEvent):
	boss_health_bar.max_value = payload.max_health
	boss_health_bar.value = payload.current_health

func on_boss_phase_changed(payload: Dictionary):
	var phases_remaining = payload.get("phases_remaining", 1)
	_update_phase_visuals(phases_remaining)

func on_boss_died(_payload):
	_update_phase_visuals(0)

# THE FIX: This now uses the pre-built styles. The logic is confirmed correct
# for right-to-left depletion.
func _update_phase_visuals(phases_remaining: int):
	for i in range(_phase_squares.size()):
		var square = _phase_squares[i]
		if i < phases_remaining:
			square.add_theme_stylebox_override("panel", _filled_style)
		else:
			square.add_theme_stylebox_override("panel", _empty_style)
