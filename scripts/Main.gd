extends Node2D

const W := 800.0
const H := 450.0
const GRAV := 900.0
const SW := 90.0
const SH := 90.0

# --- Level system ---
const LEVEL_CLASSIC = preload("res://resources/levels/classic.tres")
const LEVEL_SKYSCRAPER = preload("res://resources/levels/skyscraper.tres")
const LEVEL_CRATER = preload("res://resources/levels/crater.tres")
const LEVEL_FROST = preload("res://resources/levels/frost_bridge.tres")
const LEVEL_COLISEUM = preload("res://resources/levels/coliseum.tres")
const _levels = [LEVEL_CLASSIC, LEVEL_SKYSCRAPER, LEVEL_CRATER, LEVEL_FROST, LEVEL_COLISEUM]
var active_level = null
var _prev_level_idx = -1
var _level_flash_t = 0.0


var ASEN_DEF   = preload("res://resources/asen.tres")
var DJOLEV_DEF = preload("res://resources/djolev.tres")
var SIYANA_DEF = preload("res://resources/siyana.tres")
var CRUNCH_DEF = preload("res://resources/crunch.tres")
var DANI_DEF   = preload("res://resources/dani.tres")
var DRAGO_DEF  = preload("res://resources/drago.tres")
var RADO_DEF   = preload("res://resources/rado.tres")
var YAVOR_DEF  = preload("res://resources/yavor.tres")
var FIVEQ_DEF  = preload("res://resources/5q.tres")
var BOBE_DEF   = preload("res://resources/bobe.tres")
var IPMAN_DEF  = preload("res://resources/ipman.tres")
var ITSO_DEF   = preload("res://resources/itso.tres")
var SASHO_DEF  = preload("res://resources/sasho.tres")
var VALKA_DEF  = preload("res://resources/valka.tres")
var VELI_DEF   = preload("res://resources/veli.tres")

