# Create a New Character

This skill explains how to add a new playable character to cuckcuckgo — a two-player fighting platformer built in Godot 3 with GDScript.

## Overview

Characters are defined by **three things**:
1. **Sprite sheets** — 2×2 PNG atlases for each animation state
2. **A `CharacterDef` resource** (`.tres`) — all stats, hitbox, colors, and skill assignments
3. **Optional `SkillDef` resources** — up to 3 projectile/area-of-effect skills

The game loop is a single `Main.gd` script. No scene nodes per character — everything is data-driven.

---

## Step 1 — Sprite Sheets

Drop four 2×2 PNG sprite sheets into `assets/<char_name>/`:

```
assets/<char_name>/
  <name>-idle.png    # standing still (frame 0 = center, frame 1 = variant)
  <name>-walk.png    # walking cycle
  <name>-jump.png    # jumping pose
  <name>-punch.png   # casting/punch pose (used during skill cast_time)
```

**Rules:**
- Each frame is **128×128 px** (scaled to 90×90 at runtime)
- 2 columns × 2 rows = 4 frames per sheet
- Frames cycle left-to-right, top-to-bottom

---

## Step 2 — Skill Resources (Optional)

Skills live in `resources/skills/`. Each is a `SkillDef` resource (see `scripts/SkillDef.gd`).

### SkillDef fields

| Field | Type | Default | Description |
|---|---|---|---|
| `display_name` | String | `""` | Name shown in UI |
| `cast_time` | float | `0.20` | Seconds the player is locked in cast pose before effect fires |
| `cooldown` | float | `1.0` | Seconds between casts |
| `anim_cast` | float | `0.10` | Frame duration during cast animation |
| `cast_anim` | String | `"punch"` | Sprite sheet key used while casting (`"idle"`, `"walk"`, `"jump"`, `"punch"`) |
| `effect_width` | float | `100.0` | Hitbox width of the effect |
| `effect_height` | float | `60.0` | Hitbox height of the effect |
| `effect_offset_x` | float | `0.0` | Hitbox X offset from character center (positive = in facing direction) |
| `effect_offset_y` | float | `0.0` | Hitbox Y offset from character top (positive = down) |
| `effect_duration` | float | `0.5` | How long the effect persists before despawning |
| `effect_color` | Color | `white` | Color for fallback rendering (no sprite) |
| `effect_sprite_path` | String | `""` | Path to a single-frame sprite PNG (leave `""` for colored rect fallback) |
| `effect_dx` | float | `0.0` | Horizontal velocity of effect (positive = right) |
| `effect_dy` | float | `0.0` | Vertical velocity of effect (positive = down) |
| `effect_rotation_speed` | float | `0.0` | Degrees per second the effect sprite rotates |
| `effect_gravity` | float | `0.0` | Gravity applied to effect (0 = no gravity, 900 = world gravity) |

### Example: Projectile skill

```ini
[gd_resource type="Resource" load_steps=2 format=2]

[ext_resource path="res://scripts/SkillDef.gd" type="Script" id=1]

[resource]
script = ExtResource( 1 )
display_name = "Shuriken"
cast_time = 0.1
cooldown = 0.8
anim_cast = 0.08
cast_anim = "punch"
effect_width = 20.0
effect_height = 20.0
effect_offset_x = 60.0
effect_offset_y = 20.0
effect_duration = 1.0
effect_color = Color( 1, 0.85, 0.25, 1 )
effect_sprite_path = "res://assets/<char_name>/shuriken.png"
effect_dx = 420.0
effect_dy = 0.0
effect_rotation_speed = 540.0
effect_gravity = 0.0
```

### Example: Dropped projectile (gravity)

```ini
[gd_resource type="Resource" load_steps=2 format=2]

[ext_resource path="res://scripts/SkillDef.gd" type="Script" id=1]

[resource]
script = ExtResource( 1 )
display_name = "Rice"
cast_time = 0.35
cooldown = 2.0
anim_cast = 0.2
cast_anim = "punch"
effect_width = 25.0
effect_height = 25.0
effect_offset_x = -25.0
effect_offset_y = 64.0
effect_duration = 20.0
effect_color = Color( 0.75, 0.3, 1, 1 )
effect_sprite_path = "res://assets/<char_name>/rice-bowl.png"
effect_dx = 0.0
effect_dy = 0.0
effect_rotation_speed = 0.0
effect_gravity = 900.0
```

---

## Step 3 — CharacterDef Resource

Create `resources/<char_name>.tres`. Template:

```ini
[gd_resource type="Resource" load_steps=5 format=2]

[ext_resource path="res://scripts/CharacterDef.gd" type="Script" id=1]
[ext_resource path="res://resources/skills/<name>_skill1.tres" type="Resource" id=2]
[ext_resource path="res://resources/skills/<name>_skill2.tres" type="Resource" id=3]
[ext_resource path="res://resources/skills/<name>_skill3.tres" type="Resource" id=4]

[resource]
script = ExtResource( 1 )
display_name = "NAME"              # Shown in HUD
char_name = "<name>"               # Matches sprite folder and _TEX key
label_color = Color( 1, 1, 1, 1 )  # HUD name color
start_pos = Vector2( 0, 0 )        # Ignored — Main.gd uses P1_START/P2_START
facing_right = true                # Initial facing direction
action_left = ""                   # Auto-assigned to pX_left if empty
action_right = ""                  # Auto-assigned to pX_right if empty
action_jump = ""                   # Auto-assigned to pX_jump if empty
speed = 210.0                      # px/s horizontal
jump_vel = -530.0                  # px/s initial upward velocity
body_w = 40.0                      # Hitbox width within 90×90 sprite cell
body_h = 82.0                      # Hitbox height
body_offset_x = 20.0               # Hitbox X from sprite top-left
body_offset_y = 4.0                # Hitbox Y from sprite top-left
anim_idle = 0.18                   # Seconds per frame in idle animation
anim_walk = 0.1                    # Seconds per frame in walk animation
anim_jump = 0.14                   # Seconds per frame in jump animation
anim_dead = 0.2                    # Seconds per frame in death animation
action_skill1 = ""                 # Auto-assigned to pX_skill1 if empty
action_skill2 = ""                 # Auto-assigned to pX_skill2 if empty
action_skill3 = ""                 # Auto-assigned to pX_skill3 if empty
skill1 = ExtResource( 2 )          # Reference to SkillDef .tres (or null)
skill2 = ExtResource( 3 )          # Reference to SkillDef .tres (or null)
skill3 = ExtResource( 4 )          # Reference to SkillDef .tres (or null)
```

