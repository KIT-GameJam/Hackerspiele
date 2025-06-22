shader_type spatial;
render_mode cull_front, unshaded;

uniform vec3 color : source_color = vec3(0, 0, 0);
uniform float thickness : hint_range(0.0, 1.0, 0.01) = 0.0;

void vertex() {
	VERTEX *= 1.0 + thickness;
}

void fragment() {
	ALBEDO = color;
}
