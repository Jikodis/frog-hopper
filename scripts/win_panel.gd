extends CanvasLayer
## Shown when you reach the goal: how many coins you earned, and two buttons.
## The game is paused behind it, so this panel is set to keep running while paused.

@onready var panel: Panel = $Panel
@onready var earned_label: Label = $Panel/EarnedLabel
@onready var play_again_button: Button = $Panel/Buttons/PlayAgainButton
@onready var town_button: Button = $Panel/Buttons/TownButton

func _ready() -> void:
	panel.visible = false
	play_again_button.pressed.connect(_on_play_again)
	town_button.pressed.connect(_on_back_to_town)

func show_win(coins_earned: int) -> void:
	earned_label.text = "+%d coins" % coins_earned
	panel.visible = true
	get_tree().paused = true          # freeze the level behind the panel
	play_again_button.grab_focus()    # so Space/Enter and the arrow keys work right away

func _on_play_again() -> void:
	get_tree().paused = false
	SceneRouter.replay_level()

func _on_back_to_town() -> void:
	get_tree().paused = false
	SceneRouter.return_to_town()
