extends Node
## Autoloaded as "Game". Holds state that must survive scene changes, and saves the
## parts that must survive closing the game (coins, items, story flags).

signal score_changed(new_score: int)
signal coins_changed(new_coins: int)
signal won

const COINS_PER_FLY := 1   # coins each fly is worth when you finish a level
const FINISH_BONUS := 5    # extra coins for reaching the goal

## Flies caught in the current run of a level. Not saved; reset when a level starts.
var score: int = 0

## Saved between play sessions:
var coins: int = 0
var owned_items: Array[String] = []  # item ids, e.g. "twig_sword"
var intro_done := false              # true once the bedroom story has been shown

func _ready() -> void:
	_load()

# --- Flies (this run) ---

func add_score(amount: int) -> void:
	score += amount
	score_changed.emit(score)

func reset_score() -> void:
	score = 0
	score_changed.emit(score)

func win() -> void:
	won.emit()

## Turn this run's flies into coins (plus the finish bonus), save, and return how many
## coins were earned so the win panel can show it.
func finish_level() -> int:
	var earned := score * COINS_PER_FLY + FINISH_BONUS
	coins += earned
	coins_changed.emit(coins)
	save()
	return earned

# --- Items ---

func owns(item_id: String) -> bool:
	return item_id in owned_items

## Try to buy an item (a dictionary from ItemCatalog). Returns true if it was bought.
## All the money rules live here, so every shop follows the same rules.
func buy(item: Dictionary) -> bool:
	if owns(item["id"]) or coins < item["price"]:
		return false
	coins -= item["price"]
	owned_items.append(item["id"])
	coins_changed.emit(coins)
	save()
	return true

# --- Story ---

func mark_intro_done() -> void:
	intro_done = true
	save()

# --- Saving ---

func save() -> void:
	SaveGame.write({
		"coins": coins,
		"owned_items": owned_items,
		"intro_done": intro_done,
	})

func _load() -> void:
	var data := SaveGame.read()
	# JSON stores every number as a decimal, so turn coins back into a whole number.
	coins = int(data.get("coins", 0))
	owned_items.assign(data.get("owned_items", []))
	intro_done = bool(data.get("intro_done", false))

## Wipe the save and start from nothing (the F9 key, until the title screen exists).
func new_game() -> void:
	SaveGame.erase()
	score = 0
	coins = 0
	owned_items.clear()
	intro_done = false
	coins_changed.emit(coins)
