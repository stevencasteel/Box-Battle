# src/core/util/dependency_validator.gd
## A stateless utility for validating component dependencies at runtime.
class_name DependencyValidator
extends RefCounted

## Validates that a dictionary of dependencies contains a set of required keys.
## If a key is missing, it pushes a descriptive error.
## Returns 'true' if validation passes, 'false' otherwise.
static func validate(component: IComponent, dependencies: Dictionary, required_keys: Array[String]) -> bool:
	var component_script_path = component.get_script().resource_path
	var component_name = component_script_path.get_file()

	for key in required_keys:
		if not dependencies.has(key):
			var error_msg = "Component '%s' is missing required dependency: '%s'" % [component_name, key]
			push_error(error_msg)
			return false
	return true
