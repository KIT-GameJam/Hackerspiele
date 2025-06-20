shader_type canvas_item;

uniform float stripe_size = 100.0;
uniform float speed = 1.2;
uniform vec4 stripe1: source_color = vec4(1.0, 0.0, 0.0, 1.0);
uniform vec4 stripe2: source_color = vec4(0.0, 1.0, 0.0, 1.0);
uniform float rotation = 0.0;

const float FEATHER = 0.02;

void fragment() {
	vec2 sc = vec2(sin(rotation), cos(rotation));
	vec2 uv = mat2(sc, sc.yx) * UV.xy;
	float val = sin(uv.x * stripe_size + TIME * speed);
	val = clamp(val / length(SCREEN_PIXEL_SIZE) * FEATHER, -1.0, 1.0);
	COLOR = mix(stripe1, stripe2, val * 0.5 + 0.5);
}