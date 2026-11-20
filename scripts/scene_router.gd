extends Node
## Autoloaded as "SceneRouter". Switches between the bedroom, the town, the level, and
## building interiors, and remembers where to place the frog when the town next loads.

const TOWN := "res://scenes/town.tscn"
const LEVEL := "res://scenes/level_1.tscn"
const INTERIOR := "res://scenes/building_interior.tscn"
const BEDROOM := "res://scenes/bedroom.tscn"
const WEAPON_SHOP := "res://scenes/weapon_shop.tscn"

## On the street just in front of the house door (house door is at (0, 360)).
## Used the first time you walk out of the bedroom, when no door has set a spawn yet.
const HOUSE_FRONT := Vector2(0, 300)

var town_spawn := Vector2.ZERO   # where to drop the frog when the town loads
var has_town_spawn := false
var current_building := ""        # shown inside the interior

func go_to_level(spawn_on_return: Vector2) -> void:
	town_spawn = spawn_on_return
	has_town_spawn = true
	Game.reset_score()  # every run starts with zero flies
	get_tree().change_scene_to_file(LEVEL)

## Start the same level again (the win panel's "Play again"). The town spawn stays the
## same, so "Back to town" later still lands by the gate.
func replay_level() -> void:
	Game.reset_score()
	get_tree().change_scene_to_file(LEVEL)

func enter_building(building_name: String, spawn_on_return: Vector2) -> void:
	current_building = building_name
	town_spawn = spawn_on_return
	has_town_spawn = true
	# Some buildings have their own room; the rest share the empty placeholder room.
	match building_name:
		"House":
			get_tree().change_scene_to_file(BEDROOM)
		"Weapon Shop":
			get_tree().change_scene_to_file(WEAPON_SHOP)
		_:
			get_tree().change_scene_to_file(INTERIOR)

func return_to_town() -> void:
	# The game starts in the bedroom, so the first trip to town has no remembered
	# spawn yet: put the frog in front of the house it just walked out of.
	if not has_town_spawn:
		town_spawn = HOUSE_FRONT
		has_town_spawn = true
	get_tree().change_scene_to_file(TOWN)

## F9 = start over (temporary, until the title screen has a New game button).
func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("new_game"):
		get_viewport().set_input_as_handled()
		get_tree().paused = false
		Game.new_game()
		has_town_spawn = false
		get_tree().change_scene_to_file(BEDROOM)
