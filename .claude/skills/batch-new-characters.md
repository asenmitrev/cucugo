# Batch New Characters

Add **multiple playable characters** to cuckcuckgo in a single operation.

## When to Use

- Adding 2+ characters at once (e.g. a roster expansion, a themed pack)
- User provides character names, themes, or descriptions and expects all files + wiring created together
- You want to avoid incremental edits to `Main.gd` and `CharSelect.gd` (one big edit per file is cleaner than N small ones)

---

## Input: Character Specification

Accept a list of characters. Each character needs at minimum:

| Field | Required | Description |
|---|---|---|
| `name` | yes | Lowercase identifier (folder name, `char_name` key) |
| `display_name` | yes | HUD label (e.g. "ASEN") |
| `label_color` | yes | Color tuple for HUD name |
| `theme` | yes | Short theme description for skill invention (e.g. "pirate", "cyber-ninja", "baker") |

Optional overrides (use defaults from existing characters if omitted):

| Field | Default | Description |
|---|---|---|
| `speed` | 210.0 | Horizontal speed (px/s) |
| `jump_vel` | -530.0 | Jump velocity (px/s) |
| `body_w` | 40.0 | Hitbox width |
| `body_h` | 82.0 | Hitbox height |
| `body_offset_x` | 20.0 | Hitbox X offset |
| `body_offset_y` | 4.0 | Hitbox Y offset |
| `anim_idle` | 0.18 | Idle frame duration |
| `anim_walk` | 0.10 | Walk frame duration |
| `anim_jump` | 0.14 | Jump frame duration |
| `anim_dead` | 0.20 | Death frame duration |
| `cast_anim` | "punch" | Animation key for skill cast (use "kick" if character has a kick sheet) |

---

## Step 1 — Create Asset Directories

For each character, create the sprite folder:

```bash
mkdir -p assets/<name>/
```

If real sprite sheets are not yet available, note this clearly in the output — the `.tres` and code will still be created and the game will reference the paths. The game crashes on missing textures at `preload()` time, so **only create `.tres` files if sprite sheets exist or placeholder images are provided**.

> **Placeholder strategy:** If the user hasn't provided sprites yet, create a single 1×1 white pixel PNG as a temporary placeholder at each expected path (`<name>-idle.png`, `<name>-walk.png`, etc.) so `preload()` does not crash. Mark every placeholder clearly in the summary.

---

## Step 2 — Invent Skills (3 per character)

For each character, invent 3 thematic skills based on their `theme`. Follow the same rules as the single-character skill:

- Create `.tres` files in `resources/skills/` named `<charname>_<skill_name>.tres`
- Vary skill types: mix projectile, AoE, gravity-drop, or charge patterns
- Vary stats so skills feel distinct (different cast_time, cooldown, effect sizes)
- Leave `effect_sprite_path = ""` unless an effect sprite is provided (falls back to colored rect)

### SkillDef template

```ini
[gd_resource type="Resource" load_steps=2 format=2]

[ext_resource path="res://scripts/SkillDef.gd" type="Script" id=1]

[resource]
script = ExtResource( 1 )
display_name = "<Skill Name>"
cast_time = 0.20
cooldown = 1.0
anim_cast = 0.10
cast_anim = "punch"
effect_width = 100.0
effect_height = 60.0
effect_offset_x = 0.0
effect_offset_y = 0.0
effect_duration = 0.5
effect_color = Color( 1, 1, 1, 1 )
effect_sprite_path = ""
effect_dx = 0.0
effect_dy = 0.0
effect_rotation_speed = 0.0
effect_gravity = 0.0
```

### Skill patterns to draw from

| Pattern | effect_dx/dy | effect_gravity | effect_rotation_speed |
|---|---|---|---|
| **Straight projectile** | dx ≠ 0, dy = 0 | 0.0 | any (spin) |
| **Arc projectile** | dx ≠ 0, dy < 0 | 600–900 | 0–180 |
| **Dropped bomb** | dx = 0, dy = 0 | 900.0 | 0.0 |
| **AoE burst** | dx = 0, dy = 0 | 0.0 | high (360+) |
| **Charge/dash** | large dx, short duration | 0.0 | 0.0 |

---

## Step 3 — Create CharacterDef Resources

For each character, create `resources/<name>.tres`. Template:

```ini
[gd_resource type="Resource" load_steps=5 format=2]

[ext_resource path="res://scripts/CharacterDef.gd" type="Script" id=1]
[ext_resource path="res://resources/skills/<name>_skill1.tres" type="Resource" id=2]
[ext_resource path="res://resources/skills/<name>_skill2.tres" type="Resource" id=3]
[ext_resource path="res://resources/skills/<name>_skill3.tres" type="Resource" id=4]

[resource]
script = ExtResource( 1 )
display_name = "DISPLAY_NAME"
char_name = "<name>"
label_color = Color( r, g, b, 1 )
action_left = ""
action_right = ""
action_jump = ""
speed = 210.0
jump_vel = -530.0
body_w = 40.0
body_h = 82.0
body_offset_x = 20.0
body_offset_y = 4.0
anim_idle = 0.18
anim_walk = 0.1
anim_jump = 0.14
anim_dead = 0.2
action_skill1 = ""
action_skill2 = ""
action_skill3 = ""
skill1 = ExtResource( 2 )
skill2 = ExtResource( 3 )
skill3 = ExtResource( 4 )
```

---

