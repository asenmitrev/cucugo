
extends Node

const W := 800.0
const H := 450.0

const MAIN_MENU_ITEMS := ["Controls", "Character Select", "Level Editor", "Quit"]
var show_main_menu: bool = false
var main_menu_sel: int = 0

var show_controls: bool = false
var controls_sel: int = 0
var is_binding: bool = false

# When true, ESC/Start won't open the menu (used during game-over countdown)
var locked: bool = false

const CTRL_ACTIONS := [
	{"player": 0, "label": "Left", "action": "p1_left"},
	{"player": 0, "label": "Right", "action": "p1_right"},
	{"player": 0, "label": "Jump", "action": "p1_jump"},
	{"player": 0, "label": "Skill 1", "action": "p1_skill1"},
	{"player": 0, "label": "Skill 2", "action": "p1_skill2"},
	{"player": 0, "label": "Skill 3", "action": "p1_skill3"},
	{"player": 1, "label": "Left", "action": "p2_left"},
	{"player": 1, "label": "Right", "action": "p2_right"},
	{"player": 1, "label": "Jump", "action": "p2_jump"},
	{"player": 1, "label": "Skill 1", "action": "p2_skill1"},
	{"player": 1, "label": "Skill 2", "action": "p2_skill2"},
	{"player": 1, "label": "Skill 3", "action": "p2_skill3"},
	{"player": 2, "label": "Left", "action": "p3_left"},
	{"player": 2, "label": "Right", "action": "p3_right"},
	{"player": 2, "label": "Jump", "action": "p3_jump"},
	{"player": 2, "label": "Skill 1", "action": "p3_skill1"},
	{"player": 2, "label": "Skill 2", "action": "p3_skill2"},
	{"player": 2, "label": "Skill 3", "action": "p3_skill3"},
	{"player": 3, "label": "Left", "action": "p4_left"},
	{"player": 3, "label": "Right", "action": "p4_right"},
	{"player": 3, "label": "Jump", "action": "p4_jump"},
	{"player": 3, "label": "Skill 1", "action": "p4_skill1"},
	{"player": 3, "label": "Skill 2", "action": "p4_skill2"},
	{"player": 3, "label": "Skill 3", "action": "p4_skill3"},
]

const CTRL_VISIBLE_ROWS := 8
const CTRL_ROW_H := 28
const CTRL_BOX_W := 560
const CTRL_BOX_H := 320

var DEFAULT_BINDS: Dictionary = {
	"p1_left":	KEY_A,
	"p1_right":   KEY_D,
	"p1_jump":	KEY_W,
	"p1_skill1":  KEY_R,
	"p1_skill2":  KEY_F,
	"p1_skill3":  KEY_V,
	"p2_left":	KEY_LEFT,
	"p2_right":   KEY_RIGHT,
	"p2_jump":	KEY_UP,
	"p2_skill1":  KEY_SEMICOLON,
	"p2_skill2":  KEY_APOSTROPHE,
	"p2_skill3":  KEY_BACKSLASH,
	"p3_left":	KEY_J,
	"p3_right":   KEY_L,
	"p3_jump":	KEY_I,
	"p3_skill1":  KEY_U,
	"p3_skill2":  KEY_O,
	"p3_skill3":  KEY_P,
	"p4_left":	KEY_KP_4,
	"p4_right":   KEY_KP_6,
	"p4_jump":	KEY_KP_8,
	"p4_skill1":  KEY_KP_7,
	"p4_skill2":  KEY_KP_9,
	"p4_skill3":  KEY_KP_ADD,
}