# Preload all sprite textures at parse time so _init_player does zero disk I/O.
const _TEX := {
    "asen": {
        "idle":    preload("res://assets/asen/asen-idle.png"),
        "walk":    preload("res://assets/asen/asen-walk.png"),
        "jump":    preload("res://assets/asen/asen-jump.png"),
        "punch":   preload("res://assets/asen/asen-punch.png"),
        "falling": preload("res://assets/asen/asen-falling.png"),
    },
    "djolev": {
        "idle":    preload("res://assets/djolev/djolev-idle.png"),
        "walk":    preload("res://assets/djolev/djolev-walk.png"),
        "jump":    preload("res://assets/djolev/djolev-jump.png"),
        "punch":   preload("res://assets/djolev/djolev-punch.png"),
        "falling": preload("res://assets/djolev/djolev-falling.png"),
    },
    "siyana": {
        "idle":    preload("res://assets/siyana/siyana-idle.png"),
        "walk":    preload("res://assets/siyana/siyana-walk.png"),
        "jump":    preload("res://assets/siyana/siyana-jump.png"),
        "punch":   preload("res://assets/siyana/siyana-punch.png"),
        "kick":    preload("res://assets/siyana/siyana-finger.png"),
        "falling": preload("res://assets/siyana/siyana-falling.png"),
    },
    "crunch": {
        "idle":    preload("res://assets/crunch/crunch-idle.png"),
        "walk":    preload("res://assets/crunch/crunch-walk.png"),
        "jump":    preload("res://assets/crunch/crunch-punch.png"),
        "punch":   preload("res://assets/crunch/crunch-punch.png"),
        "kick":    preload("res://assets/crunch/crunch-kick.png"),
        "flykick": preload("res://assets/crunch/crunch-flykick.png"),
        "falling": preload("res://assets/crunch/crunch-falling.png"),
    },
    "dani": {
        "idle":    preload("res://assets/dani/dani-idle.png"),
        "walk":    preload("res://assets/dani/dani-walk.png"),
        "jump":    preload("res://assets/dani/dani-jump.png"),
        "punch":   preload("res://assets/dani/dani-punch.png"),
        "kick":    preload("res://assets/dani/dani-kick.png"),
        "falling": preload("res://assets/dani/dani-fall.png"),
    },
    "drago": {
        "idle":    preload("res://assets/drago/drago-idle.png"),
        "walk":    preload("res://assets/drago/drago-walk.png"),
        "jump":    preload("res://assets/drago/drago-jump.png"),
        "punch":   preload("res://assets/drago/drago-punch.png"),
        "kick":    preload("res://assets/drago/drago-kick.png"),
        "falling": preload("res://assets/drago/drago-fall.png"),
    },
    "rado": {
        "idle":    preload("res://assets/rado/rado-idle.png"),
        "walk":    preload("res://assets/rado/rado-walk.png"),
        "jump":    preload("res://assets/rado/rado-jumping.png"),
        "punch":   preload("res://assets/rado/rado-punch.png"),
        "kick":    preload("res://assets/rado/rado-kick.png"),
        "falling": preload("res://assets/rado/rado-falling.png"),
    },
    "yavor": {
        "idle":    preload("res://assets/yavor/yavor-idle.png"),
        "walk":    preload("res://assets/yavor/yavor-walk.png"),
        "jump":    preload("res://assets/yavor/yavor-jump.png"),
        "punch":   preload("res://assets/yavor/yavor-punch.png"),
        "kick":    preload("res://assets/yavor/yavor-kick.png"),
        "falling": preload("res://assets/yavor/yavor-falling.png"),
    },
    "5q": {
        "idle":    preload("res://assets/5q/5q-idle.png"),
        "walk":    preload("res://assets/5q/5q-walk.png"),
        "jump":    preload("res://assets/5q/5q-jump.png"),
        "punch":   preload("res://assets/5q/5q-punch.png"),
        "kick":    preload("res://assets/5q/5q-kick.png"),
        "falling": preload("res://assets/5q/5q-falls.png"),
    },
    "bobe": {
        "idle":    preload("res://assets/bobe/bobe-idle.png"),
        "walk":    preload("res://assets/bobe/bobe-walk.png"),
        "jump":    preload("res://assets/bobe/bobe-jump.png"),
        "punch":   preload("res://assets/bobe/bobe-punch.png"),
        "kick":    preload("res://assets/bobe/bobe-kick.png"),
        "falling": preload("res://assets/bobe/bobe-falling.png"),
    },
    "ipman": {
        "idle":    preload("res://assets/ipman/ipman-idle.png"),
        "walk":    preload("res://assets/ipman/ipman-walk.png"),
        "jump":    preload("res://assets/ipman/ipman-jump.png"),
        "punch":   preload("res://assets/ipman/ipman-punch.png"),
        "kick":    preload("res://assets/ipman/ipman-kick.png"),
        "falling": preload("res://assets/ipman/ipman-fall.png"),
        "getting_up": preload("res://assets/ipman/ipman-getting-up.png"),
    },
    "itso": {
        "idle":    preload("res://assets/itso/itso-idle.png"),
        "walk":    preload("res://assets/itso/itso-walk.png"),
        "jump":    preload("res://assets/itso/itso-jump.png"),
        "punch":   preload("res://assets/itso/itso-punch.png"),
        "kick":    preload("res://assets/itso/itso-kick.png"),
        "falling": preload("res://assets/itso/itso-falling.png"),
    },
    "sasho": {
        "idle":    preload("res://assets/sasho/sasho-idle.png"),
        "walk":    preload("res://assets/sasho/sasho-walk.png"),
        "jump":    preload("res://assets/sasho/sasho-jump.png"),
        "punch":   preload("res://assets/sasho/sasho-punch.png"),
        "kick":    preload("res://assets/sasho/sasho-kick.png"),
        "falling": preload("res://assets/sasho/sasho-falling.png"),
    },
    "valka": {
        "idle":    preload("res://assets/valka/valka-idle.png"),
        "walk":    preload("res://assets/valka/valka-walk.png"),
        "jump":    preload("res://assets/valka/valka-jump.png"),
        "punch":   preload("res://assets/valka/valka-punch.png"),
        "kick":    preload("res://assets/valka/valka-kick.png"),
        "falling": preload("res://assets/valka/valka-fall.png"),
    },
    "veli": {
        "idle":    preload("res://assets/veli/veli-walk.png"),
        "walk":    preload("res://assets/veli/veli-walk.png"),
        "jump":    preload("res://assets/veli/veli-jump.png"),
        "punch":   preload("res://assets/veli/veli-punch.png"),
        "kick":    preload("res://assets/veli/veli-kick.png"),
        "falling": preload("res://assets/veli/veli-falling.png"),
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
var _lbl_level: Label


func _pick_level() -> void:
	var idx: int = 0
	if _levels.size() > 1:
		idx = randi() % _levels.size()
		while idx == _prev_level_idx:
			idx = randi() % _levels.size()
		_prev_level_idx = idx
	else:
		idx = 0
	active_level = _levels[idx]
	_level_flash_t = 2.5
	if _lbl_level != null:
		_lbl_level.text = active_level.level_name


func _ready() -> void:
	OS.window_fullscreen = true
	MenuManager.locked = false
	_pick_level()

	var ui := CanvasLayer.new()
	add_child(ui)

	var _p1: CharacterDef = p1_def if p1_def != null else ASEN_DEF
	var _p2: CharacterDef = p2_def if p2_def != null else DJOLEV_DEF
	_lbl_level = _make_lbl(active_level.level_name, Vector2(0, 8), Color(0.55, 0.55, 0.7, 1))
	_lbl_level.rect_size = Vector2(W / 2.2, 30)
	_lbl_level.rect_scale = Vector2(2.2, 2.2)
	_lbl_level.align = Label.ALIGN_CENTER

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

	for lbl in [_lbl_p1, _lbl_p2, _lbl_controls, _lbl_winner, _lbl_restart, _lbl_level]:
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
	var start_pos: Vector2 = active_level.start_p1 if i == 0 else active_level.start_p2
	pl[i] = {
		"def": def,
		"name": def.display_name, "pos": start_pos, "vel": Vector2.ZERO,
		"right": i == 0, "on_gnd": false,
		"state": "idle",
		"dead": false, "death_t": 0.0,
		"anim_t": 0.0, "anim_frame": 0, "prev_state": "idle",
		"tex": tex, "spr": spr,
		"lives": def.lives, "stunned": false, "getting_up": false, "getting_up_t": 0.0, "invulnerable": false,
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
		"stunned": return def.anim_dead
		"getting_up": return def.anim_getting_up
	return 0.15


func _process(delta: float) -> void:
	var dt := min(delta, 0.1)

	# Level flash countdown
	if _level_flash_t > 0.0:
		_level_flash_t = max(0.0, _level_flash_t - dt)

	if game_over:
		restart_t += dt
		_lbl_restart.text = "Restarting in %d..." % int(ceil(RESTART_DELAY - restart_t))
		if restart_t >= RESTART_DELAY:
			_restart_round()
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
			key = "falling"
		elif p.get("stunned", false):
			key = "falling"
		elif p.get("getting_up", false):
			key = "getting_up"
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
		if p.get("stunned", false):
			cur_state = "stunned"
		elif p.get("getting_up", false):
			cur_state = "getting_up"
		if cur_state != p["prev_state"]:
			p["prev_state"] = cur_state
			p["anim_t"] = 0.0
			p["anim_frame"] = 0
		p["anim_t"] += dt
		var frame_dur: float = _anim_spd(p["def"], cur_state)
		if p["dead"]:
			frame_dur = p["def"].anim_dead
		if p["casting_skill"] >= 0:
			var csk: Resource = ([p["def"].skill1, p["def"].skill2, p["def"].skill3] as Array)[p["casting_skill"]]
			if csk != null:
				frame_dur = csk.anim_cast
		if p["anim_t"] >= frame_dur:
			p["anim_t"] -= frame_dur
			if p["dead"] or p.get("stunned", false) or p.get("getting_up", false):
				p["anim_frame"] = min(int(p["anim_frame"]) + 1, 3)
			else:
				p["anim_frame"] = (int(p["anim_frame"]) + 1) % 4
		spr.frame = int(p["anim_frame"])

		if p["dead"]:
			spr.modulate.a = max(0.0, 1.0 - p["death_t"] * 0.75)
			spr.rotation += 3.0 * PI * dt * min(p["death_t"], 0.8)
		elif p.get("stunned", false) or p.get("getting_up", false):
			spr.modulate = Color(1.0, 1.0, 1.0, 1.0)
			spr.rotation = 0.0
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

	if p["stunned"]:
		p["casting_skill"] = -1
		p["active_effects"] = []
		p["vel"].y += GRAV * dt
		p["pos"] += p["vel"] * dt
		p["vel"].x = lerp(p["vel"].x, 0.0, 4.0 * dt)
		p["death_t"] += dt
		_collide_plats(p)
		if p["on_gnd"]:
			p["stunned"] = false
			p["getting_up"] = true
			p["getting_up_t"] = 0.0
			p["vel"] = Vector2.ZERO
			p["anim_t"] = 0.0
			p["anim_frame"] = 0
		if p["pos"].y > H + 100.0:
			p["dead"] = true
			p["stunned"] = false
			p["invulnerable"] = false
			p["death_t"] = 0.0
			p["anim_frame"] = 0
			p["anim_t"] = 0.0
		return

	if p["getting_up"]:
		p["casting_skill"] = -1
		p["active_effects"] = []
		p["getting_up_t"] += dt
		p["vel"].x = lerp(p["vel"].x, 0.0, 14.0 * dt)
		p["vel"].y += GRAV * dt
		p["pos"] += p["vel"] * dt
		_collide_plats(p)
		if p["getting_up_t"] >= p["def"].anim_getting_up * 4.0:
			p["getting_up"] = false
			p["invulnerable"] = false
			p["death_t"] = 0.0
			p["anim_t"] = 0.0
			p["anim_frame"] = 0
			p["state"] = "idle"
		if p["pos"].y > H + 100.0:
			p["dead"] = true
			p["getting_up"] = false
			p["invulnerable"] = false
			p["death_t"] = 0.0
			p["anim_frame"] = 0
			p["anim_t"] = 0.0
		return

	# Tick skill cooldowns — drain faster while walking if def says so
	var cd_mult: float = def.walk_cd_rate if p["state"] == "walk" else 1.0
	for k in 3:
		if p["skill_cds"][k] > 0.0:
			p["skill_cds"][k] = max(0.0, p["skill_cds"][k] - dt * cd_mult)

	# Tick active effects and check for hits
	var live_effects := []
	var new_effects := []
	for ae in p["active_effects"]:
		ae["t"] += dt
		ae["vy"] += ae["skill"].effect_gravity * dt
		ae["rect"] = Rect2(ae["rect"].position + Vector2(ae["dx"], ae["dy"] + ae["vy"]) * dt, ae["rect"].size)
		if ae["skill"].effect_gravity > 0.0 and ae["vy"] >= 0.0:
			_collide_effect_plats(ae)
		ae["rotation"] += ae["rotation_speed"] * dt
		if ae["skill"].effect_turnaround:
			_maybe_turnaround_effect(ae)
		if not ae["hit"] and not o["dead"] and not o.get("invulnerable", false):
			var odef: CharacterDef = o["def"]
			var o_rect := Rect2(o["pos"] + Vector2(odef.body_offset_x, odef.body_offset_y), Vector2(odef.body_w, odef.body_h))
			var eff_rect: Rect2 = ae["rect"]
			if eff_rect.intersects(o_rect):
				ae["hit"] = true
				var hit_pos: Vector2 = eff_rect.position + eff_rect.size * 0.5
				impacts.append({"pos": hit_pos, "age": 0.0})
				if ae["skill"].hit_trigger_cooldowns:
					var oskills: Array = [o["def"].skill1, o["def"].skill2, o["def"].skill3]
					for k in 3:
						if oskills[k] != null:
							o["skill_cds"][k] = oskills[k].cooldown
				if ae["skill"].hit_kills:
					var dir: float = 1.0 if p["right"] else -1.0
					if o["lives"] > 1:
						o["lives"] -= 1
						o["stunned"] = true
						o["invulnerable"] = true
						o["death_t"] = 0.0
						o["anim_frame"] = 0
						o["anim_t"] = 0.0
						o["vel"] = Vector2(dir * 380.0, -440.0)
					else:
						o["dead"] = true
						o["death_t"] = 0.0
						o["anim_frame"] = 0
						o["anim_t"] = 0.0
						o["vel"] = Vector2(dir * 380.0, -440.0)

		var csk = ae["child_skill"]
		if csk != null and ae["skill"].child_spawn_interval > 0.0:
			ae["child_t"] += dt
			var limit: int = ae["skill"].child_spawn_limit
			var under_limit: bool = (limit == 0 or ae["child_spawn_count"] < limit)
			if ae["child_t"] >= ae["skill"].child_spawn_interval and under_limit:
				ae["child_t"] -= ae["skill"].child_spawn_interval
				ae["child_spawn_count"] += 1
				var center: Vector2 = ae["rect"].position + ae["rect"].size * 0.5
				var cx: float = center.x - csk.effect_width * 0.5
				var cy: float = center.y - csk.effect_height * 0.5
				new_effects.append(_make_effect_dict(csk, Vector2(cx, cy), ae["facing"]))

		if csk != null and ae.get("ground_hit", false):
			var limit: int = ae["skill"].child_spawn_limit
			var count: int = limit if limit > 0 else 1
			var center: Vector2 = ae["rect"].position + ae["rect"].size * 0.5
			for j in range(count):
				var spread: float = lerp(-1.0, 1.0, float(j) / float(count - 1)) if count > 1 else 1.0
				var child_dir: float = spread
				var cx: float = center.x - csk.effect_width * 0.5
				var cy: float = center.y - csk.effect_height * 0.5
				new_effects.append(_make_effect_dict(csk, Vector2(cx, cy), child_dir))
			ae["t"] = ae["skill"].effect_duration
			ae["ground_hit"] = false

		if ae["t"] < ae["skill"].effect_duration:
			live_effects.append(ae)
	p["active_effects"] = live_effects + new_effects

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
		p["anim_frame"] = 0
		p["anim_t"] = 0.0


func _activate_skill(p: Dictionary, skill_idx: int, sk: Resource) -> void:
	var pos: Vector2 = p["pos"]
	var hx: float
	if p["right"]:
		hx = pos.x + sk.effect_offset_x
	else:
		hx = pos.x + SW - sk.effect_offset_x - sk.effect_width
	var hy: float = pos.y + sk.effect_offset_y
	var dir: float = 1.0 if p["right"] else -1.0
	p["active_effects"].append(_make_effect_dict(sk, Vector2(hx, hy), dir))
	p["skill_cds"][skill_idx] = sk.cooldown
	p["casting_skill"] = -1
	p["cast_t"] = 0.0


func _make_effect_dict(sk: Resource, spawn_pos: Vector2, dir: float) -> Dictionary:
	var ae_tex: Texture = null
	if sk.effect_sprite_path != "":
		ae_tex = load(sk.effect_sprite_path) as Texture
	var child_sk = null
	if sk.child_skill_path != "":
		child_sk = load(sk.child_skill_path)
	return {
		"skill":             sk,
		"t":                 0.0,
		"rect":              Rect2(spawn_pos, Vector2(sk.effect_width, sk.effect_height)),
		"hit":               false,
		"tex":               ae_tex,
		"dx":                sk.effect_dx * dir,
		"dy":                0.0,
		"vy":                sk.effect_dy,
		"rotation":          0.0,
		"rotation_speed":    deg2rad(sk.effect_rotation_speed),
		"facing":            dir,
		"child_skill":       child_sk,
		"child_t":           0.0,
		"child_spawn_count": 0,
		"ground_hit":        false,
	}


func _collide_plats(p: Dictionary) -> void:
	p["on_gnd"] = false
	var plats: Array = active_level._get_platforms()
	for plat in plats:
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
	var plats: Array = active_level._get_platforms()
	for plat in plats:
		var px: float = plat[0]
		var py: float = plat[1]
		var pw: float = plat[2]
		var bottom: float = rect.end.y
		if rect.position.x < px + pw - 5.0 \
				and rect.end.x > px + 5.0 \
				and bottom >= py \
				and bottom <= py + 35.0:
			ae["rect"] = Rect2(rect.position.x, py - rect.size.y, rect.size.x, rect.size.y)
			var bc: float = ae["skill"].bounce_coefficient
			if bc > 0.0:
				ae["vy"] = -abs(ae["vy"]) * bc
			else:
				ae["vy"] = 0.0
			if ae["skill"].spawn_on_impact:
				ae["ground_hit"] = true
			return


func _maybe_turnaround_effect(ae: Dictionary) -> void:
	var rect: Rect2 = ae["rect"]
	var dx: float = ae["dx"]
	if dx == 0.0:
		return
	# Screen edge reversal
	if (dx < 0.0 and rect.position.x <= 0.0) or (dx > 0.0 and rect.end.x >= W):
		ae["dx"] = -dx
		ae["facing"] = -ae["facing"]
		return
	# Platform edge reversal — only when effect just landed (vy reset to 0 this frame)
	if ae["vy"] > 5.0:
		return
	var plats: Array = active_level._get_platforms()
	var bottom_y: float = rect.end.y
	var lead_x: float = rect.end.x if dx > 0.0 else rect.position.x
	var supported: bool = false
	for plat in plats:
		var px: float = plat[0]
		var py: float = plat[1]
		var pw: float = plat[2]
		if lead_x > px and lead_x < px + pw and abs(bottom_y - py) < 15.0:
			supported = true
			break
	if not supported:
		ae["dx"] = -ae["dx"]
		ae["facing"] = -ae["facing"]


func _end_game(text: String) -> void:
	if game_over:
		return
	game_over = true
	restart_t = 0.0
	MenuManager.locked = true
	_lbl_winner.text = text
	_lbl_winner.visible = true
	_lbl_restart.visible = true


func _restart_round() -> void:
	_pick_level()
	# Remove old sprites
	for i in [0, 1]:
		if pl[i].has("spr"):
			var spr: Sprite = pl[i]["spr"]
			if spr != null and spr.is_inside_tree():
				spr.queue_free()
	# Reset state
	game_over = false
	restart_t = 0.0
	impacts = []
	MenuManager.locked = false
	_lbl_winner.visible = false
	_lbl_restart.visible = false
	# Re-init players with their current defs
	var _p1_def: CharacterDef = pl[0]["def"] if pl[0].has("def") and pl[0]["def"] != null else ASEN_DEF
	var _p2_def: CharacterDef = pl[1]["def"] if pl[1].has("def") and pl[1]["def"] != null else DJOLEV_DEF
	_init_player(0, _p1_def)
	_init_player(1, _p2_def)


func _draw() -> void:
	var lev: Resource = active_level
	var bg_top: Color = lev.bg_top
	var bg_bottom: Color = lev.bg_bottom
	var split_y: float = H * lev.bg_split

	# Background
	draw_rect(Rect2(0, 0, W, split_y), bg_top)
	draw_rect(Rect2(0, split_y, W, H - split_y), bg_bottom)

	# Stars (deterministic from level seed)
	var seedd: int = lev.star_seed
	var star_col: Color = lev.star_color
	var star_cnt: int = lev.star_count
	for i in range(star_cnt):
		var sx := fmod(float(i * 137 + seedd), 780.0) + 10.0
		var sy := fmod(float(i * 97 + seedd * 3), float(split_y - 20.0)) + 8.0
		var sz := 2.0 if i % 3 == 0 else 1.0
		draw_rect(Rect2(sx, sy, sz, sz), star_col)

	# Platforms
	var plats: Array = lev._get_platforms()
	var pf: Color = lev.plat_fill
	var ph: Color = lev.plat_highlight
	var ps: Color = lev.plat_shadow
	var pd: Color = lev.plat_dark
	for plat in plats:
		var px: float = plat[0]
		var py: float = plat[1]
		var pw: float = plat[2]
		var pheight: float = plat[3]
		draw_rect(Rect2(px + 4, py + 4, pw, pheight), pd)
		draw_rect(Rect2(px, py, pw, pheight), pf)
		draw_rect(Rect2(px, py, pw, 5), ph)
		draw_rect(Rect2(px, py, 3, pheight), ps)
		draw_rect(Rect2(px + pw - 3, py, 3, pheight), ps)

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
				var flip: float = ae.get("facing", 1.0)
				draw_set_transform(center, ae["rotation"], Vector2(flip, 1.0))
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
		if p.empty() or p["dead"] or p.get("stunned", false) or p.get("getting_up", false):
			continue
		var pos: Vector2 = p["pos"]
		for k in 3:
			var dot_center: Vector2 = Vector2(pos.x + k * 14.0 + 4.0, pos.y - 8.0)
			var ready: bool = p["skill_cds"][k] <= 0.0
			var dot_col: Color = Color(0.2, 0.85, 0.25) if ready else Color(0.45, 0.18, 0.08)
			draw_circle(dot_center, 4.0, dot_col)
			if not ready:
				var skill_ref: SkillDef = [p["def"].skill1, p["def"].skill2, p["def"].skill3][k]
				var max_cd: float = skill_ref.cooldown
				if max_cd > 0.0:
					var ratio: float = p["skill_cds"][k] / max_cd
					var filled_angle: float = (1.0 - ratio) * TAU
					if filled_angle > 0.0:
						draw_arc(dot_center, 4.0, -PI * 0.5, -PI * 0.5 + filled_angle, 24, Color(0.2, 0.85, 0.25), 2.0)

	for imp in impacts:
		var a: float = 1.0 - float(imp["age"]) / 0.55
		var r: float = 10.0 + float(imp["age"]) * 90.0
		draw_circle(imp["pos"] as Vector2, r, Color(1.0, 0.35, 0.1, a * 0.55))
		draw_circle(imp["pos"] as Vector2, r * 0.45, Color(1.0, 0.9, 0.3, a * 0.7))

	if game_over:
		draw_rect(Rect2(0, 0, W, H), Color(0, 0, 0, 0.58))

	# Level transition flash
	if _level_flash_t > 0.0:
		var flash_alpha: float = min(1.0, _level_flash_t)
		draw_rect(Rect2(0, 0, W, H), Color(0, 0, 0, 0.4 * flash_alpha))
		draw_rect(Rect2(0, 0, W, 60), Color(0, 0, 0, 0.6 * flash_alpha))
		draw_rect(Rect2(0, H - 60, W, 60), Color(0, 0, 0, 0.6 * flash_alpha))

	MenuManager.draw_overlay(self)
