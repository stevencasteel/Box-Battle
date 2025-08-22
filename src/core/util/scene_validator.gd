# src/core/util/scene_validator.gd
@tool
## A central utility for validating scene configurations in the editor.
##
## Its functions are static, allowing them to be called from any @tool script
## to provide configuration warnings in the Godot editor.
class_name SceneValidator
extends Object

# --- Static Validation Functions ---


## Validates a node to ensure it meets the BaseBoss contract.
static func validate_boss_scene(node: Node) -> PackedStringArray:
	var warnings = PackedStringArray()

	if not node.has_node("HealthComponent"):
		warnings.append("A HealthComponent node is required.")
	if not node.has_node("StateMachine"):
		warnings.append("A StateMachine node is required.")
	if not node.has_node("ArmorComponent"):
		warnings.append("An ArmorComponent node is required.")

	if node.get("phase_1_patterns") == null or node.get("phase_1_patterns").is_empty():
		warnings.append(
			"Phase 1 has no attack patterns assigned. The boss will be unable to attack."
		)

	return warnings
