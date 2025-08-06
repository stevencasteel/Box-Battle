# src/ui/game_hud/game_hud.gd
#
# Manages the in-game heads-up display. It connects to signals from the
# player and boss to update health bars and other UI elements in real-time.
extends CanvasLayer

# --- Node References ---
@onready var player_health_value: Label = $PlayerInfo/PlayerHealthHBox/PlayerHealthValue
@onready var player_heal_charges_value: Label = $PlayerInfo/PlayerHealChargesHBox/PlayerHealChargesValue
@onready var boss_health_bar: ProgressBar = $BossHealthBar

func _ready():
	# Wait until the main scene tree is ready before trying to connect signals.
	await get_tree().process_frame
	
	var player = get_tree().get_first_node_in_group("player")
	var boss = get_tree().get_first_node_in_group("enemy")

	if is_instance_valid(player):
		# Connect to the player's signals.
		player.health_changed.connect(on_player_health_changed)
		player.healing_charges_changed.connect(on_player_healing_charges_changed)
	
	if is_instance_valid(boss):
		# Connect to the boss's signals.
		boss.health_changed.connect(on_boss_health_changed)

# --- Signal Callbacks ---

func on_player_health_changed(current_health: int, max_health: int):
	player_health_value.text = str(current_health) + " / " + str(max_health)

func on_player_healing_charges_changed(current_charges: int):
	player_heal_charges_value.text = str(current_charges)

func on_boss_health_changed(current_health: int, max_health: int):
	# Set the max_value of the progress bar first in case it has changed.
	boss_health_bar.max_value = max_health
	# Update the current value.
	boss_health_bar.value = current_health