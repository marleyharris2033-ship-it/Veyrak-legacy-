extends Control

const Frame = preload("res://scripts/gold_frame.gd")
const Tile = preload("res://scripts/appearance_tile.gd")
const OrnateButton = preload("res://scripts/ornate_button.gd")
const BACKGROUND = preload("res://assets/creator/veyathuun-background-v1.png")
const CHARACTER = preload("res://assets/creator/veyrakian-default-v1.png")
const PixelPortrait = preload("res://scripts/portrait.gd")
const REFERENCE = preload("res://assets/creator/layout-reference.jpeg")
const PALETTE = preload("res://assets/creator/character_palette.gdshader")
const GOLD = Color("efbb64")
const BLUE = Color("a5b9ed")
const KEYS = ["build", "face", "ridge", "brow", "hair", "hair_colour", "eyes", "skin", "markings", "outfit", "accent"]
const TITLES = ["BODY TYPE", "FACE", "CRANIAL RIDGE", "BROW", "HAIR STYLE", "HAIR COLOUR", "EYES", "SKIN TONE", "MARKINGS", "OUTFIT", "ARMOUR ACCENT"]
var profile: Dictionary
var initial_profile: Dictionary
var canvas: Control
var extent: Control
var scroll: ScrollContainer
var background: TextureRect
var scene_background: TextureRect
var warrior: TextureRect
var live_character: Control
var warrior_material: ShaderMaterial
var name_input: LineEdit
var status: Label
var modal: PopupPanel
var modal_content: VBoxContainer
var rows: Dictionary = {}
var categories: Array[Button] = []
var active_category = 0
var portrait_layout = false
var compact = false
var design_scale = 1.0
var selected_row = ""
var right_panel: PanelContainer
var left_banner: TextureRect
var logo: TextureRect
var name_panel: PanelContainer
var confirm_button: Button
var back_button: Button
var quote: Label
var saved_notice = ""
var name_was_edited = false

func default_art_profile() -> Dictionary:
	var value = VeyrakProfile.defaults()
	value.merge({"art_revision": 1, "hair": 8, "skin": 2, "markings": 4, "eyes": 1}, true)
	return value

func _ready() -> void:
	if OS.has_feature("web"):
		get_window().content_scale_factor = maxf(1.0, float(JavaScriptBridge.eval("window.devicePixelRatio || 1")))
	var saved = SaveSlots.current_profile()
	profile = saved if saved.get("art_revision", 0) == 1 else default_art_profile()
	if saved.get("art_revision", 0) != 1 and not saved.name.is_empty():
		profile.name = saved.name
		saved_notice = "Your earlier character is kept until you confirm this new appearance."
	initial_profile = profile.duplicate()
	_make_theme()
	_build()
	get_viewport().size_changed.connect(_layout)
	_layout()
	_update()

func _make_theme() -> void:
	theme = Theme.new()
	theme.default_font = preload("res://assets/fonts/DejaVuSansMono.ttf")
	theme.default_font_size = 22
	theme.set_color("font_color", "Label", BLUE)
	for type in ["Button", "LineEdit"]:
		var normal = StyleBoxFlat.new()
		normal.bg_color = Color("08101d")
		normal.border_color = Color("706953")
		normal.set_border_width_all(2)
		normal.set_content_margin_all(10)
		theme.set_stylebox("normal", type, normal)
		var active = normal.duplicate()
		active.border_color = GOLD
		active.bg_color = Color("171b22")
		active.shadow_color = Color(1, 0.64, 0.2, 0.17)
		active.shadow_size = 5
		theme.set_stylebox("hover", type, active)
		theme.set_stylebox("pressed", type, active)
		theme.set_stylebox("focus", type, active)
		theme.set_color("font_color", type, BLUE)
		theme.set_color("font_hover_color", type, GOLD)
		theme.set_color("font_pressed_color", type, GOLD)
		theme.set_color("font_placeholder_color", type, Color("7c8cae"))

