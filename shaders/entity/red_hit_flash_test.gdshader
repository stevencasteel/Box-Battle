// shaders/entity/red_hit_flash_test.gdshader
shader_type canvas_item;

uniform vec4 tint_color : source_color = vec4(1.0, 0.0, 0.0, 1.0);
// The effect's progress, from 0.0 (start) to 1.0 (end).
uniform float fx_progress : hint_range(0.0, 1.0);

void fragment() {
    // Get the base color from the ColorRect
    vec4 original_color = COLOR;
    
    // As fx_progress goes from 0 to 1, intensity goes from 1 to 0.
    float intensity = 1.0 - fx_progress;
    
    // Mix the original color with the tint color
    vec3 mixed_rgb = mix(original_color.rgb, tint_color.rgb, intensity);
    
    // Apply the mixed color, preserving the original alpha
    COLOR = vec4(mixed_rgb, original_color.a);
}