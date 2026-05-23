extends Node2D

const W := 800.0
const H := 450.0
const GRAV := 900.0
const SW := 90.0
const SH := 90.0

const PLATS := [
	[0.0,   400.0, 800.0, 50.0],
	[80.0,  305.0, 165.0, 16.0],
	[555.0, 305.0, 165.0, 16.0],
	[315.0, 220.0, 170.0, 16.0],
]


var ASEN_DEF   = preload("res://resources/asen.tres")
var DJOLEV_DEF = preload("res://resources/djolev.tres")


var pl := [{}, {}]
var impacts := []
var game_over := false

var _lbl_p1: Label
var _lbl_p2: Label
var _lbl_winner: Label
var _lbl_restart: Label
var _lbl_controls: Label


func _ready() -> void:
	var ui := CanvasLayer.new()
	add_child(ui)

	_lbl_p1 = _make_lbl(ASEN_DEF.display_name, Vector2(18, 8), ASEN_DEF.label_color)
	_lbl_p2 = _make_lbl(DJOLEV_DEF.display_name, Vector2(680, 8), DJOLEV_DEF.label_color)
	_lbl_controls = _make_lbl(
		"ASEN: A/D move  W jump  Space punch  R/F/V skills        DJOLEV: ←/→ move  ↑ jump  Enter punch  ;/'/ \\ skills",
		Vector2(8, 432), Color(0.35, 0.35, 0.45))
	_lbl_winner = _make_lbl("", Vector2(0, 168), Color.white)
	_lbl_winner.rect_size = Vector2(W / 2.8, 40)
	_lbl_winner.rect_scale = Vector2(2.8, 2.8)
	_lbl_winner.align = Label.ALIGN_CENTER
	_lbl_winner.visible = false

	_lbl_restart = _make_lbl("Press R to rematch", Vector2(0, 248), Color(0.6, 0.6, 0.85))
	_lbl_restart.rect_size = Vector2(W / 1.4, 30)
	_lbl_restart.rect_scale = Vector2(1.4, 1.4)
	_lbl_restart.align = Label.ALIGN_CENTER
	_lbl_restart.visible = false

	for lbl in [_lbl_p1, _lbl_p2, _lbl_controls, _lbl_winner, _lbl_restart]:
		ui.add_child(lbl)

	_init_player(0, ASEN_DEF)
	_init_player(1, DJOLEV_DEF)



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

	var tex := {}
	for s in ["idle", "walk", "jump", "punch"]:
		tex[s] = load("res://assets/%s/%s-%s.png" % [def.char_name, def.char_name, s])

	pl[i] = {
		"def": def,
		"name": def.display_name, "pos": def.start_pos, "vel": Vector2.ZERO,
		"right": def.facing_right, "on_gnd": false,
		"state": "idle",
		"punch_t": 0.0, "punch_hit": false, "last_pe": 0.0,
		"dead": false, "death_t": 0.0,
		"anim_t": 0.0, "anim_frame": 0, "prev_state": "idle",
		"tex": tex, "spr": spr,
		"skill_cds":     [0.0, 0.0, 0.0],
		"casting_skill": -1,
		"cast_t":         0.0,
		"active_effect":  null,
	}


func _anim_spd(def: CharacterDef, state: String) -> float:
	match state:
		"idle":  return def.anim_idle
		"walk":  return def.anim_walk
		"jump":  return def.anim_jump
		"punch": return def.anim_punch
		"dead":  return def.anim_dead
	return 0.15


