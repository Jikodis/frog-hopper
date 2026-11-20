extends CanvasLayer
## Shows the flies caught this run, and the win panel when you reach the goal.
## Listens to the Game autoload.

@onready var score_label: Label = $ScoreLabel
@onready var level_label: Label = $LevelLabel
@onready var win_panel: CanvasLayer = $WinPanel

func _ready() -> void:
	var level := LevelCatalog.find(Game.current_level)
	level_label.text = "Level %d: %s" % [Game.current_level, level.get("name", "")]
	_update_score(Game.score)
	Game.score_changed.connect(_update_score)
	Game.won.connect(_on_won)

func _update_score(new_score: int) -> void:
	score_label.text = "Flies: %d" % new_score

func _on_won() -> void:
	var earned := Game.finish_level()  # flies become coins (and get saved)
	win_panel.show_win(earned)
