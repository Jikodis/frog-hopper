extends CharacterBody2D
## One piece of furniture in the bedroom. It only shows up once you own it (bought in
## the furniture shop). Walk into it to push it; it stops at walls and other furniture,
## and remembers where you left it, even after closing the game.
## A flat one (the rug) can't be pushed: you just walk over it.

@export var item_id := ""
@export var size := Vector2(60, 60)
@export var color := Color(0.6, 0.4, 0.2)
@export var flat := false  # true = lies on the floor, no pushing, no bumping

const SAVE_DELAY := 0.3  # seconds after you stop pushing before the spot is saved

var _unsaved := false
var _since_push := 0.0

func _ready() -> void:
	if not Game.owns(item_id):
		queue_free()
		return
	global_position = Game.furniture_position(item_id, global_position)
	var visual := ColorRect.new()
	visual.size = size
	visual.position = -size / 2.0
	visual.color = color
	visual.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(visual)
	if flat:
		z_index = -1  # drawn under the frog
		collision_layer = 0
		collision_mask = 0
		return
	var shape := RectangleShape2D.new()
	shape.size = size
	var collision := CollisionShape2D.new()
	collision.shape = shape
	add_child(collision)

## Called by the frog when it walks into this. Slides until something is in the way.
func push(motion: Vector2) -> void:
	if flat:
		return
	move_and_collide(motion)
	_unsaved = true
	_since_push = 0.0

func _physics_process(delta: float) -> void:
	if _unsaved:
		_since_push += delta
		if _since_push >= SAVE_DELAY:
			_save_spot()

func _exit_tree() -> void:
	if _unsaved:
		_save_spot()  # leaving the room right after a push still saves it

func _save_spot() -> void:
	_unsaved = false
	Game.set_furniture_position(item_id, global_position)
