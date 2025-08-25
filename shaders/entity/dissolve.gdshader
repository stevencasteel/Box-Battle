// shaders/entity/dissolve.gdshader
shader_type canvas_item;

uniform sampler2D noise_texture;
uniform float fx_progress : hint_range(0.0, 1.0);
uniform vec4 border_color : source_color = vec4(1.0, 1.0, 1.0, 1.0);
uniform float border_width : hint_range(0.0, 0.1) = 0.02;

void fragment() {
	vec4 original_color = COLOR;
	// Sample the noise texture using screen-space UVs, which are
	// always available, instead of local UVs, which Polygon2D does not have.
	float noise_value = texture(noise_texture, SCREEN_UV).r;

	if (noise_value < fx_progress) {
		discard;
	} else if (noise_value < fx_progress + border_width) {
		COLOR = border_color;
	} else {
		COLOR = original_color;
	}
}