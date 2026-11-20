extends Node
## Autoloaded as "Game". Holds state that must survive scene changes, and saves the
## parts that must survive closing the game (coins, items, story flags).

signal score_changed(new_score: int)
signal coins_changed(new_coins: int)
signal won
signal hearts_changed(new_hearts: int)
signal out_of_hearts

const COINS_PER_FLY := 1   # coins each fly is worth when you finish a level
const FINISH_BONUS := 5    # extra coins for reaching the goal
const MAX_HEARTS := 3      # hearts the frog starts every level with (before bonuses)

## Flies caught in the current run of a level. Not saved; reset when a level starts.
var score: int = 0

## Hearts left in the current run. Not saved; full again when a level starts.
var hearts: int = MAX_HEARTS

## The level being played right now (set by level.gd). Not saved.
var current_level := 1

## Saved between play sessions:
var coins: int = 0
var owned_items: Array[String] = []  # item ids, e.g. "twig_sword"
var intro_done := false              # true once the bedroom story has been shown
var levels_beaten := 0               # highest level number you've beaten (0 = none yet)
var furniture_positions := {}        # item id -> [x, y] where you pushed it in the bedroom

func _ready() -> void:
	_load()

# --- Flies (this run) ---

func add_score(amount: int) -> void:
	score += amount
	score_changed.emit(score)

func reset_score() -> void:
	score = 0
	score_changed.emit(score)

# --- Hearts (this run) ---

## Hearts at the start of a level: the base 3, plus 1 for owning the Big Bed.
func max_hearts() -> int:
	return MAX_HEARTS + (1 if owns("big_bed") else 0)

func reset_hearts() -> void:
	hearts = max_hearts()
	hearts_changed.emit(hearts)

## Take away one heart. When the last one is gone, the level is failed.
func lose_heart() -> void:
	if hearts <= 0:
		return
	hearts -= 1
	hearts_changed.emit(hearts)
	if hearts == 0:
		out_of_hearts.emit()

func win() -> void:
	won.emit()

## Turn this run's flies into coins (plus the finish bonus), save, and return how many
## coins were earned so the win panel can show it.
func finish_level() -> int:
	var earned := score * COINS_PER_FLY + FINISH_BONUS
	coins += earned
	levels_beaten = max(levels_beaten, current_level)  # beating a level unlocks the next
	coins_changed.emit(coins)
	save()
	return earned

# --- Levels ---

## Level 1 is always open; every other level opens once you beat the one before it.
func is_unlocked(number: int) -> bool:
	return number <= levels_beaten + 1

func is_beaten(number: int) -> bool:
	return number <= levels_beaten

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

# --- Furniture ---

## Remember where a piece of furniture was pushed to, and save it.
func set_furniture_position(item_id: String, pos: Vector2) -> void:
	furniture_positions[item_id] = [pos.x, pos.y]
	save()

## Where a piece of furniture was pushed to, or `fallback` if it was never moved.
func furniture_position(item_id: String, fallback: Vector2) -> Vector2:
	var saved: Array = furniture_positions.get(item_id, [])
	return Vector2(saved[0], saved[1]) if saved.size() == 2 else fallback

# --- Saving ---

func save() -> void:
	SaveGame.write({
		"coins": coins,
		"owned_items": owned_items,
		"intro_done": intro_done,
		"levels_beaten": levels_beaten,
		"furniture_positions": furniture_positions,
	})

func _load() -> void:
	var data := SaveGame.read()
	# JSON stores every number as a decimal, so turn coins back into a whole number.
	coins = int(data.get("coins", 0))
	owned_items.assign(data.get("owned_items", []))
	intro_done = bool(data.get("intro_done", false))
	levels_beaten = int(data.get("levels_beaten", 0))
	furniture_positions = data.get("furniture_positions", {})

## Wipe the save and start from nothing (the F9 key, until the title screen exists).
func new_game() -> void:
	SaveGame.erase()
	score = 0
	coins = 0
	owned_items.clear()
	intro_done = false
	levels_beaten = 0
	furniture_positions = {}
	hearts = MAX_HEARTS
	coins_changed.emit(coins)
