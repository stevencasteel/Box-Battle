# src/core/settings.gd
#
# This script is a "Singleton" (also known as an "Autoload" in Godot).
# It now emits a signal whenever an audio setting is changed, allowing other
# systems like the AudioManager to react efficiently without polling.
extends Node

# NEW: A signal that is emitted whenever any audio setting is changed.
signal audio_settings_changed

# --- Audio Settings ---
# The variables have been converted to properties with setters. This allows us
# to run code (emitting the signal) whenever their values are changed.

@export var master_volume: float = 1.0:
	set(value):
		# MODIFIED: Added validation to clamp the value between 0.0 and 1.0
		var clamped_value = clampf(value, 0.0, 1.0)
		if not is_equal_approx(master_volume, clamped_value):
			master_volume = clamped_value
			audio_settings_changed.emit()

@export var music_volume: float = 1.0:
	set(value):
		# MODIFIED: Added validation to clamp the value between 0.0 and 1.0
		var clamped_value = clampf(value, 0.0, 1.0)
		if not is_equal_approx(music_volume, clamped_value):
			music_volume = clamped_value
			audio_settings_changed.emit()

@export var sfx_volume: float = 1.0:
	set(value):
		# MODIFIED: Added validation to clamp the value between 0.0 and 1.0
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