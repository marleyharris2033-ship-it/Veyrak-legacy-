class_name VeyrakAppearance
extends Control
## Layered art renderer shared by creation, save portraits and future NPCs.
const BODY = preload("res://assets/creator/modular/bodies.png")
const FACE = preload("res://assets/creator/modular/faces.png")
const HAIR = preload("res://assets/creator/modular/hair.png")
const PALETTE = preload("res://assets/creator/modular/palette.gdshader")
# Per-style cap registration (width relative to face, x/y offsets).
# Long tails must not determine the size or position of the skull cap.
const HAIR_FIT = [
	Vector3(1.12, -.06, -.04), Vector3(1.20, -.12, -.15),
	Vector3(1.18, -.10, -.22), Vector3(1.20, -.12, -.16),
	Vector3(1.30, -.20, -.10), Vector3(1.22, -.14, -.10),
	Vector3(1.40, -.30, -.12), Vector3(1.26, -.18, -.25),
	Vector3(1.16, -.08, -.10), Vector3(1.42, -.32, -.20),
	Vector3(1.24, -.15, -.12)
]
var profile: Dictionary = VeyrakProfile.defaults()
var zoom_face = false
var layers: Array[TextureRect] = []
var detail: Control
var head_rect = Rect2()
var cache: Dictionary = {}

func _ready() -> void:
	mouse_filter = MOUSE_FILTER_IGNORE
	texture_filter = TEXTURE_FILTER_NEAREST
	clip_contents = true
	for i in range(3):
		var layer = TextureRect.new()
		layer.mouse_filter = MOUSE_FILTER_IGNORE
		layer.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		layer.stretch_mode = TextureRect.STRETCH_SCALE
		layer.material = ShaderMaterial.new()
		layer.material.shader = PALETTE
		add_child(layer)
		layers.append(layer)
	detail = Control.new()
	detail.mouse_filter = MOUSE_FILTER_IGNORE
	detail.draw.connect(_draw_details)
	add_child(detail)
	# Biological details belong on skin, beneath the hair, not on its surface.
	move_child(detail, layers[2].get_index())
	resized.connect(refresh)
	refresh()

func set_profile(value: Dictionary) -> void:
	profile = VeyrakProfile.validate(value)
	if is_node_ready(): refresh()

func region(texture: Texture2D, rect: Rect2i, trim: bool = true) -> Texture2D:
	var key = str(texture.resource_path, rect, trim)
	if cache.has(key): return cache[key]
	var image = texture.get_image().get_region(rect)
	if trim: image = image.get_region(image.get_used_rect())
	var result = ImageTexture.create_from_image(image)
	cache[key] = result
	return result

