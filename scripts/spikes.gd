extends Area2D
## A strip of spikes. Touching it costs the frog a heart and knocks it back.
## Set the width in the Inspector; the red triangles are drawn to fit.

@export var width := 80.0

const HEIGHT := 20.0
const SPIKE_WIDTH := 20.0

func _ready() -> void:
	var shape := RectangleShape2D.new()
	shape.size = Vector2(width, HEIGHT)
	$CollisionShape2D.shape = shape
	$CollisionShape2D.position = Vector2(0, -HEIGHT / 2.0)

func _draw() -> void:
	var count := maxi(int(width / SPIKE_WIDTH), 1)
	var step := width / count
	for i in count:
		var left := -width / 2.0 + i * step
		draw_colored_polygon(PackedVector2Array([
			Vector2(left, 0), Vector2(left + step / 2.0, -HEIGHT), Vector2(left + step, 0),
		]), Color(0.85, 0.15, 0.15))

func _physics_process(_delta: float) -> void:
	for body in get_overlapping_bodies():
		if body.is_in_group("player"):
			# Knock the frog up and away from the middle of the strip.
			body.take_hit(global_position + Vector2(0, 10))
