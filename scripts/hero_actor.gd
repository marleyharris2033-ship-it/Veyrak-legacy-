class_name VeyrakActor
extends Node2D
## Shared 4-cell rig per hero: front idle/step, rear idle/step.
## Later attack/equipment atlases can reuse the same feet anchor and frame grid.
const SHEET = preload("res://assets/heroes/gameplay-sprites.png")
const KAERUN_ANIMS = preload("res://assets/heroes/40D7EB5F-39B8-4B93-884B-65BFB5F6BDF0.png")
var hero_id = "kaerun"
var motion = Vector2.ZERO
var facing = Vector2(1,1)
var clock = 0.0
var flash = 0.0
var sprite: Sprite2D
var action_anim := ""
var action_clock := 0.0
func _ready() -> void:
	texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	sprite = Sprite2D.new()
	sprite.texture = SHEET
	# Use explicit atlas regions instead of hframes/vframes. Some source artwork
	# crosses the nominal 256px cell boundaries; the safe top insets prevent
	# neighbouring-frame pixels (the stray marks seen above Nyvara) rendering.
	sprite.region_enabled = true
	sprite.region_filter_clip_enabled = true
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
	action_clock += delta
	if action_anim != "" and action_clock > (0.75 if action_anim == "slam" else 0.55):
		action_anim = ""
		action_clock = 0.0
	flash = maxf(0,flash-delta)
	if motion.length_squared() > .01: facing = motion
	_update_frame()
func _update_frame() -> void:
	if hero_id == "kaerun":
		_update_kaerun_frame()
		return
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
	# Wind-up, recoil/lunge and recovery for the non-atlas weapon users.
	if action_anim == "punch":
		var phase = clampf(action_clock/.4,0,1)
		var thrust = sin(phase*PI)
		var ranged = hero_id in ["dhoran","nyvara","ilyra"]
		sprite.position += facing.normalized()*thrust*(-6 if ranged else 10)
		sprite.rotation = thrust*(.07 if sprite.flip_h else -.07)
	else: sprite.rotation = 0
func _draw() -> void:
	draw_set_transform(Vector2.ZERO,0,Vector2(1,.36))
	draw_circle(Vector2.ZERO,24,Color(0,0,0,.3))


func play_attack() -> void:
	action_anim = "punch"
	action_clock = 0.0

func play_signature() -> void:
	if hero_id == "kaerun":
		action_anim = "slam"
		action_clock = 0.0

func play_hit() -> void:
	flash = .18
	if hero_id == "kaerun":
		action_anim = "hit"
		action_clock = 0.0

func _update_kaerun_frame() -> void:
	# Source is NOT a regular grid. Each pose has an authored crop and feet pivot.
	sprite.texture = KAERUN_ANIMS
	var frames = [[20,0,180,187,100,181]]
	if action_anim == "punch":
		frames = [[15,364,192,176,109,171],[214,364,198,177,102,171],[416,361,222,180,108,174],[640,364,214,177,102,171],[214,364,198,177,102,171],[15,364,192,176,109,171]]
	elif action_anim == "slam":
		frames = [[0,548,230,186,122,180],[237,548,377,186,177,180],[617,548,311,186,158,180],[930,548,301,187,144,181],[1236,548,221,186,104,180]]
	elif action_anim == "hit":
		frames = [[15,874,172,139,92,133]]
	elif motion.length_squared() > .01:
		frames = [[432,0,168,187,85,181],[627,0,145,187,74,181],[831,0,145,187,74,181]] if facing.y >= -.1 else [[1018,0,157,187,78,181],[1197,0,159,187,80,181],[1370,0,160,187,80,181]]
	elif facing.y < -.1:
		frames = [[1018,0,157,187,78,181]]
	var index = mini(frames.size()-1,int(action_clock*11)) if action_anim != "" else int(clock*8)%frames.size()
	var f = frames[index]
	sprite.region_enabled = true
	sprite.region_rect = Rect2(f[0],f[1],f[2],f[3])
	sprite.region_filter_clip_enabled = true
	sprite.centered = false
	sprite.offset = Vector2(-f[4],-f[5])
	sprite.flip_h = facing.x < 0
	if sprite.flip_h: sprite.offset.x = f[4]-f[2]
	sprite.position = Vector2.ZERO
	sprite.scale = Vector2(.43,.43)
	sprite.modulate = Color(1.6,1.4,1.1) if flash>0 else Color.WHITE
