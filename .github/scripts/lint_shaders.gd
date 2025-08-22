# .github/scripts/lint_shaders.gd
## A command-line script to lint all .gdshader files in the project.
## It enforces project-specific best practices for shader development.
extends SceneTree

var _shader_files: Array[String] = []
var _error_count: int = 0


func _init() -> void:
	print("--- Running Shader Linter ---")
	_find_all_shaders("res://")
	_lint_files()

	if _error_count > 0:
		print("\nLinter FAILED: Found %d error(s)." % _error_count)
		quit(1)
	else:
		print("\nLinter PASSED: All shader files are compliant.")
		quit(0)


## Recursively finds all .gdshader files in the project.
func _find_all_shaders(path: String) -> void:
	var dir = DirAccess.open(path)
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			var full_path = path.path_join(file_name)
			if dir.current_is_dir() and file_name != "." and file_name != "..":
				_find_all_shaders(full_path)
			elif file_name.ends_with(".gdshader"):
				_shader_files.append(full_path)
			file_name = dir.get_next()


## Iterates through found shader files and applies linting rules.
func _lint_files() -> void:
	for file_path in _shader_files:
		var file = FileAccess.open(file_path, FileAccess.READ)
		if not is_instance_valid(file):
			_report_error(file_path, -1, "Could not open file.")
			continue

		var content = file.get_as_text()
		var lines = content.split("\n")

		_check_shader_type_present(file_path, content)
		_check_source_color_hints(file_path, lines)


## Linter Rule 1: Ensure 'shader_type' is declared.
func _check_shader_type_present(file_path: String, content: String) -> void:
	if not content.contains("shader_type"):
		_report_error(file_path, 1, "Missing required 'shader_type' declaration.")


## Linter Rule 2: Ensure color uniforms have ': source_color'.
func _check_source_color_hints(file_path: String, lines: Array[String]) -> void:
	for i in range(lines.size()):
		var line = lines[i].strip_edges()
		if line.begins_with("uniform vec4") and "color" in line.to_lower():
			if not line.contains(": source_color"):
				_report_error(
					file_path,
					i + 1,
					"Color uniform is missing ': source_color' hint. Line: '%s'" % line
				)


## Reports a formatted error message to the console.
func _report_error(file_path: String, line_num: int, message: String) -> void:
	_error_count += 1
	var line_str = "L%d" % line_num if line_num > 0 else "FILE"
	print("ERROR: %s:%s - %s" % [file_path, line_str, message])
