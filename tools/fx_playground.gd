# tools/fx_playground.gd
@tool
extends Control

@export var _hit_flash_effect: ShaderEffect

@onready var test_subject: ColorRect = %TestSubject
@onready var fx_component: FXComponent = %TestSubject/FXComponent

func _ready() -> void:
	if not Engine.is_editor_hint():
		# In a real game, the entity owner (Player, Boss) would do this.
		# Here, the playground itself is the owner.
		fx_component.setup(test_subject, {"visual_node": test_subject})

func _on_button_pressed() -> void:
	if not is_instance_valid(_hit_flash_effect):
		print("ERROR: No ShaderEffect resource assigned or could not be loaded.")
		return
	
	# The playground's only job is to tell the component to play the effect.
	fx_component.play_effect(_hit_flash_effect)
	print("Requested FXComponent to play hit-flash effect!") # VERIFICATION
