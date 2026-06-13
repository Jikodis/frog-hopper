extends CharacterBody2D
## The frog. Run + jump with the "Option A" feel:
## a tall floaty jump, hold for higher, plus one mid-air hop.

# --- Tunable feel values (change these to change how the frog feels) ---
const RUN_SPEED := 500.0       # how fast the frog runs (pixels/second)
const JUMP_VELOCITY := -800.0  # upward kick when jumping (negative = up)
const MAX_AIR_JUMPS := 2       # extra hops allowed after leaving the ground
const JUMP_CUT := 0.4          # fraction of upward speed kept if you release early
const FALL_LIMIT := 1000.0     # how far below the start you can fall before respawning

# Gravity comes from Project Settings so it matches the rest of the game.
var gravity: float = ProjectSettings.get_setting("physics/2d/default_gravity")

var air_jumps_left := 0
var start_position := Vector2.ZERO

func _ready() -> void:
	start_position = global_position

func _physics_process(delta: float) -> void:
	# 1. Gravity pulls us down while in the air; on the ground, refill our air hops.
	if not is_on_floor():
		velocity.y += gravity * delta
	else:
		air_jumps_left = MAX_AIR_JUMPS

	# 2. Jump — from the ground, or spend a mid-air hop.
	if Input.is_action_just_pressed("jump"):
		if is_on_floor():
			velocity.y = JUMP_VELOCITY
		elif air_jumps_left > 0:
			velocity.y = JUMP_VELOCITY
			air_jumps_left -= 1

	# 3. Variable height: let go early while still rising = a shorter jump.
	if Input.is_action_just_released("jump") and velocity.y < 0.0:
		velocity.y *= JUMP_CUT

	# 4. Run left / right.
	var direction := Input.get_axis("move_left", "move_right")
	velocity.x = direction * RUN_SPEED

	# 5. Move, then check if we fell off the bottom.
	move_and_slide()
	if global_position.y > start_position.y + FALL_LIMIT:
		respawn()

func respawn() -> void:
	global_position = start_position
	velocity = Vector2.ZERO
