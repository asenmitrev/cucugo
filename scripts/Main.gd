extends Node2D

const W := 800.0
const H := 450.0
const GRAV := 900.0
const SW := 90.0
const SH := 90.0

const P1_START := Vector2(140.0, 300.0)
const P2_START := Vector2(570.0, 300.0)

const PLATS := [
	[0.0,   400.0, 800.0, 50.0],
	[80.0,  305.0, 165.0, 16.0],
	[555.0, 305.0, 165.0, 16.0],
	[315.0, 220.0, 170.0, 16.0],
]


var ASEN_DEF   = preload("res://resources/asen.tres")
var DJOLEV_DEF = preload("res://resources/djolev.tres")
var SIYANA_DEF = preload("res://resources/siyana.tres")

# Preload all sprite textures at parse time so _init_player does zero disk I/O.
const _TEX := {
    "asen": {
        "idle":  preload("res://assets/asen/asen-idle.png"),
        "walk":  preload("res://assets/asen/asen-walk.png"),
        "jump":  preload("res://assets/asen/asen-jump.png"),
        "punch": preload("res://assets/asen/asen-punch.png"),
    },
    "djolev": {
        "idle":  preload("res://assets/djolev/djolev-idle.png"),
        "walk":  preload("res://assets/djolev/djolev-walk.png"),
        "jump":  preload("res://assets/djolev/djolev-jump.png"),
        "punch": preload("res://assets/djolev/djolev-punch.png"),
    },
    "siyana": {
        "idle":  preload("res://assets/siyana/siyana-idle.png"),
        "walk":  preload("res://assets/siyana/siyana-walk.png"),
        "jump":  preload("res://assets/siyana/siyana-jump.png"),
        "punch": preload("res://assets/siyana/siyana-punch.png"),
        "kick":  preload("res://assets/siyana/siyana-finger.png"),
    },
}


var p1_def = null
var p2_def = null

var pl := [{}, {}]
var impacts := []
var game_over := false
var restart_t: float = 0.0
const RESTART_DELAY := 3.0

var _lbl_p1: Label
var _lbl_p2: Label
var _lbl_winner: Label
var _lbl_restart: Label
var _lbl_controls: Label


func _ready() -> void:
	OS.window_fullscreen = true
	MenuManager.locked = false
	var ui := CanvasLayer.new()
	add_child(ui)

	var _p1: CharacterDef = p1_def if p1_def != null else ASEN_DEF
	var _p2: CharacterDef = p2_def if p2_def != null else DJOLEV_DEF
	_lbl_p1 = _make_lbl(_p1.display_name, Vector2(18, 8), _p1.label_color)
	_lbl_p2 = _make_lbl(_p2.display_name, Vector2(680, 8), _p2.label_color)
	_lbl_controls = _make_lbl(
		"ASEN: A/D move  W jump  R/F/V skills        DJOLEV: ←/→ move  ↑ jump  ;/'/ \\ skills        Esc menu",
		Vector2(8, 432), Color(0.35, 0.35, 0.45))
	_lbl_winner = _make_lbl("", Vector2(0, 168), Color.white)
	_lbl_winner.rect_size = Vector2(W / 2.8, 40)
	_lbl_winner.rect_scale = Vector2(2.8, 2.8)
	_lbl_winner.align = Label.ALIGN_CENTER
	_lbl_winner.visible = false

	_lbl_restart = _make_lbl("Restarting in 3...", Vector2(0, 248), Color(0.6, 0.6, 0.85))
	_lbl_restart.rect_size = Vector2(W / 1.4, 30)
	_lbl_restart.rect_scale = Vector2(1.4, 1.4)
	_lbl_restart.align = Label.ALIGN_CENTER
	_lbl_restart.visible = false

	for lbl in [_lbl_p1, _lbl_p2, _lbl_controls, _lbl_winner, _lbl_restart]:
		ui.add_child(lbl)

	_init_player(0, _p1)
	_init_player(1, _p2)



