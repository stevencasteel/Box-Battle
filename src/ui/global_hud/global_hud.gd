# src/ui/global_hud/global_hud.gd
#
# This autoloaded scene is always present. Its main job is to manage the
# global mute button that appears in the top-right corner of menu screens.
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
	# Wait for the viewport to be ready before positioning.
	await get_tree().process_frame

	# FIX: Revert to the original, correct positioning logic.
	# The dynamic calculation was flawed because the button's size is 0 before its texture is set.
	mute_button.position = Vector2(get_viewport_rect().size.x - 120, padding)

	# Connect signals for interaction.
	mute_button.pressed.connect(_on_mute_button_pressed)
	mute_button.mouse_entered.connect(CursorManager.set_pointer_state.bind(true))
	mute_button.mouse_exited.connect(CursorManager.set_pointer_state.bind(false))

	# Set the initial icon state.
	_update_icon()

func _process(_delta):
	if not get_tree().current_scene: return

	var current_scene_path = get_tree().current_scene.scene_file_path
	mute_button.visible = current_scene_path in MENU_SCENES

	if mute_button.visible:
		var is_muted_in_settings = Settings.music_muted
		var icon_is_off = mute_button.texture_normal == ICON_SOUND_OFF

		# If the setting and the icon are out of sync, update the icon.
		if is_muted_in_settings != icon_is_off:
			_update_icon()

func _on_mute_button_pressed():
	# Toggle the setting, play a sound, and update the icon.
	Settings.music_muted = not Settings.music_muted
	AudioManager.play_sfx(AssetPaths.AUDIO_SFX_MENU_SELECT)
	_update_icon()

func _update_icon():
	# Set the button's texture based on the current setting.
	if Settings.music_muted:
		mute_button.texture_normal = ICON_SOUND_OFF
	else:
		mute_button.texture_normal = ICON_SOUND_ON