# Spec: Milestone 8: House + furniture

_Created: 2026-11-20 · Status: draft, 3 decisions open (marked **Decision**)_

## Goal

The **Furniture Shop** in town opens for real. Walk up to its counter, talk to the
shopkeeper, and buy furniture with your coins. Everything you buy **appears in your
bedroom** in its own spot, and it's still there after closing the game.

## In scope

- **Furniture shop scene** (`furniture_shop.tscn`): a copy of the weapon shop with its own
  shopkeeper greeting and the furniture list. The town's Furniture Shop door opens it.
- **Furniture list** in `ItemCatalog.FURNITURE`. **Decision 1:** the starting list.
  Recommended (placeholder names and prices your son can change in one file):

  | Item | Price | Where it goes in the bedroom |
  |---|---|---|
  | Rug | 8 | middle of the floor |
  | Lamp | 12 | next to the bed |
  | Bookshelf | 20 | top-right wall |
  | Fish Tank | 35 | right wall |
  | Big Bed | 50 | replaces the small bed |

- **Showing it:** each item has a spot in `bedroom.tscn`, hidden until you own it.
  **Decision 2:** fixed spots (recommended), or let the frog push furniture around and
  save where it ends up.
- **Does furniture do anything?** **Decision 3:** decoration only for now (recommended);
  or the Big Bed gives +1 heart in levels (ties into Milestone 7's hearts).
- **Saving:** furniture is an owned item like a sword, so `Game.owned_items` already
  saves it. No new save fields.
- **Deploy** when the playtest passes.

## Out of scope (later)

More rooms or a bigger house, moving furniture (unless Decision 2 says so), Dad
reacting to new furniture, furniture art (Milestone 12), the armor and shield shops
(Milestone 9).

## Scenes & scripts

| File | Type | Responsibility |
|---|---|---|
| `scenes/furniture_shop.tscn` + `scripts/furniture_shop.gd` | scene | Same parts as the weapon shop (counter, `TalkZone`, `DialogueBox`, `ShopPanel`, exit door); opens `ShopPanel` with `ItemCatalog.FURNITURE`. |
| `scripts/furniture_spot.gd` | script on a `Node2D` | `@export var item_id`; shows itself only when `Game.owns(item_id)`, and updates when you buy. |

**Modified:**
- `scripts/item_catalog.gd`: `FURNITURE` list; `find()` searches every list.
- `scripts/scene_router.gd`: `"Furniture Shop"` goes to the furniture shop scene.
- `scenes/bedroom.tscn`: one `FurnitureSpot` per item, with a placeholder shape. The
  small bed hides when the Big Bed is owned.

**Teaching note:** this milestone is the payoff of the reusable shop from Milestone 5:
the shop panel, the money rules and the saving are not touched at all. A new shop is a
new list plus a copied room.

## Done = this playtest passes

Press F9 first (new game), then F5. Confirm:

- [ ] The Furniture Shop door opens a shop room; talking at the counter opens the list.
- [ ] Buying an item takes the coins and shows "Owned"; "Not enough coins" still works.
- [ ] Back in the bedroom, each bought item is in its spot; items not bought are not.
- [ ] Close and reopen the game: the furniture is still there.
- [ ] The weapon shop still works the same.
- [ ] Milestones 3 to 7 checklists still pass.
- [ ] Deployed to the website.
