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
var FIVEQ_DEF  = preload("res://resources/5q.tres")
var BOBE_DEF   = preload("res://resources/bobe.tres")
var IPMAN_DEF  = preload("res://resources/ipman.tres")
var ITSO_DEF   = preload("res://resources/itso.tres")
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
var _cs_sel: Array = [0, 0]
var _cs_confirmed: Array = [false, false]
var _font: Font


func _ready() -> void:
	OS.window_fullscreen = true
	MenuManager.locked = false
	_all_defs = [ASEN_DEF, DJOLEV_DEF, SIYANA_DEF, CRUNCH_DEF, DANI_DEF, DRAGO_DEF, RADO_DEF, YAVOR_DEF, FIVEQ_DEF, BOBE_DEF, IPMAN_DEF, ITSO_DEF, SASHO_DEF, VALKA_DEF, VELI_DEF]
	var tmp := Label.new()
	add_child(tmp)
	_font = tmp.get_font("font")
	tmp.queue_free()


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey:
		var kev := event as InputEventKey
		if not kev.pressed or kev.echo:
			return
	elif event is InputEventJoypadButton:
		var jev := event as InputEventJoypadButton
		if not jev.pressed:
			return
	else:
		return

	get_tree().set_input_as_handled()

	if event.is_action_pressed("p1_left") and not _cs_confirmed[0]:
		_cs_sel[0] = wrapi(_cs_sel[0] - 1, 0, _all_defs.size())
		update()
	elif event.is_action_pressed("p1_right") and not _cs_confirmed[0]:
		_cs_sel[0] = wrapi(_cs_sel[0] + 1, 0, _all_defs.size())
		update()
	elif event.is_action_pressed("p1_jump"):
		_cs_confirmed[0] = not _cs_confirmed[0]
		update()

	if event.is_action_pressed("p2_left") and not _cs_confirmed[1]:
		_cs_sel[1] = wrapi(_cs_sel[1] - 1, 0, _all_defs.size())
		update()
	elif event.is_action_pressed("p2_right") and not _cs_confirmed[1]:
		_cs_sel[1] = wrapi(_cs_sel[1] + 1, 0, _all_defs.size())
		update()
	elif event.is_action_pressed("p2_jump"):
		_cs_confirmed[1] = not _cs_confirmed[1]
		update()

	if _cs_confirmed[0] and _cs_confirmed[1]:
		_start_game()


func _start_game() -> void:
	var main_inst = load("res://scenes/Main.tscn").instance()
	main_inst.p1_def = _all_defs[_cs_sel[0]]
	main_inst.p2_def = _all_defs[_cs_sel[1]]
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

	draw_rect(Rect2(W * 0.5 - 1.0, 62.0, 2.0, H - 90.0), Color(0.35, 0.32, 0.5, 0.5))

	_draw_player_card(0)
	_draw_player_card(1)

	draw_string(_font, Vector2(20.0, H - 14.0), "P1: A/D select   W confirm", Color(0.5, 0.5, 0.65))
	draw_string(_font, Vector2(W * 0.5 + 20.0, H - 14.0), "P2: ←/→ select   ↑ confirm", Color(0.5, 0.5, 0.65))

	MenuManager.draw_overlay(self)


func _draw_player_card(pi: int) -> void:
	var def: CharacterDef = _all_defs[_cs_sel[pi]]
	var confirmed: bool = _cs_confirmed[pi]

	var cx: float = W * 0.25 if pi == 0 else W * 0.75
	var card_x: float = cx - 100.0
	var card_y: float = 68.0
	var card_w: float = 200.0
	var card_h: float = 300.0

	var bg_col := Color(0.08, 0.14, 0.10) if confirmed else Color(0.10, 0.10, 0.18)
	draw_rect(Rect2(card_x, card_y, card_w, card_h), bg_col)
	var lc: Color = def.label_color
	var border_col: Color = lc if confirmed else Color(lc.r * 0.45, lc.g * 0.45, lc.b * 0.45)
	draw_rect(Rect2(card_x, card_y, card_w, card_h), border_col, false, 2.0)

	var plabel: String = "P1" if pi == 0 else "P2"
	draw_string(_font, Vector2(cx - 8.0, card_y + 22.0), plabel, def.label_color)

	var portrait_size := 140.0
	var px: float = cx - portrait_size * 0.5
	var py: float = card_y + 35.0
	var tex: Texture = _get_idle_tex(def.char_name)
	draw_texture_rect_region(tex, Rect2(px, py, portrait_size, portrait_size), Rect2(0, 0, 128, 128))

	if not confirmed:
		draw_string(_font, Vector2(card_x + 8.0, py + portrait_size * 0.5 + 8.0), "◄", Color.white)
		draw_string(_font, Vector2(card_x + card_w - 20.0, py + portrait_size * 0.5 + 8.0), "►", Color.white)

	var name_x: float = cx - float(def.display_name.length()) * 4.5
	draw_string(_font, Vector2(name_x, py + portrait_size + 22.0), def.display_name, def.label_color)

	var status_y: float = py + portrait_size + 48.0
	if confirmed:
		draw_string(_font, Vector2(cx - 38.0, status_y), "CONFIRMED!", Color(0.3, 1.0, 0.4))
	else:
		var hint: String = "W to confirm" if pi == 0 else "↑ to confirm"
		draw_string(_font, Vector2(cx - 46.0, status_y), hint, Color(0.5, 0.5, 0.65))
