# frog-hopper — game vision & roadmap

_Last updated: 2026-06-13_

## The dream

You're a frog on an adventure. The game has two worlds woven together:

- **Levels** — side-scrolling platformer stages (Mario-style). You run and jump with a
  big, floaty, frog-like hop, collect flies, and reach the goal.
- **The town** — a top-down hub (like *Zelda: A Link to the Past* or the original
  *Final Fantasy*) you return to between levels. You can walk around and do whatever
  you want: visit shops, spend the coins you earned, and fix up your house.

The game **opens in your bedroom** with a bit of dialogue to set up the story, then
you step out into the town and the adventure begins.

## The town

- **Your house** — start here; buy **furniture** to decorate and upgrade it.
- **Weapon shop** — buy weapons.
- **Armor shop** — buy armor.
- **Shield shop** — buy shields.
- **Furniture shop** — buy things for your house.

You earn **coins** by collecting flies and finishing levels, then spend them in town.

## The frog feel (locked: Option A)

Mario-style run, but with a frog's jump:

- A tall, floaty jump.
- **Hold** the jump button to jump higher (variable height).
- **One** extra mid-air hop (double jump).

Every part of the feel is a single tunable number, so it's easy to experiment with.

## How it all hangs together (the backbone)

- A shared **`Game` save object** (a Godot autoload singleton) holds your coins, items
  owned, furniture, and story progress. It survives moving between scenes, so what you
  buy in town is still there when you come back from a level.
- The **town is top-down**; the **levels are side-scrolling**. Same frog, two control
  styles depending on where you are.
- A small **transition manager** carries you between the town and the levels.

We only build each piece of the backbone when we reach the milestone that needs it —
no over-building up front.

## Roadmap (build order)

Each milestone is **playable** when it's done and teaches one new system. Build order
is not play order — we build the level first because it's the fastest path to fun and
because shops need coins, which come from playing levels.

| # | Milestone | What you can do when it's done | New thing it teaches |
|---|---|---|---|
| **1** | Frog that runs & jumps | Hop around a test screen (Option A feel) | Movement, input, gravity |
| **2** | One full platformer level | Play a level: platforms, collect flies, reach the goal, win/lose + score | Collisions, collectibles, camera, HUD |
| 3 | Town hub (top-down) | Walk around town, enter a building, start a level from a door, come back | Top-down movement, scene transitions |
| 4 | Intro + dialogue | Wake up in your room, read the story setup, step into town | Dialogue box, game-start flow |
| 5 | Money + first shop | Flies become coins; buy a weapon in the weapon shop; it sticks | Saved game state, inventory, shop UI |
| 6 | House + furniture | Buy furniture and see it appear in your house | Reusing the shop system |
| 7 | Make gear matter | Weapons/armor/shields actually do something (enemies, combat) | The deep RPG layer |

Once milestone 5's shop works, the **armor / shield / furniture shops are copies** of
it with different items — cheap to add.

**Current focus:** Milestones 1 + 2. See `docs/specs/` for the spec and `TASKS.md` for
live tasks.