# _ctrl_bindings maps action_name -> Array[InputEvent]  (supports multiple joypads + keyboard fallback)
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
		
		if is_binding:
			if event is InputEventKey:
				var ev: InputEventKey = event as InputEventKey
				if not ev.pressed or ev.echo: return
				if ev.scancode == KEY_ESCAPE:
					is_binding = false
					_update_hint()
					_request_update()
					return
				_ctrl_remap(event)
				is_binding = false
				_update_hint()
				_request_update()
				return
			elif event is InputEventJoypadButton:
				var ev: InputEventJoypadButton = event as InputEventJoypadButton
				if not ev.pressed: return
				_ctrl_remap(event)
				is_binding = false
				_update_hint()
				_request_update()
				return
			elif event is InputEventJoypadMotion:
				var ev: InputEventJoypadMotion = event as InputEventJoypadMotion
				if abs(ev.axis_value) > 0.5:
					# Use sign to capture axis direction (1 or -1)
					var nev = ev.duplicate()
					nev.axis_value = 1.0 if ev.axis_value > 0 else -1.0
					_ctrl_remap(nev)
					is_binding = false
					_update_hint()
					_request_update()
				return
			return

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
			elif ev.scancode == KEY_ENTER or ev.scancode == KEY_KP_ENTER:
				if controls_sel == CTRL_ACTIONS.size():
					_ctrl_reset_defaults()
				else:
					is_binding = true
					_update_hint()
			_request_update()
			return
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
		_request_update()
		return

	# No overlay open — ESC opens menu (unless locked)
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


func _request_update() -> void:
	var scene = get_tree().get_current_scene()
	if scene != null and scene.has_method("update"):
		scene.update()


func _main_menu_confirm() -> void:
	match main_menu_sel:
		0:
			show_main_menu = false
			_ctrl_toggle()
		1:
			show_main_menu = false
			_go_to_char_select()
		2:
			show_main_menu = false
			_go_to_level_editor()
		3:
			get_tree().quit()


func _go_to_char_select() -> void:
	locked = false
	show_controls = false
	var current: Node = get_tree().current_scene
	if current:
		current.queue_free()
	var cs: Node2D = load("res://scenes/CharSelect.tscn").instance()
	get_tree().get_root().add_child(cs)
	get_tree().current_scene = cs


func _go_to_level_editor() -> void:
	locked = false
	show_controls = false
	var current: Node = get_tree().current_scene
	if current:
		current.queue_free()
	# Create level editor instance
	var editor = preload("res://scripts/LevelEditor.gd").new()
	get_tree().get_root().add_child(editor)
	get_tree().current_scene = editor
	# Store reference to main scene for returning
	editor.main_scene = self


func exit_level_editor() -> void:
	var current: Node = get_tree().current_scene
	if current:
		current.queue_free()
	# Return to main menu
	show_main_menu = true
	main_menu_sel = 0
	get_tree().current_scene = self


func _ctrl_toggle() -> void:
	if show_controls:
		_ctrl_save()
	show_controls = not show_controls


func _ctrl_nav(dir: int) -> void:
	controls_sel = wrapi(controls_sel + dir, 0, CTRL_ACTIONS.size() + 1)
	_update_hint()


func _ctrl_remap(ev: InputEvent) -> void:
	var ca: Dictionary = CTRL_ACTIONS[controls_sel]
	_apply_event_to_action(ca["action"], ev, _get_event_device(ev))


func _ctrl_reset_defaults() -> void:
	for action in DEFAULT_BINDS:
		var ev := InputEventKey.new()
		ev.scancode = DEFAULT_BINDS[action]
		_apply_event_to_action(action, ev, -1)
	_ctrl_save()


func _update_hint() -> void:
	if is_binding:
		_hint_text = "Press any key/button to bind (Esc to cancel)"
	elif controls_sel == CTRL_ACTIONS.size():
		_hint_text = "↑↓ navigate   Enter/A-btn to reset   Esc/Start close"
	else:
		_hint_text = "↑↓ navigate   Enter/A-btn to bind   Esc/Start close"


func _setup_default_controls() -> void:
	for action in DEFAULT_BINDS:
		if not _input_map_has_action(action):
			InputMap.add_action(action)
		else:
			InputMap.action_erase_events(action)
		var ev := InputEventKey.new()
		ev.scancode = DEFAULT_BINDS[action]
		_apply_event_to_action(action, ev, -1)




	var axis_mappings := [
		["p1_left",  0, JOY_AXIS_0, -1.0],
		["p1_right", 0, JOY_AXIS_0,  1.0],
		["p1_jump",  0, JOY_AXIS_1, -1.0],
		["p2_left",  1, JOY_AXIS_0, -1.0],
		["p2_right", 1, JOY_AXIS_0,  1.0],
		["p2_jump",  1, JOY_AXIS_1, -1.0],
		["p3_left",  2, JOY_AXIS_0, -1.0],
		["p3_right", 2, JOY_AXIS_0,  1.0],
		["p3_jump",  2, JOY_AXIS_1, -1.0],
		["p4_left",  3, JOY_AXIS_0, -1.0],
		["p4_right", 3, JOY_AXIS_0,  1.0],
		["p4_jump",  3, JOY_AXIS_1, -1.0],
	]
	for m in axis_mappings:
		var ev := InputEventJoypadMotion.new()
		ev.device = m[1]
		ev.axis = m[2]
		ev.axis_value = m[3]
		InputMap.action_add_event(m[0], ev)


