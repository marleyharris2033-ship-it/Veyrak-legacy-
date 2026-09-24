extends Control
const GOLD = Color("dcb66e")
const IVORY = Color("eee4ce")
const HudAction = preload("res://scripts/hud_action.gd")
const FacePortrait = preload("res://scripts/hero_face_portrait.gd")
var game: Control
var map: Control
var hp: ProgressBar
var core: ProgressBar
var top_frame: PanelContainer
var chat: PanelContainer
var speech: Label
var next: Button
var action: Button
var skill: Button
var stick: Control
var toast: Label
var toast_time = 0.0
var pending = false
var field_menu: Control
var hotbar_panel: PanelContainer
var hotbar: HBoxContainer
var quick_slots: Array[Button] = []
var dodge_button: Button
var strike_button: Button
var pack_button: Button
var character_button: Button

func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	theme = Theme.new()
	theme.default_font = preload("res://assets/fonts/DejaVuSansMono.ttf")
	theme.default_font_size = 13
	top_frame = panel(self,7)
	var identity = HBoxContainer.new()
	identity.add_theme_constant_override("separation",8)
	top_frame.add_child(identity)
	var portrait = FacePortrait.new()
	portrait.hero_id = game.profile.hero_id
	portrait.custom_minimum_size = Vector2(44,44)
	identity.add_child(portrait)
	var bars = VBoxContainer.new()
	bars.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	bars.add_theme_constant_override("separation",3)
	identity.add_child(bars)
	var name = label(bars,game.profile.name.to_upper())
	name.add_theme_font_size_override("font_size",12)
	hp = meter(bars,Color("aa4945"))
	core = meter(bars,Color("448cb8"))
	map = preload("res://scripts/terrace_minimap.gd").new()
	add_child(map)
	pack_button = icon_button(self,"res://assets/ui/hud-pack.svg",func(): open_menu("PACK"))
	character_button = icon_button(self,"res://assets/ui/hud-character.svg",func(): open_menu("STATS"))
	stick = preload("res://scripts/move_stick.gd").new()
	add_child(stick)
	strike_button = icon_button(self,"res://assets/ui/hud-attack.svg",game.attack)
	skill = icon_button(self,"res://assets/ui/hud-core.svg",game.ability)
	dodge_button = icon_button(self,"res://assets/ui/hud-dodge.svg",game.dodge)
	action = button(self,"TALK",game.interact)
	action.custom_minimum_size = Vector2(92,42)
	hotbar_panel = panel(self,4)
	hotbar = HBoxContainer.new()
	hotbar.add_theme_constant_override("separation",2)
	hotbar_panel.add_child(hotbar)
	for i in range(8):
		var slot = HudAction.new()
		slot.text = ""
		slot.tooltip_text = "Field slot %d" % [i+1]
		slot.activated.connect(func(slot_index=i): game.use_hotbar(slot_index))
		hotbar.add_child(slot)
		quick_slots.append(slot)
	toast = label(self,"")
	toast.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	toast.hide()
	chat = panel(self,12)
	var chat_box = VBoxContainer.new()
	chat_box.add_theme_constant_override("separation",8)
	chat.add_child(chat_box)
	var speaker = label(chat_box,"VEYATHUUN COUNCIL")
	speaker.add_theme_font_size_override("font_size",13)
	speech = label(chat_box,"")
	speech.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	speech.add_theme_color_override("font_color",IVORY)
	speech.size_flags_vertical = Control.SIZE_EXPAND_FILL
	next = button(chat_box,"CONTINUE",close_chat)
	chat.hide()
	field_menu = preload("res://scripts/field_menu.gd").new()
	field_menu.game = game
	add_child(field_menu)
	field_menu.hide()
	resized.connect(layout)
	layout()

func panel(parent: Node, padding: int = 8) -> PanelContainer:
	var p = PanelContainer.new()
	var b = StyleBoxFlat.new()
	b.bg_color = Color("07111bef")
	b.border_color = GOLD
	b.set_border_width_all(2)
	b.set_corner_radius_all(5)
	b.set_content_margin_all(padding)
	p.add_theme_stylebox_override("panel",b)
	parent.add_child(p)
	return p

