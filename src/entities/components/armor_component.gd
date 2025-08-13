# src/entities/components/armor_component.gd
#
# A simple component that manages an "armored" state. When active, it can
# be queried by other components (like HealthComponent) to determine if
# damage should be ignored.
class_name ArmorComponent
extends ComponentInterface

var is_armored: bool = false

func setup(_p_owner: Node, _p_dependencies: Dictionary = {}) -> void:
	# This component currently requires no setup.
	pass

func teardown() -> void:
	# This component holds no references, so no teardown is needed.
	pass

func activate():
	is_armored = true

func deactivate():
	is_armored = false