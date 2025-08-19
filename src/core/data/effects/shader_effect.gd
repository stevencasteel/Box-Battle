# src/core/data/effects/shader_effect.gd
@tool
## A data resource that defines a "recipe" for a shader-based visual effect.
##
## This allows the FXManager to treat shaders as reusable, configurable assets,
## just like particle effects or screen shakes.
class_name ShaderEffect
extends Resource

## The scope determines where the shader will be applied.
enum TargetScope {
	ENTITY,     # Applied to a single entity's visual node.
	UI,         # Applied to a single UI control.
	FULLSCREEN  # Applied to the entire screen.
}

# --- Editor Properties ---
## The actual shader code to be applied.
@export var shader: Shader

## The duration of the effect in seconds. A value of 0 means it runs indefinitely
## until manually stopped.
@export var duration: float = 0.15

## A priority level to resolve conflicts if multiple effects are triggered at once.
## Higher numbers have higher priority.
@export var priority: int = 0

## The target scope for this effect.
@export var target_scope: TargetScope = TargetScope.ENTITY

## A dictionary of uniform parameters to be passed to the shader.
## Example: { "intensity": 1.0, "tint_color": Color.RED }
@export var params: Dictionary = {}