# Spec — Milestone 5: Money + first shop + saving

_Created: 2026-11-19 · Status: drafted, awaiting review_

## Goal

Flies you catch in a level turn into **coins** when you finish it. In town you walk up
to the **weapon shop** counter, the shopkeeper says hello in the dialogue box, and a shop
list lets you **buy a sword**. What you own and how many coins you have are **saved**, so
they are still there after you close the browser tab. After winning a level you can
**play it again**, and each run starts with zero flies.

## In scope

- **Coins:** each fly is worth 1 coin and finishing a level adds a 5-coin bonus. Coins
  are added only when you win; a run you quit or lose pays nothing.
- **Fly reset:** the fly counter starts at 0 every time a level loads.
- **Win panel:** "You win! +N coins" with two buttons, **Play again** and **Back to town**.
- **Coin display** in the town, the bedroom and the shops ("Coins: N", top-left).
- **The weapon shop:** its own room with a shopkeeper behind a counter. Walk up to the
  counter and press `interact`; the shopkeeper says a line, then the shop list opens.
- **A reusable shop list:** item names and prices; up/down to choose, `interact` to buy,
  a **Leave** row to close it. Items you own show "Owned"; items you can't afford say so.
- **An item catalog:** one file listing every item (id, name, price). Three swords for now.
- **Saving:** coins, owned items and `intro_done` are written to `user://save.json` after
  every change and read when the game starts. On the web, Godot keeps `user://` in the
  browser's storage (IndexedDB), so this works on the website too.
- **Start over (temporary):** a `new_game` key (F9) wipes the save and reloads the bedroom,
  until the title screen in Milestone 13 has a real New game button.
- **Deploy** the web build to the website when the milestone passes its playtest.

## Out of scope (later)

What swords actually do (Milestone 9), equipping, armor/shield/furniture shops (copies of
this shop in Milestones 8 and 9), selling items, more levels (Milestone 6), enemies
(Milestone 7), real art and sound.

## The items (placeholders; your son can rename and reprice them)

| id | Name | Price |
|---|---|---|
| `twig_sword` | Twig Sword | 10 |
| `iron_sword` | Iron Sword | 30 |
| `golden_sword` | Golden Sword | 60 |

One win of the current level pays up to 10 coins (5 flies + 5 bonus), so the Twig Sword
takes one good run and the Golden Sword takes about six.

## Scenes & scripts

| File | Type | Responsibility |
|---|---|---|
| `scripts/item_catalog.gd` | `class_name ItemCatalog` | `const WEAPONS` (the table above) and `find(id)`. The one place items are defined. |
| `scripts/save_game.gd` | `class_name SaveGame` | `static func write(data: Dictionary)` and `static func read() -> Dictionary` for `user://save.json` (JSON, with a `version` field). Knows nothing about coins; it just saves a dictionary. |
| `scenes/coin_hud.tscn` + `scripts/coin_hud.gd` | `CanvasLayer` | "Coins: N", listening to `Game.coins_changed`. |
| `scenes/shop_panel.tscn` + `scripts/shop_panel.gd` | `CanvasLayer` | Reusable shop list. `open(items: Array)` shows the rows; buying calls `Game.buy(item)`; emits `closed` when you pick Leave. Shows a short message for "Not enough coins". |
| `scenes/talk_zone.tscn` + `scripts/talk_zone.gd` | `Area2D` | Reusable "press `interact` here" spot. Emits `talked` when the frog is inside and presses `interact`. Shows a small "Space" hint while the frog is inside. Future shopkeepers and people in town reuse it. |
| `scenes/weapon_shop.tscn` + `scripts/weapon_shop.gd` | scene | The shop room: floor, counter, shopkeeper (a rectangle), a `TalkZone` at the counter, an exit door, a `TownPlayer`, a `DialogueBox`, a `ShopPanel`, a `CoinHud`. On `talked`: freeze the frog, play the greeting, then open the shop panel; on `closed`: unfreeze. |
| `scenes/win_panel.tscn` + `scripts/win_panel.gd` | `CanvasLayer` | "You win! +N coins" with Play again / Back to town buttons (keyboard focus, `ui_accept` presses). |

**Modified:**
- `scripts/game.gd`: add `coins`, `owned_items`, signal `coins_changed`, `buy(item) -> bool`,
  `owns(id)`, `finish_level()` (adds flies + bonus to coins, saves), `save()`, `new_game()`;
  read the save in `_ready()`. Rename nothing: `score` stays the flies-this-run counter.
- `scripts/scene_router.gd`: `go_to_level()` resets the fly counter; `enter_building("Weapon Shop")`
  goes to the weapon shop scene; add `replay_level()`.
- `scripts/hud.gd` / `scenes/hud.tscn`: on win, call `Game.finish_level()` and show the
  win panel instead of returning to town after 1.5 seconds.
- `scenes/town.tscn`, `scenes/bedroom.tscn`, `scenes/building_interior.tscn`: add a `CoinHud`.
- `project.godot`: add the `new_game` action (F9).

## How a purchase works

1. The frog stands in the counter's `TalkZone` and presses `interact` → `talked`.
2. `weapon_shop.gd` sets `player.can_move = false` and plays the greeting in the dialogue box.
3. On the box's `finished`, it calls `shop_panel.open(ItemCatalog.WEAPONS)`.
4. The player picks a row and presses `interact`. `shop_panel` calls `Game.buy(item)`:
   - owned already → nothing happens (the row says "Owned");
   - not enough coins → `buy` returns false and the panel shows "Not enough coins";
   - otherwise `Game` subtracts the price, adds the id to `owned_items`, emits
     `coins_changed`, and saves.
5. Picking **Leave** emits `closed`; the shop unfreezes the frog.

**Teaching note:** the shop panel never decides whether you can afford something; `Game`
does. The panel only shows what `Game` says. That keeps the money rules in one place, so
the armor, shield and furniture shops get them for free.

**Correctness note: saving on the web.** Saves must be written with `FileAccess` to
`user://`, never `res://` (read-only in an export). The browser can clear site storage, so
the game must start cleanly when the save file is missing or broken (treat it as a new game).

## Done = this playtest passes

Press F5. Confirm:

- [ ] Coins show top-left in the bedroom and town, starting at 0 on a new game.
- [ ] In the level the fly counter starts at 0; winning shows "You win! +N coins" (N = flies + 5).
- [ ] **Play again** restarts the level with 0 flies; **Back to town** returns by the gate
      with the coins added.
- [ ] Walking into the weapon shop opens the shop room. Pressing Space at the counter
      plays the greeting, then the shop list opens.
- [ ] Buying with too few coins says "Not enough coins"; buying with enough lowers the
      coins and marks the sword "Owned". Leave closes the list and the frog can walk.
- [ ] Close the game and press F5 again: coins and owned swords are still there, and the
      intro story does not replay.
- [ ] Press F9: the save is wiped, the bedroom reloads, and the intro plays again with 0 coins.
- [ ] The web build (exported and served locally) keeps coins after a browser reload.
- [ ] Milestones 3 and 4 checklists still pass.
- [ ] Deployed to the website.
