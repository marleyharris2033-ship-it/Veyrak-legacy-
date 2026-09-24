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
	slots.storage_root = "user://tutorial-test"
	DirAccess.make_dir_recursive_absolute(slots.storage_root)
	slots.active_slot = 1
	for id in VeyrakHeroes.IDS:
		var profile = VeyrakProfile.defaults()
		profile.hero_id = id
		check(slots.save_checkpoint(profile,"res://tutorial.tscn","Training",{}) == OK,"Seed save")
		var game = load("res://tutorial.tscn").instantiate()
		root.add_child(game)
		await process_frame
		for dimensions in [Vector2i(390,844),Vector2i(844,390)]:
			root.size = dimensions
			await process_frame
			await process_frame
			check(game.arena.size.y >= 80,"Arena must fit")
			check(game.arena.size.y == game.size.y,"World uses full viewport")
			check(not game.objective.visible and not game.status.visible,"No permanent instruction wall")
			check(game.hud.map.get_global_rect().end.x <= root.size.x,"Minimap fits viewport")
			check(game.action_button.get_global_rect().end.y <= root.size.y,"Touch controls must fit")
			check(game.ability_button.get_global_rect().end.x <= root.size.x,"Ability fits screen")
		game.actor.motion = Vector2(0,-1)
		game.actor.facing = Vector2(0,-1)
		game.actor._update_frame()
		if id == "kaerun":
			check(game.actor.sprite.texture == game.actor.KAERUN_ANIMS,"Kaerun uses dedicated animation atlas")
			check(game.actor.sprite.region_rect.size.y == 187,"Kaerun uses authored pose boundaries")
			game.actor.play_attack()
			game.actor.action_clock = .2
			game.actor._update_frame()
			check(game.actor.sprite.region_rect.position.y >= 360,"Punch uses actual punch artwork")
		else:
			check(int(game.actor.sprite.region_rect.position.y / 256.0) == VeyrakHeroes.index_of(id),"Correct hero sprite row")
		game.actor.position = Vector2(560,570)
		game._process(.01)
		check(game.stage == 1,"Movement completes lesson")
		game.interact()
		check(game.stage == 1,"Interaction requires proximity")
		game.actor.position = game.instructor.position
		game.interact()
		check(game.hud.chat.visible and game.stage == 1,"NPC dialogue waits for player")
		game.hud.close_chat()
		check(game.stage == 2,"Instructor begins combat")
		game.actor.position = Vector2(235,600)
		game.attack()
		check(game.target.health == 100,"Attack requires range")
		game.actor.position = game.target.position+Vector2(-50,0)
		game.actor.motion = Vector2.ZERO
		game.actor.facing = Vector2.RIGHT
		for i in range(10):
			game.cooldown = 0
			game.attack()
		check(game.stage == 3,"Basic attacks reach ability lesson")
		check(game.target.health > 0,"Basic attacks cannot deadlock ability lesson")
		game.ability()
		check(game.stage == 4,"All six abilities complete exercise")
		game.actor.position = Vector2(1120,600)
		game.interact()
		check(game.claimed and not game.equipped,"Loot first enters inventory")
		game.interact()
		check(game.equipped and game.stage == 5,"Equipment completes lesson")
		game.actor.position = game.instructor.position
		game.interact()
		game.hud.close_chat()
		check(game.stage == 6,"Tutorial completion")
		check(slots.read_slot(1).checkpoint.state.equipped,"Equipment persisted")
		game.queue_free()
		await process_frame
		var resume = load("res://tutorial.tscn").instantiate()
		root.add_child(resume)
		await process_frame
		check(resume.stage == 6 and resume.equipped,"Resume progress")
		resume.queue_free()
		await process_frame
	slots.delete_slot(1)
	print("Tutorial tests passed" if not failed else "Tutorial tests FAILED")
	quit(1 if failed else 0)
