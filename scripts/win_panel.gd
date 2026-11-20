extends CanvasLayer
## Shown when you reach the goal: how many coins you earned, and two buttons.
## The game is paused behind it, so this panel is set to keep running while paused.

@onready var panel: Panel = $Panel
@onready var earned_label: Label = $Panel/EarnedLabel
@onready var next_button: Button = $Panel/Buttons/NextButton
@onready var play_again_button: Button = $Panel/Buttons/PlayAgainButton
@onready var map_button: Button = $Panel/Buttons/MapButton

func _ready() -> void:
	panel.visible = false
	next_button.pressed.connect(_on_next_level)
	play_again_button.pressed.connect(_on_play_again)
	map_button.pressed.connect(_on_back_to_map)

func show_win(coins_earned: int) -> void:
	earned_label.text = "+%d coins" % coins_earned
	# Only offer "Next level" when there is one.
	next_button.visible = Game.current_level < LevelCatalog.count()
	panel.visible = true
	get_tree().paused = true          # freeze the level behind the panel
	# Focus a button so Space/Enter and the arrow keys work right away.
	if next_button.visible:
		next_button.grab_focus()
	else:
		play_again_button.grab_focus()

func _on_next_level() -> void:
	get_tree().paused = false
	SceneRouter.next_level()

func _on_play_again() -> void:
	get_tree().paused = false
	SceneRouter.replay_level()

func _on_back_to_map() -> void:
	get_tree().paused = false
	SceneRouter.return_to_map()
