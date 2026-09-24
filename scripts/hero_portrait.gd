extends TextureRect
## Complete approved illustrations; no independent head/hair/body composition.
const ROSTER = preload("res://assets/heroes/council-roster.png")
const REGIONS = [Rect2(35,32,430,442),Rect2(523,55,491,419),Rect2(1108,47,410,427),Rect2(57,515,415,448),Rect2(576,518,416,445),Rect2(1133,519,388,444)]
var hero_id = "kaerun"
func _ready() -> void:
	expand_mode = EXPAND_IGNORE_SIZE
	stretch_mode = STRETCH_KEEP_ASPECT_CENTERED
	mouse_filter = MOUSE_FILTER_IGNORE
	texture_filter = TEXTURE_FILTER_NEAREST
	show_hero(hero_id)
func show_hero(id: String) -> void:
	hero_id = id
	var atlas = AtlasTexture.new()
	atlas.atlas = ROSTER
	atlas.region = REGIONS[maxi(0,VeyrakHeroes.index_of(id))]
	texture = atlas
