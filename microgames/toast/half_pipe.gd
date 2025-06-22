@tool
extends Node2D

@export var line_node: NodePath : set = set_line_node
@export var line_width: float = 10.0 : set = set_line_width  
@export var outline_width: float = 12.0 : set = set_outline_width
@export var show_shadow: bool = true : set = set_show_shadow
@export var shadow_offset: Vector2 = Vector2(2, 2) : set = set_shadow_offset
@export var shadow_blur_radius: float = 3.0 : set = set_shadow_blur_radius
@export var shadow_texture_size: Vector2i = Vector2i(512, 512) : set = set_shadow_texture_size

var outline: Line2D
var shadow_texture_rect: TextureRect
var shadow_viewport: SubViewport
var static_body: StaticBody2D
var collision_polygon: CollisionPolygon2D
var last_line_points: PackedVector2Array
var last_line_position: Vector2
var blur_material: ShaderMaterial
var cached_shadow_texture: ImageTexture
var shadow_needs_update: bool = true
var updating: bool = false

func _ready():
	setup_blur_shader()
	setup_shadow_viewport()
	generate_all()

func _process(_delta):
	if Engine.is_editor_hint() and not updating:
		check_for_line_changes()

func set_line_node(value: NodePath):
	line_node = value
	shadow_needs_update = true
	if is_inside_tree() and not updating:
		call_deferred("generate_all")

func set_line_width(value: float):
	line_width = value
	shadow_needs_update = true
	if is_inside_tree() and not updating:
		call_deferred("generate_all")

func set_outline_width(value: float):
	outline_width = value
	if outline:
		outline.width = line_width + outline_width
	shadow_needs_update = true
	if is_inside_tree() and not updating:
		call_deferred("generate_all")

func set_show_shadow(value: bool):
	show_shadow = value
	if is_inside_tree() and not updating:
		call_deferred("generate_all")

func set_shadow_offset(value: Vector2):
	shadow_offset = value
	if is_inside_tree() and shadow_texture_rect and not updating:
		update_shadow_position()

func set_shadow_blur_radius(value: float):
	shadow_blur_radius = value
	if blur_material:
		blur_material.set_shader_parameter("blur_radius", shadow_blur_radius)

func set_shadow_texture_size(value: Vector2i):
	shadow_texture_size = value
	shadow_needs_update = true
	if is_inside_tree() and not updating:
		setup_shadow_viewport()
		call_deferred("generate_all")

func check_for_line_changes():
	var line = get_node_or_null(line_node) as Line2D
	if not line:
		return
	
	if line.points != last_line_points or line.position != last_line_position:
		last_line_points = line.points.duplicate()  
		last_line_position = line.position
		shadow_needs_update = true
		call_deferred("generate_all")


func setup_blur_shader():
	var shader = Shader.new()
	shader.code = """
shader_type canvas_item;

uniform float blur_radius : hint_range(0.0, 10.0) = 3.0;
uniform sampler2D screen_texture : hint_screen_texture, repeat_disable, filter_nearest;

vec4 gaussian_blur(sampler2D tex, vec2 uv, vec2 pixel_size, float radius) {
	vec4 color = vec4(0.0);
	float total_weight = 0.0;
	
	int samples = int(radius * 2.0) + 1;
	
	for (int x = -samples; x <= samples; x++) {
		for (int y = -samples; y <= samples; y++) {
			vec2 offset = vec2(float(x), float(y)) * pixel_size;
			float distance = length(vec2(float(x), float(y)));
			
			if (distance <= radius) {
				float weight = exp(-(distance * distance) / (2.0 * radius * radius * 0.3));
				color += texture(tex, uv + offset) * weight;
				total_weight += weight;
			}
		}
	}
	
	return color / total_weight;
}

void fragment() {
	vec2 pixel_size = 1.0 / TEXTURE_PIXEL_SIZE;
	COLOR = gaussian_blur(TEXTURE, UV, 1.0 / pixel_size, blur_radius);
}
"""
	
	blur_material = ShaderMaterial.new()
	blur_material.shader = shader
	blur_material.set_shader_parameter("blur_radius", shadow_blur_radius)

func setup_shadow_viewport():
	cleanup_viewport()
	
	shadow_viewport = SubViewport.new()
	shadow_viewport.size = shadow_texture_size
	shadow_viewport.transparent_bg = true
	shadow_viewport.render_target_update_mode = SubViewport.UPDATE_DISABLED
	shadow_viewport.size_2d_override = Vector2(128,128)
	
	add_child(shadow_viewport)
	shadow_needs_update = true

func cleanup_viewport():
	if shadow_viewport:
		# Clean up all children first
		for child in shadow_viewport.get_children():
			child.queue_free()
		
		if shadow_viewport.get_parent():
			remove_child(shadow_viewport)
		shadow_viewport.queue_free()
		shadow_viewport = null

func generate_all():
	if updating:
		return
		
	updating = true
	cleanup_all()
	
	var line = get_node_or_null(line_node) as Line2D
	if not line:
		print("Line2D node not found.")
		updating = false
		return
	
	if show_shadow:
		await generate_shadow_texture(line)
	generate_outline(line)
	generate_collision(line)
	
	updating = false

