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
	focus_mode = FOCUS_NONE
	_update_icon()

	if not Engine.is_editor_hint():
		self.pressed.connect(_on_pressed)
		Settings.audio_settings_changed.connect(_update_icon)
		mouse_entered.connect(CursorManager.set_pointer_state.bind(true))
		mouse_exited.connect(CursorManager.set_pointer_state.bind(false))

func _exit_tree() -> void:
	if not Engine.is_editor_hint():
		if Settings.audio_settings_changed.is_connected(_update_icon):
			Settings.audio_settings_changed.disconnect(_update_icon)

# --- Private Methods ---

func _update_icon() -> void:
	if Settings.music_muted:
		self.texture_normal = ICON_SOUND_OFF
	else:
		self.texture_normal = ICON_SOUND_ON

# --- Signal Handlers ---

func _on_pressed() -> void:
	Settings.music_muted = not Settings.music_muted