# Spec: Milestone 8: House + furniture

_Created: 2026-11-20 · Status: approved 2026-11-20 (5 items, push furniture around with positions saved, Big Bed gives +1 heart)_

## Goal

The **Furniture Shop** in town opens for real. Walk up to its counter, talk to the
shopkeeper, and buy furniture with your coins. Everything you buy **appears in your
bedroom**. Walk into a piece to **push it around**; it stays where you leave it, even
after closing the game. The **Big Bed** also gives the frog **+1 heart** in every level.

## In scope

- **Furniture shop scene** (`furniture_shop.tscn`): a copy of the weapon shop with its own
  shopkeeper greeting and the furniture list. The town's Furniture Shop door opens it.
- **Furniture list** in `ItemCatalog.FURNITURE`. **Decision 1:** these 5 (placeholder names
  and prices your son can change in one file):

  | Item | Price | Where it starts in the bedroom |
  |---|---|---|
  | Rug | 8 | middle of the floor (flat: you walk over it, it can't be pushed) |
  | Lamp | 12 | next to the bed |
  | Bookshelf | 20 | top-right wall |
  | Fish Tank | 35 | right wall |
  | Big Bed | 50 | replaces the small bed |

- **Showing it:** each item has a starting spot in `bedroom.tscn`, hidden until you own it.
- **Pushing (Decision 2):** walk into a piece of furniture to slide it, slower than
  walking. It stops at walls and other furniture, and it can't be pushed onto the door,
  so the frog can always get out. Its spot is saved a moment after you stop pushing.
- **Big Bed bonus (Decision 3):** owning the Big Bed makes every level start with 4
  hearts instead of 3. The shop shows "(+1 heart)" next to it.
- **Saving:** owned furniture is in `Game.owned_items` like a sword; the pushed spots
  are a new saved field, `furniture_positions`.
- **Deploy** when the playtest passes.

## Out of scope (later)

More rooms or a bigger house, rotating furniture, a button to reset furniture spots, Dad
reacting to new furniture, furniture art (Milestone 12), the armor and shield shops
(Milestone 9).

## Scenes & scripts

| File | Type | Responsibility |
|---|---|---|
| `scenes/furniture_shop.tscn` + `scripts/furniture_shop.gd` | scene | Same parts as the weapon shop (counter, `TalkZone`, `DialogueBox`, `ShopPanel`, exit door); opens `ShopPanel` with `ItemCatalog.FURNITURE`. |
| `scripts/furniture.gd` | script on a `CharacterBody2D` | `@export` `item_id`, `size`, `color`, `flat`; removes itself unless owned, starts at its saved spot, `push(motion)` slides it, saves the spot. |

**Modified:**
- `scripts/item_catalog.gd`: `FURNITURE` list (with an optional `note`); `find()` searches every list.
- `scripts/shop_panel.gd`: shows an item's `note` next to its price.
- `scripts/game.gd`: `max_hearts()` (+1 with the Big Bed), `furniture_positions` (saved).
- `scripts/town_player.gd`: walking into something with `push()` nudges it.
- `scripts/hearts_hud.gd`: draws `Game.max_hearts()` hearts.
- `scripts/scene_router.gd`: `"Furniture Shop"` goes to the furniture shop scene.
- `scenes/bedroom.tscn`: one furniture node per item, plus an invisible block in front of
  the door that only furniture bumps into. The small bed is removed when the Big Bed is
  owned.

**Teaching note:** this milestone is the payoff of the reusable shop from Milestone 5:
the money rules and the save system are reused as they are. A new shop is a
new list plus a copied room.

## Done = this playtest passes

Press F9 first (new game), then F5. Confirm:

- [ ] The Furniture Shop door opens a shop room; talking at the counter opens the list.
- [ ] Buying an item takes the coins and shows "Owned"; "Not enough coins" still works.
- [ ] Back in the bedroom, each bought item is there; items not bought are not; the Big
      Bed replaces the small bed.
- [ ] Walking into furniture pushes it; it stops at walls and never covers the door; the
      rug can be walked over.
- [ ] Close and reopen the game: the furniture is still there, where you pushed it.
- [ ] With the Big Bed, levels start with 4 hearts; without it, 3.
- [ ] The weapon shop still works the same.
- [ ] Milestones 3 to 7 checklists still pass.
- [ ] Deployed to the website.
