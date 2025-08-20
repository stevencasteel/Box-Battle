// shaders/entity/hit_flash.gdshader
shader_type canvas_item;

// The color to flash.
uniform vec4 tint_color : source_color = vec4(1.0, 0.0, 0.0, 1.0);
// The strength of the flash, from 0.0 (no flash) to 1.0 (full flash).
uniform float intensity : hint_range(0.0, 1.0) = 0.0;

void fragment() {
	// 1. Get the original color of the pixel from the texture.
	vec4 original_color = texture(TEXTURE, UV);
	
	// 2. Mix the original color with the tint color based on the intensity.
	// The mix() function performs a linear interpolation: mix(x, y, a) -> x*(1-a) + y*a
	vec3 final_rgb = mix(original_color.rgb, tint_color.rgb, intensity);
	
	// 3. Combine the final RGB with the ORIGINAL alpha channel. This is the fix.
	COLOR = vec4(final_rgb, original_color.a);
}