func _input_map_has_action(aname: String) -> bool:
	for a in InputMap.get_actions():
		if a == aname:
			return true
	return false


func _apply_event_to_action(action: String, ev: InputEvent, device: int) -> void:
	# Exclusive binding: remove this event from every other remappable action first.
	for ca in CTRL_ACTIONS:
		var other: String = ca["action"]
		if other == action:
			continue
		var other_events: Array = _ctrl_bindings.get(other, [])
		var kept := []
		for e in other_events:
			var conflict := false
			if ev is InputEventJoypadButton and e is InputEventJoypadButton:
				conflict = (e as InputEventJoypadButton).button_index == (ev as InputEventJoypadButton).button_index \
					and (e.device == device or device == -1 or e.device == -1)
			elif ev is InputEventKey and e is InputEventKey:
				conflict = (e as InputEventKey).scancode == (ev as InputEventKey).scancode
			elif ev is InputEventJoypadMotion and e is InputEventJoypadMotion:
				conflict = (e as InputEventJoypadMotion).axis == (ev as InputEventJoypadMotion).axis \
					and sign((e as InputEventJoypadMotion).axis_value) == sign((ev as InputEventJoypadMotion).axis_value) \
					and (e.device == device or device == -1 or e.device == -1)
			if conflict:
				InputMap.action_erase_event(other, e)
			else:
				kept.append(e)
		_ctrl_bindings[other] = kept

	# One binding per action: clear everything currently on this action.
	for e in _ctrl_bindings.get(action, []):
		InputMap.action_erase_event(action, e)

	if ev is InputEventJoypadButton:
		(ev as InputEventJoypadButton).device = device
	elif ev is InputEventJoypadMotion:
		(ev as InputEventJoypadMotion).device = device
	InputMap.action_add_event(action, ev)
	_ctrl_bindings[action] = [ev]


func _get_event_device(ev: InputEvent) -> int:
	if ev is InputEventJoypadButton:
		return (ev as InputEventJoypadButton).device
	if ev is InputEventJoypadMotion:
		return (ev as InputEventJoypadMotion).device
	return -1


func _get_binding_display(action: String) -> String:
	var events: Array = _ctrl_bindings.get(action, [])
	if events.empty():
		return "(unbound)"

	var parts := []
	for e in events:
		if e is InputEventKey:
			parts.append(OS.get_scancode_string((e as InputEventKey).scancode))
		elif e is InputEventJoypadButton:
			var dev: int = e.device
			var dev_name: String = Input.get_joy_name(dev) if dev >= 0 else "any"
			if dev_name == "":
				dev_name = "dev%d" % dev
			parts.append("JoyBtn:%d(%s)" % [e.button_index, dev_name])
		elif e is InputEventJoypadMotion:
			var dev: int = e.device
			var dev_name: String = Input.get_joy_name(dev) if dev >= 0 else "any"
			if dev_name == "":
				dev_name = "dev%d" % dev
			var sign_str = "+" if e.axis_value > 0 else "-"
			parts.append("JoyAxis:%d%s(%s)" % [e.axis, sign_str, dev_name])

	return ", ".join(parts) if parts.size() > 1 else parts[0] if parts.size() == 1 else "(unbound)"


