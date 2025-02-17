shader_type canvas_item;

uniform float intensity : hint_range(0.0, 1.0) = 0.8; // Darkness intensity
uniform float radius : hint_range(0.0, 1.0) = 0.5; // Size of the bright center
uniform float softness : hint_range(0.0, 1.0) = 0.3; // Edge smoothness

void fragment() {
    vec2 uv = SCREEN_UV;
    vec2 center = vec2(0.5, 0.5); // Screen center

    // Distance from the center
    float dist = distance(uv, center);
    
    // Smooth vignette effect
    float vignette = smoothstep(radius, radius + softness, dist);
    
    // Blend with darkness
    vec3 color = vec3(0.0);
    COLOR = vec4(color, vignette * intensity);
}
