# Milestone 3 — Town Hub Implementation Plan

> **For workers:** Inline / human-in-the-editor (use `superpowers:executing-plans`). The AI authors `.gd` scripts and `.tscn` scenes as files; after each task the human does **Project → Reload Current Project**, presses **F5**, and reports the playtest. Steps use checkbox (`- [ ]`) syntax.

**Goal:** A top-down town the frog walks around, with five enterable buildings (empty placeholder interiors) and a gate that starts the platformer level and returns you — all routed through a `SceneRouter` autoload.

**Architecture:** A separate top-down player (`town_player`) handles 8-direction walking. A reusable `door` Area2D triggers transitions via `SceneRouter`, which remembers where to drop the frog when the town reloads. One reusable `building_interior` serves all five buildings. The town becomes the start scene; the level's win returns to town.

**Tech Stack:** Godot 4.6, GDScript, GL Compatibility.

**Reference spec:** `docs/specs/milestone-3-town-hub.md`

---

## Town coordinate map (used in Task 1 & 3)

Vertical street centred on x=0; walls at x=±150; buildings drawn outside the walls;
door mats sit just inside the wall on the street side.

| Thing | Building block pos | Door mat pos | `exit_offset` (onto street) |
|---|---|---|---|
| Gate (level) | top center, y=-560 | (0, -540) | (0, 90) |
| Weapon Shop | (-280, -300) | (-130, -300) | (40, 0) |
| Armor Shop | (280, -300) | (130, -300) | (-40, 0) |
| Shield Shop | (-280, 100) | (-130, 100) | (40, 0) |
| Furniture Shop | (280, 100) | (130, 100) | (-40, 0) |
| House | (0, 450) | (0, 360) | (0, -50) |
| DefaultSpawn (launch) | — | (0, -440) | — |

Street vertical extent ≈ y -560..480.

---

## Task 1: Inputs, top-down frog, and a walkable town

**Files:**
- Modify: `project.godot`
- Create: `scripts/scene_router.gd`, `scripts/town_player.gd`, `scenes/town_player.tscn`, `scripts/town.gd`, `scenes/town.tscn`

- [ ] **Step 1: Add inputs, autoload, and start scene to `project.godot`.**
  - Add input actions `move_up` (Up Arrow `4194320`, W `87`) and `move_down` (Down Arrow `4194322`, S `83`), same serialization style as the existing actions.
  - Add autoload: `SceneRouter="*res://scripts/scene_router.gd"`.
  - Change `run/main_scene` to `"res://scenes/town.tscn"`.

- [ ] **Step 2: Write `scripts/scene_router.gd`.**

```gdscript
extends Node
## Autoloaded as "SceneRouter". Switches between the town, the level, and building
## interiors, and remembers where to place the frog when the town next loads.

const TOWN := "res://scenes/town.tscn"
const LEVEL := "res://scenes/level_1.tscn"
const INTERIOR := "res://scenes/building_interior.tscn"

var town_spawn := Vector2.ZERO   # where to drop the frog when the town loads
var has_town_spawn := false
var current_building := ""        # shown inside the interior

func go_to_level(spawn_on_return: Vector2) -> void:
	town_spawn = spawn_on_return
	has_town_spawn = true
	get_tree().change_scene_to_file(LEVEL)

func enter_building(building_name: String, spawn_on_return: Vector2) -> void:
	current_building = building_name
	town_spawn = spawn_on_return
	has_town_spawn = true
	get_tree().change_scene_to_file(INTERIOR)

func return_to_town() -> void:
	get_tree().change_scene_to_file(TOWN)
```

- [ ] **Step 3: Write `scripts/town_player.gd`.**

```gdscript
extends CharacterBody2D
## The top-down frog used in the town and building interiors.
## Walks in all directions; no gravity, no jumping.

const SPEED := 220.0  # walk speed in pixels/second

func _physics_process(_delta: float) -> void:
	var direction := Input.get_vector("move_left", "move_right", "move_up", "move_down")
	velocity = direction * SPEED
	move_and_slide()
```

- [ ] **Step 4: Create `scenes/town_player.tscn`.** Root `CharacterBody2D` named `TownPlayer`, in group `player`, script `town_player.gd`. Children: a 28×28 green `ColorRect` (`Visual`, offsets ±14, centered), a `CollisionShape2D` with a `CircleShape2D` radius 14, and a `Camera2D`.

