extends Node
class_name LevelGenerator

# Configuration
const LEVEL_WIDTH: float = 1600.0
const LEVEL_HEIGHT: float = 900.0
const NUM_LEVELS: int = 10

# Platform generation parameters
const MIN_PLATFORMS: int = 8
const MAX_PLATFORMS: int = 15
const MIN_PLATFORM_WIDTH: float = 80.0
const MAX_PLATFORM_WIDTH: float = 300.0
const PLATFORM_HEIGHT: float = 14.0
const MIN_PLATFORM_Y: float = 100.0
const MAX_PLATFORM_Y: float = 700.0
const GROUND_PLATFORM_Y: float = 850.0  # Near bottom of level

# Color palettes for different level themes
const COLOR_PALETTES: Array = [
	# Forest theme
	{
		"name": "Forest",
		"bg_top": Color(0.05, 0.12, 0.08),
		"bg_bottom": Color(0.10, 0.20, 0.15),
		"plat_fill": Color(0.25, 0.35, 0.20),
		"plat_highlight": Color(0.45, 0.65, 0.35),
		"plat_shadow": Color(0.15, 0.25, 0.12),
		"plat_dark": Color(0, 0, 0, 0.22),
		"star_color": Color(0.8, 1.0, 0.7, 0.5)
	},
	# Desert theme
	{
		"name": "Desert",
		"bg_top": Color(0.95, 0.85, 0.65),
		"bg_bottom": Color(0.85, 0.70, 0.50),
		"plat_fill": Color(0.75, 0.60, 0.40),
		"plat_highlight": Color(1.0, 0.90, 0.70),
		"plat_shadow": Color(0.65, 0.50, 0.30),
		"plat_dark": Color(0, 0, 0, 0.22),
		"star_color": Color(1.0, 0.95, 0.7, 0.5)
	},
	# Ocean theme
	{
		"name": "Ocean",
		"bg_top": Color(0.05, 0.10, 0.20),
		"bg_bottom": Color(0.10, 0.20, 0.35),
		"plat_fill": Color(0.20, 0.35, 0.50),
		"plat_highlight": Color(0.40, 0.65, 0.85),
		"plat_shadow": Color(0.15, 0.25, 0.40),
		"plat_dark": Color(0, 0, 0, 0.22),
		"star_color": Color(0.7, 0.9, 1.0, 0.5)
	},
	# Volcano theme
	{
		"name": "Volcano",
		"bg_top": Color(0.15, 0.05, 0.05),
		"bg_bottom": Color(0.25, 0.10, 0.08),
		"plat_fill": Color(0.40, 0.15, 0.10),
		"plat_highlight": Color(0.85, 0.35, 0.20),
		"plat_shadow": Color(0.30, 0.10, 0.05),
		"plat_dark": Color(0, 0, 0, 0.22),
		"star_color": Color(1.0, 0.5, 0.3, 0.5)
	},
	# Space theme
	{
		"name": "Space",
		"bg_top": Color(0.02, 0.02, 0.08),
		"bg_bottom": Color(0.05, 0.05, 0.15),
		"plat_fill": Color(0.20, 0.20, 0.35),
		"plat_highlight": Color(0.45, 0.45, 0.75),
		"plat_shadow": Color(0.15, 0.15, 0.25),
		"plat_dark": Color(0, 0, 0, 0.22),
		"star_color": Color(0.9, 0.9, 1.0, 0.7)
	}
]

func _ready():
	generate_levels()

func generate_levels():
	print("Generating random 1600x900 levels...")
	
	for i in range(NUM_LEVELS):
		var level_name = "random_%02d" % (i + 1)
		var level = generate_single_level(level_name, i)
		save_level(level, level_name)
		print("Generated: " + level_name)
	
	print("Done! Generated %d levels." % NUM_LEVELS)
	
	# Auto-quit after generation
	get_tree().quit()