func cleanup_all():
	# Clean up shadow texture rect
	if shadow_texture_rect and is_instance_valid(shadow_texture_rect):
		if shadow_texture_rect.get_parent():
			remove_child(shadow_texture_rect)
		shadow_texture_rect.queue_free()
		shadow_texture_rect = null
	
	# Clean up outline
	if outline and is_instance_valid(outline):
		if outline.get_parent():
			remove_child(outline)
		outline.queue_free()
		outline = null
	
	# Clean up static body
	if static_body and is_instance_valid(static_body):
		if static_body.get_parent():
			remove_child(static_body)
		static_body.queue_free()
		static_body = null
		collision_polygon = null

func generate_shadow_texture(line: Line2D):
	if line.points.size() < 2:
		return
	
	# Only regenerate texture if needed
	if shadow_needs_update:
		await create_shadow_texture(line)
		shadow_needs_update = false
	
	# Create TextureRect with cached texture
	if cached_shadow_texture:
		print("Create shadow texture first.")
		shadow_texture_rect = TextureRect.new()
		shadow_texture_rect.texture = cached_shadow_texture
		shadow_texture_rect.material = blur_material
		shadow_texture_rect.size = Vector2(shadow_texture_size)
		add_child(shadow_texture_rect)
		move_child(shadow_texture_rect, 0)
		update_shadow_position()

func create_shadow_texture(line: Line2D):
	if not shadow_viewport:
		return
		
	# Clear existing children in viewport
	for child in shadow_viewport.get_children():
		child.queue_free()
	
	await get_tree().process_frame  # Wait for cleanup
	
	print("Update shadow")
	# Calculate bounds and scaling
	var bounds = get_line_bounds(line)
	var padding = 60.0  # Increased padding for blur
	var content_size = bounds.size + Vector2(padding * 2, padding * 2)
	var scale_factor = min(
		(shadow_texture_size.x - 40) / content_size.x,
		(shadow_texture_size.y - 40) / content_size.y
	)
	scale_factor = min(scale_factor, 1.0)
	
	# Create shadow line in viewport
	var shadow_line = Line2D.new()
	shadow_line.points = line.points
	shadow_line.default_color = Color(0, 0, 0, 0.8)  # Semi-transparent black
	shadow_line.width = (line_width + 10.0) * scale_factor
	
	# Center the line in the viewport
	var center_offset = (Vector2(shadow_texture_size) - content_size * scale_factor) * 0.5
	shadow_line.position = center_offset + (Vector2(padding, padding) - bounds.position) * scale_factor
	shadow_line.scale = Vector2(scale_factor, scale_factor)
	
	shadow_line.end_cap_mode = Line2D.LINE_CAP_ROUND
	shadow_line.begin_cap_mode = Line2D.LINE_CAP_ROUND
	shadow_line.joint_mode = Line2D.LINE_JOINT_ROUND
	shadow_viewport.add_child(shadow_line)
	
	# Force render
	shadow_viewport.render_target_update_mode = SubViewport.UPDATE_ONCE
	await get_tree().process_frame
	# await get_tree().process_frame
	
	# Cache the texture
	var viewport_texture = shadow_viewport.get_texture()
	if viewport_texture:
		cached_shadow_texture = ImageTexture.new()
		cached_shadow_texture.set_image(viewport_texture.get_image())
	
	shadow_viewport.render_target_update_mode = SubViewport.UPDATE_DISABLED

func update_shadow_position():
	if not shadow_texture_rect or not is_instance_valid(shadow_texture_rect):
		return
	
	var line = get_node_or_null(line_node) as Line2D
	if not line:
		return
	
	var bounds = get_line_bounds(line)
	shadow_texture_rect.position = line.position + shadow_offset + bounds.position - Vector2(shadow_texture_size) * 0.5

func get_line_bounds(line: Line2D) -> Rect2:
	if line.points.is_empty():
		return Rect2()
	
	var min_point = line.points[0]
	var max_point = line.points[0]
	
	for point in line.points:
		min_point.x = min(min_point.x, point.x)
		min_point.y = min(min_point.y, point.y)
		max_point.x = max(max_point.x, point.x)
		max_point.y = max(max_point.y, point.y)
	
	return Rect2(min_point, max_point - min_point)

func generate_outline(line: Line2D):
	outline = Line2D.new()
	outline.points = line.points
	outline.default_color = Color(0.788, 0.509, 0.0)
	outline.width = line_width + outline_width
	outline.position = line.position
	outline.end_cap_mode = Line2D.LINE_CAP_ROUND
	outline.begin_cap_mode = Line2D.LINE_CAP_ROUND
	outline.joint_mode = Line2D.LINE_JOINT_ROUND
	add_child(outline)
	move_child(outline, 0)  # Move outline to the bottom

func generate_collision(line: Line2D):
	var line_points = line.points
	if line_points.size() < 2:
		print("Line2D needs at least 2 points to generate a collision shape.")
		return
	
	static_body = StaticBody2D.new()
	static_body.name = "LineCollision"
	static_body.position = line.position
	var physics_material = PhysicsMaterial.new()
	physics_material.friction = 0.1
	static_body.physics_material_override = physics_material 
	add_child(static_body)
	
	collision_polygon = CollisionPolygon2D.new()
	static_body.add_child(collision_polygon)
	
	var polygon_points = Geometry2D.offset_polyline(
		line_points,
		line_width / 2.0,
		Geometry2D.JOIN_SQUARE,
		Geometry2D.END_ROUND
	)
	
	if not polygon_points.is_empty():
		collision_polygon.polygon = polygon_points[0]  
	else:
		print("Failed to generate polygon points.")