- [ ] **Step 5: Write `scripts/town.gd`.**

```gdscript
extends Node2D
## The town hub. Places the frog at the spawn SceneRouter remembered (beside the door
## it last used), or a default spot by the gate on first launch.

@onready var player: CharacterBody2D = $TownPlayer
@onready var default_spawn: Marker2D = $DefaultSpawn

func _ready() -> void:
	if SceneRouter.has_town_spawn:
		player.global_position = SceneRouter.town_spawn
	else:
		player.global_position = default_spawn.global_position
```

- [ ] **Step 6: Create `scenes/town.tscn`.** Root `Node2D` named `Town`, script `town.gd`. Build (using the coordinate map above):
  - `Street` (`ColorRect`): a long neutral strip down the middle (x -150..150, y -560..480).
  - `Buildings` (`Node2D`): six `ColorRect` blocks (the five shops/house) ~150×120 each at the *building block* positions, each with a child `Label` showing its name. (No doors yet — those come in Tasks 2–3.)
  - `Walls` (`StaticBody2D`): thin `CollisionShape2D` rectangles forming the left wall (x=-150), right wall (x=150), and a bottom wall (y=480), so the frog stays on the street. Leave the top open at the gate.
  - `DefaultSpawn` (`Marker2D`) at (0, -440).
  - `TownPlayer` (instance of `town_player.tscn`).

- [ ] **Step 7: Playtest (F5). Observe:**
  - [ ] The game now opens in the town; the frog appears on the street near the top.
  - [ ] Arrows / WASD walk the frog in all 8 directions; diagonals aren't faster.
  - [ ] The walls keep the frog on the street; the building blocks are labeled.

- [ ] **Step 8: Commit.**

```bash
git add -A
git commit -m "Task 3.1: top-down town with walkable frog, inputs, and SceneRouter"
```

---

## Task 2: The level gate and returning from a level

**Files:**
- Create: `scripts/door.gd`, `scenes/door.tscn`
- Modify: `scenes/town.tscn` (add the gate), `scripts/hud.gd` (win → return to town)

- [ ] **Step 1: Write `scripts/door.gd`.**

```gdscript
extends Area2D
## A reusable doorway. `action` chooses what happens when the frog walks in:
##   "building" -> enter the interior for `building_name`
##   "level"    -> start the platformer level
##   "town"     -> return to the town
## `exit_offset` is where to drop the frog (relative to this door) on return, so they
## land on the street beside the door instead of on top of it.

@export var action: String = "building"
@export var building_name: String = ""
@export var exit_offset: Vector2 = Vector2(0, 64)

var _armed := false  # ignore the player until shortly after the scene loads

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	await get_tree().create_timer(0.3).timeout
	_armed = true

func _on_body_entered(body: Node2D) -> void:
	if not _armed or not body.is_in_group("player"):
		return
	match action:
		"building":
			SceneRouter.enter_building(building_name, global_position + exit_offset)
		"level":
			SceneRouter.go_to_level(global_position + exit_offset)
		"town":
			SceneRouter.return_to_town()
```

- [ ] **Step 2: Create `scenes/door.tscn`.** Root `Area2D` named `Door`, script `door.gd`. Children: a 48×24 yellow `ColorRect` (`Visual`, centered) and a `CollisionShape2D` with a `RectangleShape2D` size (48, 24).

- [ ] **Step 3: Add the gate to `scenes/town.tscn`.** Instance `door.tscn` named `Gate` at (0, -540) with `action = "level"`, `exit_offset = Vector2(0, 90)`. Give it a distinct color or a "GATE" label so it reads as the level entrance.

- [ ] **Step 4: Modify `scripts/hud.gd`** so winning returns to town instead of freezing. Replace `_on_won`:

```gdscript
func _on_won() -> void:
	win_label.show()
	await get_tree().create_timer(1.5).timeout
	SceneRouter.return_to_town()
```

(Delete the old `get_tree().paused = true` line. `goal.gd` is unchanged — it still calls `Game.win()`.)

- [ ] **Step 5: Playtest (F5). Observe:**
  - [ ] Walking the frog up into the gate starts the platformer level.
  - [ ] Reaching the level's goal shows "You win!" then, after ~1.5s, returns to the town.
  - [ ] Back in town, the frog appears just below the gate — and does **not** instantly re-enter it.

