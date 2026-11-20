# Spec: Milestone 7: Enemies, hazards + hearts

_Created: 2026-11-20 · Status: draft, 4 decisions open (marked **Decision**)_

## Goal

Levels can now hurt you. The frog has **hearts** shown in the HUD. **Beetles** walk back
and forth on platforms: jump on one's head to **stomp** it (the frog bounces up), touch
it from the side and you lose a heart. **Spikes** cost a heart too. After a hit the frog
blinks and can't be hurt again for a moment. Run out of hearts and the level **fails**:
a panel offers Try again or Back to map.

## In scope

- **Hearts:** the frog starts every level with full hearts. **Decision 1:** 3 hearts
  (recommended) or 5.
- **HUD:** a row of hearts next to the fly count; an empty heart for each one lost.
- **Getting hurt:** lose 1 heart, the frog is knocked back away from the hit, then blinks
  for 1 second and can't be hurt again (so one touch never costs two hearts).
- **Beetle enemy** (`beetle.tscn`): walks at a steady speed and turns around at a wall or
  a platform edge, so it never walks off. Speed is one tunable number.
- **Stomp:** landing on a beetle from above removes it and bounces the frog up (about a
  normal jump). The bounce also gives back the frog's air hops.
- **Spikes** (`spikes.tscn`): a strip of red triangles. Touching it costs a heart and
  knocks the frog up and back.
- **Falling in the water or off the bottom.** **Decision 2:** costs 1 heart and respawns
  at the start (recommended), or stays free like now.
- **Running out of hearts.** **Decision 3:** a "Try again / Back to map" panel, and the
  level restarts with flies reset and no coins paid (recommended); or restart the level
  instantly with no panel.
- **Where enemies go.** **Decision 4:** add beetles and spikes to Levels 2 to 4 and keep
  Level 1 safe for learning (recommended); add them to all 4 levels; or build a new Level 5
  for them.
- **Deploy** when the playtest passes.

## Out of scope (later)

Tongue and sword attacks, armor and shields (Milestone 9); more enemy types; checkpoints
in the middle of a level; enemies dropping coins; enemy art and sounds (Milestone 12).

## Scenes & scripts

| File | Type | Responsibility |
|---|---|---|
| `scenes/beetle.tscn` + `scripts/beetle.gd` | `CharacterBody2D`, group `enemy` | Walks along `direction`, flips at walls (`is_on_wall`) and edges (a `RayCast2D` that looks down just ahead). A `Hurtbox` `Area2D` touches the frog; `stomp()` removes it. |
| `scenes/spikes.tscn` + `scripts/spikes.gd` | `Area2D`, group `hazard` | Calls `player.take_hit(from_position)` when the frog touches it. |
| `scenes/hearts_hud.tscn` + `scripts/hearts_hud.gd` | `HBoxContainer` | Draws full and empty hearts from `Game.hearts`. |
| `scenes/fail_panel.tscn` + `scripts/fail_panel.gd` | `CanvasLayer` | "Out of hearts!" with Try again and Back to map; pauses the game like the win panel. |

**Modified:**
- `scripts/player.gd`: `take_hit(from_position)`, `bounce()`, an invincibility timer and
  blinking, knockback. Falling off the bottom goes through `take_hit` if Decision 2 says so.
- `scripts/game.gd`: `MAX_HEARTS`, `hearts`, `hearts_changed` and `out_of_hearts`
  signals, `lose_heart()`, `reset_hearts()` (called when a level starts). Hearts are
  **not** saved; every level starts full.
- `scripts/hud.gd` + `scenes/hud.tscn`: adds the hearts row and the fail panel.
- `scenes/level_2.tscn` to `level_4.tscn` (per Decision 4): beetles and spikes placed.

**How the stomp is detected:** when the beetle's hurtbox touches the frog, the beetle
checks whether the frog is falling (`velocity.y > 0`) and its feet are above the beetle's
middle. Yes: stomp. No: the frog takes a hit. One rule in one place, easy to tune.

**Teaching note:** the beetle is a new reusable piece like the fly. Your son can drag more
beetles into any level in the editor and set each one's starting direction and speed in
the Inspector.

## Done = this playtest passes

Press F9 first (new game), then F5. Confirm:

- [ ] The HUD shows full hearts when a level starts.
- [ ] A beetle walks back and forth and never walks off its platform.
- [ ] Jumping on a beetle removes it and bounces the frog up.
- [ ] Walking into a beetle costs one heart, knocks the frog back, and the frog blinks;
      touching it again while blinking costs nothing.
- [ ] Spikes cost a heart the same way.
- [ ] Falling in the water behaves as Decision 2 says.
- [ ] Losing the last heart shows the fail panel; Try again restarts with full hearts and
      flies reset; Back to map works; no coins are paid for a failed run.
- [ ] Every level is still beatable; Level 1 matches Decision 4.
- [ ] Milestones 3 to 6 checklists still pass.
- [ ] Deployed to the website.
