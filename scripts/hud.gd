extends CanvasLayer
## Shows the flies caught and hearts left this run, the win panel when you reach the
## goal, and the fail panel when the hearts run out.
## Listens to the Game autoload.

@onready var score_label: Label = $ScoreLabel
@onready var level_label: Label = $LevelLabel
@onready var win_panel: CanvasLayer = $WinPanel
@onready var fail_panel: CanvasLayer = $FailPanel

func _ready() -> void:
	var level := LevelCatalog.find(Game.current_level)
	level_label.text = "Level %d: %s" % [Game.current_level, level.get("name", "")]
	_update_score(Game.score)
	Game.score_changed.connect(_update_score)
	Game.won.connect(_on_won)
	Game.out_of_hearts.connect(_on_out_of_hearts)

func _update_score(new_score: int) -> void:
	score_label.text = "Flies: %d" % new_score

func _on_won() -> void:
	var earned := Game.finish_level()  # flies become coins (and get saved)
	win_panel.show_win(earned)

func _on_out_of_hearts() -> void:
	fail_panel.show_fail()  # a failed run pays no coins
