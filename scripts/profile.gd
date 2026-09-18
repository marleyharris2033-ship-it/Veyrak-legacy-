class_name VeyrakProfile
extends RefCounted

const SAVE_PATH = "user://character.json"
const OPTIONS = {
	"base": ["Male", "Female"],
	"ridge": ["Subtle", "Swept", "Crowned", "Split", "Angular", "Smooth"],
	"face": ["Resolute", "Angular", "Broad", "Noble", "Weathered", "Sleek", "Sharp", "Stoic"],
	"hair": ["Shaven", "Cropped", "Swept", "Crest", "Undercut", "Long", "Braided", "Tied back", "Spiked", "Parted", "Warrior mane", "Temple braid"],
	"hair_colour": ["Obsidian", "Silver", "Ash", "Copper", "Sand", "Midnight"],
	"skin": ["Pale stone", "Silver grey", "Warm ash", "Slate", "Umber", "Deep stone"],
	"markings": ["None", "Temple lines", "Brow sigil", "Twin stripes", "Chevrons", "Starborn", "Warpaint", "Lineage", "Core veins", "Crown lines"],
	"eyes": ["Gold", "Ice blue", "Jade", "Violet", "Amber", "Silver"],
	"brow": ["Natural", "Strong", "Sharp", "Straight", "Arched", "Heavy"],
	"build": ["Lean", "Athletic", "Powerful", "Heavy", "Vanguard"],
	"outfit": ["Vanguard", "Wayfarer", "Sentinel", "Envoy", "Scout", "Initiate", "High Guard", "Frontier"],
	"accent": ["Veyathuun Gold", "Ivory", "Steel", "Azure", "Crimson", "Amethyst"]
}
const SKIN_COLOURS = ["c5c5bb", "a8afb1", "a89c90", "77848b", "80716a", "535d67"]
const HAIR_COLOURS = ["232632", "dddcd0", "777b81", "965a41", "bfa575", "303d61"]
const EYE_COLOURS = ["f1ce73", "99dbf1", "82d0ac", "c6a3f3", "e59a5e", "d8e4ea"]

static func defaults() -> Dictionary:
	return {"version": 1, "species": "Veyrakian", "homeworld": "Veyathuun", "name": "", "base": 0, "face": 0, "hair": 1, "hair_colour": 0, "skin": 0, "markings": 1, "eyes": 0, "brow": 0, "ridge": 0, "build": 2, "outfit": 0, "accent": 0}

static func validate(value: Variant) -> Dictionary:
	var result = defaults()
	if not value is Dictionary:
		return result
	if value.get("name") is String:
		result.name = value.name.strip_edges().left(24)
	if value.get("art_revision") == 1:
		result.art_revision = 1
	for key in OPTIONS:
		var index: Variant = value.get(key)
		if (index is int or index is float) and is_finite(float(index)):
			result[key] = clampi(int(index), 0, OPTIONS[key].size() - 1)
	return result

static func load_saved() -> Dictionary:
	if not FileAccess.file_exists(SAVE_PATH):
		return defaults()
	return validate(JSON.parse_string(FileAccess.get_file_as_string(SAVE_PATH)))

static func save(profile: Dictionary) -> Error:
	var file = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file == null:
		return FileAccess.get_open_error()
	file.store_string(JSON.stringify(validate(profile), "\t"))
	file.flush()
	return file.get_error()
