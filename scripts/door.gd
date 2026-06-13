extends Area2D
## A reusable doorway. `action` chooses what happens when the frog walks in:
##   "building" -> enter the interior for `building_name`
##   "level"    -> start the platformer level
##   "town"     -> return to the town
## `exit_offset` is where to drop the frog (relative to this door) on return, so they
## land on the street beside the door instead of on top of it.

@export var action: String = "building"
@export var building_name: String = ""
@export var exit_offset: Vector2 = Vector2(0, 64)

var _armed := false  # ignore the player until shortly after the scene loads

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	await get_tree().create_timer(0.3).timeout
	_armed = true

func _on_body_entered(body: Node2D) -> void:
	if not _armed or not body.is_in_group("player"):
		return
	match action:
		"building":
			SceneRouter.enter_building(building_name, global_position + exit_offset)
		"level":
			SceneRouter.go_to_level(global_position + exit_offset)
		"town":
			SceneRouter.return_to_town()
