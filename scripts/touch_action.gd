extends "res://scripts/ornate_button.gd"
signal activated
var last_touch = -1000
func _ready() -> void:
	super._ready()
	focus_mode = Control.FOCUS_NONE
	pressed.connect(func():
		if Time.get_ticks_msec()-last_touch > 400: activated.emit()
	)
func _input(event: InputEvent) -> void:
	if event is InputEventScreenTouch and event.pressed and is_visible_in_tree() and not disabled:
		if get_global_rect().has_point(event.position):
			last_touch = Time.get_ticks_msec()
			activated.emit()
