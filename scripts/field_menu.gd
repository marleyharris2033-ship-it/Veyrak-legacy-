extends PanelContainer
var game: Control
var body: VBoxContainer
var tab = "PACK"

func _ready() -> void:
	var box = StyleBoxFlat.new()
	box.bg_color = Color("070f19fa")
	box.border_color = Color("d7b66e")
	box.set_border_width_all(3)
	box.set_corner_radius_all(6)
	box.set_content_margin_all(12)
	add_theme_stylebox_override("panel",box)
	var stack = VBoxContainer.new()
	stack.add_theme_constant_override("separation",8)
	add_child(stack)
	var title = game.hud.label(stack,"VEYATHUUN FIELD KIT")
	title.add_theme_font_size_override("font_size",18)
	var tabs = HBoxContainer.new()
	stack.add_child(tabs)
	for title_text in ["PACK","GEAR","STATS"]:
		game.hud.button(tabs,title_text,func(): tab = title_text; rebuild())
	var scroll = ScrollContainer.new()
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	stack.add_child(scroll)
	body = VBoxContainer.new()
	body.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	body.add_theme_constant_override("separation",10)
	scroll.add_child(body)
	var footer = HBoxContainer.new()
	stack.add_child(footer)
	game.hud.button(footer,"RESUME",game.hud.toggle_menu)
	game.hud.button(footer,"SAVE / EXIT",game._exit)
	rebuild()

func text(value: String, gold: bool = false) -> Label:
	var l = game.hud.label(body,value)
	l.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	if not gold:
		l.add_theme_color_override("font_color",Color("e7e1d3"))
	return l

func rebuild() -> void:
	for child in body.get_children():
		body.remove_child(child)
		child.queue_free()
	var kit = game.kit
	match tab:
		"PACK":
			text("INVENTORY",true)
			text("Assign weapons, utilities or food to any of the eight field slots.")
			for id in kit.ITEM_ORDER:
				if kit.inventory.get(id,0) <= 0:
					continue
				var item = kit.ITEMS[id]
				var suffix = " ×%d" % kit.inventory[id] if item.kind == "food" else ""
				text("%s%s · %s" % [item.name,suffix,item.kind.to_upper()])
				var grid = GridContainer.new()
				grid.columns = 4
				body.add_child(grid)
				for i in range(8):
					var b = game.hud.button(grid,"%d%s" % [i+1," ✓" if kit.hotbar[i] == id else ""],func(slot=i,item_id=id):
						kit.hotbar[slot] = item_id
						kit.active_slot = slot
						game._save()
						rebuild()
					)
					b.custom_minimum_size.x = 64
			var clear_grid = GridContainer.new()
			clear_grid.columns = 4
			body.add_child(clear_grid)
			for i in range(8):
				if kit.hotbar[i] != "":
					game.hud.button(clear_grid,"CLEAR %d" % [i+1],func(slot=i):
						kit.hotbar[slot] = ""
						if kit.active_slot == slot:
							kit.active_slot = 0
						game._save()
						rebuild()
					)
		"GEAR":
			text("EQUIPMENT",true)
			text("Active field slot: %d · %s" % [kit.active_slot+1,kit.ITEMS.get(kit.selected_id(),{}).get("name","Empty")])
			text("STANDARD ISSUE · "+VeyrakHeroes.record(game.profile.hero_id).weapon)
			for id in ["primary","sidearm"]:
				if kit.inventory.get(id,0) <= 0:
					continue
				game.hud.button(body,"READY "+kit.ITEMS[id].name.to_upper(),func(item_id=id):
					var slot = kit.hotbar.find(item_id)
					if slot >= 0:
						kit.active_slot = slot
						game._save()
						rebuild()
				)
			text("TRAINING CORE · +2 "+game.signature_attribute())
			if game.claimed:
				game.hud.button(body,"UNEQUIP CORE" if kit.core_worn else "EQUIP CORE",func():
					kit.core_worn = not kit.core_worn
					game.equipped = kit.core_worn
					game.health = minf(game.health,game.stats().Health)
					game.energy = minf(game.energy,game.stats().Energy)
					if game.stage == 4 and kit.core_worn:
						game._advance()
					game._save()
					rebuild()
				)
			else:
				text("Recover the marked Council reward to unlock the training core.")
		"STATS":
			text("ATTRIBUTE UPGRADES · %d POINTS" % kit.points,true)
			var attributes = VeyrakHeroes.attributes(game.profile.hero_id,game.bonuses())
			for i in range(VeyrakHeroes.ATTRIBUTES.size()):
				var attribute = VeyrakHeroes.ATTRIBUTES[i]
				text(VeyrakHeroes.EXPLANATIONS[i])
				var b = game.hud.button(body,"%s  %d  →  %d" % [attribute,attributes[attribute],attributes[attribute]+1],func(stat=attribute):
					if kit.spend(stat):
						game._save()
						rebuild()
				)
				b.disabled = kit.points <= 0 or kit.upgrades.get(attribute,0) >= 10
