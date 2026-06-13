# Milestone 1 & 2 — Playable Level Implementation Plan

> **For workers:** This is a Godot project built in the editor, so execution is **inline / human-in-the-editor** (use `superpowers:executing-plans`), not subagent-driven — a subagent can't operate the Godot GUI. The AI writes the GDScript files; the human assembles scenes in the editor and runs the playtests. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** A single side-scrolling level you can play start to finish — a frog that runs and jumps with the Option A feel, platforms, collectible flies with a score, a goal that wins, and respawn on falling.

**Architecture:** A `Game` autoload singleton holds score (seed of the future save backbone). The frog is a `CharacterBody2D` driven by `move_and_slide()`. Flies and the goal are `Area2D` nodes that detect the player by group and talk to the world through signals on `Game`. The HUD is a `CanvasLayer` that listens to `Game`. Placeholder art is simple colored shapes.

**Tech Stack:** Godot 4.6, GDScript, GL Compatibility renderer.

**How we verify:** Manual playtest — press **F5** in the editor and observe. Each task ends with an observation checklist and a commit. (See `CLAUDE.md`.)

**Reference spec:** `docs/specs/milestone-1-2-playable-level.md`

---

## File structure

Scripts (AI writes these — full code is in the tasks):

| File | Responsibility |
|---|---|
| `scripts/game.gd` | Autoload `Game`: holds `score`, `add_score()`, signals `score_changed`/`won` |
| `scripts/player.gd` | Frog movement: run, jump, hold-for-higher, one air hop, respawn |
| `scripts/fly.gd` | Collectible: on player touch → `Game.add_score(1)`, remove self |
| `scripts/goal.gd` | Lily pad: on player touch → `Game.win()` |
| `scripts/hud.gd` | Score label + win label; listens to `Game` |

Scenes (built in the editor — node trees described in the tasks):

| File | Root node |
|---|---|
| `scenes/player.tscn` | `CharacterBody2D` |
| `scenes/fly.tscn` | `Area2D` |
| `scenes/goal.tscn` | `Area2D` |
| `scenes/hud.tscn` | `CanvasLayer` |
| `scenes/level_1.tscn` | `Node2D` (the world; main scene) |

**One layout tip used throughout:** a `ColorRect` anchors at its **top-left**, but collision shapes center on their node. So to line a placeholder picture up with its collision, set the `ColorRect`'s **Position to (−width/2, −height/2)**.

---

## Task 1: Project setup — folders, input, and the Game autoload

**Files:**
- Create: `scripts/game.gd`
- Editor: folders, Input Map, Autoload, default gravity

- [ ] **Step 1: Create the folders.** In the FileSystem dock (or Finder), create `scenes/`, `scripts/`, and `assets/` at the project root.

- [ ] **Step 2: Add the input actions.** Project → Project Settings → Input Map tab. Add three actions and bind keys (click "+", type the name, Add; then click the "+" on that row to add events):
  - `move_left` → Left Arrow, **A**
  - `move_right` → Right Arrow, **D**
  - `jump` → Space, Up Arrow, **W**

- [ ] **Step 3: Write `scripts/game.gd`.**

```gdscript
extends Node
## Autoloaded as "Game". Holds state that must survive scene changes.
## For now that's just the score; later it grows into money, inventory, etc.

signal score_changed(new_score: int)
signal won

var score: int = 0

func add_score(amount: int) -> void:
	score += amount
	score_changed.emit(score)

func reset_score() -> void:
	score = 0
	score_changed.emit(score)

func win() -> void:
	won.emit()
```

- [ ] **Step 4: Register the autoload.** Project → Project Settings → Globals → Autoload. Set Path to `res://scripts/game.gd`, Node Name to `Game`, click Add. Confirm it shows enabled.