func _process(delta: float) -> void:
	var dt := min(delta, 0.033)

	if game_over:
		if Input.is_action_just_pressed("restart"):
			get_tree().reload_current_scene()
		update()
		return

	for i in [0, 1]:
		_update_player(i, 1 - i, dt)

	if not game_over:
		if pl[0]["dead"] and pl[1]["dead"]:
			_end_game("DRAW!")
		elif pl[0]["dead"]:
			_end_game(DJOLEV_DEF.display_name + " WINS!")
		elif pl[1]["dead"]:
			_end_game(ASEN_DEF.display_name + " WINS!")

	for i in [0, 1]:
		var p: Dictionary = pl[i]
		var spr: Sprite = p["spr"]
		var key: String = "idle" if p["dead"] else p["state"]
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
		elif p["state"] == "punch" and p["punch_t"] >= p["def"].hit_t0 and p["punch_t"] <= p["def"].hit_t1:
			spr.modulate = Color(1.5, 1.3, 0.5, 1.0)
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
		p["active_effect"] = null
		p["vel"].y += GRAV * dt
		p["pos"] += p["vel"] * dt
		p["vel"].x = lerp(p["vel"].x, 0.0, 4.0 * dt)
		p["death_t"] += dt
		return

	# Tick skill cooldowns
	for k in 3:
		if p["skill_cds"][k] > 0.0:
			p["skill_cds"][k] = max(0.0, p["skill_cds"][k] - dt)

	# Tick active effect and check for hits
	if p["active_effect"] != null:
		var ae: Dictionary = p["active_effect"]
		ae["t"] += dt
		if not ae["hit"] and not o["dead"]:
			var o_rect := Rect2(o["pos"], Vector2(SW, SH))
			var eff_rect: Rect2 = ae["rect"]
			if eff_rect.intersects(o_rect):
				ae["hit"] = true
				o["dead"] = true
				o["death_t"] = 0.0
				var dir: float = 1.0 if p["right"] else -1.0
				o["vel"] = Vector2(dir * 380.0, -440.0)
				var hit_pos: Vector2 = eff_rect.position + eff_rect.size * 0.5
				impacts.append({"pos": hit_pos, "age": 0.0})
		if ae["t"] >= ae["skill"].effect_duration:
			p["active_effect"] = null

	# Tick cast timer and activate when ready
	if p["casting_skill"] >= 0:
		p["cast_t"] += dt
		var skill_idx: int = p["casting_skill"]
		var sk: Resource = ([def.skill1, def.skill2, def.skill3] as Array)[skill_idx]
		if p["cast_t"] >= sk.cast_time:
			_activate_skill(p, skill_idx, sk)

	var punching: bool = p["state"] == "punch"

	if punching:
		p["punch_t"] += dt
		if p["punch_t"] >= def.punch_dur:
			p["state"] = "idle"
			p["last_pe"] = OS.get_ticks_msec() / 1000.0
			punching = false

	var now: float = OS.get_ticks_msec() / 1000.0
	if not punching and Input.is_action_just_pressed(def.action_punch):
		if now - p["last_pe"] > 0.15:
			p["state"] = "punch"
			p["punch_t"] = 0.0
			p["punch_hit"] = false
			p["vel"].x = 0.0
			punching = true

	# Skill inputs: blocked while punching or already casting
	if not punching and p["casting_skill"] < 0:
		var skill_actions: Array = [def.action_skill1, def.action_skill2, def.action_skill3]
		var skill_defs: Array = [def.skill1, def.skill2, def.skill3]
		for k in 3:
			if skill_defs[k] != null and skill_actions[k] != "" \
					and p["skill_cds"][k] <= 0.0 \
					and Input.is_action_just_pressed(skill_actions[k]):
				p["casting_skill"] = k
				p["cast_t"] = 0.0
				break

	if not punching:
		if Input.is_action_pressed(def.action_left):
			p["vel"].x = -def.speed
			p["right"] = false
		elif Input.is_action_pressed(def.action_right):
			p["vel"].x = def.speed
			p["right"] = true
		else:
			p["vel"].x = lerp(p["vel"].x, 0.0, 14.0 * dt)

		if Input.is_action_just_pressed(def.action_jump) and p["on_gnd"]:
			p["vel"].y = def.jump_vel
	else:
		p["vel"].x = lerp(p["vel"].x, 0.0, 12.0 * dt)

	p["vel"].y += GRAV * dt
	p["pos"] += p["vel"] * dt

	if not punching:
		if not p["on_gnd"]:
			p["state"] = "jump"
		elif abs(p["vel"].x) > 10.0:
			p["state"] = "walk"
		else:
			p["state"] = "idle"

	_collide_plats(p)
	p["pos"].x = clamp(p["pos"].x, 0.0, W - SW)

	if p["pos"].y > H + 100.0:
		p["dead"] = true
		p["death_t"] = 0.0

	if punching and not p["punch_hit"] and not o["dead"]:
		if p["punch_t"] >= def.hit_t0 and p["punch_t"] <= def.hit_t1:
			_punch_check(p, o)


