shader_type canvas_item;

instance uniform vec4 line_color : source_color = vec4(1.0, 1.0, 1.0, 1.0);
instance uniform float line_thickness : hint_range(0, 10) = 1.0;
instance uniform bool outline_enabled = false;

const vec2 OFFSETS[8] = {
	vec2(-1, -1), vec2(-1, 0), vec2(-1, 1),
	vec2(0, -1), vec2(0, 1),
	vec2(1, -1), vec2(1, 0), vec2(1, 1)
};

void fragment() {
	float alpha = COLOR.a;
	vec4 texture_color = texture(TEXTURE, UV);

	vec2 size = TEXTURE_PIXEL_SIZE * line_thickness;
	float outline = 0.0;

	for (int i = 0; i < OFFSETS.length(); i++) {
		outline += texture(TEXTURE, UV + size * OFFSETS[i]).a;
	}

	outline = min(outline, 1.0);

	// Pixels outside the sprite but next to it.
	float outline_mask = (1.0 - texture_color.a) * outline;
	outline_mask *= float(outline_enabled);

	if (outline_mask > 0.0) {
		COLOR = line_color;
	}

	// Draw the sprite.
	COLOR = texture_color;
	COLOR.a = alpha;

	// Draw the outline independently.
	COLOR = mix(COLOR, line_color, outline_mask);
}