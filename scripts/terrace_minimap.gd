extends Control
var player = Vector2.ZERO
var goal = Vector2.ZERO
var complete = false
const BOUNDS = Rect2(235,320,1060,340)
func _ready() -> void:
	custom_minimum_size = Vector2(106,106)
	mouse_filter = MOUSE_FILTER_IGNORE
func point(value: Vector2) -> Vector2:
	return Vector2(17,34)+(value-BOUNDS.position)/BOUNDS.size*Vector2(size.x-34,size.y-68)
func _draw() -> void:
	var centre = size*.5
	var radius = minf(size.x,size.y)*.48
	draw_circle(centre,radius,Color("09131bf5"))
	draw_arc(centre,radius-2,0,TAU,64,Color("d6b674"),3)
	draw_arc(centre,radius-7,0,TAU,64,Color("756547"),1)
	for i in range(12):
		var axis = Vector2.from_angle(TAU*i/12)
		draw_line(centre+axis*(radius-9),centre+axis*(radius-5),Color("e7c681"),2)
	var area = Rect2(Vector2(17,34),Vector2(size.x-34,size.y-68))
	draw_rect(area,Color("253341"))
	for i in range(1,5):
		var x = area.position.x+area.size.x*i/5
		draw_line(Vector2(x,34),Vector2(x,size.y-34),Color("49504e"),1)
	draw_rect(area,Color("9b865c"),false,1)
	draw_circle(point(Vector2(680,450)),3,Color("65c7fa"))
	if not complete:
		var p = point(goal)
		draw_colored_polygon(PackedVector2Array([p+Vector2(0,-5),p+Vector2(5,0),p+Vector2(0,5),p+Vector2(-5,0)]),Color("f5ca79"))
	draw_circle(point(player),3,Color("f4f0dd"))
func _frame() -> StyleBoxFlat:
	var box = StyleBoxFlat.new()
	box.bg_color = Color("09131bef")
	box.border_color = Color("b4975e")
	box.set_border_width_all(2)
	box.set_corner_radius_all(5)
	return box
