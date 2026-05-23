# cuckcuckgo

Two-player fighting platformer in Godot 3. One-hit punch mechanic. Characters: Asen (P1, purple) and Djolev (P2, cyan).

## Project structure

```
scripts/
  Main.gd          — sole game loop (physics, input, rendering, UI)
  CharacterDef.gd  — Resource subclass; all per-character properties
resources/
  asen.tres        — Asen's CharacterDef
  djolev.tres      — Djolev's CharacterDef
assets/
  asen/            — asen-idle/walk/jump/punch.png (2×2 sprite sheets, 128×128 per frame)
  djolev/          — same layout
scenes/
  Main.tscn
```

## Adding a character

1. Drop sprites into `assets/<char_name>/`.
2. Copy `resources/asen.tres`, rename, fill in all fields.
3. Add `const NEW_DEF = preload("res://resources/<name>.tres")` to `Main.gd`.
4. Call `_init_player(2, NEW_DEF)` in `_ready`.
5. Add a win-condition branch in `_process`.

## Godot 3 GDScript rules

**Never use `:=` with `preload()`.**
`preload()` returns a generic `Resource` at parse time; Godot 3 can't infer the subtype and throws "assigned value doesn't have a set type". Use plain `=`:
```gdscript
const ASEN_DEF = preload("res://resources/asen.tres")   # correct
const ASEN_DEF := preload("res://resources/asen.tres")  # error
```

**Declare types on all variables.**
Use explicit type annotations (`var x: float`, `var p: Dictionary`) rather than relying on `:=` inference wherever the type matters for correctness or readability. Reserve `:=` for locals where the type is obvious from a constructor or literal (`var spr := Sprite.new()`).

**`class_name` classes are globally available** after the project re-scans — no import needed. If a new `class_name` script isn't recognised, close and reopen the project to force a rescan.

**`export var` syntax for Resource properties** (Godot 3 style — no `@export`):
```gdscript
export var speed: float = 210.0
```

**`match` with `return` inside cases is valid** in Godot 3. No fallthrough.

## World constants (Main.gd, not per-character)

| Constant | Value | Meaning |
|----------|-------|---------|
| `W / H` | 800 / 450 | viewport size |
| `GRAV` | 900 | gravity (px/s²) |
| `SW / SH` | 90 / 90 | sprite display size |
| `PLATS` | array of `[x,y,w,h]` | platform rects |

Per-character values (speed, jump, punch timing, hitbox, anim speeds) all live in `CharacterDef`.