func _text(parent: Node, value: String, font_size: int = 22, colour: Color = GOLD) -> Label:
	var label = Label.new()
	label.text = value
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_color", colour)
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	parent.add_child(label)
	return label

func _button(parent: Node, value: String, action: Callable) -> Button:
	var button = OrnateButton.new()
	button.text = value
	button.pressed.connect(action)
	parent.add_child(button)
	return button

func _image(parent: Node, texture: Texture2D) -> TextureRect:
	var node = TextureRect.new()
	node.texture = texture
	node.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	node.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	node.mouse_filter = Control.MOUSE_FILTER_IGNORE
	node.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	parent.add_child(node)
	return node

func _atlas(region: Rect2) -> AtlasTexture:
	var atlas = AtlasTexture.new()
	atlas.atlas = REFERENCE
	atlas.region = region
	return atlas

func _place(node: Control, x: float, y: float, w: float, h: float) -> void:
	node.position = Vector2(x, y)
	node.size = Vector2(w, h)

func _build() -> void:
	background = _image(self, BACKGROUND)
	background.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	background.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	background.modulate = Color(0.3, 0.3, 0.3, 1)
	scroll = ScrollContainer.new()
	scroll.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	add_child(scroll)
	extent = Control.new()
	extent.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.add_child(extent)
	canvas = Control.new()
	extent.add_child(canvas)
	scene_background = _image(canvas, BACKGROUND)
	scene_background.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	# These are runtime crops for the approved title and decorative banner only.
	# No baked screenshot is used as the screen or to simulate interactive UI.
	logo = _image(canvas, _atlas(Rect2(38, 15, 432, 202)))
	left_banner = _image(canvas, _atlas(Rect2(24, 660, 300, 244)))
	warrior = _image(canvas, CHARACTER)
	warrior_material = ShaderMaterial.new()
	warrior_material.shader = PALETTE
	warrior.material = warrior_material
	live_character = PixelPortrait.new()
	live_character.show_face = false
	live_character.mouse_filter = Control.MOUSE_FILTER_IGNORE
	canvas.add_child(live_character)
	var category_names = ["APPEARANCE", "MARKINGS", "EYES", "OUTFIT", "NAME"]
	for i in range(5):
		var button = _button(canvas, category_names[i], func(): _category(i))
		button.toggle_mode = true
		button.alignment = HORIZONTAL_ALIGNMENT_LEFT
		button.add_theme_constant_override("h_separation", 24)
		button.icon = _atlas(Rect2(46, 246 + i * 77, 57, 53))
		button.expand_icon = true
		button.add_theme_constant_override("icon_max_width", 48)
		categories.append(button)
	right_panel = Frame.new()
	right_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	canvas.add_child(right_panel)
	for i in range(KEYS.size()): _build_row(KEYS[i], TITLES[i])
	name_panel = Frame.new()
	canvas.add_child(name_panel)
	# Place these as siblings of the frame, keeping exact reference spacing.
	var name_title = _text(canvas, "ENTER YOUR NAME", 21)
	name_title.name = "NameTitle"
	name_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	name_input = LineEdit.new()
	name_input.placeholder_text = "Veyrakian"
	name_input.max_length = 24
	name_input.alignment = HORIZONTAL_ALIGNMENT_CENTER
	name_input.text = profile.name
	name_input.text_changed.connect(func(value):
		profile.name = value
		name_was_edited = true
	)
	canvas.add_child(name_input)
	var dice = _button(canvas, "⚄", _random_name)
	dice.name = "NameDice"
	dice.tooltip_text = "Generate a character name"
	dice.add_theme_font_size_override("font_size", 36)
	confirm_button = _button(canvas, "CONFIRM CHARACTER", _confirm)
	confirm_button.featured = true
	confirm_button.add_theme_color_override("font_color", GOLD)
	back_button = _button(canvas, "❮  BACK", _back)
	quote = _text(canvas, "SAME ORIGINS.\nDIFFERENT PATHS.", 20, BLUE)
	status = _text(canvas, "", 18, Color("d1b582"))
	status.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	status.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	modal = PopupPanel.new()
	add_child(modal)
	modal_content = VBoxContainer.new()
	modal_content.add_theme_constant_override("separation", 12)
	modal.add_child(modal_content)

