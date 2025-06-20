shader_type canvas_item;

uniform sampler2D toasted_texture;
uniform sampler2D angry_texture;
uniform sampler2D dead_texture;

uniform float toastedness;

void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	if (toastedness > 1.0){
		if (toastedness > 1.5){
			COLOR = texture(dead_texture, UV);
		} else {
			COLOR = texture(angry_texture, UV);
		}
	} else {
		COLOR = mix(texture(TEXTURE, UV), texture(toasted_texture, UV), toastedness);
	}
}

//void light() {
//	// Called for every pixel for every light affecting the CanvasItem.
//	// Uncomment to replace the default light processing function with this one.
//}