func _make_lbl(txt: String, pos: Vector2, col: Color) -> Label:
	var l := Label.new()
	l.text = txt
	l.rect_position = pos
	l.add_color_override("font_color", col)
	return l


func _init_player(i: int, def: CharacterDef) -> void:
	var spr := Sprite.new()
	spr.centered = false
	spr.hframes = 2
	spr.vframes = 2
	spr.scale = Vector2(SW / 128.0, SH / 128.0)
	add_child(spr)

	var tex: Dictionary = _TEX[def.char_name]

	var slot: String = "p1" if i == 0 else "p2"
	pl[i] = {
		"def": def,
		"name": def.display_name, "pos": P1_START if i == 0 else P2_START, "vel": Vector2.ZERO,
		"right": i == 0, "on_gnd": false,
		"state": "idle",
		"dead": false, "death_t": 0.0,
		"anim_t": 0.0, "anim_frame": 0, "prev_state": "idle",
		"tex": tex, "spr": spr,
		"skill_cds":      [0.0, 0.0, 0.0],
		"casting_skill":  -1,
		"cast_t":          0.0,
		"active_effects": [],
		"action_left":   slot + "_left",
		"action_right":  slot + "_right",
		"action_jump":   slot + "_jump",
		"action_skill1": slot + "_skill1",
		"action_skill2": slot + "_skill2",
		"action_skill3": slot + "_skill3",
	}


func _anim_spd(def: CharacterDef, state: String) -> float:
	match state:
		"idle":  return def.anim_idle
		"walk":  return def.anim_walk
		"jump":  return def.anim_jump
		"dead":  return def.anim_dead
	return 0.15


func _process(delta: float) -> void:
	var dt := min(delta, 0.1)

	if game_over:
		restart_t += dt
		_lbl_restart.text = "Restarting in %d..." % int(ceil(RESTART_DELAY - restart_t))
		if restart_t >= RESTART_DELAY:
			get_tree().change_scene("res://scenes/CharSelect.tscn")
		update()
		return

	if MenuManager.is_open():
		update()
		return

	for i in [0, 1]:
		_update_player(i, 1 - i, dt)

	if not game_over:
		if pl[0]["dead"] and pl[1]["dead"]:
			_end_game("DRAW!")
		elif pl[0]["dead"]:
			_end_game(pl[1]["def"].display_name + " WINS!")
		elif pl[1]["dead"]:
			_end_game(pl[0]["def"].display_name + " WINS!")

	for i in [0, 1]:
		var p: Dictionary = pl[i]
		var spr: Sprite = p["spr"]
		var key: String
		if p["dead"]:
			key = "idle"
		elif p["casting_skill"] >= 0:
			var _sk_defs: Array = [p["def"].skill1, p["def"].skill2, p["def"].skill3]
			var _sk: Resource = _sk_defs[p["casting_skill"]]
			key = _sk.cast_anim if _sk != null else p["state"]
		else:
			key = p["state"]
		spr.texture = p["tex"].get(key, p["tex"]["idle"])
		spr.position = p["pos"]
		spr.flip_h = not p["right"]

		var cur_state: String = p["state"]
		if cur_state != p["prev_state"]:
			p["prev_state"] = cur_state
			p["anim_t"] = 0.0
			p["anim_frame"] = 0
		p["anim_t"] += dt
		var frame_dur: float = _anim_spd(p["def"], cur_state)
		if p["casting_skill"] >= 0:
			var csk: Resource = ([p["def"].skill1, p["def"].skill2, p["def"].skill3] as Array)[p["casting_skill"]]
			if csk != null:
				frame_dur = csk.anim_cast
		if p["anim_t"] >= frame_dur:
			p["anim_t"] -= frame_dur
			p["anim_frame"] = (int(p["anim_frame"]) + 1) % 4
		spr.frame = int(p["anim_frame"])

		if p["dead"]:
			spr.modulate.a = max(0.0, 1.0 - p["death_t"] * 0.75)
			spr.rotation += 3.0 * PI * dt * min(p["death_t"], 0.8)
		elif p["casting_skill"] >= 0:
			spr.modulate = Color(1.2, 1.2, 1.5, 1.0)
		else:
			spr.modulate = Color(1.0, 1.0, 1.0, spr.modulate.a)

	var keep_imp := []
	for imp in impacts:
		imp["age"] += dt
		if imp["age"] < 0.55:
			keep_imp.append(imp)
	impacts = keep_imp

	update()


