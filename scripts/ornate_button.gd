extends Button
var featured = false

func _ready() -> void:
	toggled.connect(func(_value): queue_redraw())
	mouse_entered.connect(queue_redraw)
	mouse_exited.connect(queue_redraw)
	resized.connect(queue_redraw)

func _draw() -> void:
	if size.x < 90 or size.y < 45: return
	var lit = featured or button_pressed or is_hovered() or has_focus()
	var colour = Color("efbd68") if lit else Color("776b60")
	var w = size.x
	var h = size.y
	var points = PackedVector2Array([Vector2(3, 12), Vector2(7, 12), Vector2(7, 7), Vector2(12, 7), Vector2(12, 3), Vector2(w - 12, 3), Vector2(w - 12, 7), Vector2(w - 7, 7), Vector2(w - 7, 12), Vector2(w - 3, 12), Vector2(w - 3, h - 12), Vector2(w - 7, h - 12), Vector2(w - 7, h - 7), Vector2(w - 12, h - 7), Vector2(w - 12, h - 3), Vector2(12, h - 3), Vector2(12, h - 7), Vector2(7, h - 7), Vector2(7, h - 12), Vector2(3, h - 12), Vector2(3, 12)])
	if lit: draw_polyline(points, Color(1, 0.68, 0.19, 0.16), 10)
	draw_polyline(points, colour, 2)
	draw_line(Vector2(17, 8), Vector2(w - 17, 8), colour.darkened(0.3), 1)
	draw_line(Vector2(17, h - 8), Vector2(w - 17, h - 8), colour.darkened(0.3), 1)
