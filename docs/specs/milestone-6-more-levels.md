# Spec — Milestone 6: More levels + level select

_Created: 2026-11-19 · Status: drafted, awaiting review_

## Goal

There are **4 levels** instead of 1. Walking into the town gate opens a **level picker**
that lists them; a level is locked until you beat the one before it. Beating a level
unlocks the next, and that progress is **saved**. The win panel gets a **Next level**
button. Level 4 adds the first new mechanic since Milestone 2: **moving platforms**.

## In scope

- **3 new levels** (placeholder layouts you and your son can rearrange in the editor):

  | # | Name | Idea | Flies |
  |---|---|---|---|
  | 1 | Lily Pad Meadow | the existing level, unchanged | 5 |
  | 2 | Pond Hop | wide gaps over water; falling in respawns you at the start | 6 |
  | 3 | Tall Reeds | a climb straight up, using the hold-jump and both air hops | 7 |
  | 4 | Log Drift | moving logs carry you across a river | 8 |

- **A level catalog:** one file listing each level's number, name and scene path.
- **One shared level script** (`level.gd`) so every level knows its number; the HUD shows
  "Level 2: Pond Hop" next to the fly count.
- **Level picker** at the gate: a list panel (same look and keys as the shop list). Locked
  levels show a lock and can't be picked; beaten levels show a check. Leave closes it.
- **Unlocking:** `Game.levels_beaten` (saved) records the highest level beaten.
- **Win panel:** Next level (when there is one), Play again, Back to town.
- **Moving platform:** a reusable `moving_platform.tscn` that slides back and forth between
  two points, carrying the frog. Used in Level 4.
- **Deploy** when the playtest passes.

## Out of scope (later)

A walkable world map (could come with the art pass), enemies and spikes (Milestone 7),
per-level best scores, a level timer, real water or log art.

## Scenes & scripts

| File | Type | Responsibility |
|---|---|---|
| `scripts/level_catalog.gd` | `class_name LevelCatalog` | `const LEVELS` (number, name, path) and `find(number)`. |
| `scripts/level.gd` | script on each level's root | `@export var level_number`; tells `Game` which level is running. |
| `scenes/level_2.tscn`, `level_3.tscn`, `level_4.tscn` | levels | Built from the same pieces as Level 1: ground, platforms, flies, player, HUD, goal. |
| `scenes/moving_platform.tscn` + `scripts/moving_platform.gd` | `AnimatableBody2D` | Moves between its start and `@export var travel: Vector2` and back, `@export var speed`. `AnimatableBody2D` carries a `CharacterBody2D` standing on it, so the frog rides along. |
| `scenes/level_picker.tscn` + `scripts/level_picker.gd` | `CanvasLayer` | The list panel at the gate. Emits `picked(number)` or `closed`. |

**Modified:**
- `scripts/game.gd`: `current_level`, `levels_beaten` (saved), `is_unlocked(number)`;
  `finish_level()` also records the level as beaten.
- `scripts/scene_router.gd`: `go_to_level(number, spawn_on_return)`, `replay_level()`,
  `next_level()`; the gate now opens the picker instead of starting Level 1.
- `scripts/door.gd`: the `"level"` action asks the town to open the picker.
- `scenes/town.tscn` + `scripts/town.gd`: holds the `LevelPicker`; freezes the frog while
  it's open.
- `scenes/win_panel.tscn` + `scripts/win_panel.gd`: Next level button.
- `scenes/hud.tscn` + `scripts/hud.gd`: shows the level name.
- `scenes/level_1.tscn`: gets `level.gd` with `level_number = 1`.

**Teaching note:** each new level is a copy of Level 1 with the pieces moved. That's the
"build it once, reuse it" payoff of keeping the player, flies, goal and HUD as their own
small scenes. Your son can make Level 5 himself by duplicating a level in the editor and
adding one line to `level_catalog.gd`.

## Done = this playtest passes

Press F9 first (new game), then F5. Confirm:

- [ ] Walking into the gate opens the level picker: Level 1 open, Levels 2 to 4 locked.
- [ ] Locked levels can't be picked; Leave closes the picker and the frog can walk.
- [ ] Beating Level 1 shows Next level; it starts Level 2, and the picker now shows
      Level 1 beaten and Level 2 open.
- [ ] Each level shows its name in the HUD; flies reset each run; coins are paid as before.
- [ ] Levels 2 and 3 are beatable with the normal jump, hold-jump and two air hops.
- [ ] In Level 4 the logs move, the frog rides them without sliding off, and falling in
      the river respawns at the start.
- [ ] Close and reopen the game: unlocked levels stay unlocked.
- [ ] Milestones 3 to 5 checklists still pass.
- [ ] Deployed to the website.
