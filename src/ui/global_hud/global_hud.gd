# src/ui/global_hud/global_hud.gd
#
# This autoloaded scene is always present. Its main job is to manage the
# global mute button. It is now event-driven to prevent race conditions.
extends Control

# Preload icons into constants for performance and safety.
const ICON_SOUND_ON = preload(AssetPaths.SPRITE_ICON_SOUND_ON)
const ICON_SOUND_OFF = preload(AssetPaths.SPRITE_ICON_SOUND_OFF)

var mute_button: TextureButton

const MENU_SCENES = [
	AssetPaths.SCENE_TITLE_SCREEN,
	AssetPaths.SCENE_OPTIONS_MENU,
	AssetPaths.SCENE_SOUND_MENU,
	AssetPaths.SCENE_CONTROLS_MENU,
	AssetPaths.SCENE_CREDITS_MENU,
]

func _ready():
	mute_button = TextureButton.new()
	add_child(mute_button)

	var padding = 40
	await get_tree().process_frame
	mute_button.position = Vector2(get_viewport_rect().size.x - 120, padding)

	# Connect signals for interaction.
	mute_button.pressed.connect(_on_mute_button_pressed)
	mute_button.mouse_entered.connect(CursorManager.set_pointer_state.bind(true))
	mute_button.mouse_exited.connect(CursorManager.set_pointer_state.bind(false))

	# Connect to the Settings signal to react to changes.
	Settings.audio_settings_changed.connect(_update_icon)
	
	# Set the initial icon state once on startup.
	_update_icon()

# This loop is now only responsible for VISIBILITY.
func _process(_delta):
	if not get_tree().current_scene: return

	var current_scene_path = get_tree().current_scene.scene_file_path
	mute_button.visible = current_scene_path in MENU_SCENES

func _on_mute_button_pressed():
	# Toggle the setting. This emits the 'audio_settings_changed' signal,
	# which our _update_icon function is connected to.
	Settings.music_muted = not Settings.music_muted
	AudioManager.play_sfx(AssetPaths.AUDIO_SFX_MENU_SELECT)

# The _update_icon function is now called automatically by the signal from Settings.gd.
func _update_icon():
	if Settings.music_muted:
		mute_button.texture_normal = ICON_SOUND_OFF
	else:
		mute_button.texture_normal = ICON_SOUND_ON