# tools/fx_playground.gd
@tool
extends Control

@export var _hit_flash_effect: ShaderEffect
@export var _dissolve_effect: ShaderEffect

@onready var test_subject: ColorRect = %TestSubject
@onready var fx_component: FXComponent = %TestSubject/FXComponent


func _ready() -> void:
	if not Engine.is_editor_hint():
		# When running the scene, the ServiceLocator autoload is
		# available globally. We must provide it to the component's setup
		# method to satisfy its dependency contract.
		var dependencies = {
			"visual_node": test_subject,
			"fx_manager": ServiceLocator.fx_manager,
			"hit_effect": _hit_flash_effect # Provide a default hit effect
		}
		fx_component.setup(test_subject, dependencies)
		test_subject.visible = true


func _on_button_red_pressed() -> void:
	if not is_instance_valid(_hit_flash_effect):
		print("ERROR: No Hit Flash ShaderEffect resource assigned.")
		return
	test_subject.visible = true
	fx_component.play_effect(_hit_flash_effect)


func _on_button_blue_pressed() -> void:
	if not is_instance_valid(_hit_flash_effect):
		print("ERROR: No Hit Flash ShaderEffect resource assigned.")
		return

	test_subject.visible = true
	var overrides = {"tint_color": Color.BLUE}
	fx_component.play_effect(_hit_flash_effect, overrides)


func _on_button_dissolve_pressed() -> void:
	if not is_instance_valid(_dissolve_effect):
		print("ERROR: No Dissolve ShaderEffect resource assigned.")
		return

	test_subject.visible = true
	if test_subject.material:
		test_subject.material = null

	var effect_tween: Tween = fx_component.play_effect(_dissolve_effect)
	if is_instance_valid(effect_tween):
		await effect_tween.finished
		# After dissolving, make the subject invisible but still present.
		test_subject.visible = false
