extends Node

const W := 800.0
const H := 450.0

const MAIN_MENU_ITEMS := ["Controls", "Quit"]
var show_main_menu: bool = false
var main_menu_sel: int = 0

var show_controls: bool = false
var controls_sel: int = 0

# When true, ESC/Start won't open the menu (used during game-over countdown)
var locked: bool = false

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

var DEFAULT_BINDS: Dictionary = {
	"p1_left":    KEY_A,
	"p1_right":   KEY_D,
	"p1_jump":    KEY_W,
	"p1_skill1":  KEY_R,
	"p1_skill2":  KEY_F,
	"p1_skill3":  KEY_V,
	"p2_left":    KEY_LEFT,
	"p2_right":   KEY_RIGHT,
	"p2_jump":    KEY_UP,
	"p2_skill1":  KEY_SEMICOLON,
	"p2_skill2":  KEY_APOSTROPHE,
	"p2_skill3":  KEY_BACKSLASH,
}

var _ctrl_bindings: Dictionary = {}
var _hint_text: String = ""
var font: Font


func _ready() -> void:
	var tmp := Label.new()
	add_child(tmp)
	font = tmp.get_font("font")
	tmp.queue_free()
	_setup_default_controls()
	_ctrl_load()
	_update_hint()


func is_open() -> bool:
	return show_main_menu or show_controls


func _input(event: InputEvent) -> void:
	if show_controls:
		get_tree().set_input_as_handled()
		if event is InputEventKey:
			var ev: InputEventKey = event as InputEventKey
			if not ev.pressed or ev.echo:
				return
			if ev.scancode == KEY_ESCAPE:
				_ctrl_toggle()
			elif ev.scancode == KEY_UP:
				_ctrl_nav(-1)
			elif ev.scancode == KEY_DOWN:
				_ctrl_nav(1)
			elif controls_sel == CTRL_ACTIONS.size():
				if ev.scancode == KEY_ENTER or ev.scancode == KEY_KP_ENTER:
					_ctrl_reset_defaults()
			else:
				_ctrl_remap(event)
			_request_update()
			return
		if event is InputEventJoypadButton:
			var ev: InputEventJoypadButton = event as InputEventJoypadButton
			if not ev.pressed:
				return
			if ev.button_index == JOY_DPAD_UP:
				_ctrl_nav(-1)
			elif ev.button_index == JOY_DPAD_DOWN:
				_ctrl_nav(1)
			elif event.is_action_pressed("ui_cancel"):
				_ctrl_toggle()
			elif controls_sel == CTRL_ACTIONS.size():
				_ctrl_reset_defaults()
			else:
				_ctrl_remap(event)
			_request_update()
			return
		if event is InputEventJoypadMotion:
			var ev: InputEventJoypadMotion = event as InputEventJoypadMotion
			if ev.axis == JOY_AXIS_1 or ev.axis == 7:
				if ev.axis_value < -0.5:
					_ctrl_nav(-1)
					_request_update()
				elif ev.axis_value > 0.5:
					_ctrl_nav(1)
					_request_update()
		return

	if show_main_menu:
		get_tree().set_input_as_handled()
		if event is InputEventKey:
			var ev: InputEventKey = event as InputEventKey
			if not ev.pressed or ev.echo:
				return
			if ev.scancode == KEY_ESCAPE:
				show_main_menu = false
			elif ev.scancode == KEY_UP:
				main_menu_sel = wrapi(main_menu_sel - 1, 0, MAIN_MENU_ITEMS.size())
			elif ev.scancode == KEY_DOWN:
				main_menu_sel = wrapi(main_menu_sel + 1, 0, MAIN_MENU_ITEMS.size())
			elif ev.scancode == KEY_ENTER or ev.scancode == KEY_KP_ENTER or ev.scancode == KEY_SPACE:
				_main_menu_confirm()
		elif event is InputEventJoypadButton:
			var ev: InputEventJoypadButton = event as InputEventJoypadButton
			if not ev.pressed:
				return
			if ev.button_index == JOY_DPAD_UP:
				main_menu_sel = wrapi(main_menu_sel - 1, 0, MAIN_MENU_ITEMS.size())
			elif ev.button_index == JOY_DPAD_DOWN:
				main_menu_sel = wrapi(main_menu_sel + 1, 0, MAIN_MENU_ITEMS.size())
			elif ev.button_index == JOY_SONY_X or ev.button_index == JOY_XBOX_A:
				_main_menu_confirm()
			elif event.is_action_pressed("ui_cancel"):
				show_main_menu = false
		_request_update()
		return

	# No overlay open — ESC or Start opens menu (unless locked)
	if locked:
		return
	if event is InputEventKey:
		var ev: InputEventKey = event as InputEventKey
		if ev.pressed and not ev.echo and ev.scancode == KEY_ESCAPE:
			show_main_menu = true
			main_menu_sel = 0
			get_tree().set_input_as_handled()
			_request_update()
			return
	if InputMap.has_action("start") and event.is_action_pressed("start"):
		show_main_menu = true
		main_menu_sel = 0
		get_tree().set_input_as_handled()
		_request_update()


