# src/tests/integration/test_integration_combat_loop.gd
extends GutTest

# --- Test Internals ---
var _level_container: Node
var _player: Player
var _boss: BaseBoss
var _boss_health_changed_event_fired: bool = false
var _event_token: int

# --- Test Lifecycle ---

func before_each():
	_boss_health_changed_event_fired = false

	GameManager.state.current_encounter_path = AssetPaths.ENCOUNTER_00
	_level_container = await ArenaBuilder.build_level_async()
	add_child(_level_container)
	
	_player = _level_container.get_node("Player")
	_boss = _level_container.get_node("BaseBoss")
	
	_event_token = EventBus.on(EventCatalog.BOSS_HEALTH_CHANGED, Callable(self, "_on_boss_health_changed"))
	await get_tree().process_frame

func after_each():
	EventBus.off(_event_token)
	if is_instance_valid(_level_container):
		# Explicitly call teardown on both actors before freeing the container.
		# This is the correct pattern to prevent our known memory leak issues.
		if is_instance_valid(_player):
			_player.teardown()
		if is_instance_valid(_boss):
			_boss.teardown()
		_level_container.free()

# --- The Integration Test ---

func test_player_attack_damages_boss_and_fires_event():
	# 1. VERIFY SETUP
	assert_not_null(_player, "Player should be instanced in the scene.")
	assert_not_null(_boss, "Boss should be instanced in the scene.")
	var boss_health_comp: HealthComponent = _boss.get_node("HealthComponent")
	var initial_boss_health = boss_health_comp.entity_data.health
	
	# 2. POSITION ACTORS & WAIT FOR STABLE STATE
	_player.global_position = _boss.global_position + Vector2(-60, 0)
	_player.p_data.facing_direction = 1
	
	var wait_frames = 10
	for i in wait_frames:
		if _player.state_machine.current_state == _player.state_machine.states[_player.State.MOVE]:
			break
		await get_tree().physics_frame
	
	assert_eq(_player.state_machine.current_state, _player.state_machine.states[_player.State.MOVE], "Player must be in MOVE state before attacking.")
	
	# 3. SIMULATE INPUT & TIME
	# A melee attack requires a press and a quick release.
	Input.action_press("ui_attack")
	await get_tree().physics_frame # Wait one frame for the press to register
	Input.action_release("ui_attack")
	
	var simulation_frames = 30
	for i in simulation_frames:
		await get_tree().physics_frame
	
	# 4. ASSERT THE OUTCOME
	var final_boss_health = boss_health_comp.entity_data.health
	
	assert_lt(final_boss_health, initial_boss_health, "Boss health should be lower after being hit by a player melee attack.")
	assert_true(_boss_health_changed_event_fired, "A BOSS_HEALTH_CHANGED event should be emitted on the global EventBus.")
	
	assert_gt(_player.p_data.determination_counter, 0, "Player determination should increase after dealing damage.")

# --- EventBus Signal Handler ---

func _on_boss_health_changed(_payload):
	_boss_health_changed_event_fired = true