- [ ] **Step 6: Commit.**

```bash
git add -A
git commit -m "Task 3.2: reusable door, level gate, and win-returns-to-town"
```

---

## Task 3: Enterable buildings with a shared interior

**Files:**
- Create: `scripts/building_interior.gd`, `scenes/building_interior.tscn`
- Modify: `scenes/town.tscn` (add the five building doors)

- [ ] **Step 1: Write `scripts/building_interior.gd`.**

```gdscript
extends Node2D
## A reusable empty room shown for any building. Displays which building you're in.

@onready var name_label: Label = $NameLabel

func _ready() -> void:
	name_label.text = SceneRouter.current_building
```

- [ ] **Step 2: Create `scenes/building_interior.tscn`.** Root `Node2D` named `BuildingInterior`, script `building_interior.gd`. Build:
  - `Floor` (`ColorRect`): a room rectangle (e.g., 600×400 centered on origin).
  - `Walls` (`StaticBody2D`): four thin `CollisionShape2D` rectangles around the room edge.
  - `NameLabel` (`Label`): near the top, big font; text is set by the script.
  - `ExitDoor` (instance of `door.tscn`) near the bottom with `action = "town"` (label it "EXIT").
  - `TownPlayer` (instance of `town_player.tscn`) placed in the middle of the room, above the exit so it doesn't spawn on it.

- [ ] **Step 3: Add the five building doors to `scenes/town.tscn`.** Instance `door.tscn` five times at the *door mat* positions from the coordinate map, each with `action = "building"` and:

| Door node | Position | `building_name` | `exit_offset` |
|---|---|---|---|
| `WeaponDoor` | (-130, -300) | `"Weapon Shop"` | (40, 0) |
| `ArmorDoor` | (130, -300) | `"Armor Shop"` | (-40, 0) |
| `ShieldDoor` | (-130, 100) | `"Shield Shop"` | (40, 0) |
| `FurnitureDoor` | (130, 100) | `"Furniture Shop"` | (-40, 0) |
| `HouseDoor` | (0, 360) | `"House"` | (0, -50) |

- [ ] **Step 4: Playtest (F5). Observe:**
  - [ ] Walking into each of the five doors enters the room, showing that building's name.
  - [ ] The exit door returns you to the town, beside the building you were in.
  - [ ] No transition loops — you can immediately walk away from each door on return.

- [ ] **Step 5: Commit.**

```bash
git add -A
git commit -m "Task 3.3: shared building interior and five enterable buildings"
```

---

## Task 4: Full playtest and bookkeeping

**Files:** Modify `TASKS.md`

- [ ] **Step 1: Run the full spec checklist** (`docs/specs/milestone-3-town-hub.md`, "Done = this playtest passes") and confirm every box, including the no-loop check on all six doors/gate.

- [ ] **Step 2: Tune if needed.** If the frog walks too fast/slow, adjust `SPEED` in `town_player.gd`. If a door is awkward to reach, nudge its position or `exit_offset`.

- [ ] **Step 3: Mark Milestone 3 done in `TASKS.md`** (roadmap row 3 → ✅; check the M3 task boxes) and set Milestone 4 as next.

- [ ] **Step 4: Commit and push.**

```bash
git add -A
git commit -m "Task 3.4: mark Milestone 3 complete"
git push origin main
```

---

## Self-review

**Spec coverage:** top-down town + movement (Task 1) ✓ · walls (Task 1) ✓ · reusable door (Task 2) ✓ · level gate + return (Task 2) ✓ · win→town (Task 2) ✓ · reusable interior + five buildings (Task 3) ✓ · SceneRouter + spawn-beside-door (Tasks 1–2) ✓ · no-re-trigger guard (door arm timer + exit_offset, Task 2) ✓ · new inputs + start scene (Task 1) ✓. No gaps.

**Type/name consistency:** `SceneRouter.go_to_level(Vector2)`, `enter_building(String, Vector2)`, `return_to_town()`, and `current_building`/`town_spawn`/`has_town_spawn` are defined in Task 1 and used identically in `door.gd` (Task 2), `town.gd` (Task 1), and `building_interior.gd` (Task 3). The `player` group is set on `town_player.tscn` and checked in `door.gd`. HUD node names unchanged. Consistent.

**Placeholders:** none — scripts are complete; scenes are specified by node tree + exact coordinate/parameter tables.
