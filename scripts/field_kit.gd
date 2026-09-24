extends RefCounted
## Stable inventory IDs; saved separately from the selected hero.
const FOOD = {"ration":{"name":"Field ration","health":60,"energy":0},"nectar":{"name":"Core nectar","health":0,"energy":50}}
var inventory = {"ration":3,"nectar":2}
var hotbar = ["ration","nectar",""]
var upgrades = {}
var points = 0
var rewarded = false
var core_worn = false
func restore(state: Dictionary, completed: bool, legacy_equipped: bool) -> void:
	var data = state.get("kit",{})
	if not data is Dictionary: data = {}
	var items = data.get("inventory",{})
	if not items is Dictionary: items = {}
	for id in FOOD: inventory[id] = clampi(int(items.get(id,inventory[id])),0,999)
	var saved = data.get("hotbar",hotbar)
	if saved is Array and saved.size() == 3:
		for i in range(3): hotbar[i] = saved[i] if FOOD.has(saved[i]) else ""
	var ratings = data.get("upgrades",{})
	if not ratings is Dictionary: ratings = {}
	for attribute in VeyrakHeroes.ATTRIBUTES: upgrades[attribute] = clampi(int(ratings.get(attribute,0)),0,10)
	points = clampi(int(data.get("points",0)),0,99)
	rewarded = bool(data.get("rewarded",false))
	core_worn = bool(data.get("core_worn",legacy_equipped))
	if completed: reward()
func reward() -> void:
	if rewarded: return
	rewarded = true
	points += 3
func spend(attribute: String) -> bool:
	if points <= 0 or not VeyrakHeroes.ATTRIBUTES.has(attribute) or upgrades.get(attribute,0) >= 10: return false
	points -= 1
	upgrades[attribute] = upgrades.get(attribute,0)+1
	return true
func serialise() -> Dictionary:
	return {"inventory":inventory.duplicate(),"hotbar":hotbar.duplicate(),"upgrades":upgrades.duplicate(),"points":points,"rewarded":rewarded,"core_worn":core_worn}
