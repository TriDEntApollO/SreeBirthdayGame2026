shader_type canvas_item;

uniform float shear : hint_range(-1.0, 1.0) = 0.2;

void fragment() {
    vec2 uv = UV;

    uv.y -= (0.5 - uv.y) * shear;

    if (uv.x < 0.0 || uv.x > 1.0) {
        COLOR = vec4(0.0);
    } else {
        COLOR = texture(TEXTURE, uv);
    }
}