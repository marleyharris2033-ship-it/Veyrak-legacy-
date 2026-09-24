extends Control
var direction = Vector2.ZERO
var finger = -1
var mouse_down = false
func _ready() -> void:
	custom_minimum_size = Vector2(116,116)
	mouse_filter = MOUSE_FILTER_STOP
func _gui_input(event: InputEvent) -> void:
	if event is InputEventScreenTouch:
		if event.pressed and finger == -1:
			finger = event.index
			point(event.position)
		elif event.index == finger and not event.pressed: reset()
	elif event is InputEventScreenDrag and event.index == finger: point(event.position)
	elif event is InputEventMouseButton and finger == -1 and event.button_index == MOUSE_BUTTON_LEFT:
		mouse_down = event.pressed
		if mouse_down: point(event.position)
		else: reset()
	elif event is InputEventMouseMotion and mouse_down: point(event.position)
	accept_event()
func _input(event: InputEvent) -> void:
	if event is InputEventScreenTouch and event.pressed and finger == -1 and is_visible_in_tree() and get_global_rect().has_point(event.position):
		finger = event.index
		mouse_down = false
		point(get_global_transform().affine_inverse()*event.position)
	if event is InputEventScreenDrag and event.index == finger:
		point(get_global_transform().affine_inverse()*event.position)
	if event is InputEventScreenTouch and not event.pressed and event.index == finger: reset()
	if event is InputEventMouseButton and not event.pressed and event.button_index == MOUSE_BUTTON_LEFT and mouse_down: reset()
func point(value: Vector2) -> void:
	direction = ((value-size*.5)/(size.x*.34)).limit_length()
	if direction.length()<.15: direction = Vector2.ZERO
	queue_redraw()
func reset() -> void:
	finger = -1
	mouse_down = false
	direction = Vector2.ZERO
	queue_redraw()
func _draw() -> void:
	var centre = size*.5
	draw_circle(centre,size.x*.46,Color("0b1625"))
	draw_arc(centre,size.x*.44,0,TAU,48,Color("b69b64"),2)
	draw_line(centre+Vector2(-size.x*.34,0),centre+Vector2(size.x*.34,0),Color("40516a"),1)
	draw_line(centre+Vector2(0,-size.y*.34),centre+Vector2(0,size.y*.34),Color("40516a"),1)
	draw_circle(centre+direction*size.x*.28,size.x*.15,Color("d5ad65"))
