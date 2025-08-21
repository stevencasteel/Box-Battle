# tools/fx_playground.gd
@tool
extends Control

# This is now exported as our custom type. Godot's loader handles everything.
@export var _hit_flash_effect: ShaderEffect

@onready var test_subject: ColorRect = %TestSubject

var _active_tween: Tween

# A proxy property for the tween to animate.
var _intensity: float = 0.0:
	set(value):
		_intensity = value
		if is_instance_valid(test_subject) and is_instance_valid(test_subject.material):
			test_subject.material.set_shader_parameter("intensity", _intensity)

func _on_button_pressed() -> void:
	if not is_instance_valid(_hit_flash_effect):
		print("ERROR: No ShaderEffect resource assigned or could not be loaded.")
		return
	
	_play_effect(_hit_flash_effect)

func _play_effect(effect: ShaderEffect) -> void:
	if not is_instance_valid(effect.material):
		push_error("Effect is missing a material.")
		return
		
	if is_instance_valid(_active_tween):
		_active_tween.kill()

	# In a real scenario, FXComponent would manage this. Here, we do it directly.
	var material_instance = effect.material.duplicate(true)
	test_subject.material = material_instance
	
	self._intensity = 1.0
	
	_active_tween = create_tween()
	_active_tween.tween_property(self, "_intensity", 0.0, effect.duration)
	_active_tween.finished.connect(func(): test_subject.material = null)
	
	print("Played hit-flash effect!") # VERIFICATION
