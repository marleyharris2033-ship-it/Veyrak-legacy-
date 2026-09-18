extends Control

const Portrait = preload("res://scripts/portrait.gd")
const ArtStage = preload("res://scripts/art_stage.gd")
const GOLD = Color("d5b675")
const INK = Color("0d151f")
var profile = VeyrakProfile.load_saved()
var portrait: Control
var layout: GridContainer
var preview_panel: PanelContainer
var name_input: LineEdit
var status: Label
var character_label: Label
var selectors: Dictionary = {}
var swatches: Dictionary = {}
var outer_margin: MarginContainer
var saved_profile = profile.duplicate()
var art_stage: Control
var art_caption: Label
var art_mode = true
var art_button: Button
var customise_button: Button
var page_scroll: ScrollContainer

func _ready() -> void:
	_build_theme()
	_build_interface()
	get_viewport().size_changed.connect(_resize_layout)
	_resize_layout()
	_sync_controls()

func _style(background: Color, border: Color, radius: int = 6) -> StyleBoxFlat:
	var box = StyleBoxFlat.new()
	box.bg_color = background
	box.border_color = border
	box.set_border_width_all(1)
	box.set_corner_radius_all(radius)
	box.content_margin_left = 12
	box.content_margin_right = 12
	box.content_margin_top = 10
	box.content_margin_bottom = 10
	return box

func _build_theme() -> void:
	theme = Theme.new()
	theme.default_font_size = 17
	theme.set_color("font_color", "Label", Color("e9e4d7"))
	for type in ["Button", "OptionButton"]:
		theme.set_stylebox("normal", type, _style(Color("172331"), Color("4b4b44")))
		theme.set_stylebox("hover", type, _style(Color("253444"), GOLD))
		theme.set_stylebox("pressed", type, _style(Color("35404a"), GOLD))
		theme.set_stylebox("focus", type, _style(Color(0, 0, 0, 0), GOLD))
		theme.set_color("font_color", type, Color("f2e7ce"))
	theme.set_stylebox("panel", "PanelContainer", _style(Color("101b27"), Color("555141"), 10))
	theme.set_stylebox("normal", "LineEdit", _style(INK, Color("65604d")))
	theme.set_stylebox("focus", "LineEdit", _style(INK, GOLD))
	theme.set_color("font_color", "LineEdit", Color("f2e7ce"))
	theme.set_color("font_placeholder_color", "LineEdit", Color("98a2ac"))
	theme.set_stylebox("panel", "PopupMenu", _style(Color("182430"), GOLD))
	theme.set_stylebox("hover", "PopupMenu", _style(Color("35434b"), GOLD))
	theme.set_constant("v_separation", "PopupMenu", 16)
	theme.set_constant("separation", "VBoxContainer", 14)
	theme.set_constant("separation", "HBoxContainer", 10)

func _label(text: String, font_size: int = 17, colour: Color = Color("e9e4d7")) -> Label:
	var label = Label.new()
	label.text = text
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_color", colour)
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	return label

func _button(text: String, action: Callable) -> Button:
	var button = Button.new()
	button.text = text
	button.custom_minimum_size.y = 48
	button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	button.pressed.connect(action)
	return button

