extends PanelContainer
signal hero_selected(id: String)
signal confirmed
signal back_requested
const Portrait = preload("res://scripts/hero_portrait.gd")
const Ornate = preload("res://scripts/ornate_button.gd")
const GOLD = Color("d8b56f")
const INK = Color("101218")
const IVORY = Color("e8e1d0")
var hero_id = "kaerun"
var legacy = false
var column: VBoxContainer
var spread: BoxContainer
var photograph: TextureRect
var dossier: VBoxContainer
var identity: Label
var number: Label
var tabs: Array[Button] = []
var status: Label
var scroll: ScrollContainer

func _ready() -> void:
	var paper = StyleBoxFlat.new()
	paper.bg_color = INK
	paper.border_color = GOLD.darkened(.38)
	paper.set_border_width_all(2)
	paper.set_content_margin_all(14)
	add_theme_stylebox_override("panel",paper)
	scroll = ScrollContainer.new()
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	add_child(scroll)
	column = VBoxContainer.new()
	column.size_flags_horizontal = SIZE_EXPAND_FILL
	column.add_theme_constant_override("separation",14)
	scroll.add_child(column)
	text(column,"◇  VEYATHUUN COUNCIL  ◇",20,GOLD)
	text(column,"CITIZEN SERVICE ARCHIVE",13,GOLD)
	text(column,"Choose the hero whose legacy you will follow.",15)
	if legacy: text(column,"Your existing save is safe. Select a hero to update this record when you confirm.",14)
	var roster = GridContainer.new()
	roster.columns = 3
	roster.add_theme_constant_override("h_separation",6)
	roster.add_theme_constant_override("v_separation",6)
	column.add_child(roster)
	for id in VeyrakHeroes.IDS:
		var hero = VeyrakHeroes.record(id)
		var button = make_button(roster,hero.name,func(): select_hero(id))
		button.add_theme_font_size_override("font_size",14)
		button.toggle_mode = true
		tabs.append(button)
	line(column)
	number = text(column,"",12,GOLD)
	spread = BoxContainer.new()
	spread.add_theme_constant_override("separation",22)
	column.add_child(spread)
	var left = VBoxContainer.new()
	left.name = "Identity"
	left.size_flags_horizontal = SIZE_EXPAND_FILL
	left.add_theme_constant_override("separation",12)
	spread.add_child(left)
	var photo_frame = PanelContainer.new()
	var edge = StyleBoxFlat.new()
	edge.bg_color = Color("191817")
	edge.border_color = GOLD.darkened(.15)
	edge.set_border_width_all(1)
	edge.set_content_margin_all(6)
	photo_frame.add_theme_stylebox_override("panel",edge)
	left.add_child(photo_frame)
	photograph = Portrait.new()
	photograph.custom_minimum_size.y = 340
	photo_frame.add_child(photograph)
	identity = text(left,"",25,GOLD)
	text(left,"REGISTERED · VEYRAKIAN\nHOMEWORLD · VEYATHUUN",13)
	line(left)
	text(left,"COUNCIL SEAL\n◇\nSERVICE RECORD VERIFIED",14,GOLD)
	dossier = VBoxContainer.new()
	dossier.size_flags_horizontal = SIZE_EXPAND_FILL
	dossier.add_theme_constant_override("separation",12)
	spread.add_child(dossier)
	line(column)
	status = text(column,"",14,GOLD)
	make_button(column,"SELECT THIS HERO",func(): confirmed.emit(),true)
	make_button(column,"BACK TO SAVES",func(): back_requested.emit())
	text(column,"ARCHIVE DIVISION  /  VEYATHUUN\nLEVEL 01 · INITIAL SERVICE ASSESSMENT",12,GOLD)
	resized.connect(layout)
	layout()
	select_hero(hero_id)

func text(parent: Node, value: String, font_size: int = 16, colour: Color = IVORY) -> Label:
	var label = Label.new()
	label.text = value
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label.add_theme_font_size_override("font_size",font_size)
	label.add_theme_color_override("font_color",colour)
	label.mouse_filter = MOUSE_FILTER_IGNORE
	parent.add_child(label)
	return label

