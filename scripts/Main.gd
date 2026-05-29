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
var BOBE_DEF   = preload("res://resources/bobe.tres")
var IPMAN_DEF  = preload("res://resources/ipman.tres")
var ITSO5Q_DEF = preload("res://resources/itso5q.tres")
var SASHO_DEF  = preload("res://resources/sasho.tres")
var VALKA_DEF  = preload("res://resources/valka.tres")
var VELI_DEF   = preload("res://resources/veli.tres")

func _load_tex(n: String) -> Dictionary:
	match n:
		"asen":
			return {
				"idle":    load("res://assets/asen/asen-idle.png"),
				"walk":    load("res://assets/asen/asen-walk.png"),
				"jump":    load("res://assets/asen/asen-jump.png"),
				"punch":   load("res://assets/asen/asen-punch.png"),
				"falling": load("res://assets/asen/asen-falling.png"),
			}
		"djolev":
			return {
				"idle":    load("res://assets/djolev/djolev-idle.png"),
				"walk":    load("res://assets/djolev/djolev-walk.png"),
				"jump":    load("res://assets/djolev/djolev-jump.png"),
				"punch":   load("res://assets/djolev/djolev-punch.png"),
				"falling": load("res://assets/djolev/djolev-falling.png"),
			}
		"siyana":
			return {
				"idle":    load("res://assets/siyana/siyana-idle.png"),
				"walk":    load("res://assets/siyana/siyana-walk.png"),
				"jump":    load("res://assets/siyana/siyana-jump.png"),
				"punch":   load("res://assets/siyana/siyana-punch.png"),
				"kick":    load("res://assets/siyana/siyana-finger.png"),
				"falling": load("res://assets/siyana/siyana-falling.png"),
			}
		"crunch":
			return {
				"idle":    load("res://assets/crunch/crunch-idle.png"),
				"walk":    load("res://assets/crunch/crunch-walk.png"),
				"jump":    load("res://assets/crunch/crunch-punch.png"),
				"punch":   load("res://assets/crunch/crunch-punch.png"),
				"kick":    load("res://assets/crunch/crunch-kick.png"),
				"flykick": load("res://assets/crunch/crunch-flykick.png"),
				"falling": load("res://assets/crunch/crunch-falling.png"),
			}
		"dani":
			return {
				"idle":    load("res://assets/dani/dani-idle.png"),
				"walk":    load("res://assets/dani/dani-walk.png"),
				"jump":    load("res://assets/dani/dani-jump.png"),
				"punch":   load("res://assets/dani/dani-punch.png"),
				"kick":    load("res://assets/dani/dani-kick.png"),
				"falling": load("res://assets/dani/dani-fall.png"),
			}
		"drago":
			return {
				"idle":     load("res://assets/drago/drago-idle.png"),
				"walk":     load("res://assets/drago/drago-walk.png"),
				"jump":     load("res://assets/drago/drago-jump.png"),
				"punch":    load("res://assets/drago/drago-punch.png"),
				"kick":     load("res://assets/drago/drago-kick.png"),
				"falling":  load("res://assets/drago/drago-fall.png"),
				"flypunch": load("res://assets/drago/drago-flypunch.png"),
			}
		"rado":
			return {
				"idle":    load("res://assets/rado/rado-idle.png"),
				"walk":    load("res://assets/rado/rado-walk.png"),
				"jump":    load("res://assets/rado/rado-jumping.png"),
				"punch":   load("res://assets/rado/rado-punch.png"),
				"kick":    load("res://assets/rado/rado-kick.png"),
				"falling": load("res://assets/rado/rado-falling.png"),
			}
		"yavor":
			return {
				"idle":    load("res://assets/yavor/yavor-idle.png"),
				"walk":    load("res://assets/yavor/yavor-walk.png"),
				"jump":    load("res://assets/yavor/yavor-jump.png"),
				"punch":   load("res://assets/yavor/yavor-punch.png"),
				"kick":    load("res://assets/yavor/yavor-kick.png"),
				"falling": load("res://assets/yavor/yavor-falling.png"),
			}
		"5q":
			return {
				"idle":    load("res://assets/5q/5q-idle.png"),
				"walk":    load("res://assets/5q/5q-walk.png"),
				"jump":    load("res://assets/5q/5q-jump.png"),
				"punch":   load("res://assets/5q/5q-punch.png"),
				"kick":    load("res://assets/5q/5q-kick.png"),
				"falling": load("res://assets/5q/5q-falls.png"),
			}
		"bobe":
			return {
				"idle":    load("res://assets/bobe/bobe-idle.png"),
				"walk":    load("res://assets/bobe/bobe-walk.png"),
				"jump":    load("res://assets/bobe/bobe-jump.png"),
				"punch":   load("res://assets/bobe/bobe-punch.png"),
				"kick":    load("res://assets/bobe/bobe-kick.png"),
				"falling": load("res://assets/bobe/bobe-falling.png"),
			}
		"ipman":
			return {
				"idle":       load("res://assets/ipman/ipman-idle.png"),
				"walk":       load("res://assets/ipman/ipman-walk.png"),
				"jump":       load("res://assets/ipman/ipman-jump.png"),
				"punch":      load("res://assets/ipman/ipman-punch.png"),
				"kick":       load("res://assets/ipman/ipman-kick.png"),
				"falling":    load("res://assets/ipman/ipman-fall.png"),
				"getting_up": load("res://assets/ipman/ipman-getting-up.png"),
			}
		"itso":
			return {
				"idle":    load("res://assets/itso/itso-idle.png"),
				"walk":    load("res://assets/itso/itso-walk.png"),
				"jump":    load("res://assets/itso/itso-jump.png"),
				"punch":   load("res://assets/itso/itso-punch.png"),
				"kick":    load("res://assets/itso/itso-kick.png"),
				"falling": load("res://assets/itso/itso-falling.png"),
			}
		"sasho":
			return {
				"idle":    load("res://assets/sasho/sasho-idle.png"),
				"walk":    load("res://assets/sasho/sasho-walk.png"),
				"jump":    load("res://assets/sasho/sasho-jump.png"),
				"punch":   load("res://assets/sasho/sasho-punch.png"),
				"kick":    load("res://assets/sasho/sasho-kick.png"),
				"falling": load("res://assets/sasho/sasho-falling.png"),
			}
		"valka":
			return {
				"idle":    load("res://assets/valka/valka-idle.png"),
				"walk":    load("res://assets/valka/valka-walk.png"),
				"jump":    load("res://assets/valka/valka-jump.png"),
				"punch":   load("res://assets/valka/valka-punch.png"),
				"kick":    load("res://assets/valka/valka-kick.png"),
				"falling": load("res://assets/valka/valka-fall.png"),
			}
		"veli":
			return {
				"idle":    load("res://assets/veli/veli-walk.png"),
				"walk":    load("res://assets/veli/veli-walk.png"),
				"jump":    load("res://assets/veli/veli-jump.png"),
				"punch":   load("res://assets/veli/veli-punch.png"),
				"kick":    load("res://assets/veli/veli-kick.png"),
				"falling": load("res://assets/veli/veli-falling.png"),
			}
	return {}


