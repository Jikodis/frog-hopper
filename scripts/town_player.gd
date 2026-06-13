extends CharacterBody2D
## The top-down frog used in the town and building interiors.
## Walks in all directions; no gravity, no jumping.

const SPEED := 220.0  # walk speed in pixels/second

func _physics_process(_delta: float) -> void:
	var direction := Input.get_vector("move_left", "move_right", "move_up", "move_down")
	velocity = direction * SPEED
	move_and_slide()
