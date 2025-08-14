# src/ui/components/mute_button/mute_button.gd
@tool
extends TextureButton

const ICON_SOUND_ON = preload(AssetPaths.ICON_UI_SOUND_ON)
const ICON_SOUND_OFF = preload(AssetPaths.ICON_UI_SOUND_OFF)

func _ready():
	focus_mode = FOCUS_NONE
	
	_update_icon()

	if not Engine.is_editor_hint():
		self.pressed.connect(_on_pressed)
		Settings.audio_settings_changed.connect(_update_icon)
		mouse_entered.connect(CursorManager.set_pointer_state.bind(true))
		mouse_exited.connect(CursorManager.set_pointer_state.bind(false))

func _exit_tree():
	if not Engine.is_editor_hint():
		if Settings.audio_settings_changed.is_connected(_update_icon):
			Settings.audio_settings_changed.disconnect(_update_icon)

func _on_pressed():
	Settings.music_muted = not Settings.music_muted
	AudioManager.play_sfx(AssetPaths.SFX_UI_SELECT)

func _update_icon():
	if Settings.music_muted:
		self.texture_normal = ICON_SOUND_OFF
	else:
		self.texture_normal = ICON_SOUND_ON