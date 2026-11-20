extends Node2D
## Goes on the root of every platformer level. Tells Game which level is running, so
## the HUD can show its name and winning it unlocks the next one.

@export var level_number := 1

func _enter_tree() -> void:  # runs before the HUD and other children are ready
	Game.current_level = level_number
