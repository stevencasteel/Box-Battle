# src/scenes/loading/loading_screen.gd
## Handles asynchronous level building and shader pre-warming.
##
## This scene acts as an intermediary to prevent stuttering. It first builds
## the level in batches, then pre-instantiates key entities in an off-screen
## viewport to force shader compilation before transitioning to the game scene.
extends Control

# --- Constants ---
const SHADER_PREWARM_SCENES = [
	AssetPaths.SCENE_PLAYER,
	AssetPaths.SCENE_BASE_BOSS,
	AssetPaths.SCENE_PLAYER_SHOT,
	AssetPaths.SCENE_BOSS_SHOT,
	AssetPaths.SCENE_TURRET_SHOT,
	AssetPaths.SCENE_HOMING_BOSS_SHOT,
]

# --- Node References ---
@onready var prewarm_viewport: SubViewport = $ShaderPrewarmViewport/SubViewport

# --- Godot Lifecycle Methods ---

func _ready() -> void:
	if GameManager.state.current_encounter_path.is_empty():
		print("ERROR: No encounter script specified in GameManager. Returning to title.")
		SceneManager.go_to_scene(AssetPaths.SCENE_TITLE_SCREEN)
		return

	_load_level()

# --- Private Methods ---

## The main loading and pre-warming sequence.
func _load_level() -> void:
	await get_tree().process_frame # Wait one frame for UI to draw "Loading..."

	await _prewarm_shaders()

	# THE FIX: Create the typed array locally using load() to ensure correct type resolution.
	var effects_to_prewarm: Array[ShaderEffect] = [
		load("res://src/data/effects/entity_hit_flash_effect.tres"),
		load("res://src/core/data/effects/dissolve_effect.tres"),
	]
	await FXManager.prewarm_shaders_async(effects_to_prewarm, prewarm_viewport)


	# Build the level and store the resulting node in the GameManager state.
	GameManager.state.prebuilt_level = await ArenaBuilder.build_level_async()

	await get_tree().process_frame # Wait one more frame for safety.

	SceneManager.go_to_scene(AssetPaths.SCENE_ENCOUNTER)

## Instantiates scenes off-screen to compile their shaders.
func _prewarm_shaders() -> void:
	print("Starting shader pre-warming...")
	for scene_path in SHADER_PREWARM_SCENES:
		if not FileAccess.file_exists(scene_path): continue
		var instance = load(scene_path).instantiate()
		
		if instance.has_method("inject_dependencies"):
			var deps = {
				"object_pool": ObjectPool,
				"fx_manager": FXManager,
				"event_bus": EventBus,
			}
			instance.inject_dependencies(deps)
		
		prewarm_viewport.add_child(instance)
		
		# --- Trigger Actions to Compile More Shaders ---
		if instance is Player:
			instance.velocity.x = 100
			if is_instance_valid(instance.state_machine) and instance.state_machine.has_method("change_state"):
				instance.state_machine.change_state(instance.State.ATTACK)
		elif instance is BaseBoss:
			instance.velocity.x = 100

		await get_tree().process_frame
		instance.queue_free()
	print("Shader pre-warming complete.")