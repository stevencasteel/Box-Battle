# src/scenes/loading/loading_screen.gd
#
# This script handles the pre-building of the level AND pre-warming shaders
# to prevent stuttering.
extends Control

@onready var prewarm_viewport: SubViewport = $ShaderPrewarmViewport/SubViewport

const SHADER_PREWARM_SCENES = [
	AssetPaths.SCENE_PLAYER,
	AssetPaths.SCENE_BASE_BOSS,
	AssetPaths.SCENE_PLAYER_SHOT,
	AssetPaths.SCENE_BOSS_SHOT
]

func _ready():
	if GameManager.state.current_encounter_script_path.is_empty():
		print("ERROR: No encounter script specified in GameManager. Returning to title.")
		# CORRECTED: Use SceneManager for consistency.
		SceneManager.go_to_title_screen()
		return

	_load_level()

func _load_level():
	await get_tree().process_frame
	
	await _prewarm_shaders()
	
	# CORRECTED: The call now matches the updated signature and works correctly.
	GameManager.state.prebuilt_level = await ArenaBuilder.build_level_async()
	
	await get_tree().process_frame
	
	SceneManager.go_to_scene(AssetPaths.SCENE_GAME)

func _prewarm_shaders() -> void:
	print("Starting shader pre-warming...")
	for scene_path in SHADER_PREWARM_SCENES:
		var instance = load(scene_path).instantiate()
		prewarm_viewport.add_child(instance)
		await get_tree().process_frame
		instance.queue_free()
	
	print("Shader pre-warming complete.")
