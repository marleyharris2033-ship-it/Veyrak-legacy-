extends Control

const OrnateButton = preload("res://scripts/ornate_button.gd")
const GOLD = Color("efbb64")
const BLUE = Color("afbee0")
var panel: VBoxContainer
var margin: MarginContainer
var screen = "home"
var notice: Label

func _ready() -> void:
	theme = Theme.new()
	theme.default_font = preload("res://assets/fonts/DejaVuSansMono.ttf")
	theme.default_font_size = 20
	theme.set_color("font_color", "Label", BLUE)
	for state in ["normal", "hover", "pressed", "focus", "disabled"]:
		var style = StyleBoxFlat.new()
		style.bg_color = Color(0.018, 0.032, 0.06, 0.94)
		style.set_content_margin_all(18)
		theme.set_stylebox(state, "Button", style)
	theme.set_color("font_color", "Button", GOLD)
	theme.set_color("font_hover_color", "Button", Color("ffe3a1"))
	var background = TextureRect.new()
	background.texture = preload("res://assets/menu/meteor-opening-v1.png")
	background.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	background.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	background.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	background.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	background.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(background)
	var shade = ColorRect.new()
	shade.color = Color(0.015, 0.025, 0.05, 0.24)
	shade.mouse_filter = Control.MOUSE_FILTER_IGNORE
	shade.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(shade)
	var scroll = ScrollContainer.new()
	scroll.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	add_child(scroll)
	margin = MarginContainer.new()
	margin.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.add_child(margin)
	panel = VBoxContainer.new()
	panel.add_theme_constant_override("separation", 14)
	margin.add_child(panel)
	get_viewport().size_changed.connect(_layout)
	_layout()
	if SaveSlots.return_to_slots:
		SaveSlots.return_to_slots = false
		_slots()
	else: _home()

func _layout() -> void:
	var viewport = get_viewport_rect().size
	var width = minf(440, viewport.x - 36)
	var left = (viewport.x - width) * 0.5 if viewport.x < 700 else maxf(32, viewport.x * 0.08)
	margin.add_theme_constant_override("margin_left", int(left))
	margin.add_theme_constant_override("margin_right", int(viewport.x - width - left))
	margin.add_theme_constant_override("margin_top", int(maxf(24, viewport.y * 0.09)))
	margin.add_theme_constant_override("margin_bottom", 28)

func _clear(page: String) -> void:
	screen = page
	for child in panel.get_children():
		panel.remove_child(child)
		child.queue_free()

func _label(text: String, font_size: int = 18, colour: Color = BLUE) -> Label:
	var label = Label.new()
	label.text = text
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_color", colour)
	label.add_theme_color_override("font_shadow_color", Color.BLACK)
	label.add_theme_constant_override("shadow_offset_x", 2)
	label.add_theme_constant_override("shadow_offset_y", 2)
	panel.add_child(label)
	return label

func _button(text: String, action: Callable, featured: bool = false) -> Button:
	var button = OrnateButton.new()
	button.text = text
	button.featured = featured
	button.custom_minimum_size.y = 64
	button.pressed.connect(action)
	panel.add_child(button)
	return button

func _logo() -> void:
	_label("◇", 32, GOLD)
	var title = _label("VEYRAK", 48, GOLD)
	title.add_theme_font_override("font", preload("res://assets/fonts/DejaVuSerif-Bold.ttf"))
	title.autowrap_mode = TextServer.AUTOWRAP_OFF
	_label("—  L E G A C Y  —", 20, GOLD)
	_label("──────── ◇ ────────", 14, GOLD)

func _home() -> void:
	_clear("home")
	_logo()
	_label("SAME ORIGINS. DIFFERENT PATHS.", 14, GOLD)
	_button("START", _slots, true)
	_button("SETTINGS", _settings)

func _slots() -> void:
	_clear("slots")
	_label("CHOOSE YOUR LEGACY", 24, GOLD)
	for slot in range(1, SaveSlots.SLOT_COUNT + 1):
		var value = SaveSlots.read_slot(slot)
		var text = "SLOT %d  ·  NEW GAME\nCreate your Veyrakian" % slot
		if value.get("invalid", false):
			text = "SLOT %d  ·  SAVE UNAVAILABLE" % slot
		elif not value.is_empty():
			var name_text = value.profile.name if not value.profile.name.is_empty() else "Unnamed Veyrakian"
			text = "SLOT %d  ·  %s\n%s" % [slot, name_text, value.checkpoint.get("label", "Saved progress")]
		var button = _button(text, func(): _open_slot(slot))
		button.add_theme_font_size_override("font_size", 16)
		button.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		button.custom_minimum_size.y = 106
		button.disabled = value.get("invalid", false)
	_label("Saves are stored in this browser on this device.", 14)
	notice = _label("", 15, GOLD)
	_button("BACK", _home)

func _open_slot(slot: int) -> void:
	var error = SaveSlots.open_slot(slot)
	if error != OK: notice.text = "This save could not be opened. It has been kept unchanged."

func _settings() -> void:
	_clear("settings")
	_label("SETTINGS", 26, GOLD)
	_label("MASTER VOLUME", 16)
	var volume = HSlider.new()
	volume.min_value = 0
	volume.max_value = 100
	volume.value = SaveSlots.settings.volume * 100
	volume.custom_minimum_size.y = 48
	panel.add_child(volume)
	volume.value_changed.connect(func(value):
		SaveSlots.settings.volume = value / 100.0
		_save_settings()
	)
	var mute = CheckButton.new()
	mute.text = "Mute audio"
	mute.button_pressed = SaveSlots.settings.muted
	mute.custom_minimum_size.y = 56
	panel.add_child(mute)
	mute.toggled.connect(func(value):
		SaveSlots.settings.muted = value
		_save_settings()
	)
	_label("Audio preferences will apply when sound is added.", 14)
	notice = _label("", 15, GOLD)
	_button("BACK", _home)

func _save_settings() -> void:
	if SaveSlots.save_settings() != OK: notice.text = "Could not save settings on this device."
	else: notice.text = "Settings saved"
