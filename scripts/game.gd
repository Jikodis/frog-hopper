extends Node
## Autoloaded as "Game". Holds state that must survive scene changes.
## For now that's just the score; later it grows into money, inventory, etc.

signal score_changed(new_score: int)
signal won

var score: int = 0

func add_score(amount: int) -> void:
	score += amount
	score_changed.emit(score)

func reset_score() -> void:
	score = 0
	score_changed.emit(score)

func win() -> void:
	won.emit()
