extends Node2D

const W := 800.0
const H := 450.0

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

var _idle_tex_cache: Dictionary = {}

func _get_idle_tex(char_name: String) -> Texture:
	if not _idle_tex_cache.has(char_name):
		var path: String
		match char_name:
			"veli":
				path = "res://assets/veli/veli-walk.png"
			_:
				path = "res://assets/" + char_name + "/" + char_name + "-idle.png"
		_idle_tex_cache[char_name] = load(path)
	return _idle_tex_cache[char_name]

var _all_defs: Array = []
var _cs_sel: Array = [0, 0, 0, 0]
var _cs_confirmed: Array = [false, false, false, false]
var _cs_joined: Array = [true, true, false, false]
var _font: Font


func _ready() -> void:
	if OS.get_name() == "X11":
		OS.window_borderless = true
		OS.window_position = Vector2(0, 0)
		OS.window_size = OS.get_screen_size()
	OS.window_fullscreen = true
	MenuManager.locked = false
	_all_defs = [ASEN_DEF, DJOLEV_DEF, SIYANA_DEF, CRUNCH_DEF, DANI_DEF, DRAGO_DEF, RADO_DEF, YAVOR_DEF, BOBE_DEF, IPMAN_DEF, SASHO_DEF, VALKA_DEF, VELI_DEF, ITSO5Q_DEF]
	var tmp := Label.new()
	add_child(tmp)
	_font = tmp.get_font("font")
	tmp.queue_free()


func _process(_delta: float) -> void:
	if MenuManager.is_open():
		return

	var changed := false

	for pi in range(4):
		var prefix = "p" + str(pi + 1) + "_"
		if not _cs_joined[pi]:
			if Input.is_action_just_pressed(prefix + "jump") or Input.is_action_just_pressed(prefix + "left") or Input.is_action_just_pressed(prefix + "right"):
				_cs_joined[pi] = true
				changed = true
		else:
			if not _cs_confirmed[pi]:
				if Input.is_action_just_pressed(prefix + "left"):
					_cs_sel[pi] = wrapi(_cs_sel[pi] - 1, 0, _all_defs.size() + 1)
					changed = true
				elif Input.is_action_just_pressed(prefix + "right"):
					_cs_sel[pi] = wrapi(_cs_sel[pi] + 1, 0, _all_defs.size() + 1)
					changed = true
			if Input.is_action_just_pressed(prefix + "jump"):
				_cs_confirmed[pi] = not _cs_confirmed[pi]
				changed = true

	if changed:
		update()

	var all_ready := true
	var active_count := 0
	for pi in range(4):
		if _cs_joined[pi]:
			active_count += 1
			if not _cs_confirmed[pi]:
				all_ready = false
				break
	if active_count >= 2 and all_ready:
		_start_game()


func _start_game() -> void:
	var main_inst = load("res://scenes/Main.tscn").instance()
	var rand_idx := _all_defs.size()
	main_inst.p_defs = [null, null, null, null]
	main_inst.p_active = _cs_joined.duplicate()
	main_inst.p_random = [false, false, false, false]
	for pi in range(4):
		if _cs_joined[pi]:
			if _cs_sel[pi] == rand_idx:
				main_inst.p_random[pi] = true
				main_inst.p_defs[pi] = _all_defs[randi() % _all_defs.size()]
			else:
				main_inst.p_defs[pi] = _all_defs[_cs_sel[pi]]
	main_inst.rand_defs = _all_defs
	get_tree().get_root().add_child(main_inst)
	get_tree().current_scene = main_inst
	queue_free()


func _draw() -> void:
	draw_rect(Rect2(0, 0, W, H), Color(0.07, 0.08, 0.16))
	draw_rect(Rect2(0, H * 0.6, W, H * 0.4), Color(0.10, 0.12, 0.22))

	for i in range(28):
		var sx := fmod(float(i * 137 + 29), 780.0) + 10.0
		var sy := fmod(float(i * 97 + 13), 185.0) + 8.0
		var sz := 2.0 if i % 3 == 0 else 1.0
		draw_rect(Rect2(sx, sy, sz, sz), Color(1, 1, 1, 0.45))

	draw_string(_font, Vector2(W * 0.5 - 110.0, 46.0), "SELECT YOUR CHARACTER", Color.white)

	for pi in range(3):
		var sep_cx = (pi * 0.25 + 0.25) * W
		draw_rect(Rect2(sep_cx - 1.0, 62.0, 2.0, H - 90.0), Color(0.35, 0.32, 0.5, 0.5))

	for pi in range(4):
		var cx = (pi * 0.25 + 0.125) * W
		if _cs_joined[pi]:
			_draw_player_card(pi, cx)
		else:
			_draw_join_card(pi, cx)

	draw_string(_font, Vector2(20.0, H - 14.0), "P1/P2/P3/P4: A/D/Left/Right select   W/Up confirm", Color(0.5, 0.5, 0.65))

	MenuManager.draw_overlay(self)


