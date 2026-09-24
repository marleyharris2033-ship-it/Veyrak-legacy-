extends PanelContainer
var game: Control
var body: VBoxContainer
var tab = "PACK"
func _ready() -> void:
	var box = StyleBoxFlat.new()
	box.bg_color = Color("09121aff")
	box.border_color = Color("dcb66e")
	box.set_border_width_all(3)
	box.set_content_margin_all(12)
	add_theme_stylebox_override("panel",box)
	var stack = VBoxContainer.new()
	add_child(stack)
	var tabs = HBoxContainer.new()
	stack.add_child(tabs)
	for title in ["PACK","GEAR","STATS"]:
		game.hud.button(tabs,title,func(): tab = title; rebuild())
	var scroll = ScrollContainer.new()
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	scroll.size_flags_vertical = SIZE_EXPAND_FILL
	stack.add_child(scroll)
	body = VBoxContainer.new()
	body.size_flags_horizontal = SIZE_EXPAND_FILL
	body.add_theme_constant_override("separation",10)
	scroll.add_child(body)
	var footer = HBoxContainer.new()
	stack.add_child(footer)
	game.hud.button(footer,"RESUME",game.hud.toggle_menu)
	game.hud.button(footer,"SAVE / EXIT",game._exit)
	rebuild()
func text(value: String) -> void:
	var l = game.hud.label(body,value)
	l.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
func rebuild() -> void:
	for child in body.get_children(): body.remove_child(child); child.queue_free()
	var kit = game.kit
	match tab:
		"PACK":
			text("FIELD SUPPLIES · assign food to quick slots")
			for id in kit.FOOD:
				var item = kit.FOOD[id]
				text("%s ×%d · +%d %s" % [item.name,kit.inventory[id],item.health if item.health > 0 else item.energy,"health" if item.health > 0 else "core"])
				var row = HBoxContainer.new()
				body.add_child(row)
				for i in range(3):
					game.hud.button(row,"%d%s" % [i+1," ✓" if kit.hotbar[i] == id else ""],func(): kit.hotbar[i] = id; game._save(); rebuild())
			text("Tap a filled hotbar slot to consume. Supplies are not spent when the relevant bar is full.")
			for i in range(3):
				if kit.hotbar[i] != "": game.hud.button(body,"CLEAR SLOT %d" % [i+1],func(): kit.hotbar[i] = ""; game._save(); rebuild())
		"GEAR":
			text("STANDARD ISSUE\n"+VeyrakHeroes.record(game.profile.hero_id).weapon)
			text("TRAINING CORE · +2 "+game.signature_attribute())
			if game.claimed:
				game.hud.button(body,"UNEQUIP" if kit.core_worn else "EQUIP",func():
					kit.core_worn = not kit.core_worn
					game.equipped = kit.core_worn
					game.health = minf(game.health,game.stats().Health)
					game.energy = minf(game.energy,game.stats().Energy)
					if game.stage == 4 and kit.core_worn: game._advance()
					game._save()
					rebuild()
				)
			else: text("Recover the marked Council reward to unlock this equipment.")
		"STATS":
			text("COUNCIL TRAINING · %d upgrade points" % kit.points)
			text("Complete training to earn 3 points. Each upgrade is permanent.")
			var attributes = VeyrakHeroes.attributes(game.profile.hero_id,game.bonuses())
			for i in range(VeyrakHeroes.ATTRIBUTES.size()):
				var attribute = VeyrakHeroes.ATTRIBUTES[i]
				text(VeyrakHeroes.EXPLANATIONS[i])
				var b = game.hud.button(body,"%s %d  [+1]" % [attribute,attributes[attribute]],func():
					if kit.spend(attribute): game._save(); rebuild()
				)
				b.disabled = kit.points <= 0 or kit.upgrades.get(attribute,0) >= 10
