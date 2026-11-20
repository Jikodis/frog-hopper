class_name TownPlayer
extends CharacterBody2D
## The top-down frog used in the town, the bedroom, and building interiors.
## Walks in all directions; no gravity, no jumping. Walking into furniture pushes it.

const SPEED := 220.0       # walk speed in pixels/second
const PUSH_SPEED := 120.0  # how fast furniture slides when you push it

## Set to false to freeze the frog (for example while the dialogue box is open).
## The scene that owns the frog decides this; the frog never looks at the dialogue box.
var can_move := true

func _physics_process(delta: float) -> void:
	if not can_move:
		velocity = Vector2.ZERO
		return
	var direction := Input.get_vector("move_left", "move_right", "move_up", "move_down")
	velocity = direction * SPEED
	move_and_slide()
	_push_furniture(direction, delta)

## Anything we bumped into that has a push() method (furniture) gets nudged the way
## we're walking, as long as we're walking into it and not just brushing past.
func _push_furniture(direction: Vector2, delta: float) -> void:
	for i in get_slide_collision_count():
		var hit := get_slide_collision(i)
		var thing := hit.get_collider()
		var into := -hit.get_normal()
		if thing != null and thing.has_method("push") and direction.dot(into) > 0.5:
			thing.push(into * PUSH_SPEED * delta)