func refresh() -> void:
	if layers.is_empty() or size.y < 1: return
	var row_y = 0 if profile.base == 0 else 710
	var cell_x = int(round(profile.outfit * 1254.0 / 8))
	# Remove baked heads at the neck; independent face and hair occupy that anchor.
	var top = row_y + (70 if profile.base == 0 else 66)
	var end_y = 365 if profile.base == 0 else 1030
	layers[0].texture = region(BODY, Rect2i(cell_x, top, int(round((profile.outfit + 1) * 1254.0 / 8)) - cell_x, end_y-top))
	var face_index = profile.face + profile.base * 8
	var fx = int(round((face_index % 4) * 313.5))
	var fy = int(round(int(face_index / 4) * 313.5))
	layers[1].texture = region(FACE, Rect2i(fx, fy, 313, 313))
	var build_scale = [0.87, 0.96, 1.04, 1.17, 1.27][profile.build]
	var h = size.y * 0.80
	var body_size = Vector2(layers[0].texture.get_size())
	var scale_value = h / body_size.y
	var bw = body_size.x * scale_value * build_scale
	layers[0].position = Vector2((size.x-bw)*0.5, size.y*0.17)
	layers[0].size = Vector2(bw,h)
	var head_h = h * 0.165
	var head_w = head_h * layers[1].texture.get_width() / layers[1].texture.get_height()
	head_rect = Rect2(Vector2(size.x*0.5-head_w*0.30, size.y*0.17-head_h*0.83),Vector2(head_w,head_h))
	if zoom_face:
		var zoom_scale = minf(3.8, minf(size.x * .55 / head_rect.size.x, size.y * .48 / head_rect.size.y))
		head_rect.size *= zoom_scale
		head_rect.position = Vector2((size.x-head_rect.size.x)*0.5, size.y*0.22)
	layers[0].visible = not zoom_face
	layers[1].position = head_rect.position
	layers[1].size = head_rect.size
	layers[2].visible = profile.hair != 0
	if profile.hair != 0:
		var idx = profile.hair - 1
		layers[2].texture = region(HAIR, Rect2i(int(round((idx % 4)*313.5)), int(round(int(idx/4)*418.0)),313,418))
		var fit = HAIR_FIT[idx]
		var hw = head_rect.size.x * fit.x
		var hh = hw * layers[2].texture.get_height()/layers[2].texture.get_width()
		layers[2].size = Vector2(hw,hh)
		layers[2].position = head_rect.position + Vector2(head_rect.size.x * fit.y, head_rect.size.y * fit.z)
	for i in range(3):
		var mat = layers[i].material as ShaderMaterial
		mat.set_shader_parameter("mode", i)
		mat.set_shader_parameter("skin", Color(VeyrakProfile.SKIN_COLOURS[profile.skin]))
		mat.set_shader_parameter("accent", Color(VeyrakProfile.ACCENT_COLOURS[profile.accent]))
		mat.set_shader_parameter("hair", Color(VeyrakProfile.HAIR_COLOURS[profile.hair_colour]))
		mat.set_shader_parameter("eyes", Color(VeyrakProfile.EYE_COLOURS[profile.eyes]))
	detail.queue_redraw()

func _stroke(points: Array, colour: Color, width: float) -> void:
	var path = PackedVector2Array()
	for p in points: path.append(head_rect.position + p * head_rect.size)
	detail.draw_polyline(path, colour, width)

func _draw_details() -> void:
	var unit = head_rect.size.x / 80.0
	# Eye colour is applied to the artwork's eye pixels by the palette shader.
	# A fixed line here would float over differently shaped faces.
	var mark = Color(VeyrakProfile.SKIN_COLOURS[profile.skin]).darkened(.43)
	var patterns = [[],[Vector2(.40,.40),Vector2(.45,.55),Vector2(.40,.63)],[Vector2(.56,.27),Vector2(.62,.21),Vector2(.68,.30)], [Vector2(.54,.54),Vector2(.62,.65),Vector2(.55,.67),Vector2(.65,.76)], [Vector2(.43,.57),Vector2(.55,.63),Vector2(.62,.56)], [Vector2(.45,.28),Vector2(.52,.38),Vector2(.40,.35),Vector2(.52,.31)], [Vector2(.40,.50),Vector2(.63,.55),Vector2(.71,.52)], [Vector2(.43,.44),Vector2(.40,.61),Vector2(.52,.76)], [Vector2(.50,.80),Vector2(.52,.65),Vector2(.43,.56),Vector2(.46,.43)], [Vector2(.38,.30),Vector2(.44,.18),Vector2(.55,.27),Vector2(.63,.16)]]
	if profile.markings > 0: _stroke(patterns[profile.markings],mark,maxf(1.5,unit*2.3))
	if profile.ridges > 0:
		for i in range(profile.ridges + 1):
			var x = .34 + i*.055
			_stroke([Vector2(x,.28),Vector2(x+.018,.16),Vector2(x+.09,.11)],Color(VeyrakProfile.SKIN_COLOURS[profile.skin]).lightened(.18),maxf(1.0,unit*1.3))
