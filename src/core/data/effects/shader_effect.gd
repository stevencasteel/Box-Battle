# src/core/data/effects/shader_effect.gd
@tool
## A data resource that defines a "recipe" for a shader-based visual effect.
##
## This allows the FXManager to treat shaders as reusable, configurable assets,
## just like particle effects or screen shakes.
class_name ShaderEffect
extends Resource

## The scope determines where the shader will be applied.
enum TargetScope { ENTITY, UI, FULLSCREEN }  # Applied to a single entity's visual node.  # Applied to a single UI control.  # Applied to the entire screen.

# --- Editor Properties ---
@export_group("Configuration")
## The actual ShaderMaterial resource to be applied.
@export var material: ShaderMaterial

## The duration of the effect in seconds. A value of 0 means it runs indefinitely
## until manually stopped.
@export_range(0.0, 5.0, 0.01) var duration: float = 0.15

## A dictionary of uniform parameters to be passed to the shader.
## Example: { "intensity": 1.0, "tint_color": Color.RED }
@export var params: Dictionary = {}

@export_group("Behavior")
## The target scope for this effect.
@export var target_scope: TargetScope = TargetScope.ENTITY

## A priority level to resolve conflicts if multiple effects are triggered at once.
## Higher numbers have higher priority.
@export var priority: int = 0

@export_group("Performance")
## Minimum time in seconds before this effect can be triggered again on the same target.
## A value of 0 disables coalescing.
@export_range(0.0, 1.0, 0.01) var coalesce_window: float = 0.1
