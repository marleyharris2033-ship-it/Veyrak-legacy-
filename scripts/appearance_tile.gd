extends Button
const CHARACTER = preload("res://assets/creator/veyrakian-default-v1.png")
var key = "face"
var option_index = 0
var selected = false
var available = true
var tint = Color.WHITE
var colour_tile = false
var shader_material: ShaderMaterial

func _ready() -> void:
	texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	resized.connect(queue_redraw)
	mouse_entered.connect(queue_redraw)
	mouse_exited.connect(queue_redraw)
	add_theme_stylebox_override("normal", StyleBoxEmpty.new())
	add_theme_stylebox_override("hover", StyleBoxEmpty.new())
	add_theme_stylebox_override("pressed", StyleBoxEmpty.new())
	add_theme_stylebox_override("focus", StyleBoxEmpty.new())

func _draw() -> void:
	var border = Color("ffd77b") if selected else Color("4b505d")
	if has_focus() or is_hovered(): border = Color("fff0bf")
	if selected:
		draw_rect(Rect2(Vector2.ONE, size - Vector2.ONE * 2), Color(0.9, 0.65, 0.2, 0.15))
	draw_rect(Rect2(Vector2(4, 4), size - Vector2(8, 8)), Color("0b111b"))
	var target = Rect2(Vector2(8, 8), size - Vector2(16, 16))
	if colour_tile:
		if key == "eyes":
			var centre = size * 0.5
			draw_circle(centre, minf(target.size.x, target.size.y) * 0.43, tint.darkened(0.5))
			draw_circle(centre, minf(target.size.x, target.size.y) * 0.34, tint)
			draw_circle(centre, minf(target.size.x, target.size.y) * 0.18, Color("071018"))
			draw_rect(Rect2(centre + Vector2(-8, -9), Vector2(5, 5)), Color("fff6df"))
		else:
			draw_rect(target, tint)
	else:
		var region = Rect2(375, 38, 300, 285)
		if key == "build" or key == "outfit":
			region = Rect2(195, 40, 650, 1440)
			var ratio = minf(target.size.x / region.size.x, target.size.y / region.size.y)
			var dimensions = region.size * ratio
			if key == "build": dimensions.x *= [0.82, 0.94, 1.0, 1.1][option_index]
			target = Rect2((size - dimensions) * 0.5, dimensions)
		draw_texture_rect_region(CHARACTER, target, region, Color.WHITE if available else Color(0.25, 0.29, 0.36, 0.5))
		if not available:
			# Unmade artwork is visibly locked, never a fake choice.
			var p = size * 0.5
			draw_arc(p + Vector2(0, -2), 5, PI, TAU, 12, Color("b2a17c"), 2)
			draw_rect(Rect2(p + Vector2(-7, -2), Vector2(14, 11)), Color("b2a17c"))
			draw_rect(Rect2(p + Vector2(-1, 1), Vector2(2, 4)), Color("18202a"))
	draw_rect(Rect2(Vector2(3, 3), size - Vector2(6, 6)), border, false, 2)
	for p in [Vector2(2, 8), Vector2(size.x - 3, 8), Vector2(2, size.y - 9), Vector2(size.x - 3, size.y - 9)]:
		draw_rect(Rect2(p, Vector2(3, 3)), border)
