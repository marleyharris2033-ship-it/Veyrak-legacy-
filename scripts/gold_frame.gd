extends PanelContainer
var active = false

func _ready() -> void:
	var box = StyleBoxFlat.new()
	box.bg_color = Color(0.015, 0.035, 0.06, 0.94)
	box.set_content_margin_all(12)
	add_theme_stylebox_override("panel", box)
	resized.connect(queue_redraw)

func _draw() -> void:
	var colour = Color("edbd66") if active else Color("9b8059")
	var r = Rect2(Vector2(3, 3), size - Vector2(6, 6))
	draw_rect(r, Color("171b24"), false, 6)
	draw_rect(r, colour.darkened(0.25), false, 2)
	draw_rect(Rect2(Vector2(7, 7), size - Vector2(14, 14)), colour.darkened(0.5), false, 1)
	for c in [Vector2(3, 3), Vector2(size.x - 3, 3), Vector2(3, size.y - 3), size - Vector2(3, 3)]:
		var d = Vector2(1 if c.x < size.x * 0.5 else -1, 1 if c.y < size.y * 0.5 else -1)
		draw_line(c + Vector2(6 * d.x, 0), c + Vector2(20 * d.x, 0), colour, 3)
		draw_line(c + Vector2(0, 6 * d.y), c + Vector2(0, 20 * d.y), colour, 3)
		draw_rect(Rect2(c + Vector2(4 * d.x, 4 * d.y) - Vector2(2, 2), Vector2(4, 4)), colour)
