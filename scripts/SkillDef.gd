extends Resource
class_name SkillDef

export var display_name: String = ""

export var cast_time: float = 0.20
export var cooldown: float = 1.0
export var anim_cast: float = 0.10
export var cast_anim: String = "punch"

export var effect_width: float = 100.0
export var effect_height: float = 60.0
export var effect_offset_x: float = 0.0
export var effect_offset_y: float = 0.0
export var effect_duration: float = 0.5
export var effect_color: Color = Color.white
export var effect_sprite_path: String = ""
export var effect_dx: float = 0.0
export var effect_dy: float = 0.0
export var effect_rotation_speed: float = 0.0
export var effect_gravity: float = 0.0
export var bounce_coefficient: float = 0.0
export var effect_turnaround: bool = false

export var hit_kills: bool = true
export var hit_trigger_cooldowns: bool = false

export var child_skill_path: String = ""
export var child_spawn_interval: float = 0.0
export var child_spawn_limit: int = 0
export var spawn_on_impact: bool = false

# When non-zero, set player velocity on skill activation (direction-aware for x)
export var player_launch_x: float = 0.0
export var player_launch_y: float = 0.0
export var player_launch_duration: float = 0.0

export var teleport_behind: bool = false
export var teleport_random: bool = false

export var is_passive: bool = false

# When > 0, reduce all own skill cooldowns by this fraction on activation (e.g. 0.15 = 15% off)
export var self_cd_reduce_on_cast: float = 0.0

# When > 0, passively pull all living players toward this effect's center (px/s² acceleration)
export var pull_force: float = 0.0

# When true, kill the caster if this effect expires without landing a hit
export var self_kill_if_no_hit: bool = false

export var is_transform: bool = false

# When true, also spawn a lottery-ticket trap *behind* the caster on activation.
# The ticket falls, lands, and stays until a player walks over it.
# Randomly green (halve that player's cooldowns) or red (kill that player).
export var spawn_behind_trap: bool = false

# When true, launch caster upward and activate a stomp hitbox under their feet
# while falling — kills opponent on contact (Mario stomp mechanic).
export var is_stomp: bool = false

# When > 0, caster becomes invulnerable for this many seconds on skill activation.
export var self_invulnerable_duration: float = 0.0

# When true, caster turns invisible for 4 seconds if this skill's hit kills/stuns the opponent.
export var hit_self_invisible: bool = false
