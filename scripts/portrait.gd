extends Control
## Layered low-resolution Veyrakian renderer used by the creator and future gameplay portrait pipeline.
## Every creator choice changes silhouette, facial detail, markings, colour or equipment.

var profile = VeyrakProfile.defaults()
var show_face = false

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	resized.connect(queue_redraw)

func update_character(value: Dictionary) -> void:
	profile = value.duplicate()
	queue_redraw()

func block(x: float, y: float, w: float, h: float, colour: Color) -> void:
	draw_rect(Rect2(x, y, w, h), colour)

func _draw() -> void:
	# A quiet, architectural Veyathuun backdrop, drawn on a fixed pixel grid.
	var scale_factor = maxf(1.0, floorf(minf(size.x / 144.0, size.y / 156.0)))
	draw_set_transform(Vector2((size.x - 144 * scale_factor) / 2, (size.y - 156 * scale_factor) / 2), 0, Vector2.ONE * scale_factor)
	block(0, 0, 144, 156, Color("111e2a"))
	for i in range(5):
		block(0, 12 + i * 22, 144, 22, Color("162935").lerp(Color("263b42"), i / 5.0))
	block(109, 17, 15, 15, Color("d1c3a0"))
	block(105, 21, 23, 7, Color("d1c3a0"))
	for i in range(11):
		var tower_x = i * 15 - 6
		var tower_height = 20 + ((i * 17) % 36)
		block(tower_x, 99 - tower_height, 12, tower_height, Color("647474"))
		block(tower_x + 2, 95 - tower_height, 8, 4, Color("b0ad94"))
		block(tower_x + 5, 88 - tower_height, 2, 8, Color("c8b580"))
		block(tower_x + 3, 105 - tower_height, 2, 8, Color("d3bc80"))
		block(tower_x + 8, 105 - tower_height, 2, 8, Color("d3bc80"))
	block(0, 83, 144, 4, Color("9a9b83"))
	block(8, 87, 6, 29, Color("737f78"))
	block(125, 87, 6, 29, Color("737f78"))
	block(20, 85, 5, 41, Color("7fb9ba"))
	block(21, 85, 2, 41, Color("b3d4ce"))
	block(119, 85, 4, 37, Color("7fb9ba"))
	block(0, 112, 144, 44, Color("19272c"))
	block(8, 110, 30, 8, Color("405c4e"))
	block(113, 110, 25, 8, Color("405c4e"))
	block(32, 135, 80, 6, Color("766e53"))
	block(25, 141, 94, 5, Color("3e4541"))
	block(18, 146, 108, 4, Color("252f32"))
	var sprite_scale = scale_factor * (3 if show_face else 1)
	var origin = Vector2((size.x - 144 * scale_factor) / 2, (size.y - 156 * scale_factor) / 2)
	if show_face:
		origin += Vector2(-144, -35) * scale_factor
	draw_set_transform(origin, 0, Vector2.ONE * sprite_scale)
	_draw_character()
	draw_set_transform(Vector2.ZERO)

