# src/scenes/loading/loading_screen.gd
#
# This script handles the pre-building of the level AND pre-warming shaders
# to prevent stuttering. It calls the ArenaBuilder to construct the level
# in memory and flashes key entities in an off-screen viewport.
extends Control

# --- Node References ---
@onready var prewarm_viewport: SubViewport = $ShaderPrewarmViewport/SubViewport

# An array of scenes with unique shaders we want to pre-compile.
# This makes it easy to add new enemies or effects in the future.
const SHADER_PREWARM_SCENES = [
	AssetPaths.SCENE_PLAYER,
	AssetPaths.SCENE_BASE_BOSS,
	AssetPaths.SCENE_PLAYER_SHOT,
	AssetPaths.SCENE_BOSS_SHOT
]

func _ready():
	# MODIFIED: Access the state object on GameManager
	if GameManager.state.current_encounter_script_path.is_empty():
		print("ERROR: No encounter script specified in GameManager. Returning to title.")
		get_tree().change_scene_to_file(AssetPaths.SCENE_TITLE_SCREEN)
		return

	# Start the full asynchronous loading process.
	_load_level()

func _load_level():
	# Yield to make sure the "Loading..." text renders before we start heavy work.
	await get_tree().process_frame
	
	# --- NEW: Pre-warm shaders ---
	await _prewarm_shaders()
	
	# Tell the ArenaBuilder to construct the level asynchronously.
	# MODIFIED: Access the state object on GameManager
	GameManager.state.prebuilt_level = await ArenaBuilder.build_level_async()
	
	# Yield to ensure all creation processes are finalized before we switch.
	await get_tree().process_frame
	
	# Proceed to the main game scene.
	get_tree().change_scene_to_file(AssetPaths.SCENE_GAME)

# --- NEW FUNCTION ---
# This function forces the compilation of shaders by briefly instantiating
# and rendering key game objects in an invisible, off-screen viewport.
func _prewarm_shaders() -> void:
	print("Starting shader pre-warming...")
	for scene_path in SHADER_PREWARM_SCENES:
		var instance = load(scene_path).instantiate()
		
		# Add the object to our off-screen viewport.
		prewarm_viewport.add_child(instance)
		
		# CRITICAL STEP: Wait for the next frame. This gives the rendering server
		# time to process the new object and compile its shader if it hasn't already.
		await get_tree().process_frame
		
		# Now that the shader is compiled and cached by the engine,
		# we can safely remove the temporary instance.
		instance.queue_free()
	
	print("Shader pre-warming complete.")