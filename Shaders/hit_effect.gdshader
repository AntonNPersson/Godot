shader_type canvas_item;

uniform vec4 hit_effect_color : source_color = vec4(1.0, 0.0, 0.0, 1.0);
uniform float hit_effect_intensity : hint_range(0.0, 1.0) = 0.0;
uniform float outline_intensity : hint_range(0.0, 1.0) = 0.0;
uniform float outline_size : hint_range(0.0, 0.1) = 0.05;
uniform vec4 outline_color : source_color = vec4(0.0, 0.0, 0.0, 1.0);

void fragment() {
	// Sample the original texture color
	vec4 original_color = texture(TEXTURE, UV);

	// Calculate outline
	vec4 outline = vec4(0.0, 0.0, 0.0, 0.0);
	if (outline_intensity > 0.0) {
		vec2 texel_size = vec2(1.0 / TEXTURE_PIXEL_SIZE.x, 1.0 / TEXTURE_PIXEL_SIZE.y);
		for (float x = -outline_size; x <= outline_size; x += texel_size.x) {
			for (float y = -outline_size; y <= outline_size; y += texel_size.y) {
				vec4 sample_color = texture(TEXTURE, UV + vec2(x, y));
				float alpha = sample_color.a;
				outline += (1.0 - alpha) * outline_color;
			}
		}
	}

	// Apply hit effect
	vec4 final_color = original_color;
	if (hit_effect_intensity > 0.0) {
		// Calculate the red tint color
		vec4 red_tint = vec4(hit_effect_color.x, hit_effect_color.y, hit_effect_color.z, original_color.a);

		// Blend the original color with the red tint based on hit effect intensity
		final_color = mix(original_color, red_tint, hit_effect_intensity);
	}

	// Combine hit effect and outline
	COLOR = final_color + outline;
}
