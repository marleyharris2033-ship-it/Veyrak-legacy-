extends TextureRect
## Tight Council-file portraits for the field HUD.
const ROSTER = preload("res://assets/heroes/council-roster.png")
const REGIONS = [
	Rect2(70,35,190,180),
	Rect2(625,45,190,180),
	Rect2(1150,45,190,180),
	Rect2(75,520,190,180),
	Rect2(620,520,190,180),
	Rect2(1145,520,190,180)
]
var hero_id = "kaerun"

func _ready() -> void:
	expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	show_hero(hero_id)

func show_hero(id: String) -> void:
	hero_id = id
	var atlas = AtlasTexture.new()
	atlas.atlas = ROSTER
	atlas.region = REGIONS[maxi(0,VeyrakHeroes.index_of(id))]
	texture = atlas
