# Create a New Character

This skill explains how to add a new playable character to cuckcuckgo — a two-player fighting platformer built in Godot 3 with GDScript.

## Overview

Characters are defined by **three things**:
1. **Sprite sheets** — 2×2 PNG atlases for each animation state
2. **A `CharacterDef` resource** (`.tres`) — all stats, hitbox, colors, and skill assignments
3. **Three `SkillDef` resources** — projectile/area-of-effect skills (invent 3 random thematic skills unless the user provides specifics)

The game loop is a single `Main.gd` script. The character-select screen is `CharSelect.gd`. Both must be updated — no scene nodes per character, everything is data-driven.

---

## Step 1 — Sprite Sheets

Drop five 2×2 PNG sprite sheets into `assets/<char_name>/`:

```
assets/<char_name>/
  <name>-idle.png     # standing still (frame 0 = center, frame 1 = variant)
  <name>-walk.png     # walking cycle
  <name>-jump.png     # jumping pose
  <name>-punch.png    # casting/punch pose (used during skill cast_time)
  <name>-falling.png  # death/falling animation (played when character is killed)
```

**Rules:**
- Each frame is **128×128 px** (scaled to 90×90 at runtime)
- 2 columns × 2 rows = 4 frames per sheet
- Frames cycle left-to-right, top-to-bottom
- The `-falling.png` sheet is **required** — it replaces the idle animation when the character dies

---

## Step 2 — Skill Resources

Skills live in `resources/skills/`. Each is a `SkillDef` resource (see `scripts/SkillDef.gd`).

### Default behavior: 3 random skills

**Unless the user explicitly provides skill details** (projectile description, asset paths, and an explanation for each skill), you **must invent 3 random skills** for the new character. Make them thematic to the character's personality, name, or visual design. For each skill:

1. **Create a `.tres` file** in `resources/skills/` named `<charname>_<skill_name>.tres`
2. **Choose a skill type** from the patterns below (mix and match — e.g. one projectile, one AoE, one gravity drop)
3. **Pick fitting stats** — vary cast_time, cooldown, and effect properties so skills feel distinct
4. **Provide an effect sprite** in `assets/<char_name>/` (or leave `effect_sprite_path = ""` to use the colored-rect fallback)

### Skill patterns to draw from

| Pattern | effect_dx/dy | effect_gravity | effect_rotation_speed | Example |
|---|---|---|---|---|
| **Straight projectile** | dx ≠ 0, dy = 0 | 0.0 | any (spin effect) | asen_quick_slash (shuriken) |
| **Arc projectile** | dx ≠ 0, dy < 0 | 600–900 | 0–180 | crunch_cupcake_toss |
| **Dropped bomb** | dx = 0, dy = 0 | 900.0 | 0.0 | siyana_stove_toss |
| **AoE burst** | dx = 0, dy = 0 | 0.0 | high (360+) | djolev_shockwave |
| **Charge/dash** | large dx, short duration | 0.0 | 0.0 | djolev_dash_strike |

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

Near the top (after `CRUNCH_DEF`):

```gdscript
var ASEN_DEF   = preload("res://resources/asen.tres")
var DJOLEV_DEF = preload("res://resources/djolev.tres")
var SIYANA_DEF = preload("res://resources/siyana.tres")
var CRUNCH_DEF = preload("res://resources/crunch.tres")
var NEWCHAR_DEF = preload("res://resources/newchar.tres")  # ADD THIS
```

> **Godot 3 rule:** Never use `:=` with `preload()`. Use plain `=` only.

### 4b. Register textures in `_TEX`

Add a new entry to the `_TEX` dictionary (the key must match `char_name` from the `.tres`):

```gdscript
const _TEX := {
    "asen":   { ... },
    "djolev": { ... },
    "siyana": { ... },
    "crunch": { ... },
    "newchar": {                                        # ADD THIS BLOCK
        "idle":    preload("res://assets/newchar/newchar-idle.png"),
        "walk":    preload("res://assets/newchar/newchar-walk.png"),
        "jump":    preload("res://assets/newchar/newchar-jump.png"),
        "punch":   preload("res://assets/newchar/newchar-punch.png"),
        "falling": preload("res://assets/newchar/newchar-falling.png"),
    },
}
```

**No jump sprite?** Map the `"jump"` key to any other sheet (e.g. `preload("res://assets/newchar/newchar-punch.png")`). The game uses whatever texture is at that key when the character is airborne.

**Extra animation keys** (e.g. `"kick"`, `"special"`) are supported. Add them to the `_TEX` dict and reference them via `cast_anim` in SkillDef resources. Siyana and Crunch both use `"kick"` this way.

### 4c. Register in CharSelect (`scripts/CharSelect.gd`)

The character-select screen maintains its own independent copies of character data. Add the new character to **all three** locations:

**i. Preload const** (near top, alongside other `*_DEF` vars):
```gdscript
var ASEN_DEF   = preload("res://resources/asen.tres")
var DJOLEV_DEF = preload("res://resources/djolev.tres")
var SIYANA_DEF = preload("res://resources/siyana.tres")
var CRUNCH_DEF = preload("res://resources/crunch.tres")
var NEWCHAR_DEF = preload("res://resources/newchar.tres")  # ADD THIS
```

**ii. Idle texture for portrait** (in `_IDLE_TEX` dict):
```gdscript
const _IDLE_TEX := {
    "asen":   preload("res://assets/asen/asen-idle.png"),
    "djolev": preload("res://assets/djolev/djolev-idle.png"),
    "siyana": preload("res://assets/siyana/siyana-idle.png"),
    "crunch": preload("res://assets/crunch/crunch-idle.png"),
    "newchar": preload("res://assets/newchar/newchar-idle.png"),  # ADD THIS
}
```

**iii. Character list** (in `_all_defs` array inside `_ready()`):
```gdscript
_all_defs = [ASEN_DEF, DJOLEV_DEF, SIYANA_DEF, CRUNCH_DEF, NEWCHAR_DEF]
```

> Without all three edits, the character will either crash on the select screen or be unselectable.

### 4d. Use the character in-game

**Option A — via CharSelect** (recommended)  
Once registered in Step 4c, the character is selectable. CharSelect passes the chosen def to `Main.gd` automatically.

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
| 1 | `assets/<name>/` | Drop 5 sprite sheets (`-idle`, `-walk`, `-jump`, `-punch`, `-falling`) + effect sprites for each skill |
| 2 | `resources/skills/` | Create 3 `.tres` skill files (invent 3 random thematic skills unless user provides specifics) |
| 3 | `resources/<name>.tres` | Create CharacterDef with all stats |
| 4a | `scripts/Main.gd` (top) | Add `var NAME_DEF = preload(...)` |
| 4b | `scripts/Main.gd` (`_TEX`) | Add texture entry keyed by `char_name` |
| 4c-i | `scripts/CharSelect.gd` (top) | Add `var NAME_DEF = preload(...)` |
| 4c-ii | `scripts/CharSelect.gd` (`_IDLE_TEX`) | Add idle texture for portrait |
| 4c-iii | `scripts/CharSelect.gd` (`_all_defs`) | Add `NAME_DEF` to array |

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
