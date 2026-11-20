extends AnimatableBody2D
## A platform that slides back and forth between where it starts and start + travel.
## AnimatableBody2D is the physics body made for moving platforms: anything standing on
## it (like the frog) gets carried along.

@export var travel := Vector2(300, 0)  # how far it moves from its start (pixels)
@export var speed := 120.0             # pixels per second

var _start := Vector2.ZERO
var _time := 0.0

func _ready() -> void:
	_start = position

func _physics_process(delta: float) -> void:
	if travel == Vector2.ZERO:
		return
	_time += delta * speed / travel.length()
	# pingpong goes 0 -> 1 -> 0 -> 1 ..., so the platform goes there and back forever.
	position = _start + travel * pingpong(_time, 1.0)
