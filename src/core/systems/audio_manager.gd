# src/core/systems/audio_manager.gd
## An autoloaded singleton responsible for all audio playback.
##
## Manages separate channels for music and sound effects, and responds
## dynamically to changes in the global [Settings] resource. It includes
## robust cleanup handlers to prevent memory leaks on game exit.
extends Node

# --- Private Member Variables ---
var _sfx_players: Array[AudioStreamPlayer] = []
var _sfx_player_index: int = 0
var _music_player: AudioStreamPlayer

# --- Godot Lifecycle Methods ---

func _ready() -> void:
	# --- Create SFX Players ---
	for i in range(Constants.NUM_SFX_PLAYERS):
		var player = AudioStreamPlayer.new()
		player.name = "SFXPlayer_%d" % i
		player.bus = "SFX"
		add_child(player)
		_sfx_players.append(player)

	# --- Create Music Player ---
	_music_player = AudioStreamPlayer.new()
	_music_player.name = "MusicPlayer"
	_music_player.bus = "Music"
	add_child(_music_player)

	# --- Connect to Settings ---
	Settings.audio_settings_changed.connect(_on_audio_settings_changed)
	_on_audio_settings_changed() # Apply initial settings

func _notification(what: int) -> void:
	# A robust, system-level notification for cleaning up before the app quits.
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		if is_instance_valid(_music_player):
			_music_player.stop()
			_music_player.stream = null

func _exit_tree() -> void:
	# Disconnect from the signal to be a good citizen.
	if Settings.audio_settings_changed.is_connected(_on_audio_settings_changed):
		Settings.audio_settings_changed.disconnect(_on_audio_settings_changed)

	# Secondary cleanup method for when the node is removed from the tree.
	if is_instance_valid(_music_player):
		_music_player.stop()
		_music_player.stream = null

# --- Public Methods ---

## Plays a one-shot sound effect.
func play_sfx(sound_path: String) -> void:
	var player = _sfx_players[_sfx_player_index]
	player.stream = load(sound_path)
	player.play()
	_sfx_player_index = (_sfx_player_index + 1) % Constants.NUM_SFX_PLAYERS

## Plays a looping music track.
func play_music(music_path: String) -> void:
	if _music_player.stream and _music_player.stream.resource_path == music_path and _music_player.playing:
		return

	_music_player.stream = load(music_path)
	_music_player.play()

## Stops the current music track.
func stop_music() -> void:
	_music_player.stop()

# --- Signal Handlers ---

func _on_audio_settings_changed() -> void:
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), linear_to_db(Settings.master_volume))
	AudioServer.set_bus_mute(AudioServer.get_bus_index("Master"), Settings.master_muted)

	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Music"), linear_to_db(Settings.music_volume))
	AudioServer.set_bus_mute(AudioServer.get_bus_index("Music"), Settings.music_muted)

	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("SFX"), linear_to_db(Settings.sfx_volume))
	AudioServer.set_bus_mute(AudioServer.get_bus_index("SFX"), Settings.sfx_muted)