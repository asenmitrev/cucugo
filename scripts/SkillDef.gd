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
