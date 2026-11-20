extends CharacterBody2D
## A beetle that walks back and forth. It turns around at walls and at the edge of a
## platform, so it never walks off. Jump on its head to stomp it; touch it from the
## side and the frog loses a heart.

@export var speed := 80.0      # walking speed (pixels/second)
@export var direction := -1.0  # -1 = starts walking left, 1 = right

const EDGE_LOOK_AHEAD := 22.0  # how far ahead the edge feeler sits
const STOMP_MARGIN := 6.0      # the frog's feet must be at least this far above our middle

var gravity: float = ProjectSettings.get_setting("physics/2d/default_gravity")

@onready var edge_ray: RayCast2D = $EdgeRay
@onready var hurtbox: Area2D = $Hurtbox

func _ready() -> void:
	# The frog walks through beetles (the hurtbox decides what happens), so the beetle's
	# body must not bump into the frog either.
	for player in get_tree().get_nodes_in_group("player"):
		add_collision_exception_with(player)
		edge_ray.add_exception(player)

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity.y += gravity * delta
	edge_ray.position.x = EDGE_LOOK_AHEAD * direction
	edge_ray.force_raycast_update()
	if is_on_floor() and (is_on_wall() or not edge_ray.is_colliding()):
		direction = -direction
	velocity.x = speed * direction
	move_and_slide()
	_check_frog()

## Checked every frame (not only on first touch), so standing in a beetle after the
## blinking ends still hurts.
func _check_frog() -> void:
	for body in hurtbox.get_overlapping_bodies():
		if not body.is_in_group("player"):
			continue
		var feet_y: float = body.global_position.y + 24.0  # the frog is 48 tall
		var falling: bool = body.velocity.y > 0.0
		if falling and feet_y <= global_position.y + STOMP_MARGIN:
			body.bounce()
			stomp()
			return
		body.take_hit(global_position)

func stomp() -> void:
	set_physics_process(false)
	queue_free()
