extends Resource
class_name CharacterDef

export var display_name: String = ""
export var char_name: String = ""
export var label_color: Color = Color.white

export var speed: float = 210.0
export var jump_vel: float = -530.0
export var walk_cd_rate: float = 1.0

# Body hitbox rect within the 90×90 sprite cell
export var body_w: float = 90.0
export var body_h: float = 90.0
export var body_offset_x: float = 0.0
export var body_offset_y: float = 0.0

export var anim_idle: float = 0.18
export var anim_walk: float = 0.10
export var anim_jump: float = 0.14
export var anim_dead: float = 0.20
export var anim_getting_up: float = 0.12

export var lives: int = 1

export(Resource) var skill1 = null
export(Resource) var skill2 = null
export(Resource) var skill3 = null
