# src/core/systems/fx_bindings/entity_shader_binding.gd
## Manages the lifecycle of a temporary shader effect on a single entity.
##
## It safely applies a shader, animates its uniforms via a Tween, and ensures
## the entity's original material is restored when the effect is finished or
## the entity is destroyed. This node frees itself upon completion.
class_name EntityShaderBinding
extends Node

# --- Member Variables ---
var _target_node: CanvasItem
var _original_material: Material
var _shader_material: ShaderMaterial
var _tween: Tween

# --- Private Member Variables ---
# A proxy property that we will tween instead of the shader uniform directly.
var _current_intensity: float = 0.0:
	set(value):
		_current_intensity = value
		if is_instance_valid(_shader_material):
			_shader_material.set_shader_parameter("intensity", _current_intensity)

# --- Public Methods ---

## Applies the shader effect to the target node and starts the animation.
func apply_effect(p_target: CanvasItem, p_effect: ShaderEffect) -> void:
	self._target_node = p_target
	if not is_instance_valid(_target_node):
		queue_free()
		return

	# Safely store the original material.
	_original_material = _target_node.material
	
	_shader_material = ShaderMaterial.new()
	_shader_material.shader = p_effect.shader
	
	# THE FIX: Apply our new shader material.
	_target_node.material = _shader_material

	# Set initial values from the effect resource.
	for param_name in p_effect.params:
		if param_name == "intensity":
			self._current_intensity = p_effect.params[param_name]
		else:
			_shader_material.set_shader_parameter(param_name, p_effect.params[param_name])

	# Watch for the target being deleted to prevent material leaks.
	_target_node.tree_exiting.connect(_on_target_tree_exiting)

	# Animate the shader uniforms.
	_tween = create_tween()
	_tween.tween_property(self, "_current_intensity", 0.0, p_effect.duration)
	_tween.finished.connect(_on_tween_finished)

# --- Private Methods ---

## Restores the original material and cleans up the binding node.
func _cleanup() -> void:
	if is_instance_valid(_target_node):
		# Restore the original material.
		if _target_node.material == _shader_material:
			_target_node.material = _original_material
		if _target_node.tree_exiting.is_connected(_on_target_tree_exiting):
			_target_node.tree_exiting.disconnect(_on_target_tree_exiting)
	
	if is_instance_valid(_tween):
		_tween.kill()

	queue_free()

# --- Signal Handlers ---

func _on_tween_finished() -> void:
	_cleanup()

func _on_target_tree_exiting() -> void:
	# The target is being destroyed, so we must clean up immediately.
	_cleanup()