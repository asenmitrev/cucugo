extends Node2D

const W := 800.0
const H := 450.0

# Preload LevelDef class
const LevelDef = preload("res://scripts/LevelDef.gd")

# Editor modes
enum EditorMode { PLATFORM, PLAYER_P1, PLAYER_P2, PLAYER_P3, PLAYER_P4 }
var current_mode: int = EditorMode.PLATFORM

# Editor state
var platforms: Array = []  # Each platform: [x, y, width, height]
var drawing_platform: bool = false
var dragging_p1: bool = false
var dragging_p2: bool = false
var dragging_p3: bool = false
var dragging_p4: bool = false
var current_platform_start: Vector2 = Vector2.ZERO
var current_platform_end: Vector2 = Vector2.ZERO

# Level properties (editable)
var level_name: String = "Custom Level"
var bg_top: Color = Color(0.07, 0.08, 0.16)
var bg_bottom: Color = Color(0.10, 0.12, 0.22)
var bg_split: float = 0.6
var plat_fill: Color = Color(0.18, 0.12, 0.32)
var plat_highlight: Color = Color(0.42, 0.35, 0.55)
var plat_shadow: Color = Color(0.30, 0.22, 0.44)
var plat_dark: Color = Color(0, 0, 0, 0.22)
var start_p1: Vector2 = Vector2(140, 300)
var start_p2: Vector2 = Vector2(570, 300)
var start_p3: Vector2 = Vector2(200, 200)
var start_p4: Vector2 = Vector2(600, 200)

# UI state
var show_properties: bool = false
var selected_property: int = 0
var property_editing: bool = false
var property_value_str: String = ""
var snap_to_grid: bool = true
var grid_size: int = 16
var save_message: String = ""
var save_message_time: float = 0.0

# References
var main_scene: Node = null
var font: Font

func _ready() -> void:
	# Initialize with default values
	var tmp := Label.new()
	add_child(tmp)
	font = tmp.get_font("font")
	tmp.queue_free()
	set_process_input(true)
	set_process(true)

func _process(delta: float) -> void:
	# Check if save message should be cleared
	var current_time = OS.get_ticks_msec() / 1000.0
	if save_message != "" and current_time - save_message_time >= 3.0:
		save_message = ""
		update()  # Refresh display

