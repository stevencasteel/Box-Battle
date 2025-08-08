# src/core/builders/encounter_director.gd
#
# Responsibility: To spawn all dynamic entities (Player, Boss, HUD) and to
# direct the flow of the encounter, such as running an intro sequence.
class_name EncounterDirector
extends RefCounted

# --- Stored References ---
var _parent_node: Node
var _build_data: LevelBuildData
var _tree: SceneTree

# The main public method. It takes the parent node, the data, and a valid
# SceneTree reference, then spawns the entities asynchronously.
func spawn_entities_async(parent_node: Node, build_data: LevelBuildData, tree: SceneTree) -> void:
	# Store references for use in other functions
	_parent_node = parent_node
	_build_data = build_data
	_tree = tree

	# Spawn the essential non-sequenced entities first.
	await _spawn_player_async()
	await _spawn_hud_async()

	# Run the scripted intro sequence for the boss.
	await run_intro_sequence()


# --- Entity Spawning Functions ---

func _spawn_player_async() -> void:
	var player_instance = load(AssetPaths.SCENE_PLAYER).instantiate()
	player_instance.global_position = _build_data.player_spawn_pos
	_parent_node.add_child(player_instance)
	await _tree.process_frame

func _spawn_boss_async() -> Node:
	var boss_scene: PackedScene = _build_data.encounter_script_object.BOSS_SCENE if _build_data.encounter_script_object else null
	if not boss_scene:
		push_error("EncounterDirector: Could not find BOSS_SCENE in encounter script.")
		return null

	var boss_instance = boss_scene.instantiate()
	boss_instance.global_position = _build_data.boss_spawn_pos
	_parent_node.add_child(boss_instance)
	await _tree.process_frame
	return boss_instance

func _spawn_hud_async() -> void:
	var hud_instance = load(AssetPaths.SCENE_GAME_HUD).instantiate()
	_parent_node.add_child(hud_instance)
	await _tree.process_frame


# --- Sequencer Implementation ---

# Defines and runs the sequence for the boss's grand entrance.
func run_intro_sequence() -> void:
	# This sequence is a great example of the Sequencer's power.
	# It's a readable, step-by-step recipe for what should happen.
	var intro_steps = [
		# Step 1: Pause the game to build tension.
		{ "type": "emit", "event": EventCatalog.GAME_PAUSED },

		# Step 2: A short dramatic pause.
		{ "type": "wait", "duration": 0.5 },

		# Step 3: Spawn the boss entity into the world.
		# Note: We can't use "call" here because we need the boss node reference
		# for the next step. So we call our helper and await its completion.
	]

	# Run the first part of the sequence.
	await Sequencer.run_sequence(intro_steps)

	# Manually spawn the boss to get the node reference.
	# THE FIX IS HERE: Add an underscore to silence the UNUSED_VARIABLE warning.
	var _boss_node = await _spawn_boss_async()

	# Define the rest of the sequence. We will use the _boss_node variable later.
	var outro_steps = [
		# Step 4: Add a visual/audio cue here later (e.g., spawn VFX).
		# { "type": "call", "node": vfx_manager, "function": "spawn_effect", "args": ["boss_spawn", _boss_node.global_position] }

		# Step 5: Wait for the spawn effect to finish.
		{ "type": "wait", "duration": 1.0 },

		# Step 6: Resume the game.
		{ "type": "emit", "event": EventCatalog.GAME_RESUMED }
	]

	# Run the final part of the sequence.
	await Sequencer.run_sequence(outro_steps)
