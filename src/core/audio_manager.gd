# src/core/audio_manager.gd
#
# This singleton is responsible for all audio playback. By centralizing all
# audio logic here, any other script can simply call `AudioManager.play_sfx()`
# without worrying about the implementation details.
extends Node

var sfx_players = []
var sfx_player_index = 0
var music_player: AudioStreamPlayer

func _ready():
	for i in range(Constants.NUM_SFX_PLAYERS):
		var player = AudioStreamPlayer.new()
		add_child(player)
		player.bus = "SFX"
		sfx_players.append(player)

	music_player = AudioStreamPlayer.new()
	add_child(music_player)
	music_player.bus = "Music"

func _process(_delta):
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), linear_to_db(Settings.master_volume))
	AudioServer.set_bus_mute(AudioServer.get_bus_index("Master"), Settings.master_muted)

	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Music"), linear_to_db(Settings.music_volume))
	AudioServer.set_bus_mute(AudioServer.get_bus_index("Music"), Settings.music_muted)

	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("SFX"), linear_to_db(Settings.sfx_volume))
	AudioServer.set_bus_mute(AudioServer.get_bus_index("SFX"), Settings.sfx_muted)

# --- Public Functions ---

func play_sfx(sound_path: String):
	var player = sfx_players[sfx_player_index]
	player.stream = load(sound_path)
	player.play()
	sfx_player_index = (sfx_player_index + 1) % Constants.NUM_SFX_PLAYERS

func play_music(music_path: String):
	# ROBUSTNESS FIX: Check the resource path instead of the instance.
	# This correctly prevents the music from restarting if it's already playing.
	if music_player.stream and music_player.stream.resource_path == music_path and music_player.playing:
		return

	music_player.stream = load(music_path)
	music_player.play()

func stop_music():
	music_player.stop()