func _request_update() -> void:
	var scene = get_tree().get_current_scene()
	if scene != null:
		scene.update()


func _main_menu_confirm() -> void:
	match main_menu_sel:
		0:
			show_main_menu = false
			_ctrl_toggle()
		1:
			get_tree().quit()


func _ctrl_toggle() -> void:
	if show_controls:
		_ctrl_save()
	show_controls = not show_controls


func _ctrl_nav(dir: int) -> void:
	controls_sel = wrapi(controls_sel + dir, 0, CTRL_ACTIONS.size() + 1)
	_update_hint()


func _ctrl_remap(ev: InputEvent) -> void:
	var ca: Dictionary = CTRL_ACTIONS[controls_sel]
	_apply_event_to_action(ca["action"], ev)


func _ctrl_reset_defaults() -> void:
	for action in DEFAULT_BINDS:
		var ev := InputEventKey.new()
		ev.scancode = DEFAULT_BINDS[action]
		_apply_event_to_action(action, ev)
	_ctrl_save()


func _update_hint() -> void:
	if controls_sel == CTRL_ACTIONS.size():
		_hint_text = "↑↓ navigate   Enter/any button to reset   Esc/B close"
	else:
		_hint_text = "↑↓ navigate   any key/button to bind   Esc/B close"


func _setup_default_controls() -> void:
	for action in DEFAULT_BINDS:
		if not _input_map_has_action(action):
			InputMap.add_action(action)
		var ev := InputEventKey.new()
		ev.scancode = DEFAULT_BINDS[action]
		_apply_event_to_action(action, ev)


func _input_map_has_action(aname: String) -> bool:
	for a in InputMap.get_actions():
		if a == aname:
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
	if not file.file_exists("user://controls.cfg"):
		return
	if file.open("user://controls.cfg", File.READ) != OK:
		return
	while not file.eof_reached():
		var line: String = file.get_line()
		var parts: PoolStringArray = line.split("=")
		if parts.size() != 2:
			continue
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
			var keycode: int = int(val)
			if keycode > 0:
				var kev := InputEventKey.new()
				kev.scancode = keycode
				_apply_event_to_action(action, kev)
	file.close()


# ── Drawing ──────────────────────────────────────────────────────

func draw_overlay(canvas: CanvasItem) -> void:
	if show_main_menu:
		_draw_main_menu(canvas)
	elif show_controls:
		_draw_controls(canvas)


