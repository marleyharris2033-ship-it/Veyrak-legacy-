extends Control
## A contained Council exercise; persistent lessons, equipment and hero identity.
const Actor = preload("res://scripts/hero_actor.gd")
const Stick = preload("res://scripts/move_stick.gd")
const Target = preload("res://scripts/training_target.gd")
const TERRACE = preload("res://assets/tutorial/council-terrace.png")
const GOLD = Color("efbb64")
const BOUNDS = Rect2(235,320,1060,340)
const LESSONS = ["Move to the gold beacon.", "Approach the Council projection. Tap ACTION.", "Destroy the construct. Tap ATTACK nearby.", "Use your signature ability on the new construct.", "Claim the training core, then equip it.", "Return to the projection for your assessment.", "Training complete. Explore or return to title."]
var profile: Dictionary
var stage = 0
var equipped = false
var claimed = false
var seconds = 0.0
var save_timer = 0.0
var cooldown = 0.0
var ability_cooldown = 0.0
var health = 100.0
var energy = 100.0
var arena: Control
var world: Node2D
var actor: Node2D
var target: Node2D
var instructor: Node2D
var marker: Polygon2D
var stick: Control
var objective: Label
var vitals: Label
var status: Label
var action_button: Button
var ability_button: Button
var effects: Node2D
var turret_time = 0.0
var turret_tick = 0.0
var hit_count = 0
var bearing: Label
var hud: Control

func _ready() -> void:
	profile = SaveSlots.current_profile()
	if VeyrakHeroes.index_of(profile.get("hero_id","")) < 0:
		get_tree().change_scene_to_file("res://home.tscn")
		return
	var state: Dictionary = SaveSlots.checkpoint.get("state",{})
	stage = clampi(int(state.get("lesson",0)),0,6)
	claimed = bool(state.get("claimed",false))
	equipped = claimed and bool(state.get("equipped",false))
	seconds = float(state.get("play_seconds",0))
	_build_ui()
	actor.position = Vector2(clampf(float(state.get("x",440)),235,1295),clampf(float(state.get("y",600)),320,660))
	health = float(stats().Health)
	energy = float(stats().Energy)
	_refresh_stage()
	status.text = "Move: stick / WASD · Attack: Space · Ability: Q · Action: E"

func stats() -> Dictionary:
	var bonuses = {}
	if equipped:
		bonuses[["Might","Agility","Core","Core","Precision","Resonance"][VeyrakHeroes.index_of(profile.hero_id)]] = 2
	return VeyrakHeroes.derived(profile.hero_id,1,bonuses)

func _build_ui() -> void:
	arena = Control.new()
	arena.set_anchors_and_offsets_preset(PRESET_FULL_RECT)
	arena.clip_contents = true
	add_child(arena)
	world = Node2D.new()
	arena.add_child(world)
	var floor_sprite = Sprite2D.new()
	floor_sprite.texture = TERRACE
	floor_sprite.centered = false
	world.add_child(floor_sprite)
	instructor = Actor.new()
	instructor.hero_id = "saevra"
	instructor.position = Vector2(680,450)
	instructor.modulate = Color(.4,.8,1,.65)
	world.add_child(instructor)
	marker = Polygon2D.new()
	marker.polygon = PackedVector2Array([Vector2(0,-12),Vector2(24,0),Vector2(0,12),Vector2(-24,0)])
	marker.color = GOLD
	world.add_child(marker)
	target = Target.new()
	target.position = Vector2(1020,500)
	world.add_child(target)
	actor = Actor.new()
	actor.hero_id = profile.hero_id
	world.add_child(actor)
	effects = Node2D.new()
	world.add_child(effects)

	hud = preload("res://scripts/training_hud.gd").new()
	hud.game = self
	add_child(hud)
	stick = hud.stick
	action_button = hud.action
	ability_button = hud.skill
	# Nonvisual state labels retained for compatibility; no instructional text in HUD.
	status = Label.new()
	status.hide()
	add_child(status)
	objective = Label.new()
	objective.hide()
	add_child(objective)
	vitals = Label.new()
	vitals.hide()
	add_child(vitals)
	bearing = Label.new()
	bearing.hide()
	add_child(bearing)

