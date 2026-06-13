# frog-hopper — tasks

Live task list. Check off items as we finish them. The full plan lives in
`docs/vision.md` (roadmap) and `docs/specs/` (per-milestone specs).

Status key: ▶ current · ⬜ upcoming · ✅ done

## Roadmap status

| # | Milestone | Status |
|---|---|---|
| 1 | Frog that runs & jumps | ▶ current |
| 2 | One full platformer level | ▶ current |
| 3 | Town hub (top-down) | ⬜ |
| 4 | Intro + dialogue | ⬜ |
| 5 | Money + first shop | ⬜ |
| 6 | House + furniture | ⬜ |
| 7 | Make gear matter (combat) | ⬜ |

## Current: Milestones 1 & 2 — playable level

Spec: `docs/specs/milestone-1-2-playable-level.md`

Setup
- [ ] Create folders: `scenes/`, `scripts/`, `assets/`
- [ ] Add input actions `move_left`, `move_right`, `jump` (Project Settings → Input Map)
- [ ] Create the `Game` autoload (`scripts/game.gd`) with `score` + `add_score()` + `score_changed`

Player
- [ ] Build `player.tscn` (CharacterBody2D + placeholder sprite + collision + child Camera2D)
- [ ] Write `player.gd`: run, jump, hold-for-higher, one air hop (tunable constants)
- [ ] Respawn at start when falling off the bottom

Level
- [ ] Build `level_1.tscn` with ground + a few platforms (placeholder shapes)
- [ ] Place a player instance and set the start position
- [ ] Set `level_1.tscn` as the main scene

Collectibles & goal
- [ ] Build `fly.tscn` + `fly.gd` (Area2D, adds score, removes itself)
- [ ] Place 3–5 flies around the level
- [ ] Build `goal.tscn` + `goal.gd` (lily pad → win)

HUD
- [ ] Build `hud.tscn` + `hud.gd`: score label + "You win!" label, listening to `Game.score_changed`

Verify
- [ ] Run through the playtest checklist in the spec; confirm all pass

## Backlog / parking lot (ideas for later)

- Frog could hop (not just walk) in the top-down town — cosmetic, after town exists
- Real frog sprite + animations (art pass)
- Sound effects + music
- Save/load between play sessions
