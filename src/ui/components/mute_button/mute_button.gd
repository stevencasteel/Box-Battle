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
	if not Engine.is_editor_hint():
		# The owner scene is now responsible for handling pressed and hover.
		pass

# --- Public Methods ---

## Updates the button's icon based on the provided mute state.
func update_icon(is_muted: bool) -> void:
	if is_muted:
		self.texture_normal = ICON_SOUND_OFF
	else:
		self.texture_normal = ICON_SOUND_ON