extends SceneTree

func _initialize() -> void:
	_run.call_deferred()

func _run() -> void:
	root.size = Vector2i(390, 844)
	var creator = load("res://creator.tscn").instantiate()
	root.add_child(creator)
	await process_frame
	await process_frame
	assert(creator.art_mode and creator.art_stage.visible, "Start with the new artwork preview")
	assert(not creator.layout.visible, "Do not imply the flat sprite renders all appearance variations")
	var before_art_switch: Dictionary = creator.profile.duplicate()
	creator._set_art_mode(false)
	await process_frame
	await process_frame
	assert(creator.profile == before_art_switch, "Art mode must not modify the saved character")
	assert(creator.layout.columns == 1, "Phone layout must stack")
	for key in creator.selectors:
		var control: Control = creator.selectors[key]
		assert(control.get_global_rect().end.x <= 390, "Phone control must fit: " + key)
		assert(control.size.y >= 44, "Touch target too small: " + key)
	var snapshot: Dictionary = creator.profile.duplicate()
	creator.name_input.text = "Test Veyrakian"
	creator.name_input.text_changed.emit("Test Veyrakian")
	assert(creator.profile.name == "Test Veyrakian")
	creator.selectors.hair.item_selected.emit(9)
	assert(creator.portrait.profile.hair == 9)
	creator._randomise()
	assert(creator.profile.name == "Test Veyrakian", "Randomise must preserve name")
	creator._restore()
	assert(creator.profile == snapshot, "Restore must recover all original appearance values")
	root.content_scale_factor = 3.0
	root.size = Vector2i(1170, 2532)
	await process_frame
	await process_frame
	assert(creator.layout.columns == 1, "Retina phone must retain phone layout")
	assert(creator.get_viewport_rect().size.x == 390, "Retina controls must retain CSS-pixel sizing")
	root.content_scale_factor = 1.0
	root.size = Vector2i(1100, 780)
	await process_frame
	await process_frame
	assert(creator.layout.columns == 2, "Desktop layout must have two columns")
	print("Phone layout, touch targets, preview updates, randomise and restore passed.")
	creator.queue_free()
	quit()