func _build_interface() -> void:
	page_scroll = ScrollContainer.new()
	page_scroll.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	page_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	page_scroll.vertical_scroll_mode = ScrollContainer.SCROLL_MODE_AUTO
	page_scroll.scroll_deadzone = 6
	page_scroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	page_scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	add_child(page_scroll)
	outer_margin = MarginContainer.new()
	outer_margin.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	page_scroll.add_child(outer_margin)
	var page = VBoxContainer.new()
	page.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	outer_margin.add_child(page)
	page.add_child(_label("V E Y R A K   /   L E G A C Y", 18, GOLD))
	page.add_child(_label("Forge your legacy", 34))
	page.add_child(_label("A child of Veyathuun. A future of your own.", 16, Color("a3b2bd")))
	var modes = HBoxContainer.new()
	art_button = _button("Artwork preview", func(): _set_art_mode(true))
	customise_button = _button("Customise", func(): _set_art_mode(false))
	art_button.toggle_mode = true
	customise_button.toggle_mode = true
	modes.add_child(art_button)
	modes.add_child(customise_button)
	page.add_child(modes)
	art_stage = ArtStage.new()
	art_stage.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	page.add_child(art_stage)
	art_caption = _label("DEFAULT VEYRAKIAN  /  VEYATHUUN\nFirst artwork preview. Matching appearance variations are being created. Customise opens the original working preview.", 15, Color("d5c5a3"))
	page.add_child(art_caption)
	layout = GridContainer.new()
	layout.add_theme_constant_override("h_separation", 24)
	layout.add_theme_constant_override("v_separation", 20)
	layout.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	page.add_child(layout)
	preview_panel = PanelContainer.new()
	preview_panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	preview_panel.size_flags_vertical = Control.SIZE_SHRINK_BEGIN
	layout.add_child(preview_panel)
	var preview = VBoxContainer.new()
	preview_panel.add_child(preview)
	preview.add_child(_label("V E Y R A K I A N", 15, GOLD))
	portrait = Portrait.new()
	portrait.custom_minimum_size = Vector2(0, 360)
	portrait.clip_contents = true
	portrait.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	preview.add_child(portrait)
	character_label = _label("Your Veyrakian", 23)
	character_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	preview.add_child(character_label)
	var zoom = _button("Inspect face", func():
		portrait.show_face = not portrait.show_face
		portrait.queue_redraw()
	)
	zoom.pressed.connect(func(): zoom.text = "Show full character" if portrait.show_face else "Inspect face")
	preview.add_child(zoom)
	preview.add_child(_label("Prototype pixel layers · appearance only", 13, Color("98a7b2")))
	var editor = VBoxContainer.new()
	editor.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	layout.add_child(editor)
	editor.add_child(_label("01  /  IDENTITY", 15, GOLD))
	editor.add_child(_label("Character name", 16))
	name_input = LineEdit.new()
	name_input.placeholder_text = "Name your Veyrakian"
	name_input.max_length = 24
	name_input.custom_minimum_size.y = 50
	name_input.text_changed.connect(func(value: String):
		profile.name = value
		_refresh()
	)
	editor.add_child(name_input)
	_add_select(editor, "base", "Base")
	_add_select(editor, "build", "Build")
	editor.add_child(_label("02  /  FEATURES", 15, GOLD))
	_add_select(editor, "face", "Face")
	_add_select(editor, "hair", "Hairstyle")
	_add_swatch(editor, "hair_colour", "Hair colour", VeyrakProfile.HAIR_COLOURS)
	_add_swatch(editor, "skin", "Skin tone", VeyrakProfile.SKIN_COLOURS)
	_add_swatch(editor, "eyes", "Eye colour", VeyrakProfile.EYE_COLOURS)
	_add_select(editor, "markings", "Markings")
	editor.add_child(_label("03  /  ATTIRE", 15, GOLD))
	_add_select(editor, "outfit", "Outfit")
	var actions = HBoxContainer.new()
	actions.add_child(_button("Randomise", _randomise))
	actions.add_child(_button("Restore saved", _restore))
	editor.add_child(actions)
	var save = _button("Save character", _save)
	save.add_theme_stylebox_override("normal", _style(GOLD, GOLD))
	save.add_theme_color_override("font_color", INK)
	save.custom_minimum_size.y = 56
	editor.add_child(save)
	editor.add_child(_button("Download character backup", _download))
	status = _label("Choose your appearance, then save your character.", 15, Color("a8b9c4"))
	editor.add_child(status)
	page.add_child(_label("CHARACTER CREATOR  /  0.2    •    Veyathuun awaits", 13, Color("9c9b91")))
	_set_art_mode(true)

func _set_art_mode(enabled: bool) -> void:
	art_mode = enabled
	art_stage.visible = enabled
	art_caption.visible = enabled
	layout.visible = not enabled
	art_button.set_pressed_no_signal(enabled)
	customise_button.set_pressed_no_signal(not enabled)

func _add_select(parent: VBoxContainer, key: String, title: String) -> void:
	var row = HBoxContainer.new()
	var label = _label(title, 16)
	label.custom_minimum_size.x = 90
	label.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	row.add_child(label)
	var select = OptionButton.new()
	select.custom_minimum_size = Vector2(0, 48)
	select.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	select.fit_to_longest_item = false
	for option in VeyrakProfile.OPTIONS[key]:
		select.add_item(option)
	select.item_selected.connect(func(index: int):
		profile[key] = index
		_refresh()
	)
	row.add_child(select)
	parent.add_child(row)
	selectors[key] = select