func _build_row(key: String, title: String) -> void:
	var root = Control.new()
	canvas.add_child(root)
	var heading = _button(root, "◇  " + title, func(): _open_choices(key))
	heading.alignment = HORIZONTAL_ALIGNMENT_LEFT
	for state in ["normal", "hover", "pressed"]: heading.add_theme_stylebox_override(state, StyleBoxEmpty.new())
	heading.add_theme_color_override("font_color", GOLD)
	var count = _text(root, "", 20, BLUE)
	count.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	var previous = _button(root, "❮", func(): _cycle(key, -1))
	var next = _button(root, "❯", func(): _cycle(key, 1))
	for arrow in [previous, next]:
		arrow.add_theme_font_size_override("font_size", 35)
		arrow.add_theme_color_override("font_color", GOLD)
		for state in ["normal", "hover", "pressed"]: arrow.add_theme_stylebox_override(state, StyleBoxEmpty.new())
	var line = ColorRect.new()
	line.color = Color("786c56")
	line.mouse_filter = Control.MOUSE_FILTER_IGNORE
	root.add_child(line)
	rows[key] = {"root": root, "heading": heading, "count": count, "previous": previous, "next": next, "line": line, "tiles": []}
	var visible_count = 6 if key in ["skin", "hair_colour", "eyes"] else (4 if key in ["build", "outfit"] else 5)
	for i in range(visible_count):
		var tile = Tile.new()
		tile.key = key
		tile.option_index = i
		tile.colour_tile = key in ["skin", "hair_colour", "eyes"]
		tile.pressed.connect(func(): _select(key, tile.option_index))
		root.add_child(tile)
		rows[key].tiles.append(tile)

