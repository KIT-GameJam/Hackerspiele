shader_type canvas_item;

uniform vec2 pos;

void fragment() {
	if (distance(pos, VERTEX) >= 80.0) discard;
}
