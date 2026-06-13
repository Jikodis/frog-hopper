extends Node
## Autoloaded as "SceneRouter". Switches between the town, the level, and building
## interiors, and remembers where to place the frog when the town next loads.

const TOWN := "res://scenes/town.tscn"
const LEVEL := "res://scenes/level_1.tscn"
const INTERIOR := "res://scenes/building_interior.tscn"

var town_spawn := Vector2.ZERO   # where to drop the frog when the town loads
var has_town_spawn := false
var current_building := ""        # shown inside the interior

func go_to_level(spawn_on_return: Vector2) -> void:
	town_spawn = spawn_on_return
	has_town_spawn = true
	get_tree().change_scene_to_file(LEVEL)

func enter_building(building_name: String, spawn_on_return: Vector2) -> void:
	current_building = building_name
	town_spawn = spawn_on_return
	has_town_spawn = true
	get_tree().change_scene_to_file(INTERIOR)

func return_to_town() -> void:
	get_tree().change_scene_to_file(TOWN)
