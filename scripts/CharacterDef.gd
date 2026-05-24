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

export var speed: float = 210.0
export var jump_vel: float = -530.0

# Body hitbox rect within the 90×90 sprite cell
export var body_w: float = 90.0
export var body_h: float = 90.0
export var body_offset_x: float = 0.0
export var body_offset_y: float = 0.0

export var anim_idle: float = 0.18
export var anim_walk: float = 0.10
export var anim_jump: float = 0.14
export var anim_dead: float = 0.20

export var action_skill1: String = ""
export var action_skill2: String = ""
export var action_skill3: String = ""

export(Resource) var skill1 = null
export(Resource) var skill2 = null
export(Resource) var skill3 = null
