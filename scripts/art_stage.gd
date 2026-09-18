extends Control
## Independent artwork assets: the background never contains the character/UI.
## This is a default-character art preview, not yet the modular appearance renderer.
const BACKGROUND = preload("res://assets/creator/veyathuun-background-v1.png")
const CHARACTER = preload("res://assets/creator/veyrakian-default-v1.png")

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	clip_contents = true
	texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	resized.connect(queue_redraw)

func _draw() -> void:
	# Cover both portrait and landscape stages, keeping the platform central.
	var background_size = Vector2(BACKGROUND.get_size())
	var factor = maxf(size.x / background_size.x, size.y / background_size.y)
	var scaled_size = background_size * factor
	var origin = Vector2(size.x * 0.5 - 736.0 * factor, size.y * 0.82 - 810.0 * factor)
	origin.x = clampf(origin.x, size.x - scaled_size.x, 0.0)
	origin.y = clampf(origin.y, size.y - scaled_size.y, 0.0)
	draw_texture_rect(BACKGROUND, Rect2(origin, scaled_size), false)
	# Source foot contact is y=1465; position it on the gold-ring platform.
	var feet = origin + Vector2(736, 810) * factor
	var character_scale = minf(size.y * 0.76 / 1415.0, size.x * 0.85 / 650.0)
	var character_size = Vector2(CHARACTER.get_size()) * character_scale
	var character_origin = feet - Vector2(525, 1465) * character_scale
	draw_texture_rect(CHARACTER, Rect2(character_origin, character_size), false)
	# Restrained gold edging and stepped corners remain editable native UI.
	var gold = Color("d5ad65")
	draw_rect(Rect2(Vector2.ONE, size - Vector2.ONE * 2), Color("8b734b"), false, 1)
	for corner in [Vector2(6, 6), Vector2(size.x - 6, 6), Vector2(6, size.y - 6), size - Vector2(6, 6)]:
		var direction = Vector2(1 if corner.x < size.x / 2 else -1, 1 if corner.y < size.y / 2 else -1)
		draw_line(corner, corner + Vector2(22 * direction.x, 0), gold, 2)
		draw_line(corner, corner + Vector2(0, 22 * direction.y), gold, 2)
