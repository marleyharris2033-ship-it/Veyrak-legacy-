extends Control
const GOLD = Color("dcb66e")
var game: Control
var map: Control
var hp: ProgressBar
var core: ProgressBar
var chat: PanelContainer
var speech: Label
var next: Button
var action: Button
var skill: Button
var stick: Control
var toast: Label
var toast_time = 0.0
var top: HBoxContainer
var bottom: HBoxContainer
var pending = false
var field_menu: Control
var hotbar: HBoxContainer
var quick_slots: Array[Button] = []
var dodge_button: Button
var menu_button: Button
var strike_button: Button
func _ready() -> void:
	set_anchors_and_offsets_preset(PRESET_FULL_RECT)
	mouse_filter = MOUSE_FILTER_IGNORE
	theme = Theme.new()
	theme.default_font = preload("res://assets/fonts/DejaVuSansMono.ttf")
	theme.default_font_size = 14
	top = HBoxContainer.new()
	add_child(top)
	top.add_theme_constant_override("separation",8)
	var frame = panel(top)
	frame.size_flags_horizontal = SIZE_EXPAND_FILL
	var row = HBoxContainer.new()
	frame.add_child(row)
	var portrait = preload("res://scripts/hero_portrait.gd").new()
	portrait.hero_id = game.profile.hero_id
	portrait.custom_minimum_size = Vector2(46,60)
	row.add_child(portrait)
	var bars = VBoxContainer.new()
	bars.size_flags_horizontal = SIZE_EXPAND_FILL
	row.add_child(bars)
	label(bars,game.profile.name.to_upper())
	hp = meter(bars,Color("aa4945"))
	core = meter(bars,Color("448cb8"))
	map = preload("res://scripts/terrace_minimap.gd").new()
	top.add_child(map)
	bottom = HBoxContainer.new()
	bottom.add_theme_constant_override("separation",8)
	add_child(bottom)
	stick = preload("res://scripts/move_stick.gd").new()
	bottom.add_child(stick)
	var spacer = Control.new()
	spacer.size_flags_horizontal = SIZE_EXPAND_FILL
	spacer.mouse_filter = MOUSE_FILTER_IGNORE
	bottom.add_child(spacer)
	var buttons = VBoxContainer.new()
	bottom.add_child(buttons)
	var combat = HBoxContainer.new()
	buttons.add_child(combat)
	strike_button = button(combat,"STRIKE",game.attack)
	skill = button(combat,"CORE",game.ability)
	dodge_button = button(buttons,"DODGE",game.dodge)
	action = button(buttons,"TALK",game.interact)
	var menu = button(self,"☰",toggle_menu)
	menu_button = menu
	menu.position = Vector2(10,126)
	menu.size = Vector2(48,48)
	menu.tooltip_text = "Inventory, equipment and attributes"
	hotbar = HBoxContainer.new()
	hotbar.add_theme_constant_override("separation",4)
	add_child(hotbar)
	for i in range(3):
		var slot = button(hotbar,"",func(): game.use_food(i))
		slot.add_theme_constant_override("icon_max_width",24)
		slot.custom_minimum_size = Vector2(72,48)
		quick_slots.append(slot)
	toast = label(self,"")
	toast.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	toast.hide()
	chat = panel(self)
	var box = VBoxContainer.new()
	chat.add_child(box)
	label(box,"VEYATHUUN COUNCIL")
	speech = label(box,"")
	speech.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	speech.add_theme_color_override("font_color",Color("eee8d8"))
	next = button(box,"CONTINUE",close_chat)
	chat.hide()
	field_menu = preload("res://scripts/field_menu.gd").new()
	field_menu.game = game
	add_child(field_menu)
	field_menu.hide()
	resized.connect(layout)
	layout()
func panel(parent: Node) -> PanelContainer:
	var p = PanelContainer.new()
	var b = StyleBoxFlat.new()
	b.bg_color = Color("09121af5")
	b.border_color = GOLD
	b.set_border_width_all(2)
	b.set_corner_radius_all(4)
	b.set_content_margin_all(8)
	p.add_theme_stylebox_override("panel",b)
	parent.add_child(p)
	return p
