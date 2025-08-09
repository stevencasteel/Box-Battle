# src/core/audio_manager.gd
#
# This singleton is responsible for all audio playback. It is now event-driven,
# only updating the AudioServer when settings actually change, which is much
# more performant than polling every frame.
extends Node

var sfx_players = []
var sfx_player_index = 0
var music_player: AudioStreamPlayer

func _ready():
	# --- Setup Audio Players ---
	for i in range(Constants.NUM_SFX_PLAYERS):
		var player = AudioStreamPlayer.new()
		add_child(player)
		player.bus = "SFX"
		sfx_players.append(player)

	music_player = AudioStreamPlayer.new()
	add_child(music_player)
	music_player.bus = "Music"

	# --- MODIFICATION ---
	# Connect to the settings signal. Now, _on_audio_settings_changed will be
	# called automatically whenever a relevant setting is modified.
	Settings.audio_settings_changed.connect(_on_audio_settings_changed)

	# Call the update function once at the start to set the initial volume.
	_on_audio_settings_changed()

# REMOVED: The _process(_delta) function has been deleted. No more polling!

# --- NEW: Signal Handler ---
# This function now holds the logic that used to be in _process().
# It only runs when the 'audio_settings_changed' signal is received from Settings.gd.
func _on_audio_settings_changed():
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), linear_to_db(Settings.master_volume))
	AudioServer.set_bus_mute(AudioServer.get_bus_index("Master"), Settings.master_muted)

	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Music"), linear_to_db(Settings.music_volume))
	AudioServer.set_bus_mute(AudioServer.get_bus_index("Music"), Settings.music_muted)

	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("SFX"), linear_to_db(Settings.sfx_volume))
	AudioServer.set_bus_mute(AudioServer.get_bus_index("SFX"), Settings.sfx_muted)


# --- Public Functions (Unchanged) ---

func play_sfx(sound_path: String):
	var player = sfx_players[sfx_player_index]
	player.stream = load(sound_path)
	player.play()
	sfx_player_index = (sfx_player_index + 1) % Constants.NUM_SFX_PLAYERS

func play_music(music_path: String):
	if music_player.stream and music_player.stream.resource_path == music_path and music_player.playing:
		return

	music_player.stream = load(music_path)
	music_player.play()

func stop_music():
	music_player.stop()