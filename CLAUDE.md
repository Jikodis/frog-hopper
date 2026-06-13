# frog-hopper — project guide for AI build partners

This file grounds any AI session working on this project. Read it first.

## What this is

**frog-hopper** is a 2D game built by a dad and his son as a learn-to-make-games
project. The dad guides his son; the AI is a **full-capability build partner** —
write clean, well-commented code that's easy to *teach from*, and explain the
"why," not just the "what."

- **Engine:** Godot **4.6** (installed at `~/Downloads/Godot.app`)
- **Language:** GDScript (not C#) — easiest to learn, matches all the tutorials
- **Renderer:** GL Compatibility (already set; this is what Web export wants)
- **Ship target:** the Web (HTML5/WebAssembly) — the finished game runs in a
  browser on the son's website

## The game in one line

A frog-themed game with two halves: **side-scrolling platformer levels** (Mario-style
run + big floaty jumps) and a **top-down town hub** (think *Zelda: A Link to the Past*
/ early *Final Fantasy*) where you spend coins earned in levels at shops and decorate
your house. See `docs/vision.md` for the full picture and the 7-milestone roadmap.

## How we work

- **One milestone at a time, and it stays playable.** Never build a big system
  before there's something to play. This is the rule that keeps the project from
  stalling. The current milestone and live task list are in `TASKS.md`.
- **Build order ≠ play order.** We build the platformer level first because it's the
  fastest path to fun and because shops need coins (which come from levels). The
  finished game still *opens* in the bedroom with dialogue → town → levels.
- **Specs before code.** Each milestone gets a short spec in `docs/specs/` before we
  write a plan or any code.
- **Placeholder art first.** Ship the mechanic with simple colored shapes, swap in
  real sprites later.

## Where things live

| Path | What |
|---|---|
| `docs/vision.md` | The full game vision + 7-milestone roadmap |
| `docs/specs/` | One spec per milestone (what we're building + how) |
| `TASKS.md` | Live task list + roadmap status (update as we go) |
| `scenes/` | Godot scene files (`.tscn`) |
| `scripts/` | GDScript files (`.gd`) |
| `assets/` | Art and audio (`sprites/`, `audio/`) |

## Conventions / patterns (living — add to this as we learn)

- **File names:** `snake_case` (`player.tscn`, `player.gd`, `level_1.tscn`).
- **In code:** `snake_case` for variables/functions, `PascalCase` for node names and
  `class_name`, `CONSTANT_CASE` for constants.
- **Feel values are tunable constants** at the top of a script with a comment each
  (e.g. `RUN_SPEED`, `JUMP_VELOCITY`, `GRAVITY`). Changing the feel = changing one
  number. Great teaching moments live here.
- **Input through named actions**, never hardcoded keys: `move_left`, `move_right`,
  `jump` (defined in Project Settings → Input Map). Keeps keyboard + web tidy.
- **Shared state lives in an autoload singleton** (`Game`) — score now, money /
  inventory / furniture / story flags later. This is the backbone that survives
  scene changes.
- **Nodes talk via signals**, not by reaching across the tree. A collected fly
  *emits* a signal; the HUD/Game listens.
- **Keep scenes small and single-purpose.** If one scene/script is doing two jobs,
  split it.
- **Web-safe always:** stay on GL Compatibility; the Web export preset ships with
  **threads off** so the game runs on any static host with no special server headers.

## Running the game

Open this folder in Godot (`~/Downloads/Godot.app`), press **F5** to play. The main
scene is set in Project Settings → Application → Run.

## Verifying changes

Game behavior is mostly verified by **playing it** — there's no good automated test
for "does the jump feel right." Each spec ends with a manual playtest checklist; run
through it and confirm before calling a milestone done.

## Verified Godot 4.6 references

The 2D platformer movement pattern (confirmed against the 4.6 docs):

```gdscript
extends CharacterBody2D

var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

func _physics_process(delta):
    if not is_on_floor():
        velocity.y += gravity * delta
    if Input.is_action_just_pressed("jump") and is_on_floor():
        velocity.y = JUMP_VELOCITY          # negative = up
    var direction = Input.get_axis("move_left", "move_right")
    velocity.x = direction * RUN_SPEED
    move_and_slide()                         # already accounts for delta
```

Key API: `CharacterBody2D.velocity`, `move_and_slide()`, `is_on_floor()`,
`Input.get_axis()`, `Input.is_action_just_pressed()`. Docs:
https://docs.godotengine.org/en/4.6/