func _activate_skill(p: Dictionary, skill_idx: int, sk: Resource) -> void:
	var pos: Vector2 = p["pos"]
	var hx: float
	if p["right"]:
		hx = pos.x + sk.effect_offset_x
	else:
		hx = pos.x + SW - sk.effect_offset_x - sk.effect_width
	var hy: float = pos.y + sk.effect_offset_y
	p["active_effect"] = {
		"skill": sk,
		"t":     0.0,
		"rect":  Rect2(hx, hy, sk.effect_width, sk.effect_height),
		"hit":   false,
	}
	p["skill_cds"][skill_idx] = sk.cooldown
	p["casting_skill"] = -1
	p["cast_t"] = 0.0


func _collide_plats(p: Dictionary) -> void:
	p["on_gnd"] = false
	for plat in PLATS:
		var px: float = plat[0]
		var py: float = plat[1]
		var pw: float = plat[2]
		if p["vel"].y >= 0.0 \
				and p["pos"].x + SW > px + 5.0 \
				and p["pos"].x < px + pw - 5.0 \
				and p["pos"].y + SH >= py \
				and p["pos"].y + SH <= py + 30.0:
			p["pos"].y = py - SH
			p["vel"].y = 0.0
			p["on_gnd"] = true


func _punch_check(a: Dictionary, d: Dictionary) -> void:
	var adef: CharacterDef = a["def"]
	var ax: float = a["pos"].x + SW * 0.5
	var ay: float = a["pos"].y + SH * 0.5
	var dx: float = d["pos"].x + SW * 0.5
	var dy: float = d["pos"].y + SH * 0.5
	var ddx: float = dx - ax
	var in_front: bool = ddx > 0.0 if a["right"] else ddx < 0.0
	if in_front and abs(ddx) < adef.punch_rx and abs(dy - ay) < adef.punch_ry:
		a["punch_hit"] = true
		d["dead"] = true
		d["death_t"] = 0.0
		var dir: float = 1.0 if a["right"] else -1.0
		d["vel"] = Vector2(dir * 380.0, -440.0)
		impacts.append({"pos": Vector2(dx, dy), "age": 0.0})


func _end_game(text: String) -> void:
	if game_over:
		return
	game_over = true
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
		if p.empty() or p["active_effect"] == null:
			continue
		var ae: Dictionary = p["active_effect"]
		var col: Color = ae["skill"].effect_color
		var fade: float = 1.0 - ae["t"] / ae["skill"].effect_duration
		var rect: Rect2 = ae["rect"]
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

	for i in [0, 1]:
		var p: Dictionary = pl[i]
		if p.empty():
			continue
		if p["state"] == "punch" and p["punch_t"] >= p["def"].hit_t0 and p["punch_t"] <= p["def"].hit_t1:
			var cx: float = (p["pos"] as Vector2).x + (SW if p["right"] else 0.0)
			var cy: float = (p["pos"] as Vector2).y + SH * 0.5
			draw_circle(Vector2(cx, cy), 22.0, Color(1.0, 0.85, 0.1, 0.35))

	for imp in impacts:
		var a: float = 1.0 - float(imp["age"]) / 0.55
		var r: float = 10.0 + float(imp["age"]) * 90.0
		draw_circle(imp["pos"] as Vector2, r, Color(1.0, 0.35, 0.1, a * 0.55))
		draw_circle(imp["pos"] as Vector2, r * 0.45, Color(1.0, 0.9, 0.3, a * 0.7))

	if game_over:
		draw_rect(Rect2(0, 0, W, H), Color(0, 0, 0, 0.58))
