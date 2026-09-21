extends SceneTree

func _initialize() -> void:
	_run.call_deferred()

func _run() -> void:
	var slots = root.get_node("SaveSlots")
	slots.storage_root = "user://slot-test-%s" % Time.get_ticks_usec()
	DirAccess.make_dir_recursive_absolute(slots.storage_root)
	for slot in range(1, 4): assert(slots.read_slot(slot).is_empty())
	var a = VeyrakProfile.defaults()
	a.name = "Vaerun"
	var b = a.duplicate()
	b.name = "Kaelith"
	b.skin = 4
	assert(slots.write_slot(1, a, {"scene": slots.CREATOR, "state": {}}) == OK)
	assert(slots.write_slot(2, b, {"scene": slots.CREATOR, "state": {}}) == OK)
	assert(slots.read_slot(1).profile.name == "Vaerun")
	assert(slots.read_slot(2).profile.skin == 4)
	assert(slots.read_slot(3).is_empty())
	slots.active_slot = 2
	assert(slots.current_profile().name == "Kaelith")
	assert(slots.save_checkpoint(b, "res://future-world.tscn", "Waterfall terrace", {"position": [12, 34], "quest": 2}) == OK)
	assert(slots.read_slot(2).checkpoint.state.position == [12.0, 34.0])
	assert(slots.open_slot(2) == ERR_FILE_NOT_FOUND)
	assert(slots.read_slot(2).checkpoint.state.quest == 2)
	var file = FileAccess.open(slots.path_for(3), FileAccess.WRITE)
	file.store_string("broken save")
	file.close()
	assert(slots.open_slot(3) == ERR_FILE_CORRUPT)
	assert(FileAccess.get_file_as_string(slots.path_for(3)) == "broken save")
	assert(slots.write_slot(0, a, {}) == ERR_INVALID_PARAMETER)
	# Replacing a slot must not affect its neighbours.
	assert(slots.save_character(a) == OK)
	assert(slots.read_slot(2).profile.name == "Vaerun")
	assert(slots.read_slot(1).profile.name == "Vaerun")
	for slot in range(1, 4): DirAccess.remove_absolute(slots.path_for(slot))
	DirAccess.remove_absolute(slots.storage_root)
	slots.active_slot = 0
	root.size = Vector2i(390, 844)
	var home = load("res://home.tscn").instantiate()
	root.add_child(home)
	await process_frame
	await process_frame
	assert(home.screen == "title")
	home._slots()
	await process_frame
	await process_frame
	var buttons = home.content.get_children().filter(func(node): return node is Button)
	assert(buttons.size() == 4)
	for button in buttons:
		assert(button.get_global_rect().end.x <= 390)
		assert(button.size.y >= 48)
	home._settings()
	await process_frame
	assert(home.screen == "settings")
	home.queue_free()
	print("Three isolated slots, overwrite, checkpoint state, corrupt/missing-scene protection and mobile menu passed.")
	quit()
