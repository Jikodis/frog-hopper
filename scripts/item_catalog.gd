class_name ItemCatalog
## Every item in the game, in one place. Shops read their lists from here, and Game
## looks items up here by id. To add, rename or reprice an item, edit this file only.

## Swords sold in the weapon shop. (What each sword does comes in Milestone 9.)
const WEAPONS := [
	{"id": "twig_sword", "name": "Twig Sword", "price": 10},
	{"id": "iron_sword", "name": "Iron Sword", "price": 30},
	{"id": "golden_sword", "name": "Golden Sword", "price": 60},
]

## Furniture sold in the furniture shop. It shows up in your bedroom, where you can push
## it around. A "note" is shown next to the price in the shop.
const FURNITURE := [
	{"id": "rug", "name": "Rug", "price": 8},
	{"id": "lamp", "name": "Lamp", "price": 12},
	{"id": "bookshelf", "name": "Bookshelf", "price": 20},
	{"id": "fish_tank", "name": "Fish Tank", "price": 35},
	{"id": "big_bed", "name": "Big Bed", "price": 50, "note": "+1 heart"},
]

## Look up an item by its id, in every shop's list. Returns an empty dictionary if
## there's no such item.
static func find(id: String) -> Dictionary:
	for item in WEAPONS + FURNITURE:
		if item["id"] == id:
			return item
	return {}
