# src/core/util/asset_paths.gd
#
# This singleton provides a central, validated registry for all asset file paths.
# It is now organized by feature/system for better scalability and includes a
# validation function to prevent runtime errors from missing assets.
extends Node

# --- CORE SYSTEMS ---
const SCENE_MAIN = "res://src/scenes/main/main.tscn"
const SCENE_GAME = "res://src/scenes/game/game.tscn"
const SCENE_LOADING_SCREEN = "res://src/scenes/loading/loading_screen.tscn"
const SCRIPT_MENU_MANAGER = "res://src/ui/menu_manager/menu_manager.gd"
const SCRIPT_CUSTOM_SLIDER = "res://src/ui/components/custom_slider/custom_slider.gd"

# --- ARENAS ---
const SCRIPT_ARENA_00_LAYOUT = "res://src/arenas/arena_00_layout.gd"
const SCRIPT_ARENA_00_ENCOUNTER = "res://src/arenas/arena_00_encounter.gd"

# --- PLAYER & RELATED ---
const SCENE_PLAYER = "res://src/entities/player/player.tscn"
const SCENE_PLAYER_SHOT = "res://src/projectiles/player_shot.tscn"

# --- BOSS & RELATED ---
const SCENE_BASE_BOSS = "res://src/entities/boss/base_boss.tscn"
const SCENE_BOSS_SHOT = "res://src/projectiles/boss_shot.tscn"

# --- UI & HUD ---
const SCENE_GAME_HUD = "res://src/ui/game_hud/game_hud.tscn"
const SCENE_GAME_OVER_SCREEN = "res://src/ui/screens/game_over_screen/game_over_screen.tscn"
const SCENE_VICTORY_SCREEN = "res://src/ui/screens/victory_screen/victory_screen.tscn"
const SCENE_TITLE_SCREEN = "res://src/ui/screens/title_screen/title_screen.tscn"
const SCENE_OPTIONS_MENU = "res://src/ui/screens/options_menu/options_menu.tscn"
const SCENE_SOUND_MENU = "res://src/ui/screens/sound_menu/sound_menu.tscn"
const SCENE_CONTROLS_MENU = "res://src/ui/screens/controls_menu/controls_menu.tscn"
const SCENE_CREDITS_MENU = "res://src/ui/screens/credits_menu/credits_menu.tscn"

const SPRITE_TITLE = "res://assets/sprites/ui/title/box_battle_title.png"
const SPRITE_MENU_CURSOR = "res://assets/sprites/ui/menu/menu-cursor.png"
const SPRITE_MENU_ITEM_START = "res://assets/sprites/ui/menu/menu-item-start.png"
const SPRITE_MENU_ITEM_OPTIONS = "res://assets/sprites/ui/menu/menu-item-options.png"
const SPRITE_MENU_ITEM_SOUND = "res://assets/sprites/ui/menu/menu-item-sound.png"
const SPRITE_MENU_ITEM_CONTROLS = "res://assets/sprites/ui/menu/menu-item-controls.png"
const SPRITE_MENU_ITEM_CREDITS = "res://assets/sprites/ui/menu/menu-item-credits.png"
const SPRITE_MENU_ITEM_BACK = "res://assets/sprites/ui/menu/menu-item-back.png"
const SPRITE_CURSOR_DEFAULT = "res://assets/sprites/ui/cursors/cursor_default.png"
const SPRITE_CURSOR_POINTER = "res://assets/sprites/ui/cursors/cursor_pointer.png"
const SPRITE_SLIDER_TRACK = "res://assets/sprites/ui/slider/slider-track.png"
const SPRITE_SLIDER_KNOB = "res://assets/sprites/ui/slider/slider-knob.png"
const SPRITE_CHECKBOX_CHECKED = "res://assets/sprites/ui/checkbox/checkbox-checked.png"
const SPRITE_CHECKBOX_UNCHECKED = "res://assets/sprites/ui/checkbox/checkbox-unchecked.png"
const SPRITE_ICON_SOUND_ON = "res://assets/sprites/ui/icons/icon-sound-on.png"
const SPRITE_ICON_SOUND_OFF = "res://assets/sprites/ui/icons/icon-sound-off.png"

# --- FONTS ---
const FONT_BLACK = "res://assets/fonts/MPLUSRounded1c-Black.ttf"
const FONT_BOLD = "res://assets/fonts/MPLUSRounded1c-Bold.ttf"
const FONT_REGULAR = "res://assets/fonts/MPLUSRounded1c-Regular.ttf"

# --- AUDIO ---
const AUDIO_MUSIC_TITLE = "res://assets/audio/music/title-screen-loop.mp3"
const AUDIO_SFX_MENU_BACK = "res://assets/audio/sfx/menu-back.mp3"
const AUDIO_SFX_MENU_ERROR = "res://assets/audio/sfx/menu-error.mp3"
const AUDIO_SFX_MENU_MOVE = "res://assets/audio/sfx/menu-move.mp3"
const AUDIO_SFX_MENU_SELECT = "res://assets/audio/sfx/menu-select.mp3"
const AUDIO_SFX_START_CHIME = "res://assets/audio/sfx/start-chime.mp3"


# --- NEW: VALIDATION SYSTEM ---
# This function runs at startup to verify that every path defined in this
# script actually points to a real file.
func validate_all_paths() -> void:
	print("AssetPaths: Validating all asset paths...")
	var constants = get_script().get_script_constant_map()
	var missing_assets = false
	
	for key in constants:
		var value = constants[key]
		# We only care about string paths that are project resources.
		if value is String and value.begins_with("res://"):
			if not FileAccess.file_exists(value):
				push_error("Asset path validation failed! File not found for '%s': %s" % [key, value])
				missing_assets = true

	if not missing_assets:
		print("AssetPaths: All paths validated successfully.")