func _draw_player_card(pi: int, cx: float) -> void:
	var is_random: bool = _cs_sel[pi] == _all_defs.size()
	var confirmed: bool = _cs_confirmed[pi]

	var card_w: float = 160.0
	var card_h: float = 300.0
	var card_x: float = cx - card_w * 0.5
	var card_y: float = 68.0

	var rand_color := Color(1.0, 0.85, 0.1)
	var lc: Color = rand_color if is_random else _all_defs[_cs_sel[pi]].label_color

	var bg_col := Color(0.08, 0.14, 0.10) if confirmed else Color(0.10, 0.10, 0.18)
	draw_rect(Rect2(card_x, card_y, card_w, card_h), bg_col)
	var border_col: Color = lc if confirmed else Color(lc.r * 0.45, lc.g * 0.45, lc.b * 0.45)
	draw_rect(Rect2(card_x, card_y, card_w, card_h), border_col, false, 2.0)

	var plabel: String = "P" + str(pi + 1)
	draw_string(_font, Vector2(cx - 8.0, card_y + 22.0), plabel, lc)

	var portrait_size := 120.0
	var px: float = cx - portrait_size * 0.5
	var py: float = card_y + 35.0

	if is_random:
		draw_string(_font, Vector2(cx - 10.0, py + portrait_size * 0.5 + 10.0), "?", Color.white)
	else:
		var def: CharacterDef = _all_defs[_cs_sel[pi]]
		var tex: Texture = _get_idle_tex(def.char_name)
		draw_texture_rect_region(tex, Rect2(px, py, portrait_size, portrait_size), Rect2(0, 0, 128, 128))

	if not confirmed:
		draw_string(_font, Vector2(card_x + 8.0, py + portrait_size * 0.5 + 8.0), "◄", Color.white)
		draw_string(_font, Vector2(card_x + card_w - 20.0, py + portrait_size * 0.5 + 8.0), "►", Color.white)

	if is_random:
		draw_string(_font, Vector2(cx - 28.0, py + portrait_size + 22.0), "RANDOM", rand_color)
	else:
		var def: CharacterDef = _all_defs[_cs_sel[pi]]
		var name_x: float = cx - float(def.display_name.length()) * 4.5
		draw_string(_font, Vector2(name_x, py + portrait_size + 22.0), def.display_name, def.label_color)

	var status_y: float = py + portrait_size + 48.0
	if confirmed:
		draw_string(_font, Vector2(cx - 38.0, status_y), "CONFIRMED!", Color(0.3, 1.0, 0.4))
	else:
		var hint: String = "Jump confirm"
		draw_string(_font, Vector2(cx - 40.0, status_y), hint, Color(0.5, 0.5, 0.65))

func _draw_join_card(pi: int, cx: float) -> void:
	var card_w: float = 160.0
	var card_h: float = 300.0
	var card_x: float = cx - card_w * 0.5
	var card_y: float = 68.0

	var bg_col := Color(0.08, 0.08, 0.12, 0.6)
	var border_col := Color(0.2, 0.2, 0.3)

	draw_rect(Rect2(card_x, card_y, card_w, card_h), bg_col)
	draw_rect(Rect2(card_x, card_y, card_w, card_h), border_col, false, 2.0)

	var plabel: String = "P" + str(pi + 1)
	draw_string(_font, Vector2(cx - 8.0, card_y + 22.0), plabel, Color(0.4, 0.4, 0.5))

	draw_string(_font, Vector2(cx - 24.0, card_y + card_h * 0.5 - 20.0), "PRESS", Color(0.5, 0.5, 0.5))
	draw_string(_font, Vector2(cx - 20.0, card_y + card_h * 0.5 + 5.0), "JUMP", Color(0.7, 0.7, 0.8))
	draw_string(_font, Vector2(cx - 30.0, card_y + card_h * 0.5 + 30.0), "TO JOIN", Color(0.5, 0.5, 0.5))