func label(parent: Node, text: String) -> Label:
	var l = Label.new()
	l.text = text
	l.add_theme_color_override("font_color",GOLD)
	l.mouse_filter = MOUSE_FILTER_IGNORE
	parent.add_child(l)
	return l
func meter(parent: Node, colour: Color) -> ProgressBar:
	var p = ProgressBar.new()
	p.custom_minimum_size = Vector2(70,15)
	p.show_percentage = false
	for type in ["background","fill"]:
		var b = StyleBoxFlat.new()
		b.bg_color = colour if type == "fill" else Color("172331")
		b.border_color = Color("b49b67")
		b.set_border_width_all(1)
		p.add_theme_stylebox_override(type,b)
	parent.add_child(p)
	return p
func button(parent: Node, text: String, callback: Callable) -> Button:
	var b = preload("res://scripts/touch_action.gd").new()
	b.text = text
	b.custom_minimum_size = Vector2(76,48)
	b.size_flags_horizontal = SIZE_EXPAND_FILL
	b.activated.connect(callback)
	parent.add_child(b)
	return b
func layout() -> void:
	top.position = Vector2(10,10)
	top.size = Vector2(minf(size.x-20,440),76)
	bottom.position = Vector2(10,size.y-166)
	bottom.size = Vector2(size.x-20,156)
	hotbar.position = Vector2((size.x-224)/2,size.y-220)
	hotbar.size = Vector2(224,48)
	field_menu.position = Vector2(maxf(10,(size.x-560)/2),10)
	field_menu.size = Vector2(minf(560,size.x-20),size.y-20)
	chat.position = Vector2(maxf(10,(size.x-540)/2),maxf(100,size.y-320))
	chat.size = Vector2(minf(540,size.x-20),180)
	toast.position = Vector2(10,size.y-250)
	toast.size = Vector2(size.x-20,28)
func say(value: String, advance: bool) -> void:
	pending = advance
	speech.text = value
	chat.show()
	stick.reset()
	game.actor.motion = Vector2.ZERO
	layout()
func toggle_menu() -> void:
	if chat.visible: return
	field_menu.visible = not field_menu.visible
	menu_button.visible = not field_menu.visible
	stick.reset()
	game.actor.motion = Vector2.ZERO
	bottom.visible = not field_menu.visible
	hotbar.visible = not field_menu.visible
	if field_menu.visible: field_menu.rebuild()
func blocked() -> bool:
	return chat.visible or field_menu.visible
func close_chat() -> void:
	chat.hide()
	if pending:
		pending = false
		game._advance()
func notify(value: String, persistent: bool = false) -> void:
	toast.text = value
	toast.show()
	toast_time = 99999 if persistent else 2.5
func _process(delta: float) -> void:
	for i in range(3):
		var id = game.kit.hotbar[i]
		quick_slots[i].icon = preload("res://assets/ui/field-ration.svg") if id == "ration" else preload("res://assets/ui/core-nectar.svg") if id == "nectar" else null
		quick_slots[i].text = "%d · %d" % [i+1,game.kit.inventory.get(id,0)] if id != "" else "%d · —" % [i+1]
		quick_slots[i].disabled = id == "" or game.kit.inventory.get(id,0) <= 0
	dodge_button.text = "DODGE %ds" % ceili(game.dodge_cooldown) if game.dodge_cooldown > 0 else "DODGE"
	toast_time -= delta
	if toast_time <= 0: toast.hide()
	hp.max_value = game.stats().Health
	hp.value = game.health
	core.max_value = game.stats().Energy
	core.value = game.energy
	map.player = game.actor.position
	map.goal = game.target.position if game.stage in [2,3] else game.marker.position
	map.complete = game.stage == 6
	map.queue_redraw()
	skill.text = "%ds" % ceili(game.ability_cooldown) if game.ability_cooldown > 0 else "CORE"
	action.text = "EQUIP" if game.stage == 4 and game.claimed else "COLLECT" if game.stage == 4 else "TALK"
	action.visible = (game.stage in [1,5,6] and game.actor.position.distance_to(game.instructor.position)<100) or (game.stage == 4 and game.actor.position.distance_to(Vector2(1120,600))<100)
