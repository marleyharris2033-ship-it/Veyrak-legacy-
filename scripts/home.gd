extends Control
## Opening state machine. All screens use logical pixels and native containers.
const Portrait = preload("res://scripts/hero_portrait.gd")
const Selector = preload("res://scripts/hero_selector.gd")
const Ornate = preload("res://scripts/ornate_button.gd")
const CITY = preload("res://assets/creator/veyathuun-background-v1.png")
const GOLD = Color("efbb64")
const BLUE = Color("bfcee8")
const NARRATION = [
"For millennia, the Veyrakians of Veyathuun have stood unrivalled.",
"Born beneath the crushing gravity of their homeworld, generations of hardship forged a people of extraordinary strength.",
"Their cities rose across Veyathuun. Then beyond it.",
"World after world came to know their name.",
"Some became allies. Others learned to keep their distance.",
"Today, Veyathuun stands at the heart of the most powerful civilisation in the known galaxy.",
"No fleet approaches its borders without permission.",
"No empire openly challenges its authority.",
"No enemy has reached the Veyrakian homeworld in living memory.",
"The Veyrakians believe they have reached the summit of power.",
"They are wrong.",
"VEYATHUUN\nTHE VEYRAKIAN HOMEWORLD"]
var screen = "title"
var page: Control
var background: TextureRect
var shade: ColorRect
var content: VBoxContainer
var profile: Dictionary
var selector: Control
var notice: Label
var monologue_index = 0
var transition: Tween
var play_seconds = 0.0
var auto_save_seconds = 0.0

func _ready() -> void:
	_make_theme()
	background = TextureRect.new()
	background.texture = CITY
	background.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	background.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	background.texture_filter = TEXTURE_FILTER_NEAREST
	background.mouse_filter = MOUSE_FILTER_IGNORE
	background.set_anchors_and_offsets_preset(PRESET_FULL_RECT)
	add_child(background)
	shade = ColorRect.new()
	shade.color = Color(0.015,0.025,0.05,.36)
	shade.mouse_filter = MOUSE_FILTER_IGNORE
	shade.set_anchors_and_offsets_preset(PRESET_FULL_RECT)
	add_child(shade)
	get_viewport().size_changed.connect(_responsive)
	if SaveSlots.active_slot > 0:
		profile = SaveSlots.current_profile()
		var phase = SaveSlots.checkpoint.get("state",{}).get("phase","creator")
		play_seconds = float(SaveSlots.checkpoint.get("state",{}).get("play_seconds",0))
		if profile.hero_id.is_empty():
			_creator()
		elif phase == "intro":
			monologue_index = int(SaveSlots.checkpoint.state.get("intro_index",0))
			_intro()
		elif phase == "tutorial": get_tree().change_scene_to_file("res://tutorial.tscn")
		elif phase == "ready": _endpoint()
		else: _creator()
	elif SaveSlots.return_to_slots:
		SaveSlots.return_to_slots = false
		_slots()
	else: _title()

func _process(delta: float) -> void:
	if screen in ["creator","intro","ready"]: play_seconds += delta
	if screen in ["intro","ready"]:
		auto_save_seconds += delta
		if auto_save_seconds >= 15:
			auto_save_seconds = 0
			_store(screen)

func _unhandled_key_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		if screen == "creator": _creator_back()
		elif screen == "intro": _intro_exit()
		else: _title()
	if screen == "intro" and event.is_action_pressed("ui_accept"): _advance()

func _make_theme() -> void:
	theme = Theme.new()
	theme.default_font = preload("res://assets/fonts/DejaVuSansMono.ttf")
	theme.default_font_size = 18
	for type in ["Label","Button","LineEdit","CheckButton"]:
		theme.set_color("font_color",type,BLUE)
	for type in ["Button","LineEdit"]:
		for state in ["normal","hover","pressed","focus"]:
			var box = StyleBoxFlat.new()
			box.bg_color = Color("091321")
			box.border_color = GOLD if state != "normal" else Color("6e6651")
			box.set_border_width_all(1)
			box.set_content_margin_all(12)
			theme.set_stylebox(state,type,box)
		theme.set_color("font_hover_color",type,GOLD)
		theme.set_color("font_focus_color",type,GOLD)
	var slider = StyleBoxFlat.new()
	slider.bg_color = Color("465266")
	slider.content_margin_top = 5
	slider.content_margin_bottom = 5
	theme.set_stylebox("slider","HSlider",slider)

