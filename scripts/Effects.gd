extends Reference

# All hitbox effect definitions — edit numbers here.
#
# offset_x / offset_y: pixel offset from the character's top-left corner.
# Positive offset_x follows the character's facing direction.
# Positive offset_y is downward (screen-space).
# x=0 y=0 places the hitbox at the character's top-left corner.

const FORWARD_SLASH = {
	"width":    150.0,
	"height":   30.0,
	"offset_x": 0.0,
	"offset_y": 0.0,
	"duration":  1,
	"color":    Color(1.0, 0.85, 0.25),
}

const GROUND_SLAM = {
	"width":     10.0,
	"height":    150.0,
	"offset_x":  0.0,
	"offset_y":  0.0,
	"duration":   1,
	"color":     Color(0.75, 0.30, 1.00),
}

const SPIN_ZONE = {
	"width":    110.0,
	"height":   110.0,
	"offset_x": 100.0,
	"offset_y": 100.0,
	"duration":   0.32,
	"color":     Color(0.25, 0.85, 1.00),
}

const ALL = {
	"FORWARD_SLASH": FORWARD_SLASH,
	"GROUND_SLAM":   GROUND_SLAM,
	"SPIN_ZONE":     SPIN_ZONE,
}
