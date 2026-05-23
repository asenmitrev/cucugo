extends Resource
class_name CharacterDef

export var display_name: String = ""
export var char_name: String = ""
export var label_color: Color = Color.white
export var start_pos: Vector2 = Vector2.ZERO
export var facing_right: bool = true

export var action_left: String = ""
export var action_right: String = ""
export var action_jump: String = ""
export var action_punch: String = ""

export var speed: float = 210.0
export var jump_vel: float = -530.0

export var punch_dur: float = 0.36
export var punch_rx: float = 118.0
export var punch_ry: float = 65.0
export var hit_t0: float = 0.07
export var hit_t1: float = 0.25

export var anim_idle: float = 0.18
export var anim_walk: float = 0.10
export var anim_jump: float = 0.14
export var anim_punch: float = 0.09
export var anim_dead: float = 0.20
