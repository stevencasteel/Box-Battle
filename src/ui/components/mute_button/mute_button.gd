# src/ui/components/mute_button/mute_button.gd
@tool
## A reusable UI component for toggling the game's music mute state.
##
## It automatically syncs its icon with the global [Settings] resource.
class_name MuteButton
extends TextureButton

# --- Constants ---
const ICON_SOUND_ON = preload(AssetPaths.ICON_UI_SOUND_ON)
const ICON_SOUND_OFF = preload(AssetPaths.ICON_UI_SOUND_OFF)

# --- Godot Lifecycle Methods ---


func _ready() -> void:
	# This component is now self-managing.
	# It connects to its own signals and the global Settings singleton.
	if not Engine.is_editor_hint():
		self.pressed.connect(_on_pressed)
		Settings.audio_settings_changed.connect(_on_audio_settings_changed)
		_on_audio_settings_changed() # Sync icon on ready


func _exit_tree() -> void:
	if not Engine.is_editor_hint():
		if self.pressed.is_connected(_on_pressed):
			self.pressed.disconnect(_on_pressed)
		if Settings.audio_settings_changed.is_connected(_on_audio_settings_changed):
			Settings.audio_settings_changed.disconnect(_on_audio_settings_changed)


# --- Public Methods ---


## Updates the button's icon based on the current global mute state.
func update_icon() -> void:
	if Settings.music_muted:
		self.texture_normal = ICON_SOUND_OFF
	else:
		self.texture_normal = ICON_SOUND_ON


# --- Signal Handlers ---


func _on_pressed() -> void:
	# When pressed, this button directly modifies the global setting.
	Settings.music_muted = not Settings.music_muted
	# Play sound feedback
	AudioManager.play_sfx(AssetPaths.SFX_UI_SELECT)


func _on_audio_settings_changed() -> void:
	update_icon()