var p1_def = null
var p2_def = null

var pl := [{}, {}]
var impacts := []
var trap_effects := []
var game_over := false
var restart_t: float = 0.0
const RESTART_DELAY := 1.0

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
	if OS.get_name() == "X11":
		OS.window_borderless = true
		OS.window_position = Vector2(0, 0)
		OS.window_size = OS.get_screen_size()
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
		"%s: A/D move  W jump  R/F/V skills        %s: ←/→ move  ↑ jump  ;/'/ \\ skills        Esc menu" % [_p1.display_name, _p2.display_name],
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

	var tex: Dictionary = _load_tex(def.char_name)

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
		"lives": def.lives, "stunned": false, "getting_up": false, "getting_up_t": 0.0, "invulnerable": false, "self_invuln_t": 0.0, "invisible": false, "invisible_t": 0.0,
		"skill_cds":      [0.0, 0.0, 0.0],
		"casting_skill":  -1,
		"cast_t":          0.0,
		"active_effects": [],
		"stomp_active":    false,
		"launch_t":        0.0,
		"action_left":   slot + "_left",
		"action_right":  slot + "_right",
		"action_jump":   slot + "_jump",
		"action_skill1": slot + "_skill1",
		"action_skill2": slot + "_skill2",
		"action_skill3": slot + "_skill3",
		"original_def":  def,
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

	_apply_pull_effects(dt)
	_update_traps(dt)

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
		elif p.get("invisible", false):
			spr.modulate = Color(1.0, 1.0, 1.0, 0.1)
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
		p["stomp_active"] = false
		p["invisible"] = false
		p["invisible_t"] = 0.0
		p["vel"].y += GRAV * dt
		p["pos"] += p["vel"] * dt
		p["vel"].x = lerp(p["vel"].x, 0.0, 4.0 * dt)
		p["death_t"] += dt
		return

	if p["stunned"]:
		p["casting_skill"] = -1
		p["active_effects"] = []
		p["stomp_active"] = false
		p["vel"].y += GRAV * dt
		p["pos"] += p["vel"] * dt
		p["vel"].x = lerp(p["vel"].x, 0.0, 4.0 * dt)
		p["death_t"] += dt
		_collide_plats(p, dt)
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
		_collide_plats(p, dt)
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

	# Tick skill-granted invulnerability
	if p.get("self_invuln_t", 0.0) > 0.0:
		p["self_invuln_t"] = max(0.0, p["self_invuln_t"] - dt)
		if p["self_invuln_t"] <= 0.0 and not p.get("getting_up", false):
			p["invulnerable"] = false

	# Tick invisibility
	if p.get("invisible_t", 0.0) > 0.0:
		p["invisible_t"] = max(0.0, p["invisible_t"] - dt)
		if p["invisible_t"] <= 0.0:
			p["invisible"] = false

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
		if ae["hit"] and ae["skill"].hit_interval > 0.0:
			ae["hit_t"] = max(0.0, ae["hit_t"] - dt)
			if ae["hit_t"] <= 0.0:
				ae["hit"] = false
		if not ae["hit"] and not o["dead"] and not o.get("invulnerable", false):
			var odef: CharacterDef = o["def"]
			var o_rect := Rect2(o["pos"] + Vector2(odef.body_offset_x, odef.body_offset_y), Vector2(odef.body_w, odef.body_h))
			var eff_rect: Rect2 = ae["rect"]
			if eff_rect.intersects(o_rect):
				ae["hit"] = true
				ae["hit_t"] = ae["skill"].hit_interval
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
					if ae["skill"].hit_self_invisible:
						p["invisible"] = true
						p["invisible_t"] = 4.0

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
				var spread: float = lerp(-1.0, 1.0, float(j) / float(count - 1)) if count > 1 else ae["facing"]
				var child_dir: float = spread
				var cx: float = center.x - csk.effect_width * 0.5
				var cy: float = center.y - csk.effect_height * 0.5
				new_effects.append(_make_effect_dict(csk, Vector2(cx, cy), child_dir))
			ae["t"] = ae["skill"].effect_duration
			ae["ground_hit"] = false

		if ae["t"] < ae["skill"].effect_duration:
			live_effects.append(ae)
		elif ae["skill"].self_kill_if_no_hit and not ae["hit"] and not p["dead"]:
			p["dead"] = true
			p["death_t"] = 0.0
			p["anim_frame"] = 0
			p["anim_t"] = 0.0
			p["vel"] = Vector2(0.0, -200.0)
	p["active_effects"] = live_effects + new_effects

	# Tick cast timer and activate when ready
	if p["casting_skill"] >= 0:
		p["cast_t"] += dt
		var skill_idx: int = p["casting_skill"]
		var sk: Resource = ([def.skill1, def.skill2, def.skill3] as Array)[skill_idx]
		if p["cast_t"] >= sk.cast_time:
			_activate_skill(p, i, skill_idx, sk)

	# Passive skills: auto-fire off cooldown, no input
	var _sk_all: Array = [def.skill1, def.skill2, def.skill3]
	for k in 3:
		var _psk = _sk_all[k]
		if _psk != null and _psk.is_passive and p["skill_cds"][k] <= 0.0:
			var _phx: float
			if p["right"]:
				_phx = p["pos"].x + _psk.effect_offset_x
			else:
				_phx = p["pos"].x + SW - _psk.effect_offset_x - _psk.effect_width
			p["active_effects"].append(_make_effect_dict(_psk, Vector2(_phx, p["pos"].y + _psk.effect_offset_y), 1.0 if p["right"] else -1.0))
			p["skill_cds"][k] = _psk.cooldown

	if p["casting_skill"] < 0:
		var skill_actions: Array = [p["action_skill1"], p["action_skill2"], p["action_skill3"]]
		var skill_defs: Array = [def.skill1, def.skill2, def.skill3]
		for k in 3:
			if skill_defs[k] != null and not skill_defs[k].is_passive and skill_actions[k] != "" \
					and p["skill_cds"][k] <= 0.0 \
					and Input.is_action_just_pressed(skill_actions[k]):
				p["casting_skill"] = k
				p["cast_t"] = 0.0
				p["anim_t"] = 0.0
				p["anim_frame"] = 0
				if skill_defs[k].self_invulnerable_duration > 0.0:
					p["self_invuln_t"] = skill_defs[k].cast_time + skill_defs[k].self_invulnerable_duration
					p["invulnerable"] = true
				break

	if p["launch_t"] > 0.0:
		p["launch_t"] = max(0.0, p["launch_t"] - dt)
	elif Input.is_action_pressed(p["action_left"]):
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

	# Stomp kill check must run BEFORE _collide_plats — the platform snap zeros vel.y and
	# sets on_gnd on the same frame Yavor lands, which would skip the kill check otherwise.
	if p.get("stomp_active", false) and p["vel"].y > 10.0 \
			and not o["dead"] and not o.get("invulnerable", false):
		var _stomp_pd: CharacterDef = p["def"]
		var _stomp_od: CharacterDef = o["def"]
		var _stomp_foot := Rect2(
			p["pos"].x + _stomp_pd.body_offset_x,
			p["pos"].y + _stomp_pd.body_offset_y + _stomp_pd.body_h - 12.0,
			_stomp_pd.body_w, 15.0)
		var _stomp_or := Rect2(o["pos"] + Vector2(_stomp_od.body_offset_x, _stomp_od.body_offset_y),
			Vector2(_stomp_od.body_w, _stomp_od.body_h))
		if _stomp_foot.intersects(_stomp_or):
			p["stomp_active"] = false
			impacts.append({"pos": _stomp_foot.position + _stomp_foot.size * 0.5, "age": 0.0})
			p["vel"].y = -420.0
			var _stomp_dir: float = 1.0 if p["right"] else -1.0
			if o["lives"] > 1:
				o["lives"] -= 1
				o["stunned"] = true
				o["invulnerable"] = true
				o["death_t"] = 0.0
				o["anim_frame"] = 0
				o["anim_t"] = 0.0
				o["vel"] = Vector2(_stomp_dir * 80.0, -200.0)
			else:
				o["dead"] = true
				o["death_t"] = 0.0
				o["anim_frame"] = 0
				o["anim_t"] = 0.0
				o["vel"] = Vector2(_stomp_dir * 80.0, -200.0)

	_collide_plats(p, dt)
	var _bdef: CharacterDef = p["def"]
	p["pos"].x = clamp(p["pos"].x, -_bdef.body_offset_x, W - _bdef.body_offset_x - _bdef.body_w)

	if p.get("stomp_active", false) and p["on_gnd"]:
		p["stomp_active"] = false

	if p["pos"].y > H + 100.0:
		p["dead"] = true
		p["death_t"] = 0.0
		p["anim_frame"] = 0
		p["anim_t"] = 0.0