func _label(parent: Node, value: String, font_size: int) -> Label:
	var label = Label.new()
	label.text = value
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label.add_theme_font_size_override("font_size",font_size)
	label.add_theme_color_override("font_color",GOLD)
	parent.add_child(label)
	return label

func _button(parent: Node, value: String, action: Callable) -> Button:
	var button = Button.new()
	button.text = value
	button.custom_minimum_size.y = 48
	button.size_flags_horizontal = SIZE_EXPAND_FILL
	for state in ["normal","hover","pressed","focus"]:
		var box = StyleBoxFlat.new()
		box.bg_color = Color("101b2b")
		box.border_color = GOLD
		box.set_border_width_all(1)
		box.set_content_margin_all(8)
		button.add_theme_stylebox_override(state,box)
	button.pressed.connect(action)
	parent.add_child(button)
	return button

func _process(delta: float) -> void:
	if not is_instance_valid(actor): return
	if hud.chat.visible:
		actor.motion = Vector2.ZERO
		return
	seconds += delta
	save_timer += delta
	cooldown = maxf(0,cooldown-delta)
	ability_cooldown = maxf(0,ability_cooldown-delta)
	energy = minf(float(stats().Energy),energy+delta*10)
	var direction: Vector2 = stick.direction
	if Input.is_physical_key_pressed(KEY_W) or Input.is_physical_key_pressed(KEY_UP): direction.y -= 1
	if Input.is_physical_key_pressed(KEY_S) or Input.is_physical_key_pressed(KEY_DOWN): direction.y += 1
	if Input.is_physical_key_pressed(KEY_A) or Input.is_physical_key_pressed(KEY_LEFT): direction.x -= 1
	if Input.is_physical_key_pressed(KEY_D) or Input.is_physical_key_pressed(KEY_RIGHT): direction.x += 1
	actor.motion = direction.limit_length()
	actor.position += actor.motion*170*delta
	actor.position = actor.position.clamp(BOUNDS.position,BOUNDS.end)
	world.position = arena.size*.5-actor.position
	var goal: Vector2 = target.position if stage in [2,3] else marker.position
	var offset = goal-actor.position
	var compass = ("E" if offset.x > 40 else "W" if offset.x < -40 else "") + ("S" if offset.y > 40 else "N" if offset.y < -40 else "")
	bearing.text = "OBJECTIVE %s · %dm" % [compass,ceili(offset.length()/20)] if stage < 6 else "COUNCIL CLEARANCE GRANTED"
	if stage == 0 and actor.position.distance_to(Vector2(560,570)) < 38: _advance()
	if turret_time > 0:
		turret_time -= delta
		turret_tick -= delta
		if turret_tick <= 0:
			turret_tick = .6
			_damage(30,500,Color("75d7ff"))
	if save_timer > 10:
		save_timer = 0
		_save()
	vitals.text = "HP %d · ENERGY %d · CORE %s" % [health,energy,"+2" if equipped else "—"]
	ability_button.text = "ABILITY %ds" % ceili(ability_cooldown) if ability_cooldown > 0 else "ABILITY"

func _unhandled_key_input(event: InputEvent) -> void:
	if hud.chat.visible:
		if event.is_action_pressed("ui_accept") or event.is_action_pressed("ui_cancel"): hud.close_chat()
		return
	if not event is InputEventKey or not event.pressed or event.echo: return
	match event.physical_keycode:
		KEY_SPACE: attack()
		KEY_Q: ability()
		KEY_E: interact()
		KEY_ESCAPE: _exit()

func _notification(what: int) -> void:
	if what == NOTIFICATION_APPLICATION_FOCUS_OUT and is_instance_valid(stick):
		stick.reset()
		_save()

