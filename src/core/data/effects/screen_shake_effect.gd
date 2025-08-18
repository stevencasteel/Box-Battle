# src/core/data/effects/screen_shake_effect.gd
@tool
## A data resource that defines the properties of a screen shake effect.
##
## This allows for the creation of reusable, designer-tunable shake assets.
class_name ScreenShakeEffect
extends Resource

## The maximum offset in pixels. Higher values create a more intense shake.
@export_range(0.0, 100.0, 1.0) var amplitude: float = 10.0

## The speed of the shake. Higher values create a more frantic shake.
@export_range(0.1, 50.0, 0.1) var frequency: float = 15.0

## The total duration of the shake effect in seconds.
@export_range(0.1, 5.0, 0.05) var duration: float = 0.5