## Step 4 — Wire into Main.gd (one edit block)

### 4a. Add preload consts

Add all new characters **together** after the last existing `*_DEF` var:

```gdscript
var ASEN_DEF   = preload("res://resources/asen.tres")
var DJOLEV_DEF = preload("res://resources/djolev.tres")
var SIYANA_DEF = preload("res://resources/siyana.tres")
var CRUNCH_DEF = preload("res://resources/crunch.tres")
var NEWCHAR1_DEF = preload("res://resources/newchar1.tres")
var NEWCHAR2_DEF = preload("res://resources/newchar2.tres")
# ... etc
```

### 4b. Add texture entries in `_TEX`

Add all new `_TEX` entries **together** after the last existing entry:

```gdscript
const _TEX := {
    # ... existing entries ...
    "newchar1": {
        "idle":    preload("res://assets/newchar1/newchar1-idle.png"),
        "walk":    preload("res://assets/newchar1/newchar1-walk.png"),
        "jump":    preload("res://assets/newchar1/newchar1-jump.png"),
        "punch":   preload("res://assets/newchar1/newchar1-punch.png"),
        "falling": preload("res://assets/newchar1/newchar1-falling.png"),
    },
    "newchar2": {
        "idle":    preload("res://assets/newchar2/newchar2-idle.png"),
        "walk":    preload("res://assets/newchar2/newchar2-walk.png"),
        "jump":    preload("res://assets/newchar2/newchar2-jump.png"),
        "punch":   preload("res://assets/newchar2/newchar2-punch.png"),
        "falling": preload("res://assets/newchar2/newchar2-falling.png"),
    },
}
```

> **Extra animation keys:** If a character uses a non-standard `cast_anim` (like `"kick"`), add that key to their `_TEX` entry.

---

## Step 5 — Wire into CharSelect.gd (one edit block)

### 5a. Add preload consts

```gdscript
var NEWCHAR1_DEF = preload("res://resources/newchar1.tres")
var NEWCHAR2_DEF = preload("res://resources/newchar2.tres")
```

### 5b. Add idle textures in `_IDLE_TEX`

```gdscript
const _IDLE_TEX := {
    # ... existing entries ...
    "newchar1": preload("res://assets/newchar1/newchar1-idle.png"),
    "newchar2": preload("res://assets/newchar2/newchar2-idle.png"),
}
```

### 5c. Add to `_all_defs` array

```gdscript
_all_defs = [ASEN_DEF, DJOLEV_DEF, SIYANA_DEF, CRUNCH_DEF, NEWCHAR1_DEF, NEWCHAR2_DEF]
```

---

## Execution Order

1. **Create asset directories** (`mkdir -p assets/<name>/`)
2. **Create placeholder sprites** if real ones are not yet available (see placeholder strategy above)
3. **Create 3 skill `.tres` files per character** in `resources/skills/`
4. **Create CharacterDef `.tres` per character** in `resources/`
5. **Edit `Main.gd`** — add preload consts + `_TEX` entries (one `edit` call with 2 edits)
6. **Edit `CharSelect.gd`** — add preload consts + `_IDLE_TEX` entries + `_all_defs` (one `edit` call with 3 edits)
7. **Summarize** — list all created files, skills invented, and any placeholders

---

## Batch Checklist

| Step | File / Location | Action |
|---|---|---|
| 1 | `assets/<name>/` (each) | Create directory + 5 sprite sheets (or placeholders) |
| 2 | `resources/skills/` | 3 `.tres` skill files × N characters |
| 3 | `resources/<name>.tres` (each) | CharacterDef with all stats |
| 4a | `scripts/Main.gd` (top) | Add all `NAME_DEF = preload(...)` vars |
| 4b | `scripts/Main.gd` (`_TEX`) | Add all texture entries keyed by `char_name` |
| 5a | `scripts/CharSelect.gd` (top) | Add all `NAME_DEF = preload(...)` vars |
| 5b | `scripts/CharSelect.gd` (`_IDLE_TEX`) | Add all idle texture entries |
| 5c | `scripts/CharSelect.gd` (`_all_defs`) | Append all new defs to array |

---

## Godot 3 GDScript Rules (critical)

- **Never `:= preload()`** — use `=` only
- **`export var`**, not `@export var` (Godot 3 style)
- **Declare types** on all variables: `var x: float`, `var d: Dictionary`
- **`class_name`** makes types globally available after rescan

---

## Example: Adding 2 Characters at Once

**User says:** "Add a pirate character called 'cap'n buck' and a ghost character called 'wisp'"

**You do:**

1. Create `assets/capnbuck/` and `assets/wisp/` with placeholder sprites
2. Invent skills:
   - capnbuck: `capnbuck_cannonball.tres` (arc projectile), `capnbuck_cutlass_swing.tres` (AoE burst), `capnbuck_anchor_drop.tres` (gravity bomb)
   - wisp: `wisp_phantom_bolt.tres` (straight projectile), `wisp_spectral_form.tres` (AoE burst), `wisp_chill_blast.tres` (arc projectile)
3. Create `resources/capnbuck.tres` and `resources/wisp.tres`
4. Edit `Main.gd` — add `CAPNBUCK_DEF` and `WISP_DEF` preloads + both `_TEX` entries
5. Edit `CharSelect.gd` — add both preloads + `_IDLE_TEX` entries + append to `_all_defs`
6. Summarize all 18 files created/edited