func _input(event: InputEvent) -> void:
	if property_editing:
		_handle_property_input(event)
		return
	
	if event is InputEventKey:
		if event.pressed and not event.echo:
			match event.scancode:
				KEY_ESCAPE:
					if show_properties:
						show_properties = false
					else:
						# Return to main menu
						if main_scene:
							main_scene.exit_level_editor()
				KEY_SPACE:
					# Toggle properties panel
					show_properties = not show_properties
					update()
				KEY_G:
					# Toggle grid snap
					snap_to_grid = not snap_to_grid
					update()
				KEY_DELETE, KEY_BACKSPACE:
					# Delete selected platform (if we had selection)
					if platforms.size() > 0:
						platforms.pop_back()
				KEY_S:
					if event.control:
						# Ctrl+S to save
						_save_level()
				KEY_UP:
					if show_properties:
						selected_property = wrapi(selected_property - 1, 0, 9)
						update()
				KEY_DOWN:
					if show_properties:
						selected_property = wrapi(selected_property + 1, 0, 9)
						update()
				KEY_ENTER, KEY_KP_ENTER:
					if show_properties:
						print("DEBUG: ENTER pressed, show_properties=true, selected_property=", selected_property)
						if selected_property == 8:  # Save map
							print("DEBUG: Calling _save_level()")
							_save_level()
						else:
							property_editing = true
							# Initialize with current value based on property type
							match selected_property:
								0:  # Level name
									property_value_str = level_name
								1:  # BG Top color
									property_value_str = _color_to_hex(bg_top)
								2:  # BG Bottom color
									property_value_str = _color_to_hex(bg_bottom)
								3:  # Platform fill color
									property_value_str = _color_to_hex(plat_fill)
								4:  # Start P1 position
									property_value_str = str(int(start_p1.x)) + "," + str(int(start_p1.y))
								5:  # Start P2 position
									property_value_str = str(int(start_p2.x)) + "," + str(int(start_p2.y))
								6:  # Start P3 position
									property_value_str = str(int(start_p3.x)) + "," + str(int(start_p3.y))
								7:  # Start P4 position
									property_value_str = str(int(start_p4.x)) + "," + str(int(start_p4.y))
				KEY_1:
					current_mode = EditorMode.PLATFORM
					update()
				KEY_2:
					current_mode = EditorMode.PLAYER_P1
					update()
				KEY_3:
					current_mode = EditorMode.PLAYER_P2
					update()
				KEY_4:
					current_mode = EditorMode.PLAYER_P3
					update()
				KEY_5:
					current_mode = EditorMode.PLAYER_P4
					update()
	
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_LEFT:
			if event.pressed:
				var mouse_pos = get_viewport().get_mouse_position()
				if snap_to_grid:
					mouse_pos = _snap_to_grid(mouse_pos)
				
				# Check if clicking on mode selector panel (only if properties panel is not open)
				if not show_properties:
					var panel_x = 10
					var panel_y = 30
					var panel_width = 150
					var panel_height = 180
					
					if mouse_pos.x >= panel_x and mouse_pos.x <= panel_x + panel_width and \
					   mouse_pos.y >= panel_y and mouse_pos.y <= panel_y + panel_height:
						# Clicked on mode selector panel
						var mode_y_start = panel_y + 40
						var line_height = 25
						
						for i in range(5):  # 5 modes
							var mode_y = mode_y_start + i * line_height
							var mode_y_end = mode_y + 20  # Approximate height of mode item
							
							if mouse_pos.y >= mode_y - 15 and mouse_pos.y <= mode_y_end:
								# Clicked on this mode
								current_mode = i
								var mode_names = ["Platform Drawing", "Placing P1", "Placing P2", "Placing P3", "Placing P4"]
								print("Mode switched to: " + mode_names[i] + " (mouse click)")
								update()
								break
						return  # Don't process other clicks if we clicked on mode selector
				
				# Check if clicking on spawn positions to move them
				if (mouse_pos - start_p1).length() < 15:
					# Start dragging P1 spawn
					dragging_p1 = true
				elif (mouse_pos - start_p2).length() < 15:
					# Start dragging P2 spawn
					dragging_p2 = true
				elif (mouse_pos - start_p3).length() < 15:
					# Start dragging P3 spawn
					dragging_p3 = true
				elif (mouse_pos - start_p4).length() < 15:
					# Start dragging P4 spawn
					dragging_p4 = true
				elif current_mode == EditorMode.PLATFORM:
					# Start drawing platform
					current_platform_start = mouse_pos
					current_platform_end = mouse_pos
					drawing_platform = true
				elif current_mode == EditorMode.PLAYER_P1:
					# Place P1 spawn
					start_p1 = mouse_pos
					update()
				elif current_mode == EditorMode.PLAYER_P2:
					# Place P2 spawn
					start_p2 = mouse_pos
					update()
				elif current_mode == EditorMode.PLAYER_P3:
					# Place P3 spawn
					start_p3 = mouse_pos
					update()
				elif current_mode == EditorMode.PLAYER_P4:
					# Place P4 spawn
					start_p4 = mouse_pos
					update()
			else:
				# Finish drawing platform or dragging
				if drawing_platform:
					var mouse_pos = get_viewport().get_mouse_position()
					if snap_to_grid:
						mouse_pos = _snap_to_grid(mouse_pos)
					current_platform_end = mouse_pos
					
					# Create platform rect
					var x = min(current_platform_start.x, current_platform_end.x)
					var y = min(current_platform_start.y, current_platform_end.y)
					var width = abs(current_platform_end.x - current_platform_start.x)
					var height = abs(current_platform_end.y - current_platform_start.y)
					
					# Minimum size
					if width >= 10 and height >= 8:
						platforms.append([x, y, width, height])
					
					drawing_platform = false
				dragging_p1 = false
				dragging_p2 = false
				dragging_p3 = false
				dragging_p4 = false
	
	if event is InputEventMouseMotion:
		var mouse_pos = get_viewport().get_mouse_position()
		if snap_to_grid:
			mouse_pos = _snap_to_grid(mouse_pos)
		
		if drawing_platform:
			current_platform_end = mouse_pos
			update()
		elif dragging_p1:
			start_p1 = mouse_pos
			update()
		elif dragging_p2:
			start_p2 = mouse_pos
			update()
		elif dragging_p3:
			start_p3 = mouse_pos
			update()
		elif dragging_p4:
			start_p4 = mouse_pos
			update()

func _snap_to_grid(pos: Vector2) -> Vector2:
	return Vector2(
		floor(pos.x / grid_size) * grid_size,
		floor(pos.y / grid_size) * grid_size
	)