func _update_player(i: int, oi: int, dt: float) -> void:
	var p: Dictionary = pl[i]
	var o: Dictionary = pl[oi]
	var def: CharacterDef = p["def"]

	if p["dead"]:
		p["casting_skill"] = -1
		p["active_effects"] = []
		p["vel"].y += GRAV * dt
		p["pos"] += p["vel"] * dt
		p["vel"].x = lerp(p["vel"].x, 0.0, 4.0 * dt)
		p["death_t"] += dt
		return

	# Tick skill cooldowns
	for k in 3:
		if p["skill_cds"][k] > 0.0:
			p["skill_cds"][k] = max(0.0, p["skill_cds"][k] - dt)

	# Tick active effects and check for hits
	var live_effects := []
	for ae in p["active_effects"]:
		ae["t"] += dt
		ae["vy"] += ae["skill"].effect_gravity * dt
		ae["rect"] = Rect2(ae["rect"].position + Vector2(ae["dx"], ae["dy"] + ae["vy"]) * dt, ae["rect"].size)
		if ae["skill"].effect_gravity > 0.0 and ae["vy"] >= 0.0:
			_collide_effect_plats(ae)
		ae["rotation"] += ae["rotation_speed"] * dt
		if not ae["hit"] and not o["dead"]:
			var odef: CharacterDef = o["def"]
			var o_rect := Rect2(o["pos"] + Vector2(odef.body_offset_x, odef.body_offset_y), Vector2(odef.body_w, odef.body_h))
			var eff_rect: Rect2 = ae["rect"]
			if eff_rect.intersects(o_rect):
				ae["hit"] = true
				o["dead"] = true
				o["death_t"] = 0.0
				var dir: float = 1.0 if p["right"] else -1.0
				o["vel"] = Vector2(dir * 380.0, -440.0)
				var hit_pos: Vector2 = eff_rect.position + eff_rect.size * 0.5
				impacts.append({"pos": hit_pos, "age": 0.0})
		if ae["t"] < ae["skill"].effect_duration:
			live_effects.append(ae)
	p["active_effects"] = live_effects

	# Tick cast timer and activate when ready
	if p["casting_skill"] >= 0:
		p["cast_t"] += dt
		var skill_idx: int = p["casting_skill"]
		var sk: Resource = ([def.skill1, def.skill2, def.skill3] as Array)[skill_idx]
		if p["cast_t"] >= sk.cast_time:
			_activate_skill(p, skill_idx, sk)

	if p["casting_skill"] < 0:
		var skill_actions: Array = [p["action_skill1"], p["action_skill2"], p["action_skill3"]]
		var skill_defs: Array = [def.skill1, def.skill2, def.skill3]
		for k in 3:
			if skill_defs[k] != null and skill_actions[k] != "" \
					and p["skill_cds"][k] <= 0.0 \
					and Input.is_action_just_pressed(skill_actions[k]):
				p["casting_skill"] = k
				p["cast_t"] = 0.0
				p["anim_t"] = 0.0
				p["anim_frame"] = 0
				break

	if Input.is_action_pressed(p["action_left"]):
		p["vel"].x = -def.speed
		p["right"] = false
	elif Input.is_action_pressed(p["action_right"]):
		p["vel"].x = def.speed
		p["right"] = true
	else:
		p["vel"].x = lerp(p["vel"].x, 0.0, 14.0 * dt)

	if Input.is_action_just_pressed(p["action_jump"]) and p["on_gnd"]:
		p["vel"].y = def.jump_vel

	p["vel"].y += GRAV * dt
	p["pos"] += p["vel"] * dt

	if not p["on_gnd"]:
		p["state"] = "jump"
	elif abs(p["vel"].x) > 10.0:
		p["state"] = "walk"
	else:
		p["state"] = "idle"

	_collide_plats(p)
	var _bdef: CharacterDef = p["def"]
	p["pos"].x = clamp(p["pos"].x, -_bdef.body_offset_x, W - _bdef.body_offset_x - _bdef.body_w)

	if p["pos"].y > H + 100.0:
		p["dead"] = true
		p["death_t"] = 0.0


