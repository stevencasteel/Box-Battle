# src/core/builders/encounter_director.gd
#
# Responsibility: To spawn all dynamic entities (Player, Boss, HUD) based on
# the parsed LevelBuildData.
class_name EncounterDirector
extends RefCounted

# The main public method. It takes the parent node, the data, and a valid
# SceneTree reference, then spawns the entities asynchronously.
func spawn_entities_async(parent_node: Node, build_data: LevelBuildData, tree: SceneTree) -> void:
	await _spawn_player_async(parent_node, build_data.player_spawn_pos, tree)
	await _spawn_boss_async(parent_node, build_data.boss_spawn_pos, build_data.encounter_script_object, tree)
	await _spawn_hud_async(parent_node, tree)

# --- Entity Spawning Functions (Moved from ArenaBuilder) ---

func _spawn_player_async(parent_node: Node, pos: Vector2, tree: SceneTree):
	var player_instance = load(AssetPaths.SCENE_PLAYER).instantiate()
	player_instance.global_position = pos
	parent_node.add_child(player_instance)
	await tree.process_frame

func _spawn_boss_async(parent_node: Node, pos: Vector2, encounter: Object, tree: SceneTree):
	var boss_scene: PackedScene = encounter.BOSS_SCENE if encounter else null
	if not boss_scene:
		push_error("EncounterDirector: Could not find BOSS_SCENE in encounter script.")
		return
		
	var boss_instance = boss_scene.instantiate()
	boss_instance.global_position = pos
	parent_node.add_child(boss_instance)
	await tree.process_frame

func _spawn_hud_async(parent_node: Node, tree: SceneTree):
	var hud_instance = load(AssetPaths.SCENE_GAME_HUD).instantiate()
	parent_node.add_child(hud_instance)
	await tree.process_frame