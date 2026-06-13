extends CanvasLayer
## Shows the score and a win message. Listens to the Game autoload.

@onready var score_label: Label = $ScoreLabel
@onready var win_label: Label = $WinLabel

func _ready() -> void:
	win_label.hide()
	_update_score(Game.score)
	Game.score_changed.connect(_update_score)
	Game.won.connect(_on_won)

func _update_score(new_score: int) -> void:
	score_label.text = "Flies: %d" % new_score

func _on_won() -> void:
	win_label.show()
	await get_tree().create_timer(1.5).timeout
	SceneRouter.return_to_town()
