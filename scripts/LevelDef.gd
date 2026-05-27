extends Resource
class_name LevelDef

export var level_name: String = "Untitled"

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
