# src/ui/game_hud/game_hud.gd
# Manages the in-game heads-up display. It is now fully decoupled and listens
# to the EventBus for real-time updates.
extends CanvasLayer

# --- Node References ---
@onready var player_health_value: Label = $PlayerInfo/PlayerHealthHBox/PlayerHealthValue
@onready var player_heal_charges_value: Label = $PlayerInfo/PlayerHealChargesHBox/PlayerHealChargesValue
@onready var boss_health_bar: ProgressBar = $BossHealthBar

# --- Subscription Tokens ---
var _player_health_token: int = 0
var _player_charges_token: int = 0
var _boss_health_token: int = 0

func _ready():
	_player_health_token = EventBus.on(EventCatalog.PLAYER_HEALTH_CHANGED, on_player_health_changed)
	_player_charges_token = EventBus.on(EventCatalog.PLAYER_HEALING_CHARGES_CHANGED, on_player_healing_charges_changed)
	_boss_health_token = EventBus.on(EventCatalog.BOSS_HEALTH_CHANGED, on_boss_health_changed)
	
	# MODIFIED: Get initial state from the new CombatDB resource.
	var max_health = CombatDB.config.player_max_health
	player_health_value.text = "%d / %d" % [max_health, max_health]
	player_heal_charges_value.text = "0"
	boss_health_bar.max_value = CombatDB.config.boss_health
	boss_health_bar.value = boss_health_bar.max_value


func _exit_tree():
	EventBus.off(_player_health_token)
	EventBus.off(_player_charges_token)
	EventBus.off(_boss_health_token)

# --- EventBus Callbacks ---

func on_player_health_changed(payload: PlayerHealthChangedEvent):
	player_health_value.text = str(payload.current_health) + " / " + str(payload.max_health)

func on_player_healing_charges_changed(payload: PlayerHealingChargesChangedEvent):
	player_heal_charges_value.text = str(payload.current_charges)

func on_boss_health_changed(payload: BossHealthChangedEvent):
	boss_health_bar.max_value = payload.max_health
	boss_health_bar.value = payload.current_health