func _refresh_stage() -> void:
	objective.text = "COUNCIL TRAINING · %d/6\n%s" % [mini(stage+1,6),LESSONS[stage]]
	marker.visible = stage not in [2,3,6]
	marker.position = Vector2(560,570) if stage == 0 else instructor.position
	if stage == 4: marker.position = Vector2(1120,600)
	target.health = 100 if stage in [2,3] else 0
	action_button.text = "EQUIP CORE" if stage == 4 and claimed else "ACTION"

func _advance() -> void:
	stage = mini(stage+1,6)
	_refresh_stage()
	_save()
	if stage == 6: status.text = "Council assessment complete. Training core equipped. Your legacy is saved."

func attack() -> void:
	if hud.chat.visible or cooldown > 0: return
	cooldown = .4
	actor.facing = (target.position-actor.position).normalized() if stage in [2,3] else actor.facing
	actor.play_attack()
	var reach = 330.0 if profile.hero_id in ["nyvara","dhoran","ilyra"] else 125.0
	if stage in [2,3]: _damage(24*float(stats()["Melee power"]),reach,GOLD)
	else: _strike_visual(actor.position+actor.facing*80,false)

func _damage(amount: float, reach: float, colour: Color, signature: bool = false) -> bool:
	if target.health <= 0 or actor.position.distance_to(target.position) > reach:
		status.text = "Move closer to the construct. It is east of the projection."
		return false
	_strike_visual(target.position,true)
	target.health = maxi(1 if stage == 3 and not signature else 0,target.health-int(amount))
	hit_count += 1
	status.text = "Construct integrity: %d%%" % target.health
	if target.health == 0 and stage == 2: _advance()
	return true

func ability() -> void:
	if stage == 6 and not hud.chat.visible and ability_cooldown <= 0 and energy >= 25:
		actor.play_signature()
		_signature_effect(profile.hero_id)
		_strike_visual(actor.position+actor.facing*90,false)
		ability_cooldown = 6
		energy -= 25
		return
	if hud.chat.visible or stage not in [2,3] or ability_cooldown > 0 or energy < 25: return
	if actor.position.distance_to(target.position) > 450:
		status.text = "Approach the construct before using your ability."
		return
	var id: String = profile.hero_id
	var names = {"kaerun":"Sovereign Impact","vaelis":"Phase Sever","dhoran":"Bastion Engine","saevra":"Gravity Crown","nyvara":"Dead Horizon","ilyra":"Convergence"}
	var was_ability_lesson = stage == 3
	if id == "kaerun": actor.play_signature()
	if id == "vaelis": actor.position = (target.position+Vector2(-60,25)).clamp(BOUNDS.position,BOUNDS.end)
	if id == "saevra": target.position = actor.position+Vector2(65,0)
	if id == "kaerun": actor.position = (target.position+Vector2(-80,25)).clamp(BOUNDS.position,BOUNDS.end)
	if not _damage(110*float(stats()["Ability power"]),500,Color("a8cfff"),true): return
	energy -= 25
	ability_cooldown = 6
	if id == "dhoran":
		turret_time = 3
		turret_tick = .6
	if id == "ilyra": health = minf(float(stats().Health),health+40)
	_signature_effect(id)
	status.text = names[id]+" · Council exercise successful."
	if was_ability_lesson: _advance()

func interact() -> void:
	if hud.chat.visible: return
	if stage in [1,5]:
		if actor.position.distance_to(instructor.position) > 100:
			status.text = "Approach the blue Council projection to the north."
			return
		hud.say("Demonstrate control. Strike the eastern construct, then use your core ability. Follow the gold mark on your map." if stage == 1 else "Assessment complete. Your training core is equipped. Veyathuun expects great things of you.",true)
	elif stage == 4:
		if actor.position.distance_to(Vector2(1120,600)) > 100:
			status.text = "The gold reward beacon is southeast of the construct."
			return
		if not claimed:
			claimed = true
			hud.notify("Training core +2 · tap EQUIP")
			action_button.text = "EQUIP CORE"
			_save()
		else:
			equipped = true
			hud.notify("Training core equipped")
			_advance()
	elif stage == 6 and actor.position.distance_to(instructor.position) < 100:
		hud.say("Your assessment is complete. You may practise your strikes here, or return to title.",false)

