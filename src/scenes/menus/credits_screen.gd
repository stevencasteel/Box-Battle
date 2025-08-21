# src/scenes/menus/credits_screen.gd
## The controller for the credits screen.
@tool
extends Control

# --- Constants ---
const MenuManagerScript = preload(AssetPaths.SCRIPT_MENU_MANAGER)
const CREDITS_BBCODE = """
[center]A Game By Steven Casteel[/center]
[center][url=https://www.stevencasteel.com/]www.stevencasteel.com[/url][/center]

[center]Built with the [url=https://godotengine.org/]Godot Engine[/url][/center]
[center]AI-Assisted by [url=https://gemini.google.com/]Gemini[/url][/center]

[center]Find me on [url=https://www.youtube.com/@stevencasteel]YouTube[/url] and [url=http://github.com/stevencasteel]GitHub[/url][/center]
"""

# --- Node References ---
@onready var credits_label_container: Control = %CreditsLabelContainer
@onready var back_button: StyledMenuItem = %BackButton

# --- Godot Lifecycle Methods ---

func _ready() -> void:
	for c in credits_label_container.get_children(): c.queue_free()

	var credits_label = RichTextLabel.new()
	credits_label.set_anchors_preset(Control.PRESET_FULL_RECT)
	credits_label.bbcode_enabled = true
	credits_label.mouse_filter = MOUSE_FILTER_PASS
	credits_label.add_theme_font_override("normal_font", load(AssetPaths.FONT_MAIN_REGULAR))
	credits_label.add_theme_font_size_override("normal_font_size", 38)
	credits_label.add_theme_color_override("default_color", Color.WHITE)
	credits_label.text = CREDITS_BBCODE
	credits_label_container.add_child(credits_label)

	back_button.text = "BACK"

	if not Engine.is_editor_hint():
		back_button.pressed.connect(_on_back_button_pressed)
		credits_label.meta_clicked.connect(_on_meta_clicked)
		credits_label.meta_hover_started.connect(func(_meta): CursorManager.set_pointer_state(true))
		credits_label.meta_hover_ended.connect(func(_meta): CursorManager.set_pointer_state(false))

		var menu_manager = MenuManagerScript.new()
		add_child(menu_manager)
		menu_manager.setup_menu([back_button])

		# --- Connect Feedback Handlers ---
		menu_manager.selection_changed.connect(_on_any_item_focused)
		back_button.mouse_entered.connect(CursorManager.set_pointer_state.bind(true))
		back_button.mouse_exited.connect(CursorManager.set_pointer_state.bind(false))

		await get_tree().process_frame
		back_button.grab_focus()

# --- Signal Handlers ---

func _on_any_item_focused() -> void:
	AudioManager.play_sfx(AssetPaths.SFX_UI_MOVE)
	
func _on_meta_clicked(meta) -> void:
	AudioManager.play_sfx(AssetPaths.SFX_UI_SELECT)
	OS.shell_open(str(meta))

func _on_back_button_pressed() -> void:
	AudioManager.play_sfx(AssetPaths.SFX_UI_BACK)
	SceneManager.go_to_scene(AssetPaths.SCENE_OPTIONS_SCREEN)