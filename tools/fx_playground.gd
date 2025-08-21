# tools/fx_playground.gd
@tool
extends Control

@export var _hit_flash_effect: ShaderEffect

@onready var test_subject: ColorRect = %TestSubject
@onready var fx_component: FXComponent = %TestSubject/FXComponent

func _ready() -> void:
	if not Engine.is_editor_hint():
		fx_component.setup(test_subject, {"visual_node": test_subject})

func _on_button_red_pressed() -> void:
	if not is_instance_valid(_hit_flash_effect):
		print("ERROR: No ShaderEffect resource assigned or could not be loaded.")
		return
	# Call with no overrides to test the default behavior.
	fx_component.play_effect(_hit_flash_effect)

func _on_button_blue_pressed() -> void:
	if not is_instance_valid(_hit_flash_effect):
		print("ERROR: No ShaderEffect resource assigned or could not be loaded.")
		return
	
	# Create the overrides dictionary.
	var overrides = {"tint_color": Color.BLUE}
	# Pass the overrides to the play_effect method.
	fx_component.play_effect(_hit_flash_effect, overrides)
	print("VERIFICATION: Played effect with BLUE override.")