func _ctrl_save() -> void:
	var file := File.new()
	file.open("user://controls.cfg", File.WRITE)
	for ca in CTRL_ACTIONS:
		var action: String = ca["action"]
		var events: Array = _ctrl_bindings.get(action, [])
		if events.empty():
			continue
		for e in events:
			if e is InputEventKey:
				file.store_line("%s=key:%d" % [action, (e as InputEventKey).scancode])
			elif e is InputEventJoypadButton:
				file.store_line("%s=joy:%d:%d" % [action, e.button_index, e.device])
			elif e is InputEventJoypadMotion:
				var sv = 1 if e.axis_value > 0 else -1
				file.store_line("%s=joyaxis:%d:%d:%d" % [action, e.axis, sv, e.device])
	file.close()


func _ctrl_load() -> void:
	var file := File.new()
	if not file.file_exists("user://controls.cfg"):
		return
	if file.open("user://controls.cfg", File.READ) != OK:
		return
	while not file.eof_reached():
		var line: String = file.get_line()
		var eq_parts: PoolStringArray = line.split("=")
		if eq_parts.size() != 2:
			continue
		var action: String = eq_parts[0]
		var val: String = eq_parts[1]
		if val.begins_with("key:"):
			var keycode: int = int(val.substr(4))
			if keycode > 0:
				var kev := InputEventKey.new()
				kev.scancode = keycode
				_apply_event_to_action(action, kev, -1)
		elif val.begins_with("joy:"):
			var joy_data: PoolStringArray = val.substr(4).split(":")
			var btn: int = int(joy_data[0])
			var dev: int = int(joy_data[1]) if joy_data.size() > 1 else -1
			var jev := InputEventJoypadButton.new()
			jev.button_index = btn
			jev.device = dev
			jev.pressed = true
			_apply_event_to_action(action, jev, dev)
		elif val.begins_with("joyaxis:"):
			var joy_data: PoolStringArray = val.substr(8).split(":")
			var axis: int = int(joy_data[0])
			var sv: int = int(joy_data[1])
			var dev: int = int(joy_data[2]) if joy_data.size() > 2 else -1
			var jev := InputEventJoypadMotion.new()
			jev.axis = axis
			jev.axis_value = float(sv)
			jev.device = dev
			_apply_event_to_action(action, jev, dev)
		else:
			# Legacy format (plain number = keycode)
			var keycode: int = int(val)
			if keycode > 0:
				var kev := InputEventKey.new()
				kev.scancode = keycode
				_apply_event_to_action(action, kev, -1)
	file.close()


# Called from ControllerMapper to register a joypad binding without erasing other devices
func register_joypad_binding(action: String, ev: InputEvent) -> void:
	for e in _ctrl_bindings.get(action, []):
		InputMap.action_erase_event(action, e)
	InputMap.action_add_event(action, ev)
	_ctrl_bindings[action] = [ev]


# ── Drawing ──────────────────────────────────────────────────────

func draw_overlay(canvas: CanvasItem) -> void:
	if show_main_menu:
		_draw_main_menu(canvas)
	elif show_controls:
		_draw_controls(canvas)


func _draw_main_menu(canvas: CanvasItem) -> void:
	var mw: float = 280.0
	var mh: float = 195.0
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
			var pname: String = "Player " + str(ca["player"] + 1)
			canvas.draw_string(font, Vector2(bx + 14.0, ry - 4.0), pname, Color(0.8, 0.8, 0.9))

		var key_str: String = "(press key/button...)" if (is_binding and idx == controls_sel) else _get_binding_display(ca["action"])
		var line: String = "  %s: %s" % [ca["label"], key_str]
		var col: Color = Color(1.0, 1.0, 0.2) if (is_binding and idx == controls_sel) else (Color(1.0, 1.0, 1.0) if idx == controls_sel else Color(0.75, 0.75, 0.85))
		canvas.draw_string(font, Vector2(bx + 14.0, ry + CTRL_ROW_H - 8.0), line, col)

	var reset_ry: float = row_top + float(CTRL_VISIBLE_ROWS) * CTRL_ROW_H + 10.0
	var reset_col: Color = Color(1.0, 0.55, 0.55) if controls_sel == CTRL_ACTIONS.size() else Color(0.65, 0.42, 0.42)
	canvas.draw_string(font, Vector2(bx + CTRL_BOX_W * 0.5 - 62.0, reset_ry + CTRL_ROW_H - 8.0), "[ Reset to Default ]", reset_col)
