extends Control
var player = Vector2.ZERO
var goal = Vector2.ZERO
var complete = false
const BOUNDS = Rect2(235,320,1060,340)
const GOLD = Color("d8b56f")

func _ready() -> void:
	custom_minimum_size = Vector2(94,94)
	mouse_filter = Control.MOUSE_FILTER_IGNORE

func point(value: Vector2) -> Vector2:
	var area = Rect2(Vector2(size.x*.19,size.y*.30),Vector2(size.x*.62,size.y*.40))
	return area.position+(value-BOUNDS.position)/BOUNDS.size*area.size

func _draw() -> void:
	var centre = size*.5
	var radius = minf(size.x,size.y)*.485
	draw_circle(centre,radius,Color("07111bef"))
	draw_arc(centre,radius-2,0,TAU,64,Color("f0c976"),3)
	draw_arc(centre,radius-7,0,TAU,64,Color("755f38"),1)
	for i in range(8):
		var axis = Vector2.from_angle(TAU*i/8)
		draw_line(centre+axis*(radius-9),centre+axis*(radius-4),GOLD,2)
	var area = Rect2(Vector2(size.x*.19,size.y*.30),Vector2(size.x*.62,size.y*.40))
	draw_rect(area,Color("1d2b39"))
	draw_line(Vector2(area.position.x,area.get_center().y),Vector2(area.end.x,area.get_center().y),Color("515b5f"),1)
	for i in range(1,4):
		var x = area.position.x+area.size.x*i/4
		draw_line(Vector2(x,area.position.y),Vector2(x,area.end.y),Color("414b52"),1)
	draw_rect(area,Color("8c754a"),false,1)
	draw_circle(point(Vector2(680,450)),3,Color("66c6f2"))
	if not complete:
		var p = point(goal)
		draw_colored_polygon(PackedVector2Array([p+Vector2(0,-5),p+Vector2(5,0),p+Vector2(0,5),p+Vector2(-5,0)]),Color("f7cc72"))
	var me = point(player)
	var dir = Vector2(0,-7)
	draw_colored_polygon(PackedVector2Array([me+dir,me+Vector2(5,5),me,me+Vector2(-5,5)]),Color("f3eee0"))