func _clear(value: String) -> void:
	if transition and transition.is_valid(): transition.kill()
	screen = value
	if is_instance_valid(page):
		remove_child(page)
		page.queue_free()
	page = Control.new()
	page.set_anchors_and_offsets_preset(PRESET_FULL_RECT)
	add_child(page)
	shade.color.a = .52 if value in ["settings","slots","delete"] else .25
	background.modulate = Color.WHITE

func _stack(width: int = 460) -> VBoxContainer:
	var scroll = ScrollContainer.new()
	scroll.set_anchors_and_offsets_preset(PRESET_FULL_RECT)
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	page.add_child(scroll)
	var margin = MarginContainer.new()
	margin.size_flags_horizontal = SIZE_EXPAND_FILL
	margin.size_flags_vertical = SIZE_EXPAND_FILL
	scroll.add_child(margin)
	var update = func():
		var s = get_viewport_rect().size
		var side = maxi(18,int((s.x-width)/2))
		margin.add_theme_constant_override("margin_left",side)
		margin.add_theme_constant_override("margin_right",side)
		margin.add_theme_constant_override("margin_top",maxi(22,int(s.y*.08)))
		margin.add_theme_constant_override("margin_bottom",28)
	update.call()
	margin.resized.connect(update)
	content = VBoxContainer.new()
	content.alignment = BoxContainer.ALIGNMENT_CENTER
	content.add_theme_constant_override("separation",14)
	margin.add_child(content)
	return content

func _label(parent: Node, value: String, font_size: int = 18, colour: Color = BLUE) -> Label:
	var label = Label.new()
	label.text = value
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.add_theme_font_size_override("font_size",font_size)
	label.add_theme_color_override("font_color",colour)
	label.add_theme_color_override("font_shadow_color",Color.BLACK)
	label.add_theme_constant_override("shadow_offset_y",2)
	label.mouse_filter = MOUSE_FILTER_IGNORE
	parent.add_child(label)
	return label

func _button(parent: Node, value: String, action: Callable, featured: bool = false) -> Button:
	var button = Ornate.new()
	button.text = value
	button.featured = featured
	button.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	button.custom_minimum_size.y = 56
	button.size_flags_horizontal = SIZE_EXPAND_FILL
	button.pressed.connect(action)
	parent.add_child(button)
	return button

func _title() -> void:
	SaveSlots.active_slot = 0
	_clear("title")
	_stack()
	_label(content,"◇",32,GOLD)
	var logo = _label(content,"VEYRAK",48,GOLD)
	logo.add_theme_font_override("font",preload("res://assets/fonts/DejaVuSerif-Bold.ttf"))
	_label(content,"L E G A C Y",25,GOLD)
	_label(content,"VEYATHUUN AWAITS",14)
	var gap = Control.new()
	gap.custom_minimum_size.y = 28
	content.add_child(gap)
	_button(content,"START",_slots,true)
	_button(content,"SETTINGS",_settings)

func _slots() -> void:
	SaveSlots.active_slot = 0
	_clear("slots")
	_stack(560)
	_label(content,"CHOOSE YOUR LEGACY",26,GOLD)
	for slot in range(1,4):
		var saved = SaveSlots.read_slot(slot)
		var text = "SLOT %d\nNEW LEGACY" % slot
		if saved.get("invalid",false): text = "SLOT %d\nSAVE NEEDS RESET" % slot
		elif not saved.is_empty():
			var seconds = int(saved.checkpoint.get("state",{}).get("play_seconds",0))
			text = "SLOT %d · %s\n%s · %dm" % [slot,saved.profile.name,saved.checkpoint.get("label","Veyathuun"),seconds/60]
		var button = _button(content,text,func(): _open_slot(slot))
		button.custom_minimum_size.y = 96
		if not saved.is_empty():
			var reset = _button(content,"RESET SLOT %d" % slot,func(): _delete_confirm(slot))
			reset.add_theme_font_size_override("font_size",14)
	_label(content,"Three independent legacies. Saved on this device and browser.",14)
	notice = _label(content,"",15,GOLD)
	_button(content,"BACK",_title)

