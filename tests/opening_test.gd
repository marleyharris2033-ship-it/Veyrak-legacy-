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
	for id in VeyrakHeroes.IDS:
		home.selector.select_hero(id)
		check(home.profile.hero_id == id,"Hero selection failed: "+id)
		var total = 0
		for rating in VeyrakHeroes.record(id).stats: total += rating
		check(total == 36,"Unequal starting budget: "+id)
		check(VeyrakProfile.validate(home.profile).hero_id == id,"Hero must survive validation")
	for dimensions in [Vector2i(390,844),Vector2i(844,390)]:
		root.size = dimensions
		await process_frame
		await process_frame
		home._responsive()
		await process_frame
		check(home.selector.spread.vertical == (home.selector.size.x < 760),"Dossier responsive layout")
		for button in home.selector.tabs:
			check(button.size.y >= 48,"Hero button touch height")
			check(button.get_global_rect().end.x <= home.get_viewport_rect().size.x,"Hero button fits viewport")
		check(home.selector.scroll.get_v_scroll_bar().max_value > home.selector.scroll.size.y,"Dossier is scrollable")
	home.selector.select_hero("kaerun")
	home._confirm()
	await process_frame
	check(home.screen=="intro","Confirm must enter introduction")
	check(slots.read_slot(1).profile.name=="Kaerun","Name persisted")
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
	home.selector.select_hero("ilyra")
	home._confirm()
	home._finish_intro()
	await process_frame
	check(home.screen=="ready","Skip must reach endpoint")
	check(slots.read_slot(2).profile.hero_id == "ilyra","Selected hero persists independently")
	check(slots.read_slot(1).profile.name=="Kaerun","Other slot preserved")
	check(slots.delete_slot(2)==OK,"Delete works")
	check(slots.read_slot(2).is_empty(),"Deleted slot empty")
	var legacy = VeyrakProfile.defaults()
	legacy.name = "Old character"
	slots.write_slot(3,legacy,{"scene":"res://home.tscn","state":{"phase":"ready"}})
	home._slots()
	home._open_slot(3)
	check(home.screen=="creator","Legacy saves need explicit hero selection")
	check(slots.read_slot(3).profile.name == "Old character","Browsing must not overwrite old saves")
	home.selector.select_hero("nyvara")
	home._confirm()
	check(home.screen=="ready","Legacy completed intro should stay completed")
	check(slots.read_slot(3).profile.hero_id == "nyvara","Migration confirmed")
	check(VeyrakHeroes.derived("kaerun").Health == 280,"Health formula")
	check(VeyrakHeroes.derived("nyvara")["Critical chance"] == 12,"Critical chance formula")
	check(VeyrakHeroes.derived("kaerun",2).Health == 295,"Level growth formula")
	check(VeyrakHeroes.attributes("kaerun",{"Might":2}).Might == 11,"Equipment attribute additions")
	for i in range(1,4): slots.delete_slot(i)
	home.queue_free()
	await process_frame
	print("OPENING FLOW TESTS: ","FAIL" if failed else "PASS")
	quit(1 if failed else 0)
