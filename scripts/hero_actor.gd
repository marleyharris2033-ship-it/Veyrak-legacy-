class_name VeyrakActor
extends Node2D
## Shared 4-cell rig per hero: front idle/step, rear idle/step.
## Later attack/equipment atlases can reuse the same feet anchor and frame grid.
const SHEET = preload("res://assets/heroes/gameplay-sprites.png")
var hero_id = "kaerun"
var motion = Vector2.ZERO
var facing = Vector2(1,1)
var clock = 0.0
var flash = 0.0
var sprite: Sprite2D
func _ready() -> void:
	texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	sprite = Sprite2D.new()
	sprite.texture = SHEET
	# Use explicit atlas regions instead of hframes/vframes. Some source artwork
	# crosses the nominal 256px cell boundaries; the safe top insets prevent
	# neighbouring-frame pixels (the stray marks seen above Nyvara) rendering.
	sprite.region_enabled = true
	# The generated atlas cells include artwork close to their source-cell edges.
	# Give the gameplay render a small safe inset instead of enlarging/re-cropping
	# individual heroes; this keeps all six on one consistent feet anchor and
	# prevents weapons/hair from appearing clipped at frame boundaries.
	sprite.position = Vector2(0,-42)
	sprite.scale = Vector2(.34,.34)
	add_child(sprite)
	_update_frame()
func _process(delta: float) -> void:
	clock += delta
	flash = maxf(0,flash-delta)
	if motion.length_squared() > .01: facing = motion
	_update_frame()
func _update_frame() -> void:
	var col = 2 if facing.y < -.1 else 0
	if motion.length_squared() > .01: col += int(clock*7.0)%2
	var row = maxi(0,VeyrakHeroes.index_of(hero_id))
	var top_insets = [0, 8, 8, 8, 20, 8]
	var inset = top_insets[row]
	sprite.region_rect = Rect2(col*256, row*256+inset, 256, 256-inset)
	sprite.flip_h = facing.x < 0
	# Keep the feet anchor stable across front/rear and walk frames.
	sprite.position = Vector2(0,-42 - (1 if motion.length_squared()>.01 and int(clock*7.0)%2 else 0))
	sprite.modulate = Color(1.6,1.4,1.1) if flash>0 else Color.WHITE
func _draw() -> void:
	draw_set_transform(Vector2.ZERO,0,Vector2(1,.36))
	draw_circle(Vector2.ZERO,24,Color(0,0,0,.3))