func _handle_property_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		# Check for special keys first (even when editing properties)
		match event.scancode:
			KEY_SPACE:
				# Toggle properties panel
				show_properties = not show_properties
				update()
				return
			KEY_1:
				current_mode = EditorMode.PLATFORM
				update()
				return
			KEY_2:
				current_mode = EditorMode.PLAYER_P1
				update()
				return
			KEY_3:
				current_mode = EditorMode.PLAYER_P2
				update()
				return
			KEY_4:
				current_mode = EditorMode.PLAYER_P3
				update()
				return
			KEY_5:
				current_mode = EditorMode.PLAYER_P4
				update()
				return
		
		# Handle property editing keys
		if event.scancode == KEY_ENTER or event.scancode == KEY_KP_ENTER:
			# Finish editing
			_apply_property_value()
			property_editing = false
			property_value_str = ""
			update()
		elif event.scancode == KEY_ESCAPE:
			# Cancel editing
			property_editing = false
			property_value_str = ""
			update()
		elif event.scancode == KEY_BACKSPACE:
			# Backspace
			if property_value_str.length() > 0:
				property_value_str = property_value_str.substr(0, property_value_str.length() - 1)
				update()
		else:
			# Add character
			var ch = event.unicode
			if ch >= 32 and ch <= 126:  # Printable ASCII
				property_value_str += String("%c") % ch
				update()

func _apply_property_value() -> void:
	if property_value_str.empty():
		return
	
	match selected_property:
		0:  # Level name
			level_name = property_value_str
			update()
		1:  # BG Top color
			bg_top = Color(property_value_str)
			update()
		2:  # BG Bottom color
			bg_bottom = Color(property_value_str)
			update()
		3:  # Platform fill color
			plat_fill = Color(property_value_str)
			update()
		4:  # Start P1 position
			var parts = property_value_str.split(",")
			if parts.size() == 2:
				start_p1 = Vector2(float(parts[0]), float(parts[1]))
				update()
		5:  # Start P2 position
			var parts = property_value_str.split(",")
			if parts.size() == 2:
				start_p2 = Vector2(float(parts[0]), float(parts[1]))
				update()
		6:  # Start P3 position
			var parts = property_value_str.split(",")
			if parts.size() == 2:
				start_p3 = Vector2(float(parts[0]), float(parts[1]))
				update()
		7:  # Start P4 position
			var parts = property_value_str.split(",")
			if parts.size() == 2:
				start_p4 = Vector2(float(parts[0]), float(parts[1]))
				update()
		8:  # Save map
			_save_level()

func _draw() -> void:
	# Draw background
	draw_rect(Rect2(0, 0, W, H * bg_split), bg_top)
	draw_rect(Rect2(0, H * bg_split, W, H - H * bg_split), bg_bottom)
	
	# Draw grid if enabled
	if snap_to_grid:
		_draw_grid()
	
	# Draw existing platforms
	for plat in platforms:
		var px: float = plat[0]
		var py: float = plat[1]
		var pw: float = plat[2]
		var pheight: float = plat[3]
		
		draw_rect(Rect2(px + 4, py + 4, pw, pheight), plat_dark)
		draw_rect(Rect2(px, py, pw, pheight), plat_fill)
		draw_rect(Rect2(px, py, pw, 5), plat_highlight)
		draw_rect(Rect2(px, py, 3, pheight), plat_shadow)
		draw_rect(Rect2(px + pw - 3, py, 3, pheight), plat_shadow)
	
	# Draw platform being drawn
	if drawing_platform:
		var x = min(current_platform_start.x, current_platform_end.x)
		var y = min(current_platform_start.y, current_platform_end.y)
		var width = abs(current_platform_end.x - current_platform_start.x)
		var height = abs(current_platform_end.y - current_platform_start.y)
		
		if width >= 10 and height >= 8:
			draw_rect(Rect2(x + 4, y + 4, width, height), Color(0, 0, 0, 0.3))
			draw_rect(Rect2(x, y, width, height), Color(0.3, 0.7, 0.3, 0.7))
			draw_rect(Rect2(x, y, width, 5), Color(0.5, 1.0, 0.5, 0.9))
			draw_rect(Rect2(x, y, 3, height), Color(0.2, 0.6, 0.2, 0.9))
			draw_rect(Rect2(x + width - 3, y, 3, height), Color(0.2, 0.6, 0.2, 0.9))
	
	# Draw spawn positions
	draw_circle(start_p1, 8, Color(0.2, 0.8, 0.2, 0.8))
	draw_circle(start_p2, 8, Color(0.8, 0.2, 0.2, 0.8))
	draw_circle(start_p3, 8, Color(0.2, 0.2, 0.8, 0.8))
	draw_circle(start_p4, 8, Color(0.8, 0.8, 0.2, 0.8))
	draw_string(font, start_p1 + Vector2(-10, -15), "P1", Color(0.2, 0.8, 0.2))
	draw_string(font, start_p2 + Vector2(-10, -15), "P2", Color(0.8, 0.2, 0.2))
	draw_string(font, start_p3 + Vector2(-10, -15), "P3", Color(0.2, 0.2, 0.8))
	draw_string(font, start_p4 + Vector2(-10, -15), "P4", Color(0.8, 0.8, 0.2))
	
	# Draw UI
	_draw_ui()