func _apply_pull_effects(dt: float) -> void:
	for src_i in [0, 1]:
		if pl[src_i].empty():
			continue
		for ae in pl[src_i]["active_effects"]:
			var pull: float = ae["skill"].pull_force
			if pull == 0.0:
				continue
			var center: Vector2 = ae["rect"].position + ae["rect"].size * 0.5
			for target_i in [0, 1]:
				var tp: Dictionary = pl[target_i]
				if tp.empty() or tp["dead"]:
					continue
				if pull < 0.0 and target_i == src_i:
					continue
				var tpd: CharacterDef = tp["def"]
				var tp_center: Vector2 = tp["pos"] + Vector2(tpd.body_offset_x + tpd.body_w * 0.5, tpd.body_offset_y + tpd.body_h * 0.5)
				var diff: Vector2 = center - tp_center
				var dist: float = diff.length()
				if dist > 5.0:
					tp["vel"] += diff.normalized() * pull * dt


func _activate_skill(p: Dictionary, i: int, skill_idx: int, sk: Resource) -> void:
	if sk.self_invulnerable_duration > 0.0:
		p["self_invuln_t"] = sk.self_invulnerable_duration
		p["invulnerable"] = true

	if sk.is_transform:
		var next_def: CharacterDef = p["def"].alt_form if p["def"].alt_form != null else p["original_def"]
		p["def"] = next_def
		p["tex"] = _load_tex(next_def.char_name)
		p["skill_cds"][1] = 0.0
		p["skill_cds"][2] = 0.0
		p["skill_cds"][skill_idx] = sk.cooldown
		var lbl: Label = _lbl_p1 if i == 0 else _lbl_p2
		lbl.text = next_def.display_name
		lbl.add_color_override("font_color", next_def.label_color)
		p["casting_skill"] = -1
		p["cast_t"] = 0.0
		return

	if sk.teleport_behind:
		var o: Dictionary = pl[1 - i]
		if p["pos"].x < o["pos"].x:
			p["pos"].x = o["pos"].x + 80.0
			p["right"] = false
		else:
			p["pos"].x = o["pos"].x - 80.0
			p["right"] = true
		p["pos"].y = o["pos"].y - 60.0
		p["pos"].x = clamp(p["pos"].x, 0.0, W - SW)
		p["skill_cds"][skill_idx] = sk.cooldown
		p["casting_skill"] = -1
		p["cast_t"] = 0.0
		return

	if sk.teleport_random:
		var plats: Array = active_level._get_platforms()
		var plat: Array = plats[randi() % plats.size()]
		var def: CharacterDef = p["def"]
		p["pos"].x = clamp(plat[0] + randf() * max(0.0, plat[2] - SW), 0.0, W - SW)
		p["pos"].y = plat[1] - def.body_h - def.body_offset_y
		p["vel"] = Vector2.ZERO
		p["right"] = randf() > 0.5
		p["skill_cds"][skill_idx] = sk.cooldown
		p["casting_skill"] = -1
		p["cast_t"] = 0.0
		return

	if sk.is_stomp:
		p["vel"].y = sk.player_launch_y
		p["stomp_active"] = true
		p["skill_cds"][skill_idx] = sk.cooldown
		p["casting_skill"] = -1
		p["cast_t"] = 0.0
		return

	var pos: Vector2 = p["pos"]
	var hx: float
	if p["right"]:
		hx = pos.x + sk.effect_offset_x
	else:
		hx = pos.x + SW - sk.effect_offset_x - sk.effect_width
	var hy: float = pos.y + sk.effect_offset_y
	var dir: float = 1.0 if p["right"] else -1.0
	p["active_effects"].append(_make_effect_dict(sk, Vector2(hx, hy), dir))
	if sk.spawn_behind_trap:
		_spawn_lottery_trap(p, sk)
	p["skill_cds"][skill_idx] = sk.cooldown
	p["casting_skill"] = -1
	p["cast_t"] = 0.0
	if sk.self_cd_reduce_on_cast > 0.0:
		for k in 3:
			p["skill_cds"][k] = max(0.0, p["skill_cds"][k] * (1.0 - sk.self_cd_reduce_on_cast))
	if sk.player_launch_x != 0.0:
		p["vel"].x = dir * sk.player_launch_x
		p["launch_t"] = sk.player_launch_duration
	if sk.player_launch_y != 0.0:
		p["vel"].y = sk.player_launch_y
		if sk.player_launch_y <= -750.0:
			p["stomp_active"] = true


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
		"hit_t":             0.0,
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


