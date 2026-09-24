extends RefCounted
## Persistent field inventory, mixed hotbar and hero upgrades.
const ITEMS = {
	"primary":{"name":"Signature weapon","kind":"weapon","icon":"res://assets/ui/hud-gauntlet.svg"},
	"sidearm":{"name":"Council sidearm","kind":"weapon","icon":"res://assets/ui/hud-sidearm.svg"},
	"scanner":{"name":"Core scanner","kind":"utility","icon":"res://assets/ui/hud-scanner.svg"},
	"repair":{"name":"Repair kit","kind":"utility","icon":"res://assets/ui/hud-repair.svg"},
	"ration":{"name":"Field ration","kind":"food","icon":"res://assets/ui/hud-ration.svg","health":60,"energy":0},
	"nectar":{"name":"Core nectar","kind":"food","icon":"res://assets/ui/hud-nectar.svg","health":0,"energy":50},
	"harvest":{"name":"Harvest tool","kind":"utility","icon":"res://assets/ui/hud-harvest.svg"}
}
const ITEM_ORDER = ["primary","sidearm","scanner","repair","ration","nectar","harvest"]
const FOOD = {
	"ration":{"name":"Field ration","health":60,"energy":0},
	"nectar":{"name":"Core nectar","health":0,"energy":50}
}
var inventory = {"primary":1,"sidearm":1,"scanner":1,"repair":1,"ration":3,"nectar":2,"harvest":1}
var hotbar = ["primary","sidearm","scanner","repair","ration","nectar","harvest",""]
var active_slot = 0
var upgrades = {}
var points = 0
var rewarded = false
var core_worn = false

func restore(state: Dictionary, completed: bool, legacy_equipped: bool) -> void:
	var data = state.get("kit",{})
	if not data is Dictionary:
		data = {}
	var items = data.get("inventory",{})
	if not items is Dictionary:
		items = {}
	for id in inventory:
		inventory[id] = clampi(int(items.get(id,inventory[id])),0,999)
	var saved = data.get("hotbar",[])
	if saved is Array and saved.size() == 8:
		for i in range(8):
			var id = str(saved[i])
			hotbar[i] = id if ITEMS.has(id) else ""
	elif saved is Array and saved.size() == 3:
		for i in range(3):
			var id = str(saved[i])
			if FOOD.has(id):
				hotbar[4+i] = id
	active_slot = clampi(int(data.get("active_slot",0)),0,7)
	if hotbar[active_slot] == "":
		active_slot = 0
	var ratings = data.get("upgrades",{})
	if not ratings is Dictionary:
		ratings = {}
	for attribute in VeyrakHeroes.ATTRIBUTES:
		upgrades[attribute] = clampi(int(ratings.get(attribute,0)),0,10)
	points = clampi(int(data.get("points",0)),0,99)
	rewarded = bool(data.get("rewarded",false))
	core_worn = bool(data.get("core_worn",legacy_equipped))
	if completed:
		reward()

func reward() -> void:
	if rewarded:
		return
	rewarded = true
	points += 3

func spend(attribute: String) -> bool:
	if points <= 0 or not VeyrakHeroes.ATTRIBUTES.has(attribute) or upgrades.get(attribute,0) >= 10:
		return false
	points -= 1
	upgrades[attribute] = upgrades.get(attribute,0)+1
	return true

func selected_id() -> String:
	if active_slot < 0 or active_slot >= hotbar.size():
		return ""
	return str(hotbar[active_slot])

func kind(id: String) -> String:
	return str(ITEMS.get(id,{}).get("kind",""))

func icon_path(id: String) -> String:
	return str(ITEMS.get(id,{}).get("icon",""))

func serialise() -> Dictionary:
	return {
		"inventory":inventory.duplicate(),
		"hotbar":hotbar.duplicate(),
		"active_slot":active_slot,
		"upgrades":upgrades.duplicate(),
		"points":points,
		"rewarded":rewarded,
		"core_worn":core_worn
	}
