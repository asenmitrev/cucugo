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
}


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

# --- Controls menu ---
var show_controls: bool = false
var controls_sel: int = 0

var _ctrl_title: Label
var _ctrl_hint: Label
var _ctrl_font: Font

var _ctrl_bindings: Dictionary = {}

const CTRL_ACTIONS := [
	{"player": 0, "label": "Skill 1", "action": "p1_skill1"},
	{"player": 0, "label": "Skill 2", "action": "p1_skill2"},
	{"player": 0, "label": "Skill 3", "action": "p1_skill3"},
	{"player": 1, "label": "Skill 1", "action": "p2_skill1"},
	{"player": 1, "label": "Skill 2", "action": "p2_skill2"},
	{"player": 1, "label": "Skill 3", "action": "p2_skill3"},
]

const CTRL_VISIBLE_ROWS := 6
const CTRL_ROW_H := 28
const CTRL_BOX_W := 560
const CTRL_BOX_H := 320

var DEFAULT_BINDS := {
	"p1_left":    KEY_A,
	"p1_right":   KEY_D,
	"p1_jump":    KEY_W,
	"p1_punch":   KEY_SPACE,
	"p1_skill1":  KEY_R,
	"p1_skill2":  KEY_F,
	"p1_skill3":  KEY_V,
	"p2_left":    KEY_LEFT,
	"p2_right":   KEY_RIGHT,
	"p2_jump":    KEY_UP,
	"p2_punch":   KEY_ENTER,
	"p2_skill1":  KEY_SEMICOLON,
	"p2_skill2":  KEY_APOSTROPHE,
	"p2_skill3":  KEY_BACKSLASH,
}


