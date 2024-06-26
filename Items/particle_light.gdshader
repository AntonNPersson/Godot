shader_type canvas_item;

uniform float radius = 50.0; // how far the rim light should go
uniform float intensity = 2.0; // how bright the rim light should be compared to the light source
uniform int accuracy: hint_range(4, 256) = 32; // set it higher for better appearance but worse performance, should be at least 4

void light() {
	vec4 light = texture(TEXTURE, UV);
	vec2 size = TEXTURE_PIXEL_SIZE * radius;
	
	float min_dist = max(size.x, size.y);
	float alpha = 0.0;
	
	bool found_alpha = false;
	// the goal is to find the nearest pixel where the alpha is 0, which should be the edge of the sprite
	// iterate through each circle size, starting with the largest, since most of the checks will be in the middle of the sprite, this will end the checks early for those pixels
	for(float current_radius = max(size.x, size.y); current_radius > 0.0; current_radius -= min(TEXTURE_PIXEL_SIZE.x, TEXTURE_PIXEL_SIZE.y)){
		// check each angle of the circle
		// start angle is toward the edges of the image, this assumes the sprite occupies mostly the center of the image and the edges are transparent, for minimizing the number of pixels to check
		float start_angle = atan(light.y / light.x);
		for(float rad = start_angle; rad < 2.0 * PI + start_angle; rad += (2.0 * PI) / float(accuracy)){
			float x = cos(rad) * current_radius;
			float y = sin(rad) * current_radius;
			
			alpha = texture(TEXTURE, UV + vec2(x, y)).a;
			// if the nearest pixel with alpha 0 is found, end the search for this circle
			if(alpha == 0.0){
				min_dist = min(min_dist, sqrt(x*x + y*y));
				found_alpha = true;
				break;
			}
		}
		// if none of the pixels in the circle was transparent, exit the loop since there's no reason to keep checking
		if(!found_alpha) break;
	}

	float alpha_amount = clamp(1.0 - min_dist / min(size.x, size.y), 0.0, 1.0);
	LIGHT.a = light.a * intensity * alpha_amount;
}