func _draw_grid() -> void:
	var grid_color = Color(1, 1, 1, 0.1)
	for x in range(0, int(W) + grid_size, grid_size):
		draw_line(Vector2(x, 0), Vector2(x, H), grid_color)
	for y in range(0, int(H) + grid_size, grid_size):
		draw_line(Vector2(0, y), Vector2(W, y), grid_color)

func _draw_ui() -> void:
	# Draw toolbar at top
	draw_rect(Rect2(0, 0, W, 24), Color(0.1, 0.1, 0.2, 0.9))
	draw_string(font, Vector2(10, 18), "Level Editor: " + level_name, Color(1, 1, 1))
	draw_string(font, Vector2(W - 200, 18), "ESC: Exit  SPACE: Properties  G: Grid(" + ("ON" if snap_to_grid else "OFF") + ")", Color(0.8, 0.8, 0.8))
	
	# Draw current mode
	var mode_names = ["Platform Drawing", "Placing P1", "Placing P2", "Placing P3", "Placing P4"]
	var mode_colors = [Color(0.8, 0.8, 0.8), Color(0.2, 0.8, 0.2), Color(0.8, 0.2, 0.2), Color(0.2, 0.2, 0.8), Color(0.8, 0.8, 0.2)]
	draw_string(font, Vector2(250, 18), "Mode: " + mode_names[current_mode], mode_colors[current_mode])
	
	# Draw platform count
	draw_string(font, Vector2(W - 400, 18), "Platforms: " + str(platforms.size()), Color(0.8, 0.8, 0.8))
	
	# Draw mode selector
	_draw_mode_selector()
	
	# Draw save message if set
	if save_message != "":
		var message_y = H - 40
		draw_rect(Rect2(W/2 - 150, message_y - 10, 300, 30), Color(0.1, 0.1, 0.2, 0.9))
		draw_string(font, Vector2(W/2 - 140, message_y + 10), save_message, Color(0.8, 0.8, 0.2))
	
	# Draw properties panel if shown
	if show_properties:
		_draw_properties_panel()

func _draw_mode_selector() -> void:
	# Draw mode selector panel on left side
	var panel_width = 150
	var panel_height = 180
	var panel_x = 10
	var panel_y = 30
	
	# Panel background
	draw_rect(Rect2(panel_x, panel_y, panel_width, panel_height), Color(0.1, 0.1, 0.2, 0.85))
	draw_rect(Rect2(panel_x, panel_y, panel_width, panel_height), Color(0.3, 0.3, 0.5, 0.8), false)
	
	# Title
	draw_string(font, Vector2(panel_x + 10, panel_y + 20), "Editor Mode", Color(1, 1, 1))
	
	# Mode options
	var modes = [
		"1. Platform Drawing",
		"2. Place P1 (Green)",
		"3. Place P2 (Red)",
		"4. Place P3 (Blue)",
		"5. Place P4 (Yellow)"
	]
	
	var start_y = panel_y + 40
	var line_height = 25
	
	for i in range(modes.size()):
		var y = start_y + i * line_height
		var color = Color(0.9, 0.9, 0.3) if i == current_mode else Color(0.8, 0.8, 0.8)
		
		# Highlight current mode
		if i == current_mode:
			draw_rect(Rect2(panel_x + 5, y - 15, panel_width - 10, 20), Color(0.3, 0.3, 0.5, 0.5))
		
		draw_string(font, Vector2(panel_x + 10, y), modes[i], color)
	
	# Instructions
	draw_string(font, Vector2(panel_x + 10, panel_y + panel_height - 25), "Press 1-5 to switch", Color(0.7, 0.7, 0.7))

