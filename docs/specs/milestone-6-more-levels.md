# Spec — Milestone 6: More levels + level select

_Created: 2026-11-19 · Status: approved 2026-11-19 (3 new levels, walkable world map instead of a list, Next level button, moving logs in Level 4)_

## Goal

There are **4 levels** instead of 1. Walking into the town gate takes you to a small
**world map**: a path with a stepping stone for each level. Stand on a stone and press
Space to play it; a level is locked until you beat the one before it. Beating a level
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
- **World map** behind the town gate: a path with 4 level stones. Gray = locked,
  yellow = open, green = beaten. Each stone uses a `TalkZone` ("Space: play"). A TOWN
  exit on the left returns to the town by the gate.
- **Unlocking:** `Game.levels_beaten` (saved) records the highest level beaten.
- **Win panel:** Next level (when there is one), Play again, Back to map. Back on the
  map, the frog stands at the stone of the level it just played.
- **Moving platform:** a reusable `moving_platform.tscn` that slides back and forth between
  two points, carrying the frog. Used in Level 4.
- **Deploy** when the playtest passes.

## Out of scope (later)

Map art (with the art pass), enemies and spikes (Milestone 7),
per-level best scores, a level timer, real water or log art.

## Scenes & scripts

| File | Type | Responsibility |
|---|---|---|
| `scripts/level_catalog.gd` | `class_name LevelCatalog` | `const LEVELS` (number, name, path) and `find(number)`. |
| `scripts/level.gd` | script on each level's root | `@export var level_number`; tells `Game` which level is running. |
| `scenes/level_2.tscn`, `level_3.tscn`, `level_4.tscn` | levels | Built from the same pieces as Level 1: ground, platforms, flies, player, HUD, goal. |
| `scenes/moving_platform.tscn` + `scripts/moving_platform.gd` | `AnimatableBody2D` | Moves between its start and `@export var travel: Vector2` and back, `@export var speed`. `AnimatableBody2D` carries a `CharacterBody2D` standing on it, so the frog rides along. |
| `scenes/world_map.tscn` + `scripts/world_map.gd` | scene | Grass, a path, 4 `LevelStone`s, a TOWN exit door, a `TownPlayer`, a `CoinHud`. Places the frog by the exit (from town) or at the last level's stone (from a level). |
| `scenes/level_stone.tscn` + `scripts/level_stone.gd` | `Node2D` | One stone: number, name, color by state, and a `TalkZone`. Starts its level if unlocked; otherwise says "Beat level N first". |

**Modified:**
- `scripts/game.gd`: `current_level`, `levels_beaten` (saved), `is_unlocked(number)`;
  `finish_level()` also records the level as beaten.
- `scripts/scene_router.gd`: `go_to_world_map(spawn_on_return)`, `go_to_level(number)`,
  `replay_level()`, `next_level()`, `return_to_map()`.
- `scripts/door.gd`: the `"level"` action (the town gate) goes to the world map. Doors now
  change scenes with `call_deferred`, because removing physics bodies inside a physics
  callback (`body_entered`) is not allowed.
- `scripts/talk_zone.gd`: an exported `hint_text` ("Space: talk" by default).
- `scenes/win_panel.tscn` + `scripts/win_panel.gd`: Next level button.
- `scenes/hud.tscn` + `scripts/hud.gd`: shows the level name.
- `scenes/level_1.tscn`: gets `level.gd` with `level_number = 1`.

**Teaching note:** each new level is a copy of Level 1 with the pieces moved. That's the
"build it once, reuse it" payoff of keeping the player, flies, goal and HUD as their own
small scenes. Your son can make Level 5 himself by duplicating a level in the editor and
adding one line to `level_catalog.gd`.

## Done = this playtest passes

Press F9 first (new game), then F5. Confirm:

- [ ] Walking into the gate opens the world map: stone 1 yellow, stones 2 to 4 gray.
- [ ] Space on a gray stone says "Beat level N first"; the TOWN exit returns to the gate.
- [ ] Beating Level 1 shows Next level; it starts Level 2. Back to map puts the frog at
      stone 2, with stone 1 green and stone 2 green or yellow.
- [ ] Each level shows its name in the HUD; flies reset each run; coins are paid as before.
- [ ] Levels 2 and 3 are beatable with the normal jump, hold-jump and two air hops.
- [ ] In Level 4 the logs move, the frog rides them without sliding off, and falling in
      the river respawns at the start.
- [ ] Close and reopen the game: unlocked levels stay unlocked.
- [ ] Milestones 3 to 5 checklists still pass.
- [ ] Deployed to the website.