func label(parent: Node, value: String) -> Label:
	var l = Label.new()
	l.text = value
	l.add_theme_color_override("font_color",GOLD)
	l.mouse_filter = Control.MOUSE_FILTER_IGNORE
	parent.add_child(l)
	return l

func meter(parent: Node, colour: Color) -> ProgressBar:
	var p = ProgressBar.new()
	p.custom_minimum_size = Vector2(88,8)
	p.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	p.show_percentage = false
	for type in ["background","fill"]:
		var b = StyleBoxFlat.new()
		b.bg_color = colour if type == "fill" else Color("121d29")
		b.border_color = Color("b89958")
		b.set_border_width_all(1)
		p.add_theme_stylebox_override(type,b)
	parent.add_child(p)
	return p

func button(parent: Node, value: String, callback: Callable) -> Button:
	var b = preload("res://scripts/touch_action.gd").new()
	b.text = value
	b.custom_minimum_size = Vector2(72,44)
	b.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	b.activated.connect(callback)
	parent.add_child(b)
	return b

func icon_button(parent: Node, icon_path: String, callback: Callable) -> Button:
	var b = HudAction.new()
	b.icon = load(icon_path)
	b.text = ""
	b.custom_minimum_size = Vector2(62,62)
	b.activated.connect(callback)
	parent.add_child(b)
	return b

func slot_style(selected: bool) -> StyleBoxFlat:
	var box = StyleBoxFlat.new()
	box.bg_color = Color("07111be8")
	box.border_color = Color("fff0bd") if selected else Color("9d7d45")
	box.set_border_width_all(2 if selected else 1)
	box.set_corner_radius_all(3)
	box.set_content_margin_all(3)
	return box

func open_menu(target_tab: String) -> void:
	if chat.visible:
		return
	field_menu.tab = target_tab
	field_menu.show()
	field_menu.rebuild()
	pack_button.hide()
	character_button.hide()
	stick.reset()
	game.actor.motion = Vector2.ZERO
	set_field_controls_visible(false)

func toggle_menu() -> void:
	if chat.visible:
		return
	if field_menu.visible:
		field_menu.hide()
		pack_button.show()
		character_button.show()
		set_field_controls_visible(true)
	else:
		open_menu("PACK")

func set_field_controls_visible(value: bool) -> void:
	stick.visible = value
	strike_button.visible = value
	skill.visible = value
	dodge_button.visible = value
	hotbar_panel.visible = value
	if not value:
		action.hide()

func blocked() -> bool:
	return chat.visible or field_menu.visible

