# Spec — Milestones 1 & 2: A playable platformer level

_Created: 2026-06-13 · Status: drafted, awaiting review_

## Goal

A single side-scrolling level you can actually play start to finish: a frog that runs
and jumps with the Option A feel, platforms to stand on, flies to collect for points,
and a goal that wins the level. Falling off the bottom respawns you.

This is the foundation everything else (town, shops, RPG) is built on.

## In scope

- Frog player: run left/right, jump, hold-for-higher jump, one mid-air hop.
- A hand-built level: ground + a handful of platforms.
- A camera that follows the frog.
- A few collectible flies that raise a score.
- A goal (a lily pad) that shows "You win!" when reached.
- Respawn at the start when you fall off the bottom.
- Keyboard controls via named input actions.
- Placeholder art (simple colored shapes).

## Out of scope (later milestones)

Enemies/combat, multiple levels, sound, real sprite art, animation beyond placeholder,
menus, the town, shops, saving between sessions. **Coins vs. score:** for now the fly
counter is just a per-level score; it becomes spendable money in Milestone 5.

## Scenes & scripts

Filenames are `snake_case`; node names are `PascalCase` (see `CLAUDE.md`).

| File | Type | Responsibility |
|---|---|---|
| `scripts/game.gd` | autoload singleton `Game` | Holds `score`. Seed of the future save backbone. Emits `score_changed`. |
| `scenes/player.tscn` + `scripts/player.gd` | `CharacterBody2D` | The frog: movement, jump, respawn. Owns its sprite + collision shape + a child `Camera2D`. |
| `scenes/fly.tscn` + `scripts/fly.gd` | `Area2D` | A collectible. On body-entered by the player: add to score, remove itself. |
| `scenes/goal.tscn` + `scripts/goal.gd` | `Area2D` | The lily pad. On player enter: trigger win. |
| `scenes/level_1.tscn` | scene | The world: ground + platforms (`StaticBody2D`), placed flies, a goal, and a `player` instance. Sets the player's start position. |
| `scenes/hud.tscn` + `scripts/hud.gd` | `CanvasLayer` | Shows the score; shows the "You win!" label. Listens to `Game.score_changed`. |

`level_1.tscn` is the **main scene** (Project Settings → Run).

## Player movement (Option A feel)

Built on `CharacterBody2D` + `move_and_slide()`. Tunable constants at the top of
`player.gd`, each with a comment:

| Constant | Purpose | Starting value (tune by feel) |
|---|---|---|
| `RUN_SPEED` | horizontal run speed (px/s) | `300` |
| `GRAVITY` | downward pull (px/s²) | from `ProjectSettings physics/2d/default_gravity` |
| `JUMP_VELOCITY` | upward kick on jump (negative = up) | `-650` |
| `MAX_AIR_JUMPS` | extra hops after leaving the ground | `1` |
| `JUMP_CUT` | fraction of upward speed kept when the button is released early | `0.4` |

Per physics frame:

1. Apply gravity when not on the floor: `velocity.y += GRAVITY * delta`.
2. **Jump pressed** (`jump` just-pressed) and (`is_on_floor()` **or** `air_jumps_left > 0`):
   set `velocity.y = JUMP_VELOCITY`; if it was an air hop, decrement `air_jumps_left`.
3. **Variable height:** if `jump` is *released* while still rising (`velocity.y < 0`),
   cut it: `velocity.y *= JUMP_CUT`.
4. Reset `air_jumps_left = MAX_AIR_JUMPS` whenever `is_on_floor()`.
5. Horizontal: `velocity.x = Input.get_axis("move_left", "move_right") * RUN_SPEED`.
6. `move_and_slide()`.

**Respawn:** if the player's `y` falls below a threshold (a `KillFloor`/limit set in
the level), move it back to the recorded start position and zero its velocity.

## Input actions (Project Settings → Input Map)

| Action | Keys |
|---|---|
| `move_left` | Left Arrow, A |
| `move_right` | Right Arrow, D |
| `jump` | Space, Up Arrow, W |

## Level contents

- **Ground + platforms:** `StaticBody2D` nodes, each with a `CollisionShape2D` and a
  placeholder `ColorRect` (or `Polygon2D`) so they're visible. A few platforms at
  different heights to make jumping matter.
- **Camera:** a `Camera2D` as a child of the player (simplest follow). Good enough for
  one level; we can switch to a smarter camera later if needed.
- **Flies:** 3–5 `fly.tscn` instances placed around the level, some requiring a jump.
- **Goal:** one `goal.tscn` near the far end.

## Score, win, lose

- Collecting a fly calls `Game.add_score(1)`, which updates `Game.score` and emits
  `score_changed`; the HUD label updates from that signal. The fly removes itself.
- Reaching the goal tells the HUD to show **"You win!"** (and we pause or stop input).
- Falling off the bottom respawns the frog at the start (score is kept).

## Placeholder art

- Frog: a green capsule/rectangle (`ColorRect` or `Sprite2D` with a solid texture) with
  a capsule `CollisionShape2D`.
- Flies: small dark circles. Goal: a green lily-pad-ish shape.
- Real sprites come in a later art pass; nothing here should hardcode art so swapping
  is easy.

## Done = this playtest passes

Open the project, press F5, and confirm:

- [ ] Frog runs left and right with arrow keys / A-D.
- [ ] Frog jumps with Space/Up/W; tapping = short hop, holding = higher jump.
- [ ] One mid-air hop works; a second mid-air press does nothing until you land.
- [ ] Frog lands on platforms and doesn't fall through.
- [ ] Camera follows the frog smoothly.
- [ ] Touching a fly increases the score shown on the HUD and the fly disappears.
- [ ] Reaching the goal shows "You win!".
- [ ] Falling off the bottom respawns the frog at the start with the score intact.