func generate_single_level(name: String, seed_offset: int) -> Resource:
	var rng = RandomNumberGenerator.new()
	rng.seed = hash(name) + seed_offset
	
	# Create level resource
	var level = LevelDef.new()
	level.level_name = name
	level.level_width = LEVEL_WIDTH
	level.level_height = LEVEL_HEIGHT
	level.scale_to_fit = true
	
	# Select random color palette
	var palette = COLOR_PALETTES[rng.randi() % COLOR_PALETTES.size()]
	level.bg_top = palette["bg_top"]
	level.bg_bottom = palette["bg_bottom"]
	level.bg_split = rng.randf_range(0.4, 0.7)
	level.plat_fill = palette["plat_fill"]
	level.plat_highlight = palette["plat_highlight"]
	level.plat_shadow = palette["plat_shadow"]
	level.plat_dark = palette["plat_dark"]
	level.star_color = palette["star_color"]
	level.star_seed = rng.randi() % 1000
	level.star_count = rng.randi_range(20, 40)
	
	# Generate start positions (spread out in the level)
	level.start_p1 = Vector2(
		rng.randf_range(200.0, 500.0),
		rng.randf_range(200.0, 400.0)
	)
	level.start_p2 = Vector2(
		rng.randf_range(LEVEL_WIDTH - 500.0, LEVEL_WIDTH - 200.0),
		rng.randf_range(200.0, 400.0)
	)
	level.start_p3 = Vector2(
		rng.randf_range(300.0, 600.0),
		rng.randf_range(LEVEL_HEIGHT - 400.0, LEVEL_HEIGHT - 200.0)
	)
	level.start_p4 = Vector2(
		rng.randf_range(LEVEL_WIDTH - 600.0, LEVEL_WIDTH - 300.0),
		rng.randf_range(LEVEL_HEIGHT - 400.0, LEVEL_HEIGHT - 200.0)
	)
	
	# Generate platforms
	var platforms = []
	var num_platforms = rng.randi_range(MIN_PLATFORMS, MAX_PLATFORMS)
	
	# Always add ground platform
	platforms.append([0.0, GROUND_PLATFORM_Y, LEVEL_WIDTH, PLATFORM_HEIGHT])
	
	# Generate floating platforms
	for j in range(num_platforms):
		var platform = generate_platform(rng, platforms)
		if platform:
			platforms.append(platform)
	
	# Convert platforms to string format
	var platform_strings = []
	for platform in platforms:
		platform_strings.append("%.1f,%.1f,%.1f,%.1f" % [platform[0], platform[1], platform[2], platform[3]])
	
	level.platforms_str = "|".join(platform_strings)
	
	return level

func generate_platform(rng: RandomNumberGenerator, existing_platforms: Array) -> Array:
	var max_attempts = 50
	for attempt in range(max_attempts):
		var width = rng.randf_range(MIN_PLATFORM_WIDTH, MAX_PLATFORM_WIDTH)
		var x = rng.randf_range(50.0, LEVEL_WIDTH - width - 50.0)
		var y = rng.randf_range(MIN_PLATFORM_Y, MAX_PLATFORM_Y)
		
		# Check if platform overlaps with existing platforms
		var overlaps = false
		for existing in existing_platforms:
			var existing_x = existing[0]
			var existing_y = existing[1]
			var existing_w = existing[2]
			var existing_h = existing[3]
			
			# Check for overlap with margin
			var margin = 40.0
			if (x < existing_x + existing_w + margin and
				x + width > existing_x - margin and
				y < existing_y + existing_h + margin and
				y + PLATFORM_HEIGHT > existing_y - margin):
				overlaps = true
				break
		
		if not overlaps:
			return [x, y, width, PLATFORM_HEIGHT]
	
	# Couldn't find non-overlapping position, return null
	return []

func save_level(level: Resource, name: String):
	var dir = Directory.new()
	if not dir.dir_exists("res://resources/levels/"):
		dir.make_dir_recursive("res://resources/levels/")
	
	var file_path = "res://resources/levels/%s.tres" % name
	var error = ResourceSaver.save(file_path, level)
	if error != OK:
		print("Error saving level %s: %d" % [name, error])
	else:
		print("Saved: %s" % file_path)

# Run this function from the editor or call generate_levels() in _ready()
func run_generation():
	generate_levels()