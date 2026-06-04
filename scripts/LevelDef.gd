extends Resource
class_name LevelDef

export var level_name: String = "Untitled"

# Level size properties
export var level_width: float = 800.0
export var level_height: float = 450.0
export var scale_to_fit: bool = true

# Background
export var bg_top: Color = Color(0.07, 0.08, 0.16)
export var bg_bottom: Color = Color(0.10, 0.12, 0.22)
export var bg_split: float = 0.6

# Platform rendering
export var plat_fill: Color = Color(0.18, 0.12, 0.32)
export var plat_highlight: Color = Color(0.42, 0.35, 0.55)
export var plat_shadow: Color = Color(0.30, 0.22, 0.44)
export var plat_dark: Color = Color(0, 0, 0, 0.22)

# Stars / ambient particles
export var star_seed: int = 42
export var star_color: Color = Color(1, 1, 1, 0.45)
export var star_count: int = 28

# Spawn positions
export var start_p1: Vector2 = Vector2(140, 300)
export var start_p2: Vector2 = Vector2(570, 300)
export var start_p3: Vector2 = Vector2(200, 200)
export var start_p4: Vector2 = Vector2(600, 200)

# Platforms: "x,y,w,h|x,y,w,h|..."
export var platforms_str: String = ""

func _get_platforms() -> Array:
	var out: Array = []
	if platforms_str == "":
		return out
	var entries: Array = platforms_str.split("|")
	for entry in entries:
		var parts: Array = entry.split(",")
		if parts.size() == 4:
			out.append([float(parts[0]), float(parts[1]), float(parts[2]), float(parts[3])])
	return out

# Calculate scaling factor to fit level on screen
func get_scaling_factor(screen_width: float, screen_height: float) -> float:
	if not scale_to_fit:
		return 1.0
	
	var width_scale = screen_width / level_width
	var height_scale = screen_height / level_height
	
	# Use the smaller scale to ensure level fits entirely on screen
	return min(width_scale, height_scale)

# Get screen position from level coordinates
func level_to_screen(position: Vector2, scaling_factor: float) -> Vector2:
	if not scale_to_fit:
		return position
	
	# Center the level on screen
	var offset_x = (800.0 - level_width * scaling_factor) / 2.0
	var offset_y = (450.0 - level_height * scaling_factor) / 2.0
	
	return Vector2(
		position.x * scaling_factor + offset_x,
		position.y * scaling_factor + offset_y
	)

# Get screen size from level size
func level_to_screen_size(size: Vector2, scaling_factor: float) -> Vector2:
	if not scale_to_fit:
		return size
	
	return size * scaling_factor

# Get level coordinates from screen position
func screen_to_level(screen_pos: Vector2, scaling_factor: float) -> Vector2:
	if not scale_to_fit:
		return screen_pos
	
	# Center the level on screen
	var offset_x = (800.0 - level_width * scaling_factor) / 2.0
	var offset_y = (450.0 - level_height * scaling_factor) / 2.0
	
	return Vector2(
		(screen_pos.x - offset_x) / scaling_factor,
		(screen_pos.y - offset_y) / scaling_factor
	)