func _layout() -> void:
	var viewport = get_viewport_rect().size
	portrait_layout = viewport.x < viewport.y and viewport.x < 900
	compact = viewport.x < 1000
	var dimensions = Vector2(768, 2580) if portrait_layout else Vector2(1536, 1024)
	design_scale = viewport.x / dimensions.x if portrait_layout else minf(viewport.x / dimensions.x, viewport.y / dimensions.y)
	canvas.scale = Vector2.ONE * design_scale
	canvas.size = dimensions
	_place(scene_background, 0, 0, dimensions.x, 1050 if portrait_layout else 1024)
	canvas.position = Vector2.ZERO if portrait_layout else (viewport - dimensions * design_scale) * 0.5
	extent.custom_minimum_size = Vector2(viewport.x, dimensions.y * design_scale if portrait_layout else viewport.y)
	_place(logo, 160 if portrait_layout else 35, 12, 448, 200)
	left_banner.visible = not portrait_layout
	_place(left_banner, 24, 660, 300, 244)
	for i in range(categories.size()):
		var button = categories[i]
		if portrait_layout:
			button.text = ["LOOK", "MARKS", "EYES", "OUTFIT", "NAME"][i]
			button.icon = null
			button.alignment = HORIZONTAL_ALIGNMENT_CENTER
			button.add_theme_font_size_override("font_size", 26)
			_place(button, 20 + i * 146, 218, 140, 78)
		else:
			button.text = ["APPEARANCE", "MARKINGS", "EYES", "OUTFIT", "NAME"][i]
			button.icon = _atlas(Rect2(46, 246 + i * 77, 57, 53))
			button.alignment = HORIZONTAL_ALIGNMENT_LEFT
			button.add_theme_font_size_override("font_size", 23)
			_place(button, 28, 233 + i * 78, 290, 70)
	var build_width = [0.86, 0.94, 1.0, 1.1, 1.18][profile.build]
	var character_rect = Rect2(169, 293, 430, 560) if portrait_layout else Rect2(444, 168, 458, 672)
	character_rect.position.x -= character_rect.size.x * (build_width - 1.0) * 0.5
	character_rect.size.x *= build_width
	_place(warrior, character_rect.position.x, character_rect.position.y, character_rect.size.x, character_rect.size.y)
	_place(live_character, character_rect.position.x, character_rect.position.y, character_rect.size.x, character_rect.size.y)
	# The layered pixel renderer becomes the live customisable character. Keep the approved artwork behind it as a subtle silhouette reference.
	warrior.modulate = Color(1, 1, 1, 0.12)
	live_character.scale = Vector2.ONE
	# STRETCH_SCALE applies the chosen body silhouette, keeping foot height fixed.
	warrior.stretch_mode = TextureRect.STRETCH_SCALE
	var panel_rect = Rect2(18, 1010, 732, 1320) if portrait_layout else Rect2(1046, 12, 475, 994)
	_place(right_panel, panel_rect.position.x, panel_rect.position.y, panel_rect.size.x, panel_rect.size.y)
	var row_h = 112.0 if portrait_layout else 88.0
	for i in range(KEYS.size()):
		var key = KEYS[i]
		var row = rows[key]
		var w = panel_rect.size.x - 16
		_place(row.root, panel_rect.position.x + 8, panel_rect.position.y + 5 + i * row_h, w, row_h)
		_place(row.heading, 8, 0, w - 100, 38)
		row.heading.add_theme_font_size_override("font_size", 29 if portrait_layout else 22)
		_place(row.count, w - 88, 4, 73, 30)
		_place(row.previous, 5, 35, 55, row_h - 39)
		_place(row.next, w - 56, 35, 55, row_h - 39)
		_place(row.line, 0, row_h - 1, w, 1)
		var n = row.tiles.size()
		var area = w - 118
		var tile_w = minf((area - (n - 1) * 7) / n, row_h - 41)
		var offset = 59 + (area - (n * tile_w + (n - 1) * 7)) * 0.5
		for j in range(n): _place(row.tiles[j], offset + j * (tile_w + 7), 37, tile_w, row_h - 43)
	var name_rect = Rect2(80, 861, 608, 127) if portrait_layout else Rect2(534, 803, 433, 94)
	_place(name_panel, name_rect.position.x, name_rect.position.y, name_rect.size.x, name_rect.size.y)
	_place(canvas.get_node("NameTitle"), name_rect.position.x + 15, name_rect.position.y + 8, name_rect.size.x - 30, 30)
	_place(name_input, name_rect.position.x + 32, name_rect.position.y + 39, name_rect.size.x - 112, name_rect.size.y - 51)
	name_input.add_theme_font_size_override("font_size", 31 if portrait_layout else 23)
	_place(canvas.get_node("NameDice"), name_rect.end.x - 70, name_rect.position.y + 36, 54, name_rect.size.y - 44)
	_place(confirm_button, 150 if portrait_layout else 555, 2380 if portrait_layout else 914, 468 if portrait_layout else 390, 85 if portrait_layout else 61)
	_place(back_button, 20 if portrait_layout else 27, 2480 if portrait_layout else 926, 220 if portrait_layout else 198, 66 if portrait_layout else 60)
	_place(quote, 420 if portrait_layout else 1294, 2486 if portrait_layout else 925, 330 if portrait_layout else 220, 75)
	_place(status, 24 if portrait_layout else 360, 2353 if portrait_layout else 981, 720 if portrait_layout else 820, 30 if portrait_layout else 43)
	if modal.visible: modal.hide()

func _available(_key: String, _index: int) -> bool:
	return true

