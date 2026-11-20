extends HBoxContainer
## A row of hearts: red for each heart left, dark for each one lost.
## Placeholder squares until the art pass.

const FULL := Color(0.9, 0.15, 0.25)
const EMPTY := Color(0.25, 0.25, 0.3)

func _ready() -> void:
	for i in Game.max_hearts():
		var heart := ColorRect.new()
		heart.custom_minimum_size = Vector2(28, 28)
		add_child(heart)
	_update(Game.hearts)
	Game.hearts_changed.connect(_update)

func _update(hearts_left: int) -> void:
	for i in get_child_count():
		(get_child(i) as ColorRect).color = FULL if i < hearts_left else EMPTY