func _spawn_lottery_trap(p: Dictionary, sk: Resource) -> void:
	var tw: float = sk.effect_width
	var th: float = sk.effect_height
	var tx: float
	if p["right"]:
		tx = p["pos"].x - tw - 5.0
	else:
		tx = p["pos"].x + SW + 5.0
	var ty: float = p["pos"].y + 10.0
	var ae_tex: Texture = null
	if sk.effect_sprite_path != "":
		ae_tex = load(sk.effect_sprite_path) as Texture
	trap_effects.append({
		"type": "red" if randf() > 0.5 else "green",
		"rect": Rect2(tx, ty, tw, th),
		"vy": 0.0,
		"tex": ae_tex,
		"rotation": 0.0,
		"rotation_speed": deg2rad(300.0),
		"on_ground": false,
	})


func _update_traps(dt: float) -> void:
	var TRAP_GRAV : float= 700.0
	var keep := []
	for trap in trap_effects:
		if not trap["on_ground"]:
			trap["vy"] += TRAP_GRAV * dt
			trap["rect"] = Rect2(trap["rect"].position + Vector2(0.0, trap["vy"] * dt), trap["rect"].size)
			_collide_trap_plats(trap)
		if trap["on_ground"]:
			trap["rotation_speed"] = lerp(trap["rotation_speed"], 0.0, 3.0 * dt)
		trap["rotation"] += trap["rotation_speed"] * dt
		if trap["rect"].position.y > H + 50.0:
			continue
		var hit_this_frame := false
		for pi in [0, 1]:
			var tp: Dictionary = pl[pi]
			if tp.empty() or tp["dead"] or tp.get("invulnerable", false):
				continue
			var tpd: CharacterDef = tp["def"]
			var tp_rect := Rect2(tp["pos"] + Vector2(tpd.body_offset_x, tpd.body_offset_y), Vector2(tpd.body_w, tpd.body_h))
			if trap["rect"].intersects(tp_rect):
				hit_this_frame = true
				impacts.append({"pos": trap["rect"].position + trap["rect"].size * 0.5, "age": 0.0})
				if trap["type"] == "green":
					for k in 3:
						tp["skill_cds"][k] = max(0.0, tp["skill_cds"][k] * 0.5)
				else:
					if tp["lives"] > 1:
						tp["lives"] -= 1
						tp["stunned"] = true
						tp["invulnerable"] = true
						tp["death_t"] = 0.0
						tp["anim_frame"] = 0
						tp["anim_t"] = 0.0
						tp["vel"] = Vector2(0.0, -440.0)
					else:
						tp["dead"] = true
						tp["death_t"] = 0.0
						tp["anim_frame"] = 0
						tp["anim_t"] = 0.0
						tp["vel"] = Vector2(0.0, -200.0)
				break
		if not hit_this_frame:
			keep.append(trap)
	trap_effects = keep


