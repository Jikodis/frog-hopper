class_name LevelCatalog
## Every platformer level, in play order. To add a level: duplicate a level scene in
## the editor, set its level_number, and add one line here.

const LEVELS := [
	{"number": 1, "name": "Lily Pad Meadow", "path": "res://scenes/level_1.tscn"},
	{"number": 2, "name": "Pond Hop", "path": "res://scenes/level_2.tscn"},
	{"number": 3, "name": "Tall Reeds", "path": "res://scenes/level_3.tscn"},
	{"number": 4, "name": "Log Drift", "path": "res://scenes/level_4.tscn"},
]

## Look up a level by number. Returns an empty dictionary if there's no such level.
static func find(number: int) -> Dictionary:
	for level in LEVELS:
		if level["number"] == number:
			return level
	return {}

static func count() -> int:
	return LEVELS.size()
