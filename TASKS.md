# frog-hopper — tasks

Live task list. Check off items as we finish them. The full plan lives in
`docs/vision.md` (roadmap) and `docs/specs/` (per-milestone specs).

Status key: ▶ current · ⬜ upcoming · ✅ done

## Roadmap status

| # | Milestone | Status |
|---|---|---|
| 1 | Frog that runs & jumps | ✅ done |
| 2 | One full platformer level | ✅ done |
| 3 | Town hub (top-down) | ▶ next |
| 4 | Intro + dialogue | ⬜ |
| 5 | Money + first shop | ⬜ |
| 6 | House + furniture | ⬜ |
| 7 | Make gear matter (combat) | ⬜ |

## ✅ Completed: Milestones 1 & 2 — playable level

Spec: `docs/specs/milestone-1-2-playable-level.md` · Plan: `docs/plans/milestone-1-2-playable-level-plan.md`
All playtests passed; built and pushed.

Setup
- [x] Create folders: `scenes/`, `scripts/`, `assets/`
- [x] Add input actions `move_left`, `move_right`, `jump` (in `project.godot`)
- [x] Create the `Game` autoload (`scripts/game.gd`) with `score` + `add_score()` + `score_changed`

Player
- [x] Build `player.tscn` (CharacterBody2D + placeholder visual + collision + child Camera2D)
- [x] Write `player.gd`: run, jump, hold-for-higher, one air hop (tunable constants)
- [x] Respawn at start when falling off the bottom

Level
- [x] Build `level_1.tscn` with ground + platforms (top one needs a double jump)
- [x] Place a player instance and set the start position
- [x] Set `level_1.tscn` as the main scene

Collectibles & goal
- [x] Build `fly.tscn` + `fly.gd` (Area2D, adds score, removes itself)
- [x] Place 5 flies around the level (one is the double-jump reward)
- [x] Build `goal.tscn` + `goal.gd` (lily pad → win)

HUD
- [x] Build `hud.tscn` + `hud.gd`: score label + "You win!" label, listening to `Game`

Verify
- [x] Ran through the playtest checklist in the spec; all pass

## ▶ Next: Milestone 3 — Town hub (top-down)

Not started. Needs its own spec + plan first (same flow: brainstorm → spec → plan →
build). Rough shape from `docs/vision.md`: a top-down town the frog walks around, with
buildings you can enter and a door that starts a level and returns you. This is where
the `Game` autoload grows beyond `score` and a scene-transition manager appears.

## Backlog / parking lot (ideas for later)

- In-game "play again" / restart after winning (right now you stop and re-run)
- Frog could hop (not just walk) in the top-down town — cosmetic, after town exists
- Real frog sprite + animations (art pass)
- Sound effects + music
- Save/load between play sessions
