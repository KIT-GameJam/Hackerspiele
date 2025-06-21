shader_type canvas_item;

void vertex() {
	// Called for every vertex the material is visible on.
}
uniform float player_charge : hint_range(0, 1);
uniform vec3 color_base : source_color;
uniform vec3 color_charged : source_color;


// Color conversion functions from https://stackoverflow.com/a/47379071
// by "user128511" under CC BY-SA 4.0
const float Epsilon = 1e-10;
vec3 rgb2hcv(in vec3 RGB)
{
  // Based on work by Sam Hocevar and Emil Persson
  vec4 P = mix(vec4(RGB.bg, -1.0, 2.0/3.0), vec4(RGB.gb, 0.0, -1.0/3.0), step(RGB.b, RGB.g));
  vec4 Q = mix(vec4(P.xyw, RGB.r), vec4(RGB.r, P.yzx), step(P.x, RGB.r));
  float C = Q.x - min(Q.w, Q.y);
  float H = abs((Q.w - Q.y) / (6. * C + Epsilon) + Q.z);
  return vec3(H, C, Q.x);
}

vec3 rgb2hsl(in vec3 RGB)
{
  vec3 HCV = rgb2hcv(RGB);
  float L = HCV.z - HCV.y * 0.5;
  float S = HCV.y / (1. - abs(L * 2. - 1.) + Epsilon);
  return vec3(HCV.x, S, L);
}

vec3 hsl2rgb(vec3 c)
{
  c = vec3(fract(c.x), clamp(c.yz, 0.0, 1.0));
  vec3 rgb = clamp(abs(mod(c.x * 6.0 + vec3(0.0, 4.0, 2.0), 6.0) - 3.0) - 1.0, 0.0, 1.0);
  return c.z + c.y * (rgb - 0.5) * (1.0 - abs(2.0 * c.z - 1.0));
}

void fragment() {
	// Called for every pixel the material is visible on
	vec3 a = rgb2hsl(color_base);
	vec3 b = rgb2hsl(color_charged);
	float alpha = player_charge;
	//vec3 color_hsl = mix(a, b, alpha)
	//vec3 color = hsl2rgb(mix(a, b, alpha));
	//color = player_charge * vec3(0.4, 0., 1.);
	vec3 color = hsl2rgb(vec3(mix(0., 0.36, 1.-alpha), 0.8, 0.5));
	COLOR = vec4(color, 1.);
}

//void light() {
//	// Called for every pixel for every light affecting the CanvasItem.
//	// Uncomment to replace the default light processing function with this one.
//}
