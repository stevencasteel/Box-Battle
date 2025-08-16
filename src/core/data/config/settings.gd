# src/core/data/config/settings.gd
## An autoloaded singleton that manages persistent game settings.
##
## This script uses property setters to automatically emit the
## [signal audio_settings_changed] signal whenever a value is modified,
## allowing other systems to react dynamically.
extends Node

# --- Signals ---
## Emitted whenever any audio-related setting is changed.
signal audio_settings_changed

# --- Audio Settings ---
@export var master_volume: float = 1.0:
	set(value):
		var clamped_value = clampf(value, 0.0, 1.0)
		if not is_equal_approx(master_volume, clamped_value):
			master_volume = clamped_value
			audio_settings_changed.emit()

@export var music_volume: float = 1.0:
	set(value):
		var clamped_value = clampf(value, 0.0, 1.0)
		if not is_equal_approx(music_volume, clamped_value):
			music_volume = clamped_value
			audio_settings_changed.emit()

@export var sfx_volume: float = 1.0:
	set(value):
		var clamped_value = clampf(value, 0.0, 1.0)
		if not is_equal_approx(sfx_volume, clamped_value):
			sfx_volume = clamped_value
			audio_settings_changed.emit()

@export var master_muted: bool = false:
	set(value):
		if master_muted != value:
			master_muted = value
			audio_settings_changed.emit()

@export var music_muted: bool = true:
	set(value):
		if music_muted != value:
			music_muted = value
			audio_settings_changed.emit()

@export var sfx_muted: bool = false:
	set(value):
		if sfx_muted != value:
			sfx_muted = value
			audio_settings_changed.emit()