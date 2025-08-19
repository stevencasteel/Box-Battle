shader_type canvas_item;

// The color to flash.
uniform vec4 tint_color : source_color = vec4(1.0, 1.0, 1.0, 1.0);
// The strength/alpha of the flash.
uniform float intensity : hint_range(0.0, 1.0) = 0.0;

void fragment() {
	// Directly output the tint color, using intensity to control the alpha.
	// This avoids any complex mixing and guarantees a visible result.
	COLOR = vec4(tint_color.rgb, tint_color.a * intensity);
}