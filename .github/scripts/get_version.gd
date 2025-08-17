# .github/scripts/get_version.gd
# This script runs in the CI environment to get the version
# from project.godot and print it to the command line.
extends SceneTree

func _init():
    var version = ProjectSettings.get_setting("application/config/version")
    print(version)
    quit()