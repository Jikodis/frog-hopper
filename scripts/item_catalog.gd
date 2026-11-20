class_name ItemCatalog
## Every item in the game, in one place. Shops read their lists from here, and Game
## looks items up here by id. To add, rename or reprice an item, edit this file only.

## Swords sold in the weapon shop. (What each sword does comes in Milestone 9.)
const WEAPONS := [
	{"id": "twig_sword", "name": "Twig Sword", "price": 10},
	{"id": "iron_sword", "name": "Iron Sword", "price": 30},
	{"id": "golden_sword", "name": "Golden Sword", "price": 60},
]

## Look up an item by its id. Returns an empty dictionary if there's no such item.
static func find(id: String) -> Dictionary:
	for item in WEAPONS:
		if item["id"] == id:
			return item
	return {}
