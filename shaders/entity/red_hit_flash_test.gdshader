// shaders/entity/red_hit_flash_test.gdshader
shader_type canvas_item;

uniform vec4 tint_color : source_color = vec4(1.0, 0.0, 0.0, 1.0);
uniform float intensity : hint_range(0.0, 1.0);

void fragment() {
    // Get the base color from the ColorRect
    vec4 original_color = COLOR;
    
    // Mix the original color with the tint color
    vec3 mixed_rgb = mix(original_color.rgb, tint_color.rgb, intensity);
    
    // Apply the mixed color, preserving the original alpha
    COLOR = vec4(mixed_rgb, original_color.a);
}