extends CanvasLayer
## Shown when the frog runs out of hearts. No coins are paid for a failed run.
## The game is paused behind it, so this panel keeps running while paused.

@onready var panel: Panel = $Panel
@onready var try_again_button: Button = $Panel/Buttons/TryAgainButton
@onready var map_button: Button = $Panel/Buttons/MapButton

func _ready() -> void:
	panel.visible = false
	try_again_button.pressed.connect(_on_try_again)
	map_button.pressed.connect(_on_back_to_map)

func show_fail() -> void:
	panel.visible = true
	get_tree().paused = true
	try_again_button.grab_focus()

func _on_try_again() -> void:
	get_tree().paused = false
	SceneRouter.replay_level()  # flies reset, hearts refill

func _on_back_to_map() -> void:
	get_tree().paused = false
	SceneRouter.return_to_map()