func _draw_main_menu(canvas: CanvasItem) -> void:
	var mw: float = 280.0
	var mh: float = 170.0
	var mx: float = (W - mw) / 2.0
	var my: float = (H - mh) / 2.0
	canvas.draw_rect(Rect2(0, 0, W, H), Color(0, 0, 0, 0.65))
	canvas.draw_rect(Rect2(mx, my, mw, mh), Color(0.08, 0.08, 0.14))
	canvas.draw_rect(Rect2(mx, my, mw, mh), Color(0.45, 0.4, 0.65), false, 2.0)
	canvas.draw_string(font, Vector2(mx + mw * 0.5 - 22.0, my + 30.0), "MENU", Color.white)
	for idx in MAIN_MENU_ITEMS.size():
		var iy: float = my + 72.0 + float(idx) * 38.0
		if idx == main_menu_sel:
			canvas.draw_rect(Rect2(mx + 8.0, iy - 20.0, mw - 16.0, 30.0), Color(0.22, 0.22, 0.35))
		var col: Color = Color(1.0, 1.0, 1.0) if idx == main_menu_sel else Color(0.65, 0.65, 0.78)
		canvas.draw_string(font, Vector2(mx + mw * 0.5 - 24.0, iy), MAIN_MENU_ITEMS[idx], col)
	canvas.draw_string(font, Vector2(mx + 10.0, my + mh - 12.0), "↑↓ navigate   Enter confirm   Esc close", Color(0.5, 0.5, 0.65))


func _draw_controls(canvas: CanvasItem) -> void:
	var bx: float = (W - CTRL_BOX_W) / 2.0
	var by: float = (H - CTRL_BOX_H) / 2.0
	canvas.draw_rect(Rect2(0, 0, W, H), Color(0, 0, 0, 0.65))
	canvas.draw_rect(Rect2(bx, by, CTRL_BOX_W, CTRL_BOX_H), Color(0.08, 0.08, 0.14))
	canvas.draw_rect(Rect2(bx, by, CTRL_BOX_W, CTRL_BOX_H), Color(0.45, 0.4, 0.65), false, 2.0)
	canvas.draw_string(font, Vector2(bx + CTRL_BOX_W * 0.5 - 38.0, by + 28.0), "CONTROLS", Color.white)

	var row_top: float = by + 62.0
	var max_offset: int = max(0, CTRL_ACTIONS.size() - CTRL_VISIBLE_ROWS)
	var eff_sel: int = min(controls_sel, CTRL_ACTIONS.size() - 1)
	var offset: int = clamp(eff_sel - 3, 0, max_offset)

	if controls_sel == CTRL_ACTIONS.size():
		var reset_ry: float = row_top + float(CTRL_VISIBLE_ROWS) * CTRL_ROW_H + 10.0
		canvas.draw_rect(Rect2(bx + 4.0, reset_ry - 2.0, CTRL_BOX_W - 8.0, CTRL_ROW_H + 4.0), Color(0.30, 0.14, 0.14))
	else:
		var sel_vis: int = controls_sel - offset
		var sel_ry: float = row_top + float(sel_vis) * CTRL_ROW_H
		canvas.draw_rect(Rect2(bx + 4.0, sel_ry - 2.0, CTRL_BOX_W - 8.0, CTRL_ROW_H + 4.0), Color(0.22, 0.22, 0.35))

	_draw_ctrl_rows(canvas, bx, row_top, offset)
	canvas.draw_string(font, Vector2(bx, by + CTRL_BOX_H - 28.0), _hint_text, Color(0.6, 0.6, 0.8))


func _draw_ctrl_rows(canvas: CanvasItem, bx: float, row_top: float, offset: int) -> void:
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
			canvas.draw_string(font, Vector2(bx + 14.0, ry - 4.0), pname, Color(0.8, 0.8, 0.9))

		var key_str: String = _get_binding_display(ca["action"])
		var line: String = "  %s: %s" % [ca["label"], key_str]
		var col: Color = Color(1.0, 1.0, 1.0) if idx == controls_sel else Color(0.75, 0.75, 0.85)
		canvas.draw_string(font, Vector2(bx + 14.0, ry + CTRL_ROW_H - 8.0), line, col)

	var reset_ry: float = row_top + float(CTRL_VISIBLE_ROWS) * CTRL_ROW_H + 10.0
	var reset_col: Color = Color(1.0, 0.55, 0.55) if controls_sel == CTRL_ACTIONS.size() else Color(0.65, 0.42, 0.42)
	canvas.draw_string(font, Vector2(bx + CTRL_BOX_W * 0.5 - 62.0, reset_ry + CTRL_ROW_H - 8.0), "[ Reset to Default ]", reset_col)
