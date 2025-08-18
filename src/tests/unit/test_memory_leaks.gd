# src/tests/unit/test_memory_leaks.gd
extends GutTest

const PlayerScene = preload("res://src/entities/player/player.tscn")

# This test verifies that instantiating and freeing the Player scene does not
# result in a net increase of objects in memory.
func test_player_scene_does_not_leak_objects_on_free():
	await get_tree().process_frame
	var pre_count = Performance.get_monitor(Performance.OBJECT_COUNT)

	var player = PlayerScene.instantiate()
	add_child(player)
	await get_tree().process_frame

	# THE FIX: Explicitly call the player's own public teardown method before freeing.
	player.teardown()
	player.free()
	await get_tree().process_frame

	var post_count = Performance.get_monitor(Performance.OBJECT_COUNT)
	assert_eq(post_count, pre_count, "Object count should return to baseline after freeing the player. If not, a leak has occurred in Player.gd's cleanup.")