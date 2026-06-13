extends Area2D
## The goal (a lily pad). When the player reaches it, the level is won.

var _won := false

func _ready() -> void:
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node2D) -> void:
	if _won:
		return
	if body.is_in_group("player"):
		_won = true
		Game.win()
