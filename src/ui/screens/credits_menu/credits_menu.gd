# src/ui/screens/credits_menu/credits_menu.gd
#
# Displays game credits using a RichTextLabel to handle formatted text and URLs.
extends Control

const MenuManager = preload(AssetPaths.SCRIPT_MENU_MANAGER)

func _ready():
	EventBus.emit(EventCatalog.MENU_OPENED)
	var title_font = load(AssetPaths.FONT_BLACK)

	var title_label = Label.new()
	title_label.text = "Credits"
	add_child(title_label)
	title_label.add_theme_font_override("font", title_font)
	title_label.add_theme_font_size_override("font_size", 96)
	title_label.size.x = get_viewport_rect().size.x
	title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title_label.position.y = 80

	# --- Credits RichTextLabel ---
	var credits_label = RichTextLabel.new()
	add_child(credits_label)
	credits_label.mouse_filter = Control.MOUSE_FILTER_PASS
	credits_label.add_theme_font_override("normal_font", load(AssetPaths.FONT_REGULAR))
	credits_label.add_theme_font_size_override("normal_font_size", 38)
	credits_label.add_theme_color_override("default_color", Color.WHITE)
	credits_label.position = Vector2(0, 220)
	credits_label.size.x = get_viewport_rect().size.x
	credits_label.size.y = 550
	credits_label.bbcode_enabled = true # This MUST be true to parse the [url] tags.

	credits_label.text = """
[center]A Game By Steven Casteel[/center]
[center][url=https://www.stevencasteel.com/]www.stevencasteel.com[/url][/center]

[center]Built with the [url=https://godotengine.org/]Godot Engine[/url][/center]
[center]AI-Assisted by [url=https://gemini.google.com/]Gemini[/url][/center]

[center]Find me on [url=https://www.youtube.com/@stevencasteel]YouTube[/url] and [url=http://github.com/stevencasteel]GitHub[/url][/center]
"""
	# --- Connect Signals for RichTextLabel ---
	credits_label.meta_clicked.connect(_on_meta_clicked)
	credits_label.meta_hover_started.connect(func(_meta): CursorManager.set_pointer_state(true))
	credits_label.meta_hover_ended.connect(func(_meta): CursorManager.set_pointer_state(false))

	# --- Back Button ---
	var back_button = TextureButton.new()
	back_button.texture_normal = load(AssetPaths.SPRITE_MENU_ITEM_BACK)
	add_child(back_button)
	back_button.position.x = (get_viewport_rect().size.x - back_button.size.x) / 2
	back_button.position.y = 800
	back_button.pressed.connect(_on_back_button_pressed)

	var menu = MenuManager.new()
	add_child(menu)
	menu.setup_menu([MenuManager.MenuItem.new(back_button, "BACK")])

func _exit_tree():
	EventBus.emit(EventCatalog.MENU_CLOSED)

# Called when a URL inside the RichTextLabel is clicked.
func _on_meta_clicked(meta):
	OS.shell_open(str(meta))

func _on_back_button_pressed():
	get_tree().call_deferred("change_scene_to_file", AssetPaths.SCENE_OPTIONS_MENU)