func _draw_properties_panel() -> void:
	var panel_width = 300
	var panel_height = 400
	var panel_x = (W - panel_width) / 2
	var panel_y = (H - panel_height) / 2
	
	# Panel background
	draw_rect(Rect2(panel_x, panel_y, panel_width, panel_height), Color(0.1, 0.1, 0.2, 0.95))
	draw_rect(Rect2(panel_x, panel_y, panel_width, panel_height), Color(0.3, 0.3, 0.5, 0.8), false)
	
	# Title
	draw_string(font, Vector2(panel_x + 10, panel_y + 25), "Level Properties", Color(1, 1, 1))
	
	# Properties list
	var properties = [
		"Name: " + level_name,
		"BG Top: " + _color_to_hex(bg_top),
		"BG Bottom: " + _color_to_hex(bg_bottom),
		"Platform Fill: " + _color_to_hex(plat_fill),
		"Start P1: " + str(int(start_p1.x)) + "," + str(int(start_p1.y)),
		"Start P2: " + str(int(start_p2.x)) + "," + str(int(start_p2.y)),
		"Start P3: " + str(int(start_p3.x)) + "," + str(int(start_p3.y)),
		"Start P4: " + str(int(start_p4.x)) + "," + str(int(start_p4.y)),
		"Save map"
	]
	
	var start_y = panel_y + 50
	var line_height = 30
	
	for i in range(properties.size()):
		var y = start_y + i * line_height
		var color = Color(0.8, 0.8, 1.0) if i == selected_property else Color(0.8, 0.8, 0.8)
		
		if property_editing and i == selected_property:
			draw_string(font, Vector2(panel_x + 10, y), properties[i] + " > " + property_value_str + "_", color)
		else:
			draw_string(font, Vector2(panel_x + 10, y), properties[i], color)
	
	# Instructions
	var instructions = [
		"UP/DOWN: Select property",
		"ENTER: Edit property",
		"ENTER on Save map: Save level",
		"ESC: Close panel"
	]
	
	var inst_y = panel_y + panel_height - 100
	for i in range(instructions.size()):
		draw_string(font, Vector2(panel_x + 10, inst_y + i * 20), instructions[i], Color(0.7, 0.7, 0.7))

func _color_to_hex(color: Color) -> String:
	return color.to_html()

func _save_level() -> void:
	print("DEBUG: _save_level() called")
	# Create platforms string
	var platform_strings = []
	for plat in platforms:
		platform_strings.append(str(int(plat[0])) + "," + str(int(plat[1])) + "," + str(int(plat[2])) + "," + str(int(plat[3])))
	
	var platforms_str = "|".join(platform_strings)
	
	# Create a new LevelDef resource
	var level_def = LevelDef.new()
	level_def.level_name = level_name
	level_def.bg_top = bg_top
	level_def.bg_bottom = bg_bottom
	level_def.bg_split = bg_split
	level_def.plat_fill = plat_fill
	level_def.plat_highlight = plat_highlight
	level_def.plat_shadow = plat_shadow
	level_def.plat_dark = plat_dark
	level_def.star_seed = 42
	level_def.star_color = Color(1, 1, 1, 0.45)
	level_def.star_count = 28
	level_def.start_p1 = start_p1
	level_def.start_p2 = start_p2
	level_def.start_p3 = start_p3
	level_def.start_p4 = start_p4
	level_def.platforms_str = platforms_str
	
	# Generate filename from level name
	var filename = level_name.to_lower().replace(" ", "_") + ".tres"
	var filepath = "res://resources/levels/" + filename
	
	print("DEBUG: Saving to: ", filepath)
	# Save the resource
	var error = ResourceSaver.save(filepath, level_def)
	if error == OK:
		print("Level saved to: ", filepath)
		# Show success message
		save_message = "Level saved to: " + filename
		save_message_time = OS.get_ticks_msec() / 1000.0
		update()
	else:
		print("Error saving level: ", error)
		# Show error message
		save_message = "Error saving level!"
		save_message_time = OS.get_ticks_msec() / 1000.0
		update()

func load_level(level_def: Resource) -> void:
	# Load level data from a LevelDef resource
	level_name = level_def.level_name
	bg_top = level_def.bg_top
	bg_bottom = level_def.bg_bottom
	bg_split = level_def.bg_split
	plat_fill = level_def.plat_fill
	plat_highlight = level_def.plat_highlight
	plat_shadow = level_def.plat_shadow
	plat_dark = level_def.plat_dark
	start_p1 = level_def.start_p1
	start_p2 = level_def.start_p2
	
	# Check if start_p3 and start_p4 exist (for backward compatibility)
	if level_def.has("start_p3"):
		start_p3 = level_def.start_p3
	else:
		start_p3 = Vector2(200, 200)  # Default value
	
	if level_def.has("start_p4"):
		start_p4 = level_def.start_p4
	else:
		start_p4 = Vector2(600, 200)  # Default value
	
	# Parse platforms
	platforms = []
	var plat_array = level_def._get_platforms()
	for plat in plat_array:
		platforms.append([plat[0], plat[1], plat[2], plat[3]])
	
	update()