func _open_slot(slot: int) -> void:
	var saved = SaveSlots.read_slot(slot)
	if saved.get("invalid",false):
		notice.text = "This save is unreadable. Reset it to begin a new legacy."
		return
	SaveSlots.active_slot = slot
	SaveSlots.checkpoint = saved.get("checkpoint",{})
	profile = saved.get("profile",VeyrakProfile.defaults())
	var state = SaveSlots.checkpoint.get("state",{})
	play_seconds = float(state.get("play_seconds",0))
	if profile.hero_id.is_empty():
		_creator()
		return
	match state.get("phase","creator"):
		"intro":
			monologue_index = int(state.get("intro_index",0))
			_intro()
		"tutorial": get_tree().change_scene_to_file("res://tutorial.tscn")
		"ready": _endpoint()
		_: _creator()

func _delete_confirm(slot: int) -> void:
	_clear("delete")
	_stack()
	_label(content,"END THIS LEGACY?",26,GOLD)
	_label(content,"Permanently erase slot %d? This cannot be undone. The other slots will be kept." % slot)
	_button(content,"KEEP SAVE",_slots,true)
	notice = _label(content,"",15)
	_button(content,"ERASE SLOT %d" % slot,func():
		if SaveSlots.delete_slot(slot) == OK: _slots()
		else: notice.text = "Could not erase the save. Please try again."
	)

func _settings() -> void:
	_clear("settings")
	_stack()
	_label(content,"SETTINGS",28,GOLD)
	notice = _label(content,"",14)
	for key in ["volume","music","sfx"]:
		var names = {"volume":"MASTER VOLUME","music":"MUSIC VOLUME","sfx":"SFX VOLUME"}
		var text = _label(content,names[key],18,GOLD)
		var slider = HSlider.new()
		slider.min_value = 0
		slider.max_value = 100
		slider.step = 1
		slider.value = SaveSlots.settings[key]*100
		slider.custom_minimum_size.y = 48
		content.add_child(slider)
		slider.value_changed.connect(func(value):
			SaveSlots.settings[key] = value/100.0
			text.text = "%s · %d%%" % [names[key],value]
			if SaveSlots.save_settings() != OK: notice.text = "Settings could not be saved."
		)
	if not OS.has_feature("web") or bool(JavaScriptBridge.eval("document.fullscreenEnabled === true")):
		_button(content,"TOGGLE FULLSCREEN",func():
			get_window().mode = Window.MODE_WINDOWED if get_window().mode == Window.MODE_FULLSCREEN else Window.MODE_FULLSCREEN
		)
	_button(content,"BACK",_title)

func _creator() -> void:
	_clear("creator")
	shade.color.a = .78
	var margin = MarginContainer.new()
	margin.set_anchors_and_offsets_preset(PRESET_FULL_RECT)
	for edge in ["left","right","top","bottom"]: margin.add_theme_constant_override("margin_"+edge,12)
	page.add_child(margin)
	selector = Selector.new()
	selector.legacy = not profile.name.is_empty() and profile.hero_id.is_empty()
	selector.hero_id = profile.hero_id if not profile.hero_id.is_empty() else "kaerun"
	selector.hero_selected.connect(_select_hero)
	selector.confirmed.connect(_confirm)
	selector.back_requested.connect(_creator_back)
	margin.add_child(selector)

func _select_hero(id: String) -> void:
	profile.hero_id = id
	profile.name = VeyrakHeroes.record(id).name

func _responsive() -> void:
	if screen == "creator" and is_instance_valid(selector): selector.layout()

