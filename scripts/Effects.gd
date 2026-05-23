extends Reference

# All hitbox effect definitions — edit numbers here.
#
# offset_x / offset_y: pixel offset from the character's top-left corner.
# Positive offset_x follows the character's facing direction.
# Positive offset_y is downward (screen-space).
# x=0 y=0 places the hitbox at the character's top-left corner.

const FORWARD_SLASH = {
	"width":    80.0,
	"height":   60.0,
	"offset_x": 50.0,
	"offset_y": -5.0,
	"duration":  0.20,
	"color":    Color(1.0, 0.85, 0.25),
}

const GROUND_SLAM = {
	"width":    130.0,
	"height":    28.0,
	"offset_x":  10.0,
	"offset_y":  72.0,
	"duration":   0.28,
	"color":     Color(0.75, 0.30, 1.00),
}

const SPIN_ZONE = {
	"width":    110.0,
	"height":   110.0,
	"offset_x": -10.0,
	"offset_y": -10.0,
	"duration":   0.32,
	"color":     Color(0.25, 0.85, 1.00),
}

const ALL = {
	"FORWARD_SLASH": FORWARD_SLASH,
	"GROUND_SLAM":   GROUND_SLAM,
	"SPIN_ZONE":     SPIN_ZONE,
}
