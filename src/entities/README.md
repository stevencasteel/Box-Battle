Entities: how to add components & states
=======================================

Purpose
-------
Explain the minimal conventions for adding new components and states to the entity system.

Component contract (example)
----------------------------
Create components by extending the ComponentInterface base. Keep them small and single-purpose.

Example components (GDScript):

# res://src/entities/ComponentInterface.gd
extends Node2D
class_name ComponentInterface

# Called once when the entity or builder attaches the component.
func setup(config: Dictionary) -> void:
    pass

# Called when the component or entity is being destroyed / swapped.
func teardown() -> void:
    pass

# Example concrete component: HealthComponent
# res://src/entities/components/HealthComponent.gd
extends ComponentInterface
class_name HealthComponent

@export var max_hp: int = 100
var hp: int = 100

func setup(config: Dictionary) -> void:
    if config.has("max_hp"):
        max_hp = int(config["max_hp"])
    hp = max_hp

func receive_damage(amount: int) -> void:
    hp -= amount
    if hp <= 0:
        _on_dead()

func _on_dead() -> void:
    # notify EventBus / play death FX via ObjectPool
    EventBus.emit("entity_dead", { "entity": get_parent() })
    queue_free()

State machine (example)
-----------------------
BaseState provides enter/exit and processing hooks. States are swapped by the entity's BaseStateMachine.

# res://src/core/BaseState.gd
extends Node
class_name BaseState

func enter(data = null) -> void: pass
func exit() -> void: pass
func physics_process(delta: float) -> void: pass

# res://src/core/BaseStateMachine.gd
extends Node
class_name BaseStateMachine

var current_state: BaseState = null

func change_state(new_state: BaseState, data = null) -> void:
    if current_state:
        current_state.exit()
        current_state.queue_free() # if state is a node instance
    current_state = new_state
    add_child(current_state)
    current_state.enter(data)

Best practices
--------------
- Keep state logic deterministic; side-effects should be limited and explicit.
- Components must clean themselves up in `teardown()` (disconnect signals, stop timers).
- Use the `EventBus` for cross-system signals rather than global references.
- Store tunable numbers in `.tres` resources and refer to them in `setup()`.

Example workflow to add a component
----------------------------------
1. Create `res://src/entities/components/MyComponent.gd` extending `ComponentInterface`.
2. Expose tuning via `@export` variables or read from a provided config dictionary in `setup()`.
3. Add the component as a child to the entity scene or let entity builder attach it at spawn time.
4. Ensure `teardown()` reverses all runtime connections.