func _creator_back() -> void:
	var dialog = ConfirmationDialog.new()
	dialog.title = "Leave hero selection?"
	dialog.dialog_text = "Your unconfirmed changes will be discarded."
	dialog.ok_button_text = "LEAVE"
	dialog.cancel_button_text = "KEEP CHOOSING"
	dialog.confirmed.connect(_slots)
	dialog.canceled.connect(dialog.queue_free)
	add_child(dialog)
	dialog.popup_centered(Vector2i(mini(360,int(size.x)-24),180))

func _store(phase: String) -> Error:
	return SaveSlots.save_checkpoint(profile,"res://home.tscn","Veyathuun",{"phase":phase,"intro_index":monologue_index,"play_seconds":int(play_seconds)})

func _confirm() -> void:
	if VeyrakHeroes.index_of(profile.hero_id) < 0: return
	profile.name = VeyrakHeroes.record(profile.hero_id).name
	var previous = SaveSlots.checkpoint.get("state",{})
	var phase = "ready" if previous.get("phase","") == "ready" else "intro"
	monologue_index = int(previous.get("intro_index",0)) if previous.get("phase","") == "intro" else 0
	if _store(phase) != OK:
		selector.status.text = "Could not save. Your selection is still here; please try again."
		return
	if phase == "ready": _endpoint()
	else: _intro()

func _intro() -> void:
	_clear("intro")
	monologue_index = clampi(monologue_index,0,NARRATION.size()-1)
	_stack(700)
	_label(content,"THE AGE OF VEYRAK",14,GOLD)
	var narrative = _label(content,NARRATION[monologue_index],26,Color("eee8d8"))
	narrative.custom_minimum_size.y = 160
	narrative.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	narrative.modulate.a = 0
	transition = create_tween()
	background.modulate = Color(.05,.05,.05,1)
	transition.set_parallel(true)
	transition.tween_property(narrative,"modulate:a",1.0,.9)
	transition.tween_property(background,"modulate",Color(.65,.65,.72,1),2.5)
	_label(content,"%02d / %02d" % [monologue_index+1,NARRATION.size()],14,GOLD)
	_button(content,"CONTINUE",_advance,true)
	_button(content,"SKIP INTRODUCTION",_finish_intro)
	_button(content,"RETURN TO TITLE",_intro_exit)
	notice = _label(content,"",14,GOLD)
	page.gui_input.connect(func(event):
		if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT: _advance()
	)

func _advance() -> void:
	if screen != "intro": return
	if monologue_index >= NARRATION.size()-1:
		_finish_intro()
		return
	monologue_index += 1
	if _store("intro") != OK:
		monologue_index -= 1
		notice.text = "Could not save your place. Tap Continue to retry."
		return
	_intro()

func _finish_intro() -> void:
	if _store("ready") != OK:
		notice.text = "Could not save your place. Please try again."
		return
	_endpoint()

func _intro_exit() -> void:
	if _store("intro") == OK: _title()
	else: notice.text = "Could not save your place. Please try again."

func _endpoint() -> void:
	_clear("ready")
	_stack()
	_label(content,"BEGIN YOUR LEGACY",28,GOLD)
	var portrait = Portrait.new()
	portrait.hero_id = profile.hero_id
	portrait.custom_minimum_size.y = 320
	content.add_child(portrait)
	_label(content,profile.name,28,GOLD)
	_label(content,"VEYRAKIAN OF VEYATHUUN",16)
	_label(content,"Your legacy is saved.\nReport to the Council training terrace.",18)
	notice = _label(content,"",14,GOLD)
	_button(content,"BEGIN TRAINING",func():
		if SaveSlots.save_checkpoint(profile,"res://tutorial.tscn","Council Training Terrace",{"phase":"tutorial","play_seconds":int(play_seconds)}) == OK:
			get_tree().change_scene_to_file("res://tutorial.tscn")
		else: notice.text = "Could not save. Please try again."
	,true)
	_button(content,"RETURN TO TITLE",func():
		if _store("ready") == OK: _title()
		else: notice.text = "Could not save. Please try again."
	,true)
