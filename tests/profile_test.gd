extends SceneTree

func _initialize() -> void:
	var clean = VeyrakProfile.validate({"name": "  Marley  ", "skin": -5, "face": 99, "outfit": "broken", "species": "Wrong"})
	assert(clean.name == "Marley")
	assert(clean.skin == 0)
	assert(clean.face == 7)
	assert(clean.outfit == 0)
	assert(clean.species == "Veyrakian")
	assert(VeyrakProfile.validate(null) == VeyrakProfile.defaults())
	assert(VeyrakProfile.validate({"name": "x".repeat(50)}).name.length() == 24)
	# JSON turns integers into floats; all selected appearances must survive a round trip.
	for key in VeyrakProfile.OPTIONS:
		for index in range(VeyrakProfile.OPTIONS[key].size()):
			var profile = VeyrakProfile.defaults()
			profile[key] = index
			assert(VeyrakProfile.validate(JSON.parse_string(JSON.stringify(profile))) == profile)
	print("Profile validation and all appearance JSON round trips passed.")
	quit()
