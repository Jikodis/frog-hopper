class_name TownPlayer
extends CharacterBody2D
## The top-down frog used in the town, the bedroom, and building interiors.
## Walks in all directions; no gravity, no jumping.

const SPEED := 220.0  # walk speed in pixels/second

## Set to false to freeze the frog (for example while the dialogue box is open).
## The scene that owns the frog decides this; the frog never looks at the dialogue box.
var can_move := true

func _physics_process(_delta: float) -> void:
	if not can_move:
		velocity = Vector2.ZERO
		return
	var direction := Input.get_vector("move_left", "move_right", "move_up", "move_down")
	velocity = direction * SPEED
	move_and_slide()
