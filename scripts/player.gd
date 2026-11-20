extends CharacterBody2D
## The frog. Run + jump with the "Option A" feel:
## a tall floaty jump, hold for higher, plus one mid-air hop.
## It can also get hurt: lose a heart, get knocked back, then blink for a moment.

# --- Tunable feel values (change these to change how the frog feels) ---
const RUN_SPEED := 500.0       # how fast the frog runs (pixels/second)
const JUMP_VELOCITY := -800.0  # upward kick when jumping (negative = up)
const MAX_AIR_JUMPS := 2       # extra hops allowed after leaving the ground
const JUMP_CUT := 0.4          # fraction of upward speed kept if you release early
const FALL_LIMIT := 1000.0     # how far below the start you can fall before respawning

# --- Tunable hurt values ---
const STOMP_BOUNCE := -650.0   # upward kick after stomping an enemy
const KNOCKBACK := Vector2(450.0, -400.0)  # push away from whatever hurt you
const KNOCKBACK_TIME := 0.25   # seconds the controls are ignored after a hit
const SAFE_TIME := 1.0         # seconds of blinking where you can't be hurt again

# Gravity comes from Project Settings so it matches the rest of the game.
var gravity: float = ProjectSettings.get_setting("physics/2d/default_gravity")

var air_jumps_left := 0
var start_position := Vector2.ZERO
var knockback_left := 0.0   # while above 0, the frog flies back and ignores the controls
var safe_left := 0.0        # while above 0, the frog blinks and can't be hurt

func _ready() -> void:
	start_position = global_position

func _physics_process(delta: float) -> void:
	_count_down_timers(delta)

	# 1. Gravity pulls us down while in the air; on the ground, refill our air hops.
	if not is_on_floor():
		velocity.y += gravity * delta
	else:
		air_jumps_left = MAX_AIR_JUMPS

	if knockback_left <= 0.0:
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

	# 5. Move, then check if we fell off the bottom (that costs a heart).
	move_and_slide()
	if global_position.y > start_position.y + FALL_LIMIT:
		respawn()
		_hurt()

func respawn() -> void:
	global_position = start_position
	velocity = Vector2.ZERO
	knockback_left = 0.0

## True while the frog is blinking after a hit.
func is_safe() -> bool:
	return safe_left > 0.0

## An enemy or spikes at from_position hurt the frog. Does nothing while blinking.
func take_hit(from_position: Vector2) -> void:
	if is_safe():
		return
	var away := signf(global_position.x - from_position.x)
	if away == 0.0:
		away = -1.0
	velocity = Vector2(KNOCKBACK.x * away, KNOCKBACK.y)
	knockback_left = KNOCKBACK_TIME
	_hurt()

## Jumped on an enemy's head: bounce up and get the air hops back.
func bounce() -> void:
	velocity.y = STOMP_BOUNCE
	air_jumps_left = MAX_AIR_JUMPS

func _hurt() -> void:
	safe_left = SAFE_TIME
	Game.lose_heart()

func _count_down_timers(delta: float) -> void:
	knockback_left = maxf(knockback_left - delta, 0.0)
	if safe_left > 0.0:
		safe_left = maxf(safe_left - delta, 0.0)
		# Blink: flip between see-through and solid about 10 times a second.
		modulate.a = 0.3 if int(safe_left * 10.0) % 2 == 0 else 1.0
		if safe_left == 0.0:
			modulate.a = 1.0