func make_button(parent: Node, value: String, action: Callable, featured: bool = false) -> Button:
	var button = Ornate.new()
	button.text = value
	button.featured = featured
	button.custom_minimum_size.y = 56
	button.size_flags_horizontal = SIZE_EXPAND_FILL
	button.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	button.pressed.connect(action)
	parent.add_child(button)
	return button

func line(parent: Node) -> void:
	var rule = ColorRect.new()
	rule.color = GOLD.darkened(.6)
	rule.custom_minimum_size.y = 1
	rule.mouse_filter = MOUSE_FILTER_IGNORE
	parent.add_child(rule)

func layout() -> void:
	if spread == null: return
	spread.vertical = size.x < 760
	spread.get_node("Identity").custom_minimum_size.x = 0 if spread.vertical else 290
	photograph.custom_minimum_size.y = 340 if spread.vertical else 420

func select_hero(id: String) -> void:
	hero_id = id
	var hero = VeyrakHeroes.record(id)
	photograph.show_hero(id)
	identity.text = hero.name.to_upper() + "\n" + hero.role
	number.text = "PERSONNEL DOSSIER  /  %s  /  %02d OF 06" % [hero.file,VeyrakHeroes.index_of(id)+1]
	for i in range(tabs.size()): tabs[i].set_pressed_no_signal(VeyrakHeroes.IDS[i] == id)
	for child in dossier.get_children():
		dossier.remove_child(child)
		child.queue_free()
	text(dossier,"01  /  IDENTIFICATION",15,GOLD)
	text(dossier,"ASSIGNMENT  " + hero.unit + "\nPHYSIQUE  " + hero.build + "\nWEAPON  " + hero.weapon,15)
	section("02  /  BACKGROUND",hero.background)
	section("03  /  FIELD DOCTRINE",hero.playstyle)
	section("04  /  CORE DISCIPLINE",hero.resource)
	for skill in hero.skills:
		text(dossier,skill[0],14,GOLD)
		text(dossier,skill[1],15)
	section("05  /  SPECIALISATION PATHS",hero.paths)
	line(dossier)
	text(dossier,"06  /  ATTRIBUTE ASSESSMENT",15,GOLD)
	text(dossier,"Starting ratings · 1–10 · 36 points per hero",13)
	for i in range(VeyrakHeroes.ATTRIBUTES.size()):
		text(dossier,"%s    %d / 10" % [VeyrakHeroes.ATTRIBUTES[i].to_upper(),hero.stats[i]],14,GOLD)
		var bar = ProgressBar.new()
		bar.max_value = 10
		bar.value = hero.stats[i]
		bar.show_percentage = false
		bar.custom_minimum_size.y = 8
		var fill = StyleBoxFlat.new()
		fill.bg_color = GOLD
		var base = StyleBoxFlat.new()
		base.bg_color = Color("282932")
		bar.add_theme_stylebox_override("fill",fill)
		bar.add_theme_stylebox_override("background",base)
		dossier.add_child(bar)
	var stats = VeyrakHeroes.derived(id)
	text(dossier,"HEALTH %d   ENERGY %d\nSTAMINA RECOVERY %d / SEC\nCRITICAL CHANCE %d%%\nMELEE ×%.2f   ABILITY ×%.2f\nBOND STRENGTH ×%.2f" % [stats.Health,stats.Energy,stats["Stamina / sec"],stats["Critical chance"],stats["Melee power"],stats["Ability power"],stats["Bond strength"]],14)
	for explanation in VeyrakHeroes.EXPLANATIONS: text(dossier,explanation,13,Color("b0ad9f"))
	section("07  /  COUNCIL OBSERVATIONS",hero.assessment)
	status.text = "Selected record: " + hero.name
	hero_selected.emit(id)

func section(title: String, body: String) -> void:
	line(dossier)
	text(dossier,title,15,GOLD)
	text(dossier,body,16)