func _save() -> Error:
	var error = SaveSlots.save_checkpoint(profile,"res://tutorial.tscn","Council Training Terrace",{"phase":"tutorial","lesson":stage,"claimed":claimed,"equipped":equipped,"x":actor.position.x,"y":actor.position.y,"play_seconds":int(seconds)})
	if error != OK: hud.notify("Save failed. Please retry.",true)
	return error

func _exit() -> void:
	if _save() != OK: return
	SaveSlots.active_slot = 0
	get_tree().change_scene_to_file("res://home.tscn")

func _signature_effect(id: String) -> void:
	var ring = Line2D.new()
	ring.width = 4
	ring.default_color = Color("af93ed") if id in ["vaelis","ilyra"] else GOLD
	var centre: Vector2 = actor.position+Vector2(0,-30)
	var radius = 80.0 if id in ["kaerun","saevra"] else 28.0
	for i in range(33):
		var angle = TAU*i/32.0
		ring.add_point(centre+Vector2(cos(angle)*radius,sin(angle)*radius*.5))
	effects.add_child(ring)
	var tween = create_tween()
	tween.tween_property(ring,"modulate:a",0.0,.8)
	tween.tween_callback(ring.queue_free)

func _strike_visual(destination: Vector2, hit: bool) -> void:
	var origin: Vector2 = actor.position+Vector2(0,-38)
	var end = destination+Vector2(0,-38)
	var ranged = profile.hero_id in ["dhoran","nyvara","ilyra"]
	var colour = Color("bd91ff") if profile.hero_id in ["vaelis","ilyra"] else GOLD
	if ranged:
		var bolt = Polygon2D.new()
		bolt.polygon = PackedVector2Array([Vector2(-10,-2),Vector2(8,-3),Vector2(13,0),Vector2(8,3),Vector2(-10,2)])
		bolt.color = colour
		bolt.position = origin
		bolt.rotation = (end-origin).angle()
		effects.add_child(bolt)
		var flight = create_tween()
		flight.tween_property(bolt,"position",end,.16)
		flight.tween_callback(bolt.queue_free)
		if hit: flight.tween_callback(func(): _impact(end,colour))
	else:
		var arc = Line2D.new()
		arc.width = 4
		arc.default_color = colour
		arc.position = origin
		arc.rotation = (end-origin).angle()
		for i in range(13):
			var angle = -.8+1.6*i/12
			arc.add_point(Vector2(cos(angle)*48,sin(angle)*34))
		effects.add_child(arc)
		arc.scale = Vector2(.3,.3)
		var swing = create_tween()
		swing.tween_property(arc,"scale",Vector2(1.3,1.3),.12)
		if hit: swing.tween_callback(func(): _impact(end,colour))
		swing.tween_property(arc,"modulate:a",0.0,.12)
		swing.tween_callback(arc.queue_free)

func _impact(at: Vector2, colour: Color) -> void:
	for i in range(8):
		var spark = Polygon2D.new()
		spark.polygon = PackedVector2Array([Vector2(-2,-2),Vector2(2,-2),Vector2(2,2),Vector2(-2,2)])
		spark.position = at
		spark.color = colour
		effects.add_child(spark)
		var burst = create_tween().set_parallel(true)
		burst.tween_property(spark,"position",at+Vector2.from_angle(TAU*i/8)*26,.18)
		burst.tween_property(spark,"modulate:a",0.0,.2)
		burst.chain().tween_callback(spark.queue_free)