func _draw_character() -> void:
	var skin = Color(VeyrakProfile.SKIN_COLOURS[profile.skin])
	var shadow = skin.darkened(0.25)
	var light = skin.lightened(0.15)
	var hair = Color(VeyrakProfile.HAIR_COLOURS[profile.hair_colour])
	var eyes = Color(VeyrakProfile.EYE_COLOURS[profile.eyes])
	var outfit = int(profile.outfit)
	var armour = Color(["30333d", "4b5158", "363d4c", "bab6a5", "354d48", "575365", "252b36", "4a4039"][outfit])
	var trim = Color(["d5b675", "e8e2d2", "aab4bd", "6598cf", "b55252", "8666ad"][profile.accent])
	var dark = Color("171d28")
	var width = [14, 17, 20, 23, 26][profile.build] - (2 if profile.base == 1 else 0)
	var face_width = [9, 8, 11, 9, 10, 8, 8, 10][profile.face]
	# Outfit-specific rear silhouettes.
	if outfit == 1 or outfit == 3:
		block(49, 67, 46, 62, armour.darkened(0.3))
		block(51, 70, 3, 56, trim.darkened(0.4))
		block(89, 70, 3, 56, trim.darkened(0.4))
	if outfit == 5:
		block(54, 68, 37, 55, armour.darkened(0.22))
		block(57, 72, 3, 47, trim.darkened(0.3))
	if outfit == 7:
		block(52, 73, 41, 46, armour.darkened(0.34))
	# Legs, boots and segmented armour.
	block(58, 99, 13, 32, dark)
	block(74, 99, 13, 32, dark)
	block(59, 103, 10, 23, armour)
	block(76, 103, 10, 23, armour)
	block(60, 116, 8, 3, trim)
	block(77, 116, 8, 3, trim)
	block(55, 127, 16, 8, dark)
	block(74, 127, 16, 8, dark)
	block(56, 127, 13, 3, armour.lightened(0.1))
	block(76, 127, 13, 3, armour.lightened(0.1))
	# Neck and arms, with build reflected in the actual silhouette.
	block(67, 55, 11, 13, shadow)
	block(69, 55, 6, 10, skin)
	block(70 - width - 10, 70, 12, 28, shadow)
	block(72 + width, 70, 12, 28, shadow)
	block(71 - width - 10, 71, 7, 23, skin)
	block(74 + width, 71, 7, 23, skin)
	block(69 - width - 10, 90, 12, 13, dark)
	block(73 + width, 90, 12, 13, dark)
	block(70 - width - 10, 92, 10, 3, trim)
	block(74 + width, 92, 10, 3, trim)
	block(70 - width - 10, 103, 10, 8, skin)
	block(74 + width, 103, 10, 8, skin)
	# Breastplate with a tapered waist; both bases wear full armour.
	block(72 - width, 65, width * 2, 27, dark)
	block(73 - width, 66, width * 2 - 2, 22, armour)
	block(60, 85, 25, 18, armour.darkened(0.12))
	block(61, 98, 24, 5, dark)
	block(71, 98, 5, 5, trim)
	block(72 - width, 65, width * 2, 3, trim)
	block(72 - width, 72, width - 2, 2, armour.lightened(0.2))
	block(75, 72, width - 3, 2, armour.lightened(0.2))
	block(70, 76, 5, 7, trim)
	block(68, 78, 9, 3, trim)
	block(72, 77, 1, 5, trim.lightened(0.3))
	if outfit != 4 and outfit != 5:
		block(66 - width - 5, 64, 16, 10, dark)
		block(66 + width, 64, 16, 10, dark)
		block(66 - width - 4, 65, 14, 3, trim)
		block(67 + width, 65, 14, 3, trim)
	if outfit == 0:
		block(61, 67, 23, 4, trim.darkened(0.25))
		block(63, 73, 5, 12, armour.lightened(0.12))
		block(78, 73, 5, 12, armour.lightened(0.12))
	if outfit == 1:
		block(62, 86, 21, 5, trim.darkened(0.2))
		block(68, 91, 9, 27, armour.darkened(0.15))
	if outfit == 2:
		block(56, 97, 10, 16, armour)
		block(79, 97, 10, 16, armour)
		block(57, 67, 31, 7, armour.lightened(0.12))
		block(61, 75, 5, 16, trim.darkened(0.28))
		block(80, 75, 5, 16, trim.darkened(0.28))
	if outfit == 3 or outfit == 5:
		block(61, 100, 23, 18, armour)
		block(70, 101, 4, 17, trim)
	if outfit == 6:
		block(58, 63, 29, 5, trim)
		block(55, 66, 8, 17, armour.lightened(0.08))
		block(82, 66, 8, 17, armour.lightened(0.08))
		block(68, 70, 9, 15, trim.darkened(0.18))
	if outfit == 7:
		block(58, 87, 29, 4, trim)
		block(63, 91, 19, 12, armour.darkened(0.18))
	if outfit == 4:
		block(62, 66, 21, 5, armour.lightened(0.16))
		block(60, 85, 7, 18, armour.darkened(0.18))
		block(78, 85, 7, 18, armour.darkened(0.18))
		for i in range(7):
			block(59 + i * 3, 66 + i * 4, 5, 5, trim.darkened(0.3))
	# Hair behind the head.
	if profile.hair == 5 or profile.hair == 6:
		block(58, 35, 28, 32, hair.darkened(0.2))
	if profile.hair == 7:
		block(80, 42, 9, 24, hair)
	# Build-specific anatomy accents so body types read beyond shoulder width.
	if profile.build == 0:
		block(66, 76, 3, 13, light); block(77, 76, 3, 13, light)
	elif profile.build == 2:
		block(63, 70, 7, 3, light); block(76, 70, 7, 3, light)
	elif profile.build == 3:
		block(60, 69, 10, 4, light); block(76, 69, 10, 4, light)
		block(66, 82, 14, 3, shadow)
	elif profile.build == 4:
		block(57, 68, 13, 5, light); block(76, 68, 13, 5, light)
		block(64, 80, 18, 4, shadow)
		block(65, 86, 16, 3, light)
	# Species-specific ears and subtly ridged brow.
	block(70 - face_width - 3, 42, 4, 9, shadow)
	block(72 + face_width, 42, 4, 9, shadow)
	block(71 - face_width, 33, face_width * 2 + 1, 22, shadow)
	block(72 - face_width, 34, face_width * 2 - 1, 18, skin)
	block(65, 51, 15, 7, skin)
	block(67, 57, 11, 2, shadow)
	block(65, 36, 15, 2, light)
	block(68, 33, 2, 4, shadow)
	block(72, 32, 2, 5, light)
	block(76, 33, 2, 4, shadow)
	# Veyrakian cranial ridge variants.
	match profile.ridge:
		1:
			block(64, 35, 5, 2, light); block(76, 34, 5, 2, light)
		2:
			block(66, 33, 3, 4, light); block(76, 33, 3, 4, light)
		3:
			block(68, 32, 2, 5, shadow); block(75, 32, 2, 5, shadow)
		4:
			block(63, 36, 7, 2, light); block(76, 36, 7, 2, light)
		5:
			block(66, 35, 13, 1, light)
	# Faces vary brow, cheekbone and jaw shapes.
	var eye_y = 43 + (1 if profile.face == 3 else 0)
	var brow_shift = [0, -1, 0, 1, -1, 1][profile.brow]
	var brow_thickness = [2, 3, 2, 2, 2, 3][profile.brow]
	block(64, eye_y - 2 + brow_shift, 6, brow_thickness, shadow.darkened(0.2))
	block(75, eye_y - 2 - brow_shift, 6, brow_thickness, shadow.darkened(0.2))
	block(65, eye_y, 5, 2, dark)
	block(75, eye_y, 5, 2, dark)
	block(67, eye_y, 2, 1, eyes)
	block(76, eye_y, 2, 1, eyes)
	block(72, 44, 2, 6, light)
	block(70, 50, 5, 1, shadow)
	block(69, 54, 7, 1, shadow.darkened(0.2))
	if profile.face == 0:
		block(66, 52, 2, 2, light); block(77, 52, 2, 2, light)
	if profile.face == 1 or profile.face == 5:
		block(63, 49, 4, 2, shadow)
		block(78, 49, 4, 2, shadow)
	if profile.face == 2:
		block(62, 51, 4, 4, shadow)
		block(79, 51, 4, 4, shadow)
		block(68, 55, 9, 2, shadow.darkened(0.15))
	if profile.face == 3:
		block(66, 48, 2, 4, light); block(78, 48, 2, 4, light)
		block(70, 54, 5, 2, shadow)
	if profile.face == 4:
		block(64, 45, 1, 7, light)
		block(78, 47, 3, 1, shadow)
	if profile.face == 5:
		block(64, 52, 4, 1, light); block(78, 52, 4, 1, light)
		block(71, 55, 4, 1, shadow)
	if profile.face == 6:
		block(63, 41, 7, 2, shadow.darkened(0.3))
		block(76, 42, 6, 1, shadow.darkened(0.3))
		block(65, 52, 3, 2, shadow)
	if profile.face == 7:
		block(63, 40, 5, 2, shadow)
		block(78, 40, 5, 2, shadow)
		block(66, 54, 13, 2, shadow.darkened(0.15))
	if profile.base == 1:
		block(66, 57, 2, 2, dark)
		block(78, 57, 2, 2, dark)
	# Eight marking choices, zero is deliberately unmarked.
	var marking = Color("526379").lerp(eyes, 0.25)
	match profile.markings:
		1:
			block(62, 42, 2, 9, marking)
			block(81, 42, 2, 9, marking)
		2:
			block(71, 37, 3, 5, marking)
			block(69, 38, 7, 1, marking)
		3:
			block(65, 47, 2, 5, marking)
			block(78, 47, 2, 5, marking)
		4:
			block(63, 47, 3, 2, marking)
			block(66, 49, 3, 2, marking)
			block(79, 47, 3, 2, marking)
			block(76, 49, 3, 2, marking)
		5:
			block(65, 39, 1, 1, marking)
			block(79, 39, 1, 1, marking)
			block(72, 38, 1, 2, marking)
			block(64, 49, 2, 2, marking)
			block(79, 49, 2, 2, marking)
		6:
			block(62, 46, 8, 3, marking)
			block(75, 46, 8, 3, marking)
		7:
			block(72, 38, 1, 4, marking)
			block(64, 50, 3, 3, marking)
			block(78, 50, 3, 3, marking)
		8:
			block(62, 44, 2, 2, marking)
			block(81, 44, 2, 2, marking)
			block(64, 47, 2, 2, marking)
			block(79, 47, 2, 2, marking)
			block(66, 50, 2, 2, marking)
			block(77, 50, 2, 2, marking)
		9:
			block(65, 36, 3, 2, marking)
			block(77, 36, 3, 2, marking)
			block(68, 38, 2, 3, marking)
			block(75, 38, 2, 3, marking)
	# Ten distinct hair silhouettes.
	match profile.hair:
		1:
			block(63, 31, 19, 4, hair)
		2:
			block(61, 29, 22, 5, hair)
			block(60, 33, 9, 6, hair)
			block(60, 39, 3, 7, hair)
		3:
			block(69, 23, 7, 12, hair)
			block(70, 22, 5, 2, hair.lightened(0.2))
		4:
			block(62, 29, 20, 5, hair)
			block(62, 34, 5, 7, hair)
		5:
			block(60, 30, 25, 5, hair)
			block(59, 34, 5, 30, hair)
			block(81, 34, 5, 30, hair)
		6:
			block(61, 30, 23, 5, hair)
			for i in range(8):
				block(59 + i % 2, 36 + i * 4, 4, 3, hair.lightened(0.15))
				block(82 - i % 2, 36 + i * 4, 4, 3, hair.lightened(0.15))
		7:
			block(62, 30, 21, 5, hair)
			block(78, 28, 8, 9, hair)
			block(81, 39, 5, 2, trim)
		8:
			block(63, 29, 19, 6, hair)
			block(62, 26, 4, 5, hair)
			block(70, 23, 4, 8, hair)
			block(78, 25, 4, 6, hair)
		9:
			block(61, 30, 11, 6, hair)
			block(74, 30, 10, 6, hair)
			block(61, 35, 4, 6, hair)
			block(80, 35, 4, 6, hair)
		10:
			block(59, 29, 27, 6, hair)
			block(57, 33, 7, 11, hair)
			block(81, 33, 7, 11, hair)
			block(60, 25, 6, 7, hair)
			block(69, 22, 7, 10, hair)
			block(79, 25, 6, 8, hair)
		11:
			block(62, 29, 21, 5, hair)
			block(60, 33, 6, 9, hair)
			block(80, 33, 5, 8, hair)
			block(58, 40, 4, 18, hair)
			block(57, 55, 5, 3, trim)

