extends SceneTree
var failed = false
func check(ok: bool, message: String) -> void:
	if not ok: failed = true; push_error(message)
func _initialize() -> void:
	call_deferred("run")
func run() -> void:
	var slots = root.get_node("SaveSlots")
	slots.storage_root = "user://field-kit-test"
	DirAccess.make_dir_recursive_absolute(slots.storage_root)
	slots.active_slot = 1
	var profile = VeyrakProfile.defaults()
	profile.hero_id = "kaerun"
	slots.save_checkpoint(profile,"res://tutorial.tscn","Training",{"lesson":6,"claimed":true,"equipped":true})
	var game = load("res://tutorial.tscn").instantiate()
	root.add_child(game)
	await process_frame
	check(game.kit.points == 3,"Completed legacy save earns points")
	game.kit.reward()
	check(game.kit.points == 3,"Reward cannot be repeated")
	var before = game.stats().Health
	check(game.kit.spend("Endurance"),"Spend point")
	check(game.stats().Health == before+20,"Upgrade affects actual stats")
	game.health = 30
	game.use_food(0)
	check(game.health == 90 and game.kit.inventory.ration == 2,"Food consumed and heals")
	game.health = game.stats().Health
	game.use_food(0)
	check(game.kit.inventory.ration == 2,"Full health does not waste food")
	game.hud.toggle_menu()
	for dimensions in [Vector2i(390,844),Vector2i(844,390)]:
		root.size = dimensions
		await process_frame
		await process_frame
		for tab in ["PACK","GEAR","STATS"]:
			game.hud.field_menu.tab = tab
			game.hud.field_menu.rebuild()
			await process_frame
			check(game.hud.field_menu.get_global_rect().end.y <= root.size.y,"Menu fits portrait and landscape")
	game.hud.toggle_menu()
	game.stage = 3
	var thumb = InputEventScreenTouch.new()
	thumb.index = 0
	thumb.pressed = true
	thumb.position = game.stick.get_global_rect().get_center()+Vector2(30,0)
	game.stick._input(thumb)
	check(game.stick.direction.x > 0,"First finger holds movement")
	var strike_touch = InputEventScreenTouch.new()
	strike_touch.index = 1
	strike_touch.pressed = true
	strike_touch.position = game.hud.strike_button.get_global_rect().get_center()
	game.hud.strike_button._input(strike_touch)
	check(game.cooldown > 0 and game.stick.direction.x > 0,"Second finger attacks without releasing movement")
	game.stick.reset()
	for direction in [Vector2.UP,Vector2.DOWN,Vector2.LEFT,Vector2.RIGHT]:
		game.actor.position = Vector2(750,490)
		game.actor.motion = direction
		game.actor.facing = direction
		game.target.position = game.actor.position+direction*65
		game.target.health = 100
		game.cooldown = 0
		game.attack()
		check(game.target.health < 100,"Attack hits in each movement direction")
		check(game.actor.motion == direction,"Attacking preserves movement")
		game.target.position = game.actor.position-direction*65
		game.target.health = 100
		game.cooldown = 0
		game.attack()
		check(game.target.health == 100,"Cannot hit behind facing")
	game.actor.position = Vector2(750,490)
	game.actor.motion = Vector2.RIGHT
	game.dodge()
	check(not game.can_receive_damage(),"Dodge provides future invulnerability gate")
	var position_before = game.actor.position
	game._process(.1)
	check(game.actor.position.x > position_before.x+40,"Directional dodge displacement")
	game._process(.3)
	check(game.can_receive_damage(),"Invulnerability expires")
	game.stage = 6
	game._save()
	var save = slots.read_slot(1).checkpoint.state
	var restored = load("res://scripts/field_kit.gd").new()
	restored.restore(save,true,true)
	check(restored.points == 2 and restored.upgrades.Endurance == 1,"Upgrade and points persist")
	check(restored.inventory.ration == 2,"Food count persists")
	game.queue_free()
	await process_frame
	slots.delete_slot(1)
	print("FIELD KIT TESTS: PASS" if not failed else "FIELD KIT TESTS: FAIL")
	quit(1 if failed else 0)
