# src/core/palette.gd
#
# An autoloaded singleton that holds the project's master color palette.
# It establishes a single source of truth for all visual elements, ensuring a
# cohesive aesthetic. It is designed around a 32-step grayscale value scale.
extends Node

# FIX: The Color("#hex") constructor is a valid constant expression, unlike
# Color.from_string(). This allows the entire palette and its semantic
# constants to be correctly defined at compile-time.
const _palette: Array[Color] = [
	Color("#000000"), Color("#080808"), Color("#101010"), Color("#191919"),
	Color("#212121"), Color("#292929"), Color("#313131"), Color("#3a3a3a"),
	Color("#424242"), Color("#4a4a4a"), Color("#525252"), Color("#5a5a5a"),
	Color("#636363"), Color("#6b6b6b"), Color("#737373"), Color("#7b7b7b"),
	Color("#848484"), Color("#8c8c8c"), Color("#949494"), Color("#9c9c9c"),
	Color("#a5a5a5"), Color("#adadad"), Color("#b5b5b5"), Color("#bdbdbd"),
	Color("#c5c5c5"), Color("#cecece"), Color("#d6d6d6"), Color("#dedede"),
	Color("#e6e6e6"), Color("#efefef"), Color("#f7f7f7"), Color("#ffffff")
]

# --- SEMANTIC CONSTANTS ---
# This is the most important part of the script. We refer to these constants
# in our code, not the raw index numbers. This makes the code readable and

# easy to update. If we want to make all hazards darker, we just change one
# line here.

# Gameplay
const COLOR_PLAYER: Color = _palette[31]
const COLOR_BOSS_PRIMARY: Color = _palette[30]
const COLOR_PLAYER_PROJECTILE: Color = _palette[29]
const COLOR_HAZARD_PRIMARY: Color = _palette[28] # Also Enemy Projectiles

# Environment
const COLOR_BACKGROUND: Color = _palette[0]
const COLOR_GRID: Color = _palette[2]
const COLOR_TERRAIN_PRIMARY: Color = _palette[4]
const COLOR_TERRAIN_SECONDARY: Color = _palette[6]

# UI/UX
const COLOR_TEXT_HEADER: Color = _palette[30]
const COLOR_UI_ACCENT_PRIMARY: Color = _palette[28]
const COLOR_TEXT_PRIMARY: Color = _palette[26]
const COLOR_TEXT_DISABLED: Color = _palette[16]
# THE FIX: Changed from _palette[12] to _palette[20] for a much brighter glow.
const COLOR_UI_GLOW: Color = _palette[20]
const COLOR_UI_PANEL_BG: Color = _palette[8]

# --- Helper Function ---
# Provides a safe way to get a color by its index if needed.
func get_color(index: int) -> Color:
	if index >= 0 and index < _palette.size():
		return _palette[index]
	push_warning("Palette: Invalid color index requested: %d" % index)
	return Color.MAGENTA # Return a highly visible error color