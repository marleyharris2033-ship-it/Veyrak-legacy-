extends SceneTree
var failed = false
func check(value: bool, message: String) -> void:
	if not value:
		failed = true
		push_error(message)
func _initialize() -> void:
	call_deferred("run")
func run() -> void:
	var slots = root.get_node("SaveSlots")
	slots.storage_root = "user://opening-test"
	DirAccess.make_dir_recursive_absolute(slots.storage_root)
	for i in range(1,4): slots.delete_slot(i)
	var home = load("res://home.tscn").instantiate()
	root.add_child(home)
	await process_frame
	home._slots()
	home._open_slot(1)
	await process_frame
	check(home.screen=="creator","Empty slot must enter creator")
	for key in VeyrakProfile.OPTIONS:
		for i in range(VeyrakProfile.OPTIONS[key].size()):
			home.profile[key]=i
			home._refresh()
			check(home.appearance.profile[key]==i,"Appearance selection failed: "+key)
	home.name_input.text = "Test Veyrakian"
	home._confirm()
	await process_frame
	check(home.screen=="intro","Confirm must enter introduction")
	check(slots.read_slot(1).profile.name=="Test Veyrakian","Name persisted")
	for i in range(12): home._advance()
	await process_frame
	check(home.screen=="ready","Introduction must reach endpoint")
	home._title()
	home._slots()
	home._open_slot(1)
	await process_frame
	check(home.screen=="ready","Existing slot must resume endpoint")
	home._slots()
	home._open_slot(2)
	await process_frame
	check(home.screen=="creator","Second slot independent")
	home.name_input.text = "Second"
	home._confirm()
	home._finish_intro()
	await process_frame
	check(home.screen=="ready","Skip must reach endpoint")
	check(slots.read_slot(1).profile.name=="Test Veyrakian","Other slot preserved")
	check(slots.delete_slot(2)==OK,"Delete works")
	check(slots.read_slot(2).is_empty(),"Deleted slot empty")
	for i in range(1,4): slots.delete_slot(i)
	home.queue_free()
	await process_frame
	print("OPENING FLOW TESTS: ","FAIL" if failed else "PASS")
	quit(1 if failed else 0)
