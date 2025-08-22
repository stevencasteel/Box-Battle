# src/core/util/asset_paths.gd
## An autoloaded singleton containing verified, static paths to all critical assets.
##
## Using these constants prevents runtime errors from typos in string paths and
## provides a central place to manage asset locations. Includes a validation
## system to check for missing files at startup in debug builds.
extends Node

# --- CORE SYSTEMS ---
const SCRIPT_COMBAT_UTILS = "res://src/core/util/combat_utils.gd"
const SCENE_MAIN = "res://src/scenes/main/main.tscn"
const SCENE_ENCOUNTER = "res://src/scenes/game/encounter_scene.tscn"
const SCENE_LOADING_SCREEN = "res://src/scenes/loading/loading_screen.tscn"
const SCRIPT_MENU_MANAGER = "res://src/ui/menu_manager/menu_manager.gd"
const SCRIPT_CUSTOM_SLIDER = "res://src/ui/components/custom_slider/custom_slider.gd"

# --- DATA ---
const ENCOUNTER_00 = "res://src/data/encounters/encounter_00.tres"

# --- PLAYER & RELATED ---
const SCENE_PLAYER = "res://src/entities/player/player.tscn"
const SCENE_PLAYER_SHOT = "res://src/projectiles/player_shot.tscn"

# --- BOSS, MINIONS & RELATED ---
const SCENE_BASE_BOSS = "res://src/entities/boss/base_boss.tscn"
const SCENE_BOSS_SHOT = "res://src/projectiles/boss_shot.tscn"
const SCENE_HOMING_BOSS_SHOT = "res://src/projectiles/homing_boss_shot.tscn"
const SCENE_TELEGRAPH_COMPONENT = "res://src/entities/components/telegraph_component.tscn"
const SCENE_TURRET = "res://src/entities/minions/turret.tscn"
const SCENE_TURRET_SHOT = "res://src/projectiles/turret_shot.tscn"

# --- UI & SCENES ---
const SCENE_GAME_HUD = "res://src/ui/game_hud/game_hud.tscn"
const SCENE_GAME_OVER_SCREEN = "res://src/scenes/game_over/game_over_screen.tscn"
const SCENE_VICTORY_SCREEN = "res://src/scenes/victory/victory_screen.tscn"
const SCENE_TITLE_SCREEN = "res://src/scenes/menus/title_screen.tscn"
const SCENE_OPTIONS_SCREEN = "res://src/scenes/menus/options_screen.tscn"
const SCENE_SOUND_SCREEN = "res://src/scenes/menus/sound_screen.tscn"
const SCENE_CONTROLS_SCREEN = "res://src/scenes/menus/controls_screen.tscn"
const SCENE_CREDITS_SCREEN = "res://src/scenes/menus/credits_screen.tscn"

# --- UI COMPONENTS ---
const SCENE_STYLED_MENU_ITEM = "res://src/ui/components/styled_menu_item/styled_menu_item.tscn"
const SCENE_LOGO_DISPLAY = "res://src/ui/components/logo_display/logo_display.tscn"
const SCENE_MUTE_BUTTON = "res://src/ui/components/mute_button/mute_button.tscn"

# --- DEV TOOLS ---
const SCENE_DEBUG_OVERLAY = "res://src/ui/dev/debug_overlay.tscn"

# --- VFX ---
const SCENE_HIT_SPARK = "res://src/vfx/hit_spark.tscn"

# --- SPRITES & ICONS ---
const SPRITE_CURSOR_DEFAULT = "res://assets/sprites/ui/cursors/sprite_cursor_default.png"
const SPRITE_CURSOR_POINTER = "res://assets/sprites/ui/cursors/sprite_cursor_pointer.png"
const SPRITE_SLIDER_TRACK = "res://assets/sprites/ui/slider/slider-track.png"
const SPRITE_SLIDER_KNOB = "res://assets/sprites/ui/slider/slider-knob.png"
const SPRITE_CHECKBOX_CHECKED = "res://assets/sprites/ui/checkbox/checkbox-checked.png"
const SPRITE_CHECKBOX_UNCHECKED = "res://assets/sprites/ui/checkbox/checkbox-unchecked.png"
const ICON_UI_SOUND_ON = "res://assets/sprites/ui/icons/icon_ui_sound_on.png"
const ICON_UI_SOUND_OFF = "res://assets/sprites/ui/icons/icon_ui_sound_off.png"

# --- FONTS ---
const FONT_MAIN_BLACK = "res://assets/fonts/font_main_black.ttf"
const FONT_MAIN_BOLD = "res://assets/fonts/font_main_bold.ttf"
const FONT_MAIN_REGULAR = "res://assets/fonts/font_main_regular.ttf"

# --- AUDIO ---
const MUSIC_MENU_LOOP = "res://assets/audio/music/music_menu_loop.mp3"
const SFX_UI_BACK = "res://assets/audio/sfx/sfx_ui_back.mp3"
const SFX_UI_ERROR = "res://assets/audio/sfx/sfx_ui_error.mp3"
const SFX_UI_MOVE = "res://assets/audio/sfx/sfx_ui_move.mp3"
const SFX_UI_SELECT = "res://assets/audio/sfx/sfx_ui_select.mp3"
const SFX_GAME_START = "res://assets/audio/sfx/sfx_game_start.mp3"


# --- Validation System ---
## Checks all defined paths to ensure the files exist on disk.
func validate_all_paths() -> void:
	print("AssetPaths: Validating all asset paths...")
	var constants = get_script().get_script_constant_map()
	var missing_assets = false

	for key in constants:
		var value = constants[key]
		if value is String and value.begins_with("res://"):
			if not FileAccess.file_exists(value):
				push_error(
					"Asset path validation failed! File not found for '%s': %s" % [key, value]
				)
				missing_assets = true

	if not missing_assets:
		print("AssetPaths: All paths validated successfully.")