func _activate_skill(p: Dictionary, skill_idx: int, sk: Resource) -> void:
	var def: CharacterDef = p["def"]
	var pos: Vector2 = p["pos"]
	var hx: float
	if p["right"]:
		hx = pos.x + sk.effect_offset_x
	else:
		hx = pos.x + def.body_offset_x + def.body_w - sk.effect_offset_x - sk.effect_width
	var hy: float = pos.y + sk.effect_offset_y
	var ae_tex: Texture = null
	if sk.effect_sprite_path != "":
		ae_tex = load(sk.effect_sprite_path) as Texture
	var dir: float = 1.0 if p["right"] else -1.0
	p["active_effects"].append({
		"skill":          sk,
		"t":              0.0,
		"rect":           Rect2(hx, hy, sk.effect_width, sk.effect_height),
		"hit":            false,
		"tex":            ae_tex,
		"dx":             sk.effect_dx * dir,
		"dy":             sk.effect_dy,
		"vy":             0.0,
		"rotation":       0.0,
		"rotation_speed": deg2rad(sk.effect_rotation_speed),
	})
	p["skill_cds"][skill_idx] = sk.cooldown
	p["casting_skill"] = -1
	p["cast_t"] = 0.0


func _collide_plats(p: Dictionary) -> void:
	p["on_gnd"] = false
	for plat in PLATS:
		var px: float = plat[0]
		var py: float = plat[1]
		var pw: float = plat[2]
		var _pd: CharacterDef = p["def"]
		var _bx: float = p["pos"].x + _pd.body_offset_x
		var _by: float = p["pos"].y + _pd.body_offset_y
		if p["vel"].y >= 0.0 \
				and _bx + _pd.body_w > px + 5.0 \
				and _bx < px + pw - 5.0 \
				and _by + _pd.body_h >= py \
				and _by + _pd.body_h <= py + 30.0:
			p["pos"].y = py - _pd.body_h - _pd.body_offset_y
			p["vel"].y = 0.0
			p["on_gnd"] = true


func _collide_effect_plats(ae: Dictionary) -> void:
	var rect: Rect2 = ae["rect"]
	for plat in PLATS:
		var px: float = plat[0]
		var py: float = plat[1]
		var pw: float = plat[2]
		var bottom: float = rect.end.y
		if rect.position.x < px + pw - 5.0 \
				and rect.end.x > px + 5.0 \
				and bottom >= py \
				and bottom <= py + 35.0:
			ae["rect"] = Rect2(rect.position.x, py - rect.size.y, rect.size.x, rect.size.y)
			ae["vy"] = 0.0
			ae["dx"] = 0.0
			return


func _end_game(text: String) -> void:
	if game_over:
		return
	game_over = true
	restart_t = 0.0
	MenuManager.locked = true
	_lbl_winner.text = text
	_lbl_winner.visible = true
	_lbl_restart.visible = true


