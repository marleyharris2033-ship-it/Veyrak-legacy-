extends SceneTree

func _initialize() -> void:
	_run.call_deferred()

func _run() -> void:
	root.size = Vector2i(1536, 1024)
	var creator = load("res://reference_creator.tscn").instantiate()
	root.add_child(creator)
	await process_frame
	await process_frame
	assert(not creator.portrait_layout)
	assert(creator.rows.size() == creator.KEYS.size())
	assert(creator.categories.size() == 5)
	assert(creator.warrior.texture.get_image().has_mipmaps() == false)
	assert(creator.rows.hair.tiles.any(func(tile): return tile.selected and tile.option_index == creator.profile.hair))
	for key in VeyrakProfile.OPTIONS:
		for index in range(VeyrakProfile.OPTIONS[key].size()):
			assert(creator._available(key, index), "Every creator option must be unlocked: %s %s" % [key, index])
	creator._select("skin", 4)
	assert(creator.profile.skin == 4)
	assert(creator.warrior_material.get_shader_parameter("change_skin") == true)
	creator._select("build", 0)
	var lean_width = creator.warrior.size.x
	creator._select("build", 3)
	assert(creator.warrior.size.x > lean_width)
	creator._random_name()
	assert(not creator.profile.name.is_empty())
	assert(VeyrakProfile.validate(creator.profile).art_revision == 1)
	root.size = Vector2i(390, 844)
	await process_frame
	await process_frame
	assert(creator.portrait_layout)
	creator._open_choices("skin")
	await process_frame
	await process_frame
	assert(creator.modal.size.x <= 390, "Touch picker must fit portrait iPhone")
	assert(creator.modal.size.y <= 844)
	creator.modal.hide()
	root.size = Vector2i(844, 390)
	await process_frame
	await process_frame
	assert(not creator.portrait_layout)
	creator._open_choices("hair")
	await process_frame
	await process_frame
	assert(creator.modal.size.y <= 390, "Touch picker must fit landscape iPhone")
	creator.modal.hide()
	# Core save round trip, preserving any pre-existing local development save.
	var had_save = FileAccess.file_exists(VeyrakProfile.SAVE_PATH)
	var old_save = FileAccess.get_file_as_bytes(VeyrakProfile.SAVE_PATH) if had_save else PackedByteArray()
	assert(VeyrakProfile.save(creator.profile) == OK)
	assert(VeyrakProfile.load_saved() == VeyrakProfile.validate(creator.profile))
	if had_save:
		var file = FileAccess.open(VeyrakProfile.SAVE_PATH, FileAccess.WRITE)
		file.store_buffer(old_save)
		file.close()
	else:
		DirAccess.remove_absolute(VeyrakProfile.SAVE_PATH)
	print("Reference layout, all-unlocked customisation, live renderer, mobile pickers and save/reload passed.")
	creator.queue_free()
	quit()