func _update() -> void:
	for i in range(categories.size()): categories[i].set_pressed_no_signal(i == active_category)
	for key in rows:
		var row = rows[key]
		var count = VeyrakProfile.OPTIONS[key].size()
		row.count.text = "%02d/%02d" % [profile[key] + 1, count]
		var first = clampi(profile[key] - int(row.tiles.size() / 2), 0, maxi(0, count - row.tiles.size()))
		for j in range(row.tiles.size()):
			var tile = row.tiles[j]
			tile.option_index = first + j
			tile.available = _available(key, tile.option_index)
			tile.selected = tile.option_index == profile[key]
			tile.tooltip_text = VeyrakProfile.OPTIONS[key][tile.option_index] + ("" if tile.available else " — artwork coming next")
			if key in ["skin", "hair_colour", "eyes"]:
				var colours = VeyrakProfile.SKIN_COLOURS if key == "skin" else (VeyrakProfile.HAIR_COLOURS if key == "hair_colour" else VeyrakProfile.EYE_COLOURS)
				tile.tint = Color(colours[tile.option_index])
			tile.queue_redraw()
	live_character.update_character(profile)
	warrior_material.set_shader_parameter("skin_tone", Color(VeyrakProfile.SKIN_COLOURS[profile.skin]))
	warrior_material.set_shader_parameter("hair_tone", Color(VeyrakProfile.HAIR_COLOURS[profile.hair_colour]))
	warrior_material.set_shader_parameter("eye_tone", Color(VeyrakProfile.EYE_COLOURS[profile.eyes]))
	warrior_material.set_shader_parameter("change_skin", profile.skin != 2)
	warrior_material.set_shader_parameter("change_hair", profile.hair_colour != 0)
	warrior_material.set_shader_parameter("change_eyes", profile.eyes != 1)
	status.text = saved_notice if not saved_notice.is_empty() else "Every appearance option is unlocked. Tap a heading or use the arrows to customise."

func _select(key: String, index: int) -> void:
	if not _available(key, index):
		_message("More styles are on the way", "This style still needs its matching artwork. Your current character has not changed.")
		return
	profile[key] = index
	_update()
	_layout()

func _cycle(key: String, direction: int) -> void:
	_select(key, posmod(profile[key] + direction, VeyrakProfile.OPTIONS[key].size()))

func _category(index: int) -> void:
	active_category = index
	_update()
	if index == 4:
		_edit_name()
		return
	var key = ["build", "markings", "eyes", "outfit"][index]
	if compact or index != 0: _open_choices(key)

func _clear_modal(title: String) -> void:
	for child in modal_content.get_children():
		modal_content.remove_child(child)
		child.queue_free()
	var heading = _text(modal_content, title, 22, GOLD)
	heading.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	modal_content.add_theme_constant_override("separation", 12)
	modal.add_theme_stylebox_override("panel", _modal_style())

func _modal_style() -> StyleBoxFlat:
	var box = StyleBoxFlat.new()
	box.bg_color = Color("09111e")
	box.border_color = GOLD
	box.set_border_width_all(2)
	box.set_content_margin_all(16)
	return box

func _show_modal() -> void:
	var viewport = get_viewport_rect().size
	modal.size = Vector2i(int(minf(viewport.x - 28, 540)), 0)
	modal.popup_centered()

func _message(title: String, message: String) -> void:
	_clear_modal(title)
	var body = _text(modal_content, message, 17, BLUE)
	body.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	var close = _button(modal_content, "BACK TO CHARACTER", func(): modal.hide())
	close.custom_minimum_size.y = 48
	_show_modal()

func _open_choices(key: String) -> void:
	selected_row = key
	_clear_modal(TITLES[KEYS.find(key)])
	var tip = _text(modal_content, "Choose a look. Every option is available.", 16, BLUE)
	tip.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	var choice_scroll = ScrollContainer.new()
	choice_scroll.custom_minimum_size.y = minf(260, get_viewport_rect().size.y - 190)
	modal_content.add_child(choice_scroll)
	var choices = VBoxContainer.new()
	choices.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	choice_scroll.add_child(choices)
	for index in range(VeyrakProfile.OPTIONS[key].size()):
		var available = _available(key, index)
		var title = VeyrakProfile.OPTIONS[key][index]
		if index == profile[key]: title += "  ✓"
		var button = _button(choices, title, func():
			_select(key, index)
			modal.hide()
		)
		button.custom_minimum_size.y = 48
		button.add_theme_font_size_override("font_size", 17)
	var close = _button(modal_content, "DONE", func(): modal.hide())
	close.custom_minimum_size.y = 48
	_show_modal()

