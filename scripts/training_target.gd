extends Node2D
## Council training projector, intentionally mechanical rather than a creature.
var health = 100.0
var max_health = 100.0
var clock = 0.0
func _process(delta: float) -> void:
	clock += delta
	queue_redraw()
func _draw() -> void:
	if health<=0: return
	var bob = sin(clock*2)*3
	var core = Vector2(0,-32+bob)
	draw_set_transform(Vector2.ZERO,0,Vector2(1,.4))
	draw_circle(Vector2.ZERO,30,Color(0,0,0,.3))
	draw_arc(Vector2.ZERO,26,0,TAU,24,Color("d5ad65"),2)
	draw_set_transform(Vector2.ZERO)
	draw_colored_polygon(PackedVector2Array([core+Vector2(0,-22),core+Vector2(19,0),core+Vector2(0,23),core+Vector2(-19,0)]),Color("17283c"))
	draw_polyline(PackedVector2Array([core+Vector2(0,-22),core+Vector2(19,0),core+Vector2(0,23),core+Vector2(-19,0),core+Vector2(0,-22)]),Color("d5ad65"),3)
	draw_circle(core,7,Color("72dafa"))
	draw_arc(core,29,clock,clock+PI*1.5,22,Color("55a5cb"),2)
	draw_rect(Rect2(-29,-77,58,5),Color("101624"))
	draw_rect(Rect2(-29,-77,58*health/max_health,5),Color("71d4df"))
