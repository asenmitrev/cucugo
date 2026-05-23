extends Reference

# All skill definitions — edit cast_time and cooldown here.
#
# cast_time: seconds after pressing the key before the hitbox activates.
# cooldown:  seconds before the skill can be used again (starts when cast completes).
# effect:    key in Effects.ALL — determines hitbox shape, size, and position.

const QUICK_SLASH = {
	"cast_time": 0.10,
	"cooldown":  0.80,
	"effect":    "FORWARD_SLASH",
}

const SLAM = {
	"cast_time": 0.35,
	"cooldown":  1.60,
	"effect":    "GROUND_SLAM",
}

const WHIRL = {
	"cast_time": 0.20,
	"cooldown":  2.00,
	"effect":    "SPIN_ZONE",
}

const ALL = {
	"QUICK_SLASH": QUICK_SLASH,
	"SLAM":        SLAM,
	"WHIRL":       WHIRL,
}