func _add_swatch(parent: VBoxContainer, key: String, title: String, colours: Array) -> void:
	var label = _label(title, 16)
	parent.add_child(label)
	var row = HBoxContainer.new()
	row.add_theme_constant_override("separation", 5)
	var buttons: Array[Button] = []
	for i in range(colours.size()):
		var button = Button.new()
		button.custom_minimum_size = Vector2(42, 46)
		button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		button.tooltip_text = title + ": " + VeyrakProfile.OPTIONS[key][i]
		button.toggle_mode = true
		button.add_theme_stylebox_override("normal", _style(Color(colours[i]), Color("5a646c")))
		var selected = _style(Color(colours[i]), Color("fff0c0"))
		selected.set_border_width_all(3)
		button.add_theme_stylebox_override("pressed", selected)
		button.add_theme_stylebox_override("hover", selected)
		button.add_theme_color_override("font_color", Color.BLACK if Color(colours[i]).get_luminance() > 0.35 else Color.WHITE)
		button.pressed.connect(func():
			profile[key] = i
			_sync_controls()
		)
		row.add_child(button)
		buttons.append(button)
	parent.add_child(row)
	swatches[key] = {"label": label, "title": title, "buttons": buttons}

func _resize_layout() -> void:
	var width = get_viewport_rect().size.x
	art_stage.custom_minimum_size.y = clampf(get_viewport_rect().size.y - 240.0, 380.0, 760.0)
	layout.columns = 2 if width >= 820 else 1
	var margin = 30 if width >= 820 else 12
	for side in ["left", "right", "top", "bottom"]:
		outer_margin.add_theme_constant_override("margin_" + side, margin)
	preview_panel.custom_minimum_size.x = 360 if width >= 820 else 0
	portrait.custom_minimum_size.y = 440 if width >= 820 else 320

func _sync_controls() -> void:
	name_input.text = profile.name
	for key in selectors:
		selectors[key].select(profile[key])
	for key in swatches:
		var group = swatches[key]
		group.label.text = group.title + " · " + VeyrakProfile.OPTIONS[key][profile[key]]
		for i in range(group.buttons.size()):
			group.buttons[i].set_pressed_no_signal(i == profile[key])
			group.buttons[i].text = "•" if i == profile[key] else ""
	_refresh()

func _refresh() -> void:
	portrait.update_character(profile)
	character_label.text = profile.name.strip_edges() if not profile.name.strip_edges().is_empty() else "Your Veyrakian"
	if is_instance_valid(status):
		status.text = "Unsaved changes" if profile != saved_profile else "Choose your appearance, then save your character."

func _randomise() -> void:
	for key in VeyrakProfile.OPTIONS:
		profile[key] = randi_range(0, VeyrakProfile.OPTIONS[key].size() - 1)
	_sync_controls()

func _restore() -> void:
	profile = saved_profile.duplicate()
	_sync_controls()
	status.text = "Restored your last saved appearance." if not profile.name.is_empty() else "Restored the starting appearance."

func _has_name() -> bool:
	if profile.name.strip_edges().is_empty():
		status.text = "Give your character a name first."
		name_input.grab_focus()
		return false
	return true

func _save() -> void:
	if not _has_name():
		return
	profile = VeyrakProfile.validate(profile)
	var error = VeyrakProfile.save(profile)
	if error != OK:
		status.text = "This browser could not save. Use Download character backup to keep your character."
		return
	saved_profile = profile.duplicate()
	_sync_controls()
	status.text = "%s is saved on this device. Download a backup to keep a separate copy." % profile.name
	if OS.has_feature("web") and not OS.is_userfs_persistent():
		status.text = "Saved for this session. Download a backup: this browser may not retain local saves."

func _download() -> void:
	if not _has_name():
		return
	var data = JSON.stringify(VeyrakProfile.validate(profile), "\t")
	if OS.has_feature("web"):
		JavaScriptBridge.download_buffer(data.to_utf8_buffer(), "veyrak-character.json", "application/json")
		status.text = "Character backup requested. Keep it in Files for a future game import."
	else:
		var path = OS.get_system_dir(OS.SYSTEM_DIR_DOWNLOADS).path_join("veyrak-character.json")
		var file = FileAccess.open(path, FileAccess.WRITE)
		if file == null:
			status.text = "Could not write a backup to Downloads. Your saved character is unchanged."
			return
		file.store_string(data)
		status.text = "Backup written to " + path