func _collide_trap_plats(trap: Dictionary) -> void:
	var rect: Rect2 = trap["rect"]
	if trap["vy"] < 0.0:
		return
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
			trap["rect"] = Rect2(rect.position.x, py - rect.size.y, rect.size.x, rect.size.y)
			trap["vy"] = 0.0
			trap["on_ground"] = true
			return


func _collide_plats(p: Dictionary, dt: float = 0.016) -> void:
	p["on_gnd"] = false
	var plats: Array = active_level._get_platforms()
	for plat in plats:
		var px: float = plat[0]
		var py: float = plat[1]
		var pw: float = plat[2]
		var _pd: CharacterDef = p["def"]
		var _bx: float = p["pos"].x + _pd.body_offset_x
		var _by: float = p["pos"].y + _pd.body_offset_y
		var bottom: float = _by + _pd.body_h
		var prev_bottom: float = bottom - p["vel"].y * dt
		if p["vel"].y >= 0.0 \
				and _bx + _pd.body_w > px + 5.0 \
				and _bx < px + pw - 5.0 \
				and bottom >= py \
				and prev_bottom <= py + 5.0:
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
	trap_effects = []
	MenuManager.locked = false
	_lbl_winner.visible = false
	_lbl_restart.visible = false
	# Re-init players with their original (pre-transform) defs
	var _p1_def: CharacterDef = pl[0].get("original_def", pl[0].get("def", ASEN_DEF))
	var _p2_def: CharacterDef = pl[1].get("original_def", pl[1].get("def", DJOLEV_DEF))
	_init_player(0, _p1_def)
	_init_player(1, _p2_def)
	_lbl_controls.text = "%s: A/D move  W jump  R/F/V skills        %s: ←/→ move  ↑ jump  ;/'/ \\ skills        Esc menu" % [_p1_def.display_name, _p2_def.display_name]


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

	# Lottery-ticket traps
	for trap in trap_effects:
		var rect: Rect2 = trap["rect"]
		var center: Vector2 = rect.position + rect.size * 0.5
		var tint: Color = Color(0.55, 1.0, 0.55) if trap["type"] == "green" else Color(1.0, 0.5, 0.5)
		if trap["on_ground"]:
			var glow: Color = Color(0.2, 0.85, 0.2, 0.35) if trap["type"] == "green" else Color(0.85, 0.15, 0.15, 0.35)
			draw_rect(Rect2(center.x - rect.size.x * 0.6, rect.end.y - 5.0, rect.size.x * 1.2, 6.0), glow)
		var tex: Texture = trap["tex"]
		if tex != null:
			draw_set_transform(center, trap["rotation"], Vector2.ONE)
			draw_texture_rect(tex, Rect2(-rect.size * 0.5, rect.size), false, tint)
			draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
		else:
			draw_rect(rect, tint * Color(1, 1, 1, 0.75))

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

	# Skill cooldown dots (1 dot per skill, gray for empty slots)
	for i in [0, 1]:
		var p: Dictionary = pl[i]
		if p.empty() or p["dead"] or p.get("stunned", false) or p.get("getting_up", false):
			continue
		var pos: Vector2 = p["pos"]
		var sk_defs: Array = [p["def"].skill1, p["def"].skill2, p["def"].skill3]
		for k in 3:
			var dot_center: Vector2 = Vector2(pos.x + k * 14.0 + 4.0, pos.y - 8.0)
			if sk_defs[k] == null:
				draw_circle(dot_center, 4.0, Color(0.3, 0.3, 0.35))
				continue
			var ready: bool = p["skill_cds"][k] <= 0.0
			var dot_col: Color = Color(0.2, 0.85, 0.25) if ready else Color(0.45, 0.18, 0.08)
			draw_circle(dot_center, 4.0, dot_col)
			if not ready:
				var skill_ref: SkillDef = sk_defs[k]
				var max_cd: float = skill_ref.cooldown
				if max_cd > 0.0:
					var ratio: float = p["skill_cds"][k] / max_cd
					var filled_angle: float = (1.0 - ratio) * TAU
					if filled_angle > 0.0:
						draw_arc(dot_center, 4.0, -PI * 0.5, -PI * 0.5 + filled_angle, 24, Color(0.2, 0.85, 0.25), 2.0)

	# Stomp foot hitbox glow — visible while falling with stomp active
	for i in [0, 1]:
		var p: Dictionary = pl[i]
		if p.empty() or not p.get("stomp_active", false) or p["vel"].y <= 0.0:
			continue
		var _sdef: CharacterDef = p["def"]
		var _sfr := Rect2(
			p["pos"].x + _sdef.body_offset_x,
			p["pos"].y + _sdef.body_offset_y + _sdef.body_h - 12.0,
			_sdef.body_w, 15.0)
		draw_rect(_sfr, Color(1.0, 0.35, 0.05, 0.45))
		draw_rect(_sfr, Color(1.0, 0.7, 0.1, 0.95), false)

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