### Key CharacterDef fields (from `scripts/CharacterDef.gd`)

| Field | Type | Description |
|---|---|---|
| `display_name` | String | Name displayed above player in HUD |
| `char_name` | String | Lowercase identifier — **must match** the key in `Main.gd`'s `_TEX` dict |
| `label_color` | Color | Color of the player's name label |
| `action_left/right/jump` | String | Input action names (auto-assigned if left `""`) |
| `speed` | float | Horizontal movement speed (px/s) |
| `jump_vel` | float | Jump initial velocity (negative = upward, px/s) |
| `body_w/body_h` | float | Collision hitbox dimensions within the 90×90 sprite cell |
| `body_offset_x/y` | float | Hitbox offset from top-left corner of sprite cell |
| `anim_idle/walk/jump/dead` | float | Duration per animation frame for each state |
| `action_skill1/2/3` | String | Input action names for skills (auto-assigned if left `""`) |
| `skill1/2/3` | Resource | `SkillDef` resource or `null` |

---

## Step 4 — Wire into `Main.gd`

Two edits in `scripts/Main.gd`:

### 4a. Add preload const

Near the top (after `DJOLEV_DEF`):

```gdscript
var ASEN_DEF   = preload("res://resources/asen.tres")
var DJOLEV_DEF = preload("res://resources/djolev.tres")
var NEWCHAR_DEF = preload("res://resources/newchar.tres")  # ADD THIS
```

> **Godot 3 rule:** Never use `:=` with `preload()`. Use plain `=` only.

### 4b. Register textures in `_TEX`

Add a new entry to the `_TEX` dictionary (the key must match `char_name` from the `.tres`):

```gdscript
const _TEX := {
    "asen": { ... },
    "djolev": { ... },
    "newchar": {                                        # ADD THIS BLOCK
        "idle":  preload("res://assets/newchar/newchar-idle.png"),
        "walk":  preload("res://assets/newchar/newchar-walk.png"),
        "jump":  preload("res://assets/newchar/newchar-jump.png"),
        "punch": preload("res://assets/newchar/newchar-punch.png"),
    },
}
```

### 4c. Use the character

The character can be played two ways:

**Option A — CharSelect scene** (recommended)  
Set `p1_def` or `p2_def` before `Main.tscn` loads, and `_ready()` picks it up:

```gdscript
# In CharSelect.gd or similar:
get_tree().get_root().get_node("Main").p1_def = NEWCHAR_DEF
get_tree().change_scene("res://scenes/Main.tscn")
```

**Option B — Hardcode in `_ready()`**  
Replace the default in `Main._ready()`:

```gdscript
func _ready() -> void:
    # ...
    var _p1: CharacterDef = p1_def if p1_def != null else NEWCHAR_DEF
    _init_player(0, _p1)
```

---

## Complete Checklist

| Step | File / Location | Action |
|---|---|---|
| 1 | `assets/<name>/` | Drop 4 sprite sheets (`-idle`, `-walk`, `-jump`, `-punch`) |
| 2 | `resources/skills/` | Create `.tres` skill files (0–3, optional) |
| 3 | `resources/<name>.tres` | Create CharacterDef with all stats |
| 4a | `scripts/Main.gd` (top) | Add `var NAME_DEF = preload(...)` |
| 4b | `scripts/Main.gd` (`_TEX`) | Add texture entry keyed by `char_name` |
| 4c | `scripts/Main.gd` or CharSelect | Pass `NAME_DEF` to `_init_player()` |

## Godot 3 GDScript Rules (critical)

- **Never `:= preload()`** — use `=` only
- **`export var`**, not `@export var` (Godot 3 style)
- **`class_name`** makes types globally available after rescan
- **Declare types** on all variables: `var x: float`, `var d: Dictionary`
- **`match` with `return`** inside cases is valid (no fallthrough)

## World Constants (for reference)

| Constant | Value | Meaning |
|---|---|---|
| `W / H` | 800 / 450 | Viewport size |
| `GRAV` | 900 | Gravity (px/s²) |
| `SW / SH` | 90 / 90 | Sprite display size (sprites scaled from 128→90) |
| `P1_START` | (140, 300) | Player 1 spawn position |
| `P2_START` | (570, 300) | Player 2 spawn position |
| `PLATS` | array of `[x, y, w, h]` | Platform rectangles |

## How Skills Work at Runtime

1. Player presses skill button → enters `casting_skill` state (locked in `cast_anim` pose)
2. After `cast_time` seconds → `_activate_skill()` spawns an effect at the calculated hitbox position
3. Effect moves each frame: `dx/dy + gravity`, with optional rotation
4. If effect hitbox intersects opponent's body hitbox → opponent dies (knocked upward + outward)
5. Effect despawns after `effect_duration` seconds
6. Skill enters `cooldown` — button disabled until timer expires
