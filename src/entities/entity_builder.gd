# src/entities/entity_builder.gd
## A stateless utility responsible for the construction and dependency wiring
## of all component-based entities. This separates the "setup" logic from
## the entity's "runtime" logic.
class_name EntityBuilder
extends RefCounted

## The main entry point. Takes a freshly instantiated entity and performs
## all necessary component setup and signal wiring.
static func build(entity: BaseEntity) -> void:
	if entity is Player:
		_build_player(entity)
	elif entity is BaseBoss:
		_build_boss(entity)
	elif entity is Minion:
		_build_minion(entity)
	else:
		push_warning("EntityBuilder: No build logic found for entity type: %s" % entity)

# --- Private Builder Methods ---

static func _build_player(player: Player) -> void:
	# --- Logic from _initialize_and_setup_components ---
	player.entity_data = PlayerStateData.new()
	assert(is_instance_valid(player._services), "Player requires a ServiceLocator.")
	player.entity_data.config = player._services.combat_config

	var hc: HealthComponent = player.get_component(HealthComponent)
	var sm: BaseStateMachine = player.get_component(BaseStateMachine)

	var shared_deps := {"data_resource": player.entity_data, "config": player.entity_data.config}

	var states: Dictionary = {
		Identifiers.PlayerStates.MOVE: player.state_move_script.new(player, sm, player.entity_data),
		Identifiers.PlayerStates.FALL: player.state_fall_script.new(player, sm, player.entity_data),
		Identifiers.PlayerStates.JUMP: player.state_jump_script.new(player, sm, player.entity_data),
		Identifiers.PlayerStates.DASH: player.state_dash_script.new(player, sm, player.entity_data),
		Identifiers.PlayerStates.WALL_SLIDE: player.state_wall_slide_script.new(player, sm, player.entity_data),
		Identifiers.PlayerStates.ATTACK: player.state_attack_script.new(player, sm, player.entity_data),
		Identifiers.PlayerStates.HURT: player.state_hurt_script.new(player, sm, player.entity_data),
		Identifiers.PlayerStates.HEAL: player.state_heal_script.new(player, sm, player.entity_data),
		# THE FIX: This line was missing.
		Identifiers.PlayerStates.POGO: player.state_pogo_script.new(player, sm, player.entity_data),
	}

	var per_component_deps := {
		sm: {"states": states, "initial_state_key": Identifiers.PlayerStates.FALL},
		player.get_component(FXComponent): {"visual_node": player.visual_sprite, "hit_effect": player.hit_flash_effect},
		hc: {"hit_spark_effect": player.hit_spark_effect}
	}

	player.setup_components(shared_deps, per_component_deps)

	# --- Logic from _connect_signals ---
	player.melee_hitbox.body_entered.connect(player._on_melee_hitbox_body_entered)
	player.pogo_hitbox.body_entered.connect(player._on_pogo_hitbox_body_entered)
	player.melee_hitbox.area_entered.connect(player._on_hitbox_area_entered)
	player.pogo_hitbox.area_entered.connect(player._on_hitbox_area_entered)
	player.hurtbox.area_entered.connect(player._on_hurtbox_area_entered)

	hc.health_changed.connect(player._on_health_component_health_changed)
	hc.died.connect(player._on_health_component_died)

	var cc: CombatComponent = player.get_component(CombatComponent)
	var rc: PlayerResourceComponent = player.get_component(PlayerResourceComponent)
	cc.damage_dealt.connect(rc.on_damage_dealt)
	cc.pogo_bounce_requested.connect(player._on_pogo_bounce_requested)

	sm.melee_hitbox_toggled.connect(player._enable_melee_hitbox)
	sm.pogo_hitbox_toggled.connect(player._enable_pogo_hitbox)

	player.healing_timer.timeout.connect(player._on_healing_timer_timeout)


static func _build_boss(boss: BaseBoss) -> void:
	var hc: HealthComponent = boss.get_component(HealthComponent)
	var sm: BaseStateMachine = boss.get_component(BaseStateMachine)
	var fc: FXComponent = boss.get_component(FXComponent)

	var shared_deps := {"data_resource": boss.entity_data, "config": boss.entity_data.config}

	var states: Dictionary = {
		Identifiers.BossStates.IDLE: boss.state_idle_script.new(boss, sm, boss.entity_data),
		Identifiers.BossStates.ATTACK: boss.state_attack_script.new(boss, sm, boss.entity_data),
		Identifiers.BossStates.COOLDOWN: boss.state_cooldown_script.new(boss, sm, boss.entity_data),
		Identifiers.BossStates.PATROL: boss.state_patrol_script.new(boss, sm, boss.entity_data),
		Identifiers.BossStates.LUNGE: boss.state_lunge_script.new(boss, sm, boss.entity_data),
	}

	var per_component_deps := {
		sm: {"states": states, "initial_state_key": Identifiers.BossStates.COOLDOWN},
		fc: {"visual_node": boss.visual_sprite, "hit_effect": boss.hit_flash_effect},
		hc: {"hit_spark_effect": boss.hit_spark_effect}
	}

	boss.setup_components(shared_deps, per_component_deps)

	hc.health_changed.connect(boss._on_health_component_health_changed)
	hc.died.connect(boss._on_health_component_died)
	hc.health_threshold_reached.connect(boss._on_health_threshold_reached)


static func _build_minion(minion: Minion) -> void:
	var circle_shape := CircleShape2D.new()
	circle_shape.radius = minion.entity_data.behavior.detection_radius
	minion.range_detector_shape.shape = circle_shape

	var hc: HealthComponent = minion.get_component(HealthComponent)
	var sm: BaseStateMachine = minion.get_component(BaseStateMachine)
	var fc: FXComponent = minion.get_component(FXComponent)

	var shared_deps := {
		"data_resource": minion.entity_data,
		"config": minion._services.combat_config
	}

	var states: Dictionary = {
		Identifiers.MinionStates.IDLE:
		load("res://src/entities/minions/states/state_minion_idle.gd").new(minion, sm, minion.entity_data),
		Identifiers.MinionStates.ATTACK:
		load("res://src/entities/minions/states/state_minion_attack.gd").new(minion, sm, minion.entity_data),
		Identifiers.MinionStates.FALL:
		load("res://src/entities/states/state_entity_fall.gd").new(minion, sm, minion.entity_data),
	}

	var per_component_deps := {
		sm: {"states": states, "initial_state_key": minion.entity_data.behavior.initial_state_key},
		fc: {"visual_node": minion.visual, "hit_effect": minion.hit_flash_effect},
		hc: {"hit_spark_effect": minion.hit_spark_effect}
	}

	minion.setup_components(shared_deps, per_component_deps)
	
	hc.died.connect(minion._on_health_component_died)