func _ready() -> void:
	var ui := CanvasLayer.new()
	add_child(ui)

	_lbl_p1 = _make_lbl(ASEN_DEF.display_name, Vector2(18, 8), ASEN_DEF.label_color)
	_lbl_p2 = _make_lbl(DJOLEV_DEF.display_name, Vector2(680, 8), DJOLEV_DEF.label_color)
	_lbl_controls = _make_lbl(
		"ASEN: A/D move  W jump  Space punch  R/F/V skills        DJOLEV: ←/→ move  ↑ jump  Enter punch  ;/'/ \\ skills        Esc controls",
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

	# Controls menu UI
	_ctrl_title = _make_lbl("CONTROLS", Vector2(0, 28), Color.white)
	_ctrl_title.rect_size = Vector2(CTRL_BOX_W, 30)
	_ctrl_title.rect_scale = Vector2(1.6, 1.6)
	_ctrl_title.align = Label.ALIGN_CENTER
	_ctrl_title.visible = false
	ui.add_child(_ctrl_title)

	_ctrl_hint = _make_lbl("", Vector2(0, CTRL_BOX_H - 28), Color(0.6, 0.6, 0.8))
	_ctrl_hint.rect_size = Vector2(CTRL_BOX_W, 22)
	_ctrl_hint.rect_scale = Vector2(1.0, 1.0)
	_ctrl_hint.align = Label.ALIGN_CENTER
	_ctrl_hint.visible = false
	ui.add_child(_ctrl_hint)

	_ctrl_font = _ctrl_title.get_font("font")

	_ctrl_update_hint()
	_setup_default_controls()
	_ctrl_load()

	_init_player(0, ASEN_DEF)
	_init_player(1, DJOLEV_DEF)



func _make_lbl(txt: String, pos: Vector2, col: Color) -> Label:
	var l := Label.new()
	l.text = txt
	l.rect_position = pos
	l.add_color_override("font_color", col)
	return l

# ── Controls menu helpers ──────────────────────────────────────

func _setup_default_controls() -> void:
	for action in DEFAULT_BINDS:
		if not _input_map_has_action(action):
			InputMap.add_action(action)
		var ev := InputEventKey.new()
		ev.scancode = DEFAULT_BINDS[action]
		_apply_event_to_action(action, ev)


func _input_map_has_action(name: String) -> bool:
	var actions: Array = InputMap.get_actions()
	for a in actions:
		if a == name:
			return true
	return false

func _apply_event_to_action(action: String, ev: InputEvent) -> void:
	var old: InputEvent = _ctrl_bindings.get(action, null)
	if old != null:
		InputMap.action_erase_event(action, old)
	InputMap.action_add_event(action, ev)
	_ctrl_bindings[action] = ev

func _get_binding_display(action: String) -> String:
	var ev: InputEvent = _ctrl_bindings.get(action, null)
	if ev == null:
		return "(unbound)"
	if ev is InputEventKey:
		var s: String = OS.get_scancode_string((ev as InputEventKey).scancode)
		return s if s != "" else "(unbound)"
	if ev is InputEventJoypadButton:
		return "Joy:%d" % (ev as InputEventJoypadButton).button_index
	return "(unbound)"


func _ctrl_update_hint() -> void:
	_ctrl_hint.text = "↑↓ navigate   any key/button to bind   Esc/B close"

func _ctrl_toggle() -> void:
	if show_controls:
		_ctrl_save()
	show_controls = not show_controls
	_ctrl_title.visible = show_controls
	_ctrl_hint.visible = show_controls
	if show_controls:
		var bx: float = (W - CTRL_BOX_W) / 2.0
		var by: float = (H - CTRL_BOX_H) / 2.0
		_ctrl_title.rect_position = Vector2(bx, by + 28)
		_ctrl_hint.rect_position = Vector2(bx, by + CTRL_BOX_H - 28)

func _ctrl_nav(dir: int) -> void:
	controls_sel = wrapi(controls_sel + dir, 0, CTRL_ACTIONS.size())

func _ctrl_remap(ev: InputEvent) -> void:
	var ca: Dictionary = CTRL_ACTIONS[controls_sel]
	_apply_event_to_action(ca["action"], ev)

func _ctrl_draw_rows() -> void:
	var bx: float = (W - CTRL_BOX_W) / 2.0
	var by: float = (H - CTRL_BOX_H) / 2.0
	var row_top: float = by + 62.0

	var max_offset: int = max(0, CTRL_ACTIONS.size() - CTRL_VISIBLE_ROWS)
	var offset: int = clamp(int(controls_sel) - 3, 0, max_offset)

	var prev_player: int = -1
	for v in CTRL_VISIBLE_ROWS:
		var idx: int = offset + v
		if idx >= CTRL_ACTIONS.size():
			break
		var ca: Dictionary = CTRL_ACTIONS[idx]
		var ry: float = row_top + float(v) * CTRL_ROW_H

		if ca["player"] != prev_player:
			prev_player = ca["player"]
			var pname: String = "Player 1" if ca["player"] == 0 else "Player 2"
			var pcol: Color = ASEN_DEF.label_color if ca["player"] == 0 else DJOLEV_DEF.label_color
			draw_string(_ctrl_font, Vector2(bx + 14.0, ry - 4.0), pname)

		var key_str: String = _get_binding_display(ca["action"])
		var line: String = "  %s: %s" % [ca["label"], key_str]

		var col: Color = Color(1.0, 1.0, 1.0, 1.0) if idx == controls_sel else Color(0.75, 0.75, 0.85, 1.0)
		draw_string(_ctrl_font, Vector2(bx + 14.0, ry + CTRL_ROW_H - 8.0), line)

func _ctrl_save() -> void:
	var file := File.new()
	file.open("user://controls.cfg", File.WRITE)
	for ca in CTRL_ACTIONS:
		var action: String = ca["action"]
		var ev: InputEvent = _ctrl_bindings.get(action, null)
		if ev is InputEventKey:
			file.store_line("%s=key:%d" % [action, (ev as InputEventKey).scancode])
		elif ev is InputEventJoypadButton:
			file.store_line("%s=joy:%d" % [action, (ev as InputEventJoypadButton).button_index])
	file.close()

func _ctrl_load() -> void:
	var file := File.new()
	if file.file_exists("user://controls.cfg"):
		if file.open("user://controls.cfg", File.READ) == OK:
			while !file.eof_reached():
				var line: String = file.get_line()
				var parts: PoolStringArray = line.split("=")
				if parts.size() == 2:
					var action: String = parts[0]
					var val: String = parts[1]
					if val.begins_with("key:"):
						var keycode: int = int(val.substr(4))
						if keycode > 0:
							var kev := InputEventKey.new()
							kev.scancode = keycode
							_apply_event_to_action(action, kev)
					elif val.begins_with("joy:"):
						var btn: int = int(val.substr(4))
						var jev := InputEventJoypadButton.new()
						jev.button_index = btn
						jev.pressed = true
						_apply_event_to_action(action, jev)
					else:
						# Legacy format: plain integer keycode
						var keycode: int = int(val)
						if keycode > 0:
							var kev := InputEventKey.new()
							kev.scancode = keycode
							_apply_event_to_action(action, kev)
			file.close()


func _init_player(i: int, def: CharacterDef) -> void:
	var spr := Sprite.new()
	spr.centered = false
	spr.hframes = 2
	spr.vframes = 2
	spr.scale = Vector2(SW / 128.0, SH / 128.0)
	add_child(spr)

	var tex: Dictionary = _TEX[def.char_name]

	pl[i] = {
		"def": def,
		"name": def.display_name, "pos": def.start_pos, "vel": Vector2.ZERO,
		"right": def.facing_right, "on_gnd": false,
		"state": "idle",
		"punch_t": 0.0, "punch_hit": false, "last_pe": 0.0,
		"dead": false, "death_t": 0.0,
		"anim_t": 0.0, "anim_frame": 0, "prev_state": "idle",
		"tex": tex, "spr": spr,
		"skill_cds":      [0.0, 0.0, 0.0],
		"casting_skill":  -1,
		"cast_t":          0.0,
		"active_effects": [],
	}


func _anim_spd(def: CharacterDef, state: String) -> float:
	match state:
		"idle":  return def.anim_idle
		"walk":  return def.anim_walk
		"jump":  return def.anim_jump
		"punch": return def.anim_punch
		"dead":  return def.anim_dead
	return 0.15


func _input(event: InputEvent) -> void:
	# Start action (gamepad or custom binding) toggles the controls menu
	if InputMap.has_action("start") and event.is_action_pressed("start"):
		_ctrl_toggle()
		get_tree().set_input_as_handled()
		return

	if not show_controls:
		if event is InputEventKey:
			var ev: InputEventKey = event as InputEventKey
			if ev.pressed and not ev.echo and ev.scancode == KEY_ESCAPE:
				_ctrl_toggle()
				get_tree().set_input_as_handled()
		return

	# Menu is open — consume all input so game physics don't fire
	get_tree().set_input_as_handled()

	# Navigation uses Godot's built-in ui_* actions which map to both
	# keyboard arrows and gamepad d-pad automatically on all platforms.
	if event.is_action_pressed("ui_up"):
		_ctrl_nav(-1)
		update()
		return

	if event.is_action_pressed("ui_down"):
		_ctrl_nav(1)
		update()
		return

	if event.is_action_pressed("ui_cancel"):
		_ctrl_toggle()
		return

	# Remap: accept keyboard key presses and joypad button presses
	if event is InputEventKey:
		var ev: InputEventKey = event as InputEventKey
		if ev.pressed and not ev.echo:
			_ctrl_remap(event)
			update()
	elif event is InputEventJoypadButton:
		var ev: InputEventJoypadButton = event as InputEventJoypadButton
		if ev.pressed:
			_ctrl_remap(event)
			update()

func _process(delta: float) -> void:
	var dt := min(delta, 0.1)

	if game_over:
		restart_t += dt
		_lbl_restart.text = "Restarting in %d..." % int(ceil(RESTART_DELAY - restart_t))
		if restart_t >= RESTART_DELAY:
			get_tree().reload_current_scene()
		update()
		return

	if show_controls:
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
	p["active_effects"].append({
		"skill": sk,
		"t":     0.0,
		"rect":  Rect2(hx, hy, sk.effect_width, sk.effect_height),
		"hit":   false,
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
	restart_t = 0.0
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

	# Controls menu overlay
	if show_controls:
		var bx: float = (W - CTRL_BOX_W) / 2.0
		var by: float = (H - CTRL_BOX_H) / 2.0
		draw_rect(Rect2(0, 0, W, H), Color(0, 0, 0, 0.65))
		draw_rect(Rect2(bx, by, CTRL_BOX_W, CTRL_BOX_H), Color(0.08, 0.08, 0.14))
		draw_rect(Rect2(bx, by, CTRL_BOX_W, CTRL_BOX_H), Color(0.45, 0.4, 0.65), false, 2.0)

		var row_top: float = by + 62.0
		var max_offset: int = max(0, CTRL_ACTIONS.size() - CTRL_VISIBLE_ROWS)
		var offset: int = clamp(int(controls_sel) - 3, 0, max_offset)
		var sel_vis: int = controls_sel - offset
		var sel_ry: float = row_top + float(sel_vis) * CTRL_ROW_H
		draw_rect(Rect2(bx + 4.0, sel_ry - 2.0, CTRL_BOX_W - 8.0, CTRL_ROW_H + 4.0), Color(0.22, 0.22, 0.35))

		_ctrl_draw_rows()
