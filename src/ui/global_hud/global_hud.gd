# src/ui/global_hud/global_hud.gd
#
# This autoloaded scene is always present. Its main job is to manage the
# global mute button. It is now fully event-driven and decoupled from any
# specific menu scene.
extends Control

# Preload icons into constants for performance and safety.
const ICON_SOUND_ON = preload(AssetPaths.SPRITE_ICON_SOUND_ON)
const ICON_SOUND_OFF = preload(AssetPaths.SPRITE_ICON_SOUND_OFF)

var mute_button: TextureButton

# Subscription tokens for safe cleanup.
var _menu_opened_token: int
var _menu_closed_token: int
var _audio_settings_token: int

func _ready():
	mute_button = TextureButton.new()
	add_child(mute_button)

	var padding = 40
	await get_tree().process_frame
	mute_button.position = Vector2(get_viewport_rect().size.x - 120, padding)
	mute_button.visible = false # Start hidden by default

	# Connect signals for interaction.
	mute_button.pressed.connect(_on_mute_button_pressed)
	mute_button.mouse_entered.connect(CursorManager.set_pointer_state.bind(true))
	mute_button.mouse_exited.connect(CursorManager.set_pointer_state.bind(false))

	# Subscribe to all necessary events.
	_audio_settings_token = Settings.audio_settings_changed.connect(_update_icon)
	_menu_opened_token = EventBus.on(EventCatalog.MENU_OPENED, _on_menu_opened)
	_menu_closed_token = EventBus.on(EventCatalog.MENU_CLOSED, _on_menu_closed)
	
	# Set the initial icon state once on startup.
	_update_icon()

func _exit_tree():
	# Unsubscribe from all signals and events to prevent memory leaks.
	Settings.audio_settings_changed.disconnect(_update_icon)
	EventBus.off(_menu_opened_token)
	EventBus.off(_menu_closed_token)

# --- EventBus Handlers (The New Visibility Logic) ---

func _on_menu_opened(_payload):
	mute_button.visible = true

func _on_menu_closed(_payload):
	mute_button.visible = false

# --- Internal Functions ---

func _on_mute_button_pressed():
	# Toggle the setting. This emits the 'audio_settings_changed' signal,
	# which our _update_icon function is connected to.
	Settings.music_muted = not Settings.music_muted
	AudioManager.play_sfx(AssetPaths.AUDIO_SFX_MENU_SELECT)

func _update_icon():
	if Settings.music_muted:
		mute_button.texture_normal = ICON_SOUND_OFF
	else:
		mute_button.texture_normal = ICON_SOUND_ON
