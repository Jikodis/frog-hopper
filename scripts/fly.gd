extends Area2D
## A collectible fly. When the player touches it, add to the score and disappear.

func _ready() -> void:
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		Game.add_score(1)
		queue_free()
