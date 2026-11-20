class_name SaveGame
## Reads and writes the save file. It only stores a dictionary; it doesn't know what
## coins or items are. Game decides what goes in the dictionary.
##
## user:// is a folder Godot gives every game for its own files. On a computer it's in
## your user folder; in a web browser Godot keeps it in the browser's storage. (res:// is
## the game's own files and is read-only once the game is exported, so never save there.)

const PATH := "user://save.json"
const VERSION := 1  # bump this if the save format ever changes

static func write(data: Dictionary) -> void:
	data["version"] = VERSION
	var file := FileAccess.open(PATH, FileAccess.WRITE)
	if file == null:
		push_warning("Could not write the save file: %s" % error_string(FileAccess.get_open_error()))
		return
	file.store_string(JSON.stringify(data, "  "))
	file.close()

## Returns the saved dictionary, or an empty one if there is no save (or it's broken).
## An empty dictionary simply means "new game".
static func read() -> Dictionary:
	if not FileAccess.file_exists(PATH):
		return {}
	var parsed = JSON.parse_string(FileAccess.get_file_as_string(PATH))
	if parsed is Dictionary:
		return parsed
	push_warning("The save file was broken; starting a new game.")
	return {}

static func erase() -> void:
	if FileAccess.file_exists(PATH):
		DirAccess.remove_absolute(PATH)