func _draw() -> void:
	draw_rect(Rect2(0, 0, W, H), Color(0.07, 0.08, 0.16))
	draw_rect(Rect2(0, H * 0.6, W, H * 0.4), Color(0.10, 0.12, 0.22))

	for i in range(28):
		var sx := fmod(float(i * 137 + 29), 780.0) + 10.0
		var sy := fmod(float(i * 97 + 13), 185.0) + 8.0
		var sz := 2.0 if i % 3 == 0 else 1.0
		draw_rect(Rect2(sx, sy, sz, sz), Color(1, 1, 1, 0.45))

	for plat in PLATS:
		var px: float = plat[0]
		var py: float = plat[1]
		var pw: float = plat[2]
		var ph: float = plat[3]
		draw_rect(Rect2(px + 4, py + 4, pw, ph), Color(0, 0, 0, 0.22))
		draw_rect(Rect2(px, py, pw, ph), Color(0.18, 0.12, 0.32))
		draw_rect(Rect2(px, py, pw, 5), Color(0.42, 0.35, 0.55))
		draw_rect(Rect2(px, py, 3, ph), Color(0.30, 0.22, 0.44))
		draw_rect(Rect2(px + pw - 3, py, 3, ph), Color(0.30, 0.22, 0.44))

	# Active skill effect hitboxes
	for i in [0, 1]:
		var p: Dictionary = pl[i]
		if p.empty():
			continue
		for ae in p["active_effects"]:
			var rect: Rect2 = ae["rect"]
			var tex: Texture = ae["tex"]
			if tex != null:
				var center: Vector2 = rect.position + rect.size * 0.5
				draw_set_transform(center, ae["rotation"], Vector2.ONE)
				draw_texture_rect(tex, Rect2(-rect.size * 0.5, rect.size), false)
				draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
			else:
				var col: Color = ae["skill"].effect_color
				var fade: float = 1.0 - ae["t"] / ae["skill"].effect_duration
				draw_rect(rect, Color(col.r, col.g, col.b, 0.35 * fade))
				draw_rect(rect, Color(col.r, col.g, col.b, fade), false)

	# Cast charge bars (above character head)
	for i in [0, 1]:
		var p: Dictionary = pl[i]
		if p.empty() or p["casting_skill"] < 0:
			continue
		var skill_idx: int = p["casting_skill"]
		var sk_defs: Array = [p["def"].skill1, p["def"].skill2, p["def"].skill3]
		var sk: Resource = sk_defs[skill_idx]
		var progress: float = min(1.0, p["cast_t"] / sk.cast_time)
		var pos: Vector2 = p["pos"]
		var bx: float = pos.x + SW * 0.5 - 20.0
		var by: float = pos.y - 14.0
		draw_rect(Rect2(bx, by, 40.0, 5.0), Color(0.2, 0.2, 0.2, 0.7))
		draw_rect(Rect2(bx, by, 40.0 * progress, 5.0), Color(1.0, 0.9, 0.2, 0.9))

	# Skill cooldown dots (3 dots above each player)
	for i in [0, 1]:
		var p: Dictionary = pl[i]
		if p.empty() or p["dead"]:
			continue
		var pos: Vector2 = p["pos"]
		for k in 3:
			var ready: bool = p["skill_cds"][k] <= 0.0
			var dot_col: Color = Color(0.2, 0.85, 0.25) if ready else Color(0.45, 0.18, 0.08)
			draw_circle(Vector2(pos.x + k * 14.0 + 4.0, pos.y - 8.0), 4.0, dot_col)

	for imp in impacts:
		var a: float = 1.0 - float(imp["age"]) / 0.55
		var r: float = 10.0 + float(imp["age"]) * 90.0
		draw_circle(imp["pos"] as Vector2, r, Color(1.0, 0.35, 0.1, a * 0.55))
		draw_circle(imp["pos"] as Vector2, r * 0.45, Color(1.0, 0.9, 0.3, a * 0.7))

	if game_over:
		draw_rect(Rect2(0, 0, W, H), Color(0, 0, 0, 0.58))

	MenuManager.draw_overlay(self)