- [ ] **Step 5: Confirm 2D gravity.** Project Settings → General → Physics → 2D. Leave `Default Gravity` at **980** (Godot's default — our jump values are tuned for it).

- [ ] **Step 6: Run to verify no errors.** Press **F5**. Godot will ask for a main scene — pick "Select" then cancel for now (we set it in Task 2), or just confirm the project opens with no script errors in the Output/Debugger panel.
  - Expected: no red errors about `game.gd` or the autoload.

- [ ] **Step 7: Commit.**

```bash
git add -A
git commit -m "Set up folders, input actions, and Game autoload"
```

---

## Task 2: The frog runs and jumps (Milestone 1)

**Files:**
- Create: `scripts/player.gd`, `scenes/player.tscn`, `scenes/level_1.tscn`

- [ ] **Step 1: Write `scripts/player.gd`.**

```gdscript
extends CharacterBody2D
## The frog. Run + jump with the "Option A" feel:
## a tall floaty jump, hold for higher, plus one mid-air hop.

# --- Tunable feel values (change these to change how the frog feels) ---
const RUN_SPEED := 300.0       # how fast the frog runs (pixels/second)
const JUMP_VELOCITY := -650.0  # upward kick when jumping (negative = up)
const MAX_AIR_JUMPS := 1       # extra hops allowed after leaving the ground
const JUMP_CUT := 0.4          # fraction of upward speed kept if you release early
const FALL_LIMIT := 1000.0     # how far below the start you can fall before respawning

# Gravity comes from Project Settings so it matches the rest of the game.
var gravity: float = ProjectSettings.get_setting("physics/2d/default_gravity")

var air_jumps_left := 0
var start_position := Vector2.ZERO

func _ready() -> void:
	start_position = global_position

func _physics_process(delta: float) -> void:
	# 1. Gravity pulls us down while in the air; on the ground, refill our air hops.
	if not is_on_floor():
		velocity.y += gravity * delta
	else:
		air_jumps_left = MAX_AIR_JUMPS

	# 2. Jump — from the ground, or spend a mid-air hop.
	if Input.is_action_just_pressed("jump"):
		if is_on_floor():
			velocity.y = JUMP_VELOCITY
		elif air_jumps_left > 0:
			velocity.y = JUMP_VELOCITY
			air_jumps_left -= 1

	# 3. Variable height: let go early while still rising = a shorter jump.
	if Input.is_action_just_released("jump") and velocity.y < 0.0:
		velocity.y *= JUMP_CUT

	# 4. Run left / right.
	var direction := Input.get_axis("move_left", "move_right")
	velocity.x = direction * RUN_SPEED

	# 5. Move, then check if we fell off the bottom.
	move_and_slide()
	if global_position.y > start_position.y + FALL_LIMIT:
		respawn()

func respawn() -> void:
	global_position = start_position
	velocity = Vector2.ZERO
```

- [ ] **Step 2: Build `scenes/player.tscn`.** Scene → New Scene → Other Node → `CharacterBody2D`. Rename root to `Player`. Save as `res://scenes/player.tscn`. Build this tree:
  - `Player` (CharacterBody2D)
    - `Visual` (`ColorRect`): in Inspector set **Size** to (32, 48), **Position** to (−16, −24), **Color** to a green.
    - `CollisionShape2D`: set **Shape** to a new `CapsuleShape2D`, Radius ≈ 14, Height ≈ 48 (leave Position at 0,0).
    - `Camera2D` (leave Position 0,0 — it follows the frog).

- [ ] **Step 3: Attach the script and group.** Select `Player`, attach `res://scripts/player.gd` (the link-script button, "Load", pick the file). With `Player` selected, open the **Node** dock → **Groups** → add it to a group named `player`.

- [ ] **Step 4: Build `scenes/level_1.tscn` with ground.** New Scene → Other Node → `Node2D`. Rename root to `Level1`. Save as `res://scenes/level_1.tscn`. Add:
  - `Ground` (`StaticBody2D`), Position about (0, 400):
    - `ColorRect`: Size (2000, 40), Position (−1000, −20), a brown/gray color.
    - `CollisionShape2D`: new `RectangleShape2D`, Size (2000, 40).
  - Instance the player: top toolbar of the Scene dock → "Instantiate Child Scene" (chain-link icon) → `res://scenes/player.tscn`. Move the `Player` instance to about (−400, 300) so it starts above the ground, left side.

- [ ] **Step 5: Set the main scene.** Project → Project Settings → Application → Run → set **Main Scene** to `res://scenes/level_1.tscn`.

- [ ] **Step 6: Playtest (F5). Observe:**
  - [ ] Frog falls and lands on the ground (doesn't fall through).
  - [ ] Left Arrow/A and Right Arrow/D move it; the camera follows.
  - [ ] Space/Up/W jumps. **Tap** = short hop, **hold** = noticeably higher.
  - [ ] In the air, one more press gives a second hop; a third press does nothing until you land.

- [ ] **Step 7: Commit.**

```bash
git add -A
git commit -m "Add frog player with run, variable jump, and one air hop"
```

---

## Task 3: Platforms and respawn

**Files:**
- Modify: `scenes/level_1.tscn`

- [ ] **Step 1: Add platforms.** In `level_1.tscn`, add 3–4 more `StaticBody2D` nodes (a quick way: select `Ground`, Ctrl/Cmd-D to duplicate, then resize). For each platform give it a `ColorRect` + a `CollisionShape2D` (`RectangleShape2D`) of the same size, with the `ColorRect` Position at (−width/2, −height/2). Place them at different heights and x-positions so reaching some needs a jump or the double-hop. Suggested platforms (Position / size):
  - (−150, 300) size (200, 24)
  - (150, 220) size (200, 24)
  - (450, 150) size (200, 24)

- [ ] **Step 2: Playtest (F5). Observe:**
  - [ ] You can jump from the ground onto the lowest platform, and use the air hop to reach the higher ones.
  - [ ] Standing on a platform, the frog doesn't sink or fall through.

- [ ] **Step 3: Test respawn.** Walk/jump off the right end past the ground and keep falling.
  - [ ] After falling ~1000px below the start, the frog reappears at its start position with no leftover momentum.

- [ ] **Step 4: Commit.**

```bash
git add -A
git commit -m "Add platforms to level 1 and verify fall respawn"
```

---

## Task 4: Flies and the score HUD

**Files:**
- Create: `scripts/fly.gd`, `scenes/fly.tscn`, `scripts/hud.gd`, `scenes/hud.tscn`
- Modify: `scenes/level_1.tscn`

- [ ] **Step 1: Write `scripts/fly.gd`.**

```gdscript
extends Area2D
## A collectible fly. When the player touches it, add to the score and disappear.

func _ready() -> void:
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		Game.add_score(1)
		queue_free()
```

- [ ] **Step 2: Build `scenes/fly.tscn`.** New Scene → `Area2D`, rename `Fly`, save as `res://scenes/fly.tscn`. Add:
  - `Visual` (`ColorRect`): Size (16, 16), Position (−8, −8), a dark/purple color.
  - `CollisionShape2D`: new `CircleShape2D`, Radius ≈ 10.
  - Attach `res://scripts/fly.gd` to `Fly`.

- [ ] **Step 3: Write `scripts/hud.gd`.**

```gdscript
extends CanvasLayer
## Shows the score and a win message. Listens to the Game autoload.

@onready var score_label: Label = $ScoreLabel
@onready var win_label: Label = $WinLabel

func _ready() -> void:
	win_label.hide()
	_update_score(Game.score)
	Game.score_changed.connect(_update_score)
	Game.won.connect(_on_won)

func _update_score(new_score: int) -> void:
	score_label.text = "Flies: %d" % new_score

func _on_won() -> void:
	win_label.show()
	get_tree().paused = true
```

- [ ] **Step 4: Build `scenes/hud.tscn`.** New Scene → `CanvasLayer`, rename `Hud`, save as `res://scenes/hud.tscn`. Add two `Label` children (names must match the script exactly):
  - `ScoreLabel`: Position near top-left (e.g. 16, 16), Text `Flies: 0`.
  - `WinLabel`: Text `You win!`. Center it on screen and bump the font size (Inspector → Theme Overrides → Font Sizes ≈ 48). The script hides it on start.
  - Attach `res://scripts/hud.gd` to `Hud`.

- [ ] **Step 5: Add HUD + flies to the level.** In `level_1.tscn`: instance `hud.tscn` once. Instance `fly.tscn` 3–5 times, placing flies around the platforms (some over gaps so you must jump). 

- [ ] **Step 6: Playtest (F5). Observe:**
  - [ ] "Flies: 0" shows at the top-left.
  - [ ] Touching a fly makes it vanish and the count goes up by 1.
  - [ ] Collecting all flies shows the right total.

- [ ] **Step 7: Commit.**

```bash
git add -A
git commit -m "Add collectible flies and score HUD"
```

---

## Task 5: The goal and winning

**Files:**
- Create: `scripts/goal.gd`, `scenes/goal.tscn`
- Modify: `scenes/level_1.tscn`

- [ ] **Step 1: Write `scripts/goal.gd`.**

```gdscript
extends Area2D
## The goal (a lily pad). When the player reaches it, the level is won.

var _won := false

func _ready() -> void:
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node2D) -> void:
	if _won:
		return
	if body.is_in_group("player"):
		_won = true
		Game.win()
```

- [ ] **Step 2: Build `scenes/goal.tscn`.** New Scene → `Area2D`, rename `Goal`, save as `res://scenes/goal.tscn`. Add:
  - `Visual` (`ColorRect`): Size (48, 16), Position (−24, −8), a lily-pad green.
  - `CollisionShape2D`: new `RectangleShape2D`, Size (48, 16).
  - Attach `res://scripts/goal.gd` to `Goal`.

- [ ] **Step 3: Place the goal.** In `level_1.tscn`, instance `goal.tscn` once and put it near the far-right end of the level, on the ground or the last platform.

- [ ] **Step 4: Playtest (F5). Observe:**
  - [ ] Reaching the goal makes the big "You win!" appear and the frog stops (game pauses).
  - [ ] Score collected before winning is still shown.

- [ ] **Step 5: Commit.**

```bash
git add -A
git commit -m "Add goal and win condition"
```

---

## Task 6: Full playtest, tuning, and bookkeeping

**Files:**
- Modify: `scripts/player.gd` (only if tuning), `TASKS.md`

- [ ] **Step 1: Run the full spec checklist.** Press F5 and confirm every box in the spec's "Done = this playtest passes" section.

- [ ] **Step 2: Tune the feel (optional, fun for your son).** If the jump feels off, tweak the constants at the top of `scripts/player.gd` and re-run:
  - Floatier/higher jump: make `JUMP_VELOCITY` more negative (e.g. −720).
  - Snappier fall: raise default gravity in Project Settings (e.g. 1100).
  - Faster run: raise `RUN_SPEED`.
  - Bigger difference between tap and hold: lower `JUMP_CUT` (e.g. 0.3).

- [ ] **Step 3: Check off Milestones 1 & 2 in `TASKS.md`** (mark the milestone-1-2 task boxes done and set rows 1 & 2 to ✅).

- [ ] **Step 4: Commit.**

```bash
git add -A
git commit -m "Tune frog feel and mark Milestones 1 & 2 complete"
```

---

## Self-review

**Spec coverage:** run/jump feel (Task 2) ✓ · platforms (Task 3) ✓ · camera follow (Task 2, Camera2D child) ✓ · flies + score (Task 4) ✓ · goal/win (Task 5) ✓ · respawn on fall (Tasks 2–3) ✓ · named input actions (Task 1) ✓ · placeholder art (all scene tasks) ✓ · `Game` autoload as backbone seed (Task 1) ✓. No gaps.

**Type/name consistency:** `Game.add_score(int)`, `Game.score`, signals `score_changed(int)` / `won` are defined in Task 1 and used identically in `fly.gd`/`goal.gd`/`hud.gd`. HUD child node names `ScoreLabel`/`WinLabel` match the `@onready` paths. The `player` group name matches `is_in_group("player")` in both `fly.gd` and `goal.gd`. Consistent.

**Placeholders:** none — every script is complete and every editor step names exact nodes, sizes, and paths.
