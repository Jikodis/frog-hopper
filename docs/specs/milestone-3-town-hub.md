# Spec — Milestone 3: Top-down town hub

_Created: 2026-06-13 · Status: drafted, awaiting review_

## Goal

A top-down town the frog walks around (main-street layout). Five buildings line the
street, each enterable (empty placeholder interior for now). A gate at the top of the
street starts the platformer level and returns you to town when you finish. All
scene-switching goes through one `SceneRouter` so you reappear in front of the door you
used.

## In scope

- A top-down town scene with a vertical street; five labeled buildings on the sides;
  a level gate at the top; the house at the bottom.
- A separate, simple **top-down frog** (8-directional movement, no gravity).
- Walls/edges so the frog stays on the street and out of buildings (except through doors).
- A reusable **door** you walk into; one reusable **building interior** shared by all
  five buildings (shows the building's name + an exit back to town).
- The **level gate**: town → `level_1` → back to town on winning.
- A **`SceneRouter`** autoload that performs the transitions and remembers where to drop
  the frog on return.

## Out of scope (later milestones)

Shop contents / buying / money (M5), the bedroom intro + dialogue (M4), real art,
hopping in town, enemies. Interiors are empty rooms with just a name and an exit.

## Scenes & scripts

| File | Type | Responsibility |
|---|---|---|
| `scripts/scene_router.gd` | autoload `SceneRouter` | `go_to_level()`, `enter_building(name)`, `return_to_town()`; stores the spawn point to use when town loads, and the current building name |
| `scenes/town_player.tscn` + `scripts/town_player.gd` | `CharacterBody2D` | Top-down 8-directional movement (tunable `SPEED`), no gravity |
| `scenes/door.tscn` + `scripts/door.gd` | `Area2D` | Reusable doorway. Exported `action` (`"building"` / `"level"` / `"town"`) + `building_name`. On the player entering, calls the matching `SceneRouter` function. Ignores triggers briefly after load so spawning next to a door doesn't instantly re-trigger it. |
| `scenes/town.tscn` + `scripts/town.gd` | scene | The street, five building blocks with name labels and doors, the gate, walls, and a `town_player` instance. On load, places the player at `SceneRouter`'s spawn point (or a default by the gate). |
| `scenes/building_interior.tscn` + `scripts/building_interior.gd` | scene | One reusable empty room. Shows `SceneRouter.current_building` on a label; has an exit door (`action = "town"`) and a `town_player` instance. |

**Modified:**
- `project.godot`: add input actions `move_up` (Up, W) and `move_down` (Down, S); add
  the `SceneRouter` autoload; change the **main scene** to `town.tscn`.
- `scripts/goal.gd` / `scripts/hud.gd`: on reaching the goal, show "You win!" briefly,
  then `SceneRouter.return_to_town()` instead of staying paused forever.

## Input

The town frog reads four directions; it never reads `jump`, so there's no conflict with
the level (which keeps using `move_left` / `move_right` / `jump`).

| Action | Keys | Used by |
|---|---|---|
| `move_left` / `move_right` | Arrows, A / D | level + town |
| `move_up` / `move_down` | Up / Down, W / S | town |
| `jump` | Space, Up, W | level only |

## Top-down movement

`town_player.gd` uses `Input.get_vector("move_left","move_right","move_up","move_down")`
(handles diagonal normalization), `velocity = dir * SPEED`, then `move_and_slide()`.
`SPEED` is a tunable constant (start ~220).

## The town↔elsewhere loop

- **Enter a building:** walk into its door → `SceneRouter.enter_building(name)` →
  `building_interior` loads showing that name.
- **Exit a building:** walk into the interior's exit door → `SceneRouter.return_to_town()`
  → town loads, frog placed in front of that building's door.
- **Start a level:** walk into the gate → `SceneRouter.go_to_level()` → `level_1` loads.
- **Finish a level:** reach the goal → "You win!" for ~1.5s → `return_to_town()` → frog
  placed in front of the gate.

**Correctness note — no instant re-trigger:** when the frog is dropped back into town it
must spawn *beside* the door/gate (on the street), not on top of it, and doors must
ignore entries for a short moment after the scene loads. Otherwise the frog spawns inside
the door's area and immediately transitions again, looping forever.

## Placeholder art

- Town frog: a green square like the level frog (separate scene, simpler script).
- Buildings: colored rectangles with a `Label` naming each (Weapon / Armor / Shield /
  Furniture / House). Doors: small contrasting rectangles. Street: a long neutral strip;
  walls are `StaticBody2D` edges.
- Interior: a plain room rectangle, a name label, and an exit mat (a door).

## Done = this playtest passes

Press F5 (town is now the start scene). Confirm:

- [ ] The frog starts in the town and walks in all directions with arrows / WASD; walls
      keep it on the street.
- [ ] Walking into each of the five building doors enters a room showing that building's
      name.
- [ ] Walking into the interior's exit returns to town, in front of that building.
- [ ] Walking into the gate starts the platformer level.
- [ ] Reaching the level's goal shows "You win!" then returns to the town by the gate.
- [ ] You never get stuck in a transition loop (spawning next to a door doesn't instantly
      re-enter it).
