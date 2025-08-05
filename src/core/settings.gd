# src/core/settings.gd
#
# This script is a "Singleton" (also known as an "Autoload" in Godot).
# A singleton is a script that Godot loads once at the very start of the game
# and is always available globally. We can access its variables from any other
# script in the project, which makes it perfect for managing game-wide settings.
#
# We defined this as a singleton in: Project -> Project Settings -> Autoload
extends Node

# --- Audio Settings ---
# These variables store the current sound settings for the game.
# The '@export' keyword tells Godot to show this variable in the Inspector panel
# when this node is viewed in the editor. While we don't edit it there for a
# singleton, it's a common way to mark important, configurable variables.

# A 'float' is a number that can have a decimal point (e.g., 0.5, 1.0).
# Volume values typically range from 0.0 (silent) to 1.0 (full volume).
@export var master_volume: float = 1.0
@export var music_volume: float = 1.0
@export var sfx_volume: float = 1.0

# A 'bool' is a boolean value, which can only be 'true' or 'false'.
# We use these to track whether a sound category is muted.
@export var master_muted: bool = false
@export var music_muted: bool = true # Start with music muted by default.
@export var sfx_muted: bool = false