func layout() -> void:
	if size.x <= 0 or size.y <= 0:
		return
	var portrait_mode = size.y > size.x*1.12
	var margin = 8.0
	var map_side = 82.0 if portrait_mode else 92.0
	var top_h = 54.0 if portrait_mode else 60.0
	var frame_w = clampf(size.x-map_side-24.0,172.0,260.0)
	top_frame.position = Vector2(margin,margin)
	top_frame.size = Vector2(frame_w,top_h)
	map.position = Vector2(size.x-map_side-margin,margin)
	map.size = Vector2(map_side,map_side)
	pack_button.position = Vector2(margin,top_h+18)
	character_button.position = Vector2(margin,top_h+68)
	var side_icon = 50.0 if portrait_mode else 56.0
	pack_button.size = Vector2(side_icon,side_icon)
	character_button.size = Vector2(side_icon,side_icon)
	var slot_side = clampf((size.x-30.0)/8.0,42.0,54.0)
	for slot in quick_slots:
		slot.custom_minimum_size = Vector2(slot_side,slot_side)
		slot.size = Vector2(slot_side,slot_side)
	var hot_w = slot_side*8.0+14.0
	var hot_h = slot_side+8.0
	hotbar_panel.position = Vector2((size.x-hot_w)*.5,size.y-hot_h-6)
	hotbar_panel.size = Vector2(hot_w,hot_h)
	var stick_side = 96.0 if portrait_mode else 112.0
	stick.position = Vector2(10,size.y-hot_h-stick_side-14)
	stick.size = Vector2(stick_side,stick_side)
	var action_side = 58.0 if portrait_mode else 64.0
	strike_button.size = Vector2(action_side,action_side)
	skill.size = Vector2(action_side,action_side)
	dodge_button.size = Vector2(action_side,action_side)
	if portrait_mode:
		strike_button.position = Vector2(size.x-action_side*2-18,size.y-hot_h-action_side*2-24)
		skill.position = Vector2(size.x-action_side-10,size.y-hot_h-action_side*2-24)
		dodge_button.position = Vector2(size.x-action_side-10,size.y-hot_h-action_side-12)
		action.position = Vector2(size.x-158,size.y-hot_h-action_side*3-16)
		action.size = Vector2(148,40)
	else:
		strike_button.position = Vector2(size.x-action_side*2-22,size.y-hot_h-action_side-18)
		skill.position = Vector2(size.x-action_side-10,size.y-hot_h-action_side-18)
		dodge_button.position = Vector2(size.x-action_side-10,size.y-hot_h+2)
		action.position = Vector2(size.x-178,size.y-hot_h-action_side-66)
		action.size = Vector2(168,40)
	field_menu.position = Vector2(maxf(8,(size.x-minf(620,size.x-16))/2),8)
	field_menu.size = Vector2(minf(620,size.x-16),size.y-16)
	var chat_w = minf(540,size.x-20)
	chat.position = Vector2((size.x-chat_w)*.5,maxf(96,size.y-hot_h-205))
	chat.size = Vector2(chat_w,150)
	toast.position = Vector2(10,maxf(92,size.y-hot_h-188))
	toast.size = Vector2(size.x-20,26)

func say(value: String, advance: bool) -> void:
	pending = advance
	speech.text = value
	chat.show()
	stick.reset()
	game.actor.motion = Vector2.ZERO
	set_field_controls_visible(false)
	layout()

func close_chat() -> void:
	chat.hide()
	set_field_controls_visible(true)
	if pending:
		pending = false
		game._advance()

func notify(value: String, persistent: bool = false) -> void:
	toast.text = value
	toast.show()
	toast_time = 99999 if persistent else 2.2

func _process(delta: float) -> void:
	if not is_instance_valid(game) or not is_instance_valid(game.actor):
		return
	for i in range(8):
		var id = str(game.kit.hotbar[i])
		var slot = quick_slots[i]
		var icon_path = game.kit.icon_path(id)
		slot.icon = load(icon_path) if id != "" and icon_path != "" else null
		slot.tooltip_text = game.kit.ITEMS.get(id,{}).get("name","Empty slot")
		var count = int(game.kit.inventory.get(id,0))
		slot.text = str(count) if game.kit.kind(id) == "food" and count > 1 else ""
		slot.disabled = id == "" or count <= 0
		var style = slot_style(i == game.kit.active_slot)
		for state in ["normal","hover","pressed","focus","disabled"]:
			slot.add_theme_stylebox_override(state,style)
	toast_time -= delta
	if toast_time <= 0:
		toast.hide()
	hp.max_value = game.stats().Health
	hp.value = game.health
	core.max_value = game.stats().Energy
	core.value = game.energy
	map.player = game.actor.position
	map.goal = game.target.position if game.stage in [2,3] else game.marker.position
	map.complete = game.stage == 6
	map.queue_redraw()
	skill.text = str(ceili(game.ability_cooldown)) if game.ability_cooldown > 0 else ""
	dodge_button.text = str(ceili(game.dodge_cooldown)) if game.dodge_cooldown > 0 else ""
	action.text = "EQUIP" if game.stage == 4 and game.claimed else "COLLECT" if game.stage == 4 else "TALK"
	action.visible = ((game.stage in [1,5,6] and game.actor.position.distance_to(game.instructor.position)<100) or (game.stage == 4 and game.actor.position.distance_to(Vector2(1120,600))<100)) and not chat.visible and not field_menu.visible
