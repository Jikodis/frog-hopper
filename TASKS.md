# frog-hopper — tasks

Live task list. Check off items as we finish them. The full plan lives in
`docs/vision.md` (roadmap) and `docs/specs/` (per-milestone specs).

Status key: ▶ current · ⬜ upcoming · ✅ done

## Roadmap status

| # | Milestone | Status |
|---|---|---|
| 1 | Frog that runs & jumps | ✅ done |
| 2 | One full platformer level | ✅ done |
| 3 | Town hub (top-down) | ✅ done |
| 4 | Intro + dialogue | ✅ done |
| 5 | Money + first shop + saving (+ play again, fly reset) | ✅ done |
| 6 | More levels + level select | ✅ done |
| 7 | Enemies, hazards + hearts (stomp) | ✅ done |
| 8 | House + furniture | ▶ built, waiting on playtest |
| 9 | Gear matters (tongue + sword, armor, shields) | ⬜ |
| 10 | Final boss: the King Poison Dart Frog + ending | ⬜ |
| 11 | On-screen touch buttons | ⬜ |
| 12 | Art + sound pass (later) | ⬜ |
| 13 | Title screen + pause menu (later) | ⬜ |

**Every milestone's last task is a deploy** to the website (steps in `AGENTS.md`).

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

## ✅ Completed: Milestone 3 — Town hub (top-down)

Spec: `docs/specs/milestone-3-town-hub.md` · Plan: `docs/plans/milestone-3-town-hub-plan.md`
All playtests passed; built and pushed. Top-down town with the full town↔level loop and
all 5 buildings enterable, routed through the `SceneRouter` autoload.

Task 3.1 — inputs + top-down frog + walkable town
- [x] Add `move_up`/`move_down` inputs, `SceneRouter` autoload, town as main scene
- [x] `scene_router.gd`, `town_player.gd` + `town_player.tscn`
- [x] `town.gd` + `town.tscn` (street, 5 labeled buildings, walls, spawn, frog)

Task 3.2 — level gate + return from level
- [x] `door.gd` + `door.tscn` (reusable doorway)
- [x] Add the gate to the town; win in the level returns to town (`hud.gd`)

Task 3.3 — enterable buildings
- [x] `building_interior.gd` + `building_interior.tscn` (one reusable room)
- [x] Wire the 5 building doors

Task 3.4 — full playtest + bookkeeping
- [x] Ran the spec checklist (incl. no transition loops); marked milestone done

## ✅ Completed: Milestone 4 — Intro + dialogue

Spec: `docs/specs/milestone-4-intro-dialogue.md` (approved 2026-11-19). All playtests
passed 2026-11-19; built and pushed. The game now opens in the bedroom, plays a short story in a reusable
dialogue box, then you walk out to town in front of the house.

Task 4.1 — dialogue box + interact key
- [x] Add the `interact` action (Space, Enter, E) to `project.godot`
- [x] `dialogue_box.gd` + `dialogue_box.tscn` (typing text, skip-to-end, `started` / `finished`)

Task 4.2 — bedroom + game-start flow
- [x] `Game.intro_done` story flag; `TownPlayer.can_move`
- [x] `bedroom.gd` + `bedroom.tscn` (story lines in `INTRO_LINES`); bedroom is the main scene
- [x] `SceneRouter`: house door goes to the bedroom; first trip to town lands at the house

Task 4.3 — playtest + bookkeeping
- [x] Ran the spec checklist with F5; all pass
- [x] Story speaker changed from Mom to Dad
- [ ] (Later) Your son rewrites `INTRO_LINES` in `scripts/bedroom.gd`

## ✅ Completed: Milestone 5 — Money + first shop + saving

Spec: `docs/specs/milestone-5-money-shop.md` (approved 2026-11-19). All playtests
passed 2026-11-19.

Task 5.1 — coins, saving, fly reset
- [x] `item_catalog.gd` (3 placeholder swords), `save_game.gd` (`user://save.json`)
- [x] `Game`: coins, owned items, `buy()`, `finish_level()`, save on every change, `new_game()`
- [x] Fly counter resets every time a level starts; `new_game` action (F9) wipes the save

Task 5.2 — win panel + coin display
- [x] `win_panel.tscn`: "You win! +N coins", Play again / Back to town (level pauses behind it)
- [x] `coin_hud.tscn` in the bedroom, town, shops

Task 5.3 — weapon shop
- [x] `talk_zone.tscn` (reusable "Space: talk" spot), `shop_panel.tscn` (reusable list)
- [x] `weapon_shop.tscn`: counter, shopkeeper greeting, then the shop list

Task 5.4 — playtest + deploy
- [x] Ran the spec checklist with F5; all pass
- [x] Deployed to https://xanderbush.com/froghopper/ (xanderbush 87544e6)

## ✅ Completed: Milestone 6 — More levels + level select

Spec: `docs/specs/milestone-6-more-levels.md` (approved 2026-11-19). All playtests
passed 2026-11-19.

Task 6.1 — levels
- [x] `level_catalog.gd`, `level.gd` on every level root; HUD shows the level name
- [x] Level 2 Pond Hop, Level 3 Tall Reeds, Level 4 Log Drift (placeholder layouts)
- [x] `moving_platform.tscn` (logs in Level 4)

Task 6.2 — world map + unlocking
- [x] `world_map.tscn` + `level_stone.tscn`; the town gate goes to the map
- [x] `Game.levels_beaten` (saved) unlocks the next level
- [x] Win panel: Next level / Play again / Back to map
- [x] Doors change scenes with `call_deferred` (fixes a physics-callback error)

Task 6.3 — playtest + deploy
- [x] Ran the spec checklist with F5; all pass
- [x] Deployed to https://xanderbush.com/froghopper/ (xanderbush 3f84972)

## ✅ Completed: Milestone 7: Enemies, hazards + hearts

Spec: `docs/specs/milestone-7-enemies-hearts.md` (approved 2026-11-20)

- [x] Hearts in `Game` (3 per level, not saved) and a hearts row in the HUD
- [x] Frog: take a hit, knockback, 1 second of blinking; falling costs a heart
- [x] Beetle: walks, turns at walls and edges; stomp bounces the frog
- [x] Spikes
- [x] Fail panel: Try again / Back to map, no coins paid
- [x] Beetles and spikes in Levels 2 to 4 (Level 1 stays safe)
- [x] Headless checks pass (22 of 22)
- [x] Your playtest (checklist in the spec): all passed
- [x] Deployed: https://xanderbush.com/froghopper/ (xanderbush 211dc01)

## ▶ Current: Milestone 8: House + furniture

Spec: `docs/specs/milestone-8-house-furniture.md` (approved 2026-11-20)

- [x] Furniture list in `ItemCatalog` (Rug, Lamp, Bookshelf, Fish Tank, Big Bed)
- [x] Furniture shop room behind the town's Furniture Shop door
- [x] Bought furniture shows up in the bedroom; the Big Bed replaces the small bed
- [x] Push furniture around; spots saved; the door stays clear
- [x] Big Bed gives +1 heart in levels
- [x] Headless checks pass (13 of 13)
- [ ] Your playtest (checklist in the spec)
- [ ] Deploy to the website

## Backlog / parking lot (ideas for later)

- Frog could hop (not just walk) in the top-down town — cosmetic, after town exists