func _edit_name() -> void:
	_clear_modal("NAME YOUR VEYRAKIAN")
	var input = LineEdit.new()
	input.text = profile.name
	input.placeholder_text = "Character name"
	input.max_length = 24
	input.custom_minimum_size.y = 52
	input.add_theme_font_size_override("font_size", 20)
	modal_content.add_child(input)
	var accept = _button(modal_content, "USE THIS NAME", func():
		profile.name = input.text.strip_edges()
		name_input.text = profile.name
		name_was_edited = true
		modal.hide()
	)
	accept.custom_minimum_size.y = 48
	_show_modal()
	input.grab_focus()

func _random_name() -> void:
	profile.name = ["Vaerun", "Kaelith", "Rhaevan", "Theryn", "Avarik", "Saevra", "Veyron", "Kharuun"].pick_random()
	name_input.text = profile.name
	name_was_edited = true

func _confirm() -> void:
	profile.name = profile.name.strip_edges()
	if profile.name.is_empty():
		_edit_name()
		return
	var error = SaveSlots.save_character(profile)
	if error != OK:
		_message("Could not save", "Your browser could not save the character. Try again outside private browsing.")
		return
	initial_profile = profile.duplicate()
	saved_notice = "%s · Character saved" % profile.name
	_update()
	_clear_modal("YOUR LEGACY BEGINS")
	var label = _text(modal_content, "%s\nVeyrakian of Veyathuun\n\nYour character is saved on this device. The playable world is the next development stage." % profile.name, 18, BLUE)
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	var download = _button(modal_content, "DOWNLOAD CHARACTER BACKUP", _download)
	download.custom_minimum_size.y = 48
	download.add_theme_font_size_override("font_size", 16)
	var close = _button(modal_content, "RETURN TO SAVE SLOTS", _leave_creator)
	close.custom_minimum_size.y = 48
	close.add_theme_font_size_override("font_size", 16)
	_show_modal()

func _download() -> void:
	var bytes = JSON.stringify(VeyrakProfile.validate(profile), "\t").to_utf8_buffer()
	if OS.has_feature("web"):
		JavaScriptBridge.download_buffer(bytes, "veyrak-character.json", "application/json")
	else:
		var file = FileAccess.open(OS.get_system_dir(OS.SYSTEM_DIR_DOWNLOADS).path_join("veyrak-character.json"), FileAccess.WRITE)
		if file != null: file.store_buffer(bytes)

func _leave_creator() -> void:
	SaveSlots.return_to_slots = true
	get_tree().change_scene_to_file("res://home.tscn")

func _back() -> void:
	if profile == initial_profile:
		_leave_creator()
		return
	_clear_modal("SAVE YOUR CHARACTER?")
	var body = _text(modal_content, "Save this draft before returning to your three slots?", 18, BLUE)
	body.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	var save = _button(modal_content, "SAVE AND RETURN", func():
		profile.name = profile.name.strip_edges()
		if SaveSlots.save_character(profile) == OK: _leave_creator()
		else: _message("Could not save", "Your draft is still open. Please try again.")
	)
	save.custom_minimum_size.y = 48
	var discard = _button(modal_content, "LEAVE WITHOUT SAVING", _leave_creator)
	discard.custom_minimum_size.y = 48
	discard.add_theme_font_size_override("font_size", 16)
	var cancel = _button(modal_content, "KEEP EDITING", func(): modal.hide())
	cancel.custom_minimum_size.y = 